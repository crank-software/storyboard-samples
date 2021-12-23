/*
 * Copyright 2017, Crank Software Inc. All Rights Reserved.
 * 
 * For more information email info@cranksoftware.com.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#include <time.h>
#ifdef WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h> // for usleep
#endif

#include <gre/greio.h>
#include "ThermostatIO_events.h"

#define THERMOSTAT_SEND_CHANNEL "thermostat_frontend"
#define THERMOSTAT_RECEIVE_CHANNEL "thermostat_backend"

#define SIMULATION_MAX_TEMP 35
#define SIMULATION_MIN_TEMP 8
#define SNOOZE_TIME 80

static int							dataChanged = 1; //Default to 1 so we send data to the ui once it connects
static thermostat_update_event_t	thermostat_state;
#ifdef WIN32
static CRITICAL_SECTION lock;
static HANDLE thread1;
#else 
static pthread_mutex_t lock;
static pthread_t 	thread1;
#endif

/**
 * cross-platform function to create threads
 * @param start_routine This is the function pointer for the thread to run
 * @return 0 on success, otherwise an integer above 1
 */ 
int
create_task(void *start_routine) {
#ifdef WIN32
	thread1 = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) start_routine, NULL, 0, NULL);
	if( thread1 == NULL ) {
		return 1;
	}
	return 0;
#else
	return pthread_create( &thread1, NULL, start_routine, NULL);
#endif
}

/**
 * cross platform mutex initialization
 * @return 0 on success, otherwise an integer above 1
 */ 
int
init_mutex() {
#ifdef WIN32
	InitializeCriticalSection(&lock);
	return 0;
#else
	return pthread_mutex_init(&lock, NULL);
#endif
}

/**
 * cross platform mutex lock
 */ 
void
lock_mutex() {
#ifdef WIN32
	EnterCriticalSection(&lock);
#else
	pthread_mutex_lock(&lock);
#endif
}

/**
 * cross platform mutex unlock
 */ 
void
unlock_mutex() {
#ifdef WIN32
	LeaveCriticalSection(&lock);
#else
	pthread_mutex_unlock(&lock);
#endif
}

/**
 * cross-platform sleep
 */ 
void
sleep_ms(int milliseconds) {
#ifdef WIN32
	Sleep(milliseconds);
#else
	usleep(milliseconds * 1000);
#endif
}

int
convert_temperature(char unit, int temperature) {
	int converted_temp;

	if(unit == 'c') {
		converted_temp = (int)(((float)temperature - 32.0) * (5.0/9.0));
	} else if (unit == 'f') {
		converted_temp = (int)(((float)temperature * (9.0/5.0)) + 32.0);
	}
	return converted_temp;
}

/**
 * Definition for the receive thread
 */
void *
receive_thread(void *arg) {
	gre_io_t					*handle;
	gre_io_serialized_data_t	*nbuffer = NULL;
	char *event_addr;
	char *event_name;
	char *event_format;
	void *event_data;
	int						 ret;
	int nbytes;

	printf("Opening a channel for receive\n");
	// Connect to a channel to receive messages
	handle = gre_io_open(THERMOSTAT_RECEIVE_CHANNEL, GRE_IO_TYPE_RDONLY);
	if (handle == NULL) {
		fprintf(stderr, "Can't open receive channel\n");
		return 0;
	}

	nbuffer = gre_io_size_buffer(NULL, 100);

	while (1) {
		ret = gre_io_receive(handle, &nbuffer);
		if (ret < 0) {
			return 0;
		}

		event_name = NULL;
		nbytes = gre_io_unserialize(nbuffer, &event_addr, &event_name, &event_format, &event_data);
		if (!event_name) {
			printf("Missing event name\n");
			return 0;
		}

		printf("Received Event %s nbytes: %d format: %s\n", event_name, nbytes, event_format);

		lock_mutex();
		if (strcmp(event_name, INCREASE_TEMPERATURE_EVENT) == 0) {
			increase_temperature_event_t *uidata = (increase_temperature_event_t *)event_data;

			thermostat_state.target_temperature = thermostat_state.target_temperature + uidata->num;
			dataChanged = 1;
		} else if (strcmp(event_name, DECREASE_TEMPERATURE_EVENT) == 0) {
			decrease_temperature_event_t *uidata = (decrease_temperature_event_t *)event_data;

			thermostat_state.target_temperature = thermostat_state.target_temperature - uidata->num;
			dataChanged = 1;
		} else if (strcmp(event_name, TOGGLE_AC_EVENT) == 0) {
			if (thermostat_state.ac == 0) {
				thermostat_state.ac = 1;
			} else {
				thermostat_state.ac = 0;
			}
			dataChanged = 1;
		} else if (strcmp(event_name, TOGGLE_FAN_EVENT) == 0) {
			if (thermostat_state.fan == 0) {
				thermostat_state.fan = 1;
			} else {
				thermostat_state.fan = 0;
			}
			dataChanged = 1;
		} else if (strcmp(event_name, TOGGLE_TIMER_EVENT) == 0) {
			if (thermostat_state.timer == 0) {
				thermostat_state.timer = 1;
			} else {
				thermostat_state.timer = 0;
			}
			dataChanged = 1;
		} else if (strcmp(event_name, TOGGLE_UNITS_EVENT) == 0) {
			if (thermostat_state.units == 0) {
				//Celsius
				thermostat_state.units = 1;
				thermostat_state.target_temperature = convert_temperature('c', thermostat_state.target_temperature);
				thermostat_state.current_temperature = convert_temperature('c', thermostat_state.current_temperature);
			} else {
				//Farenheit
				thermostat_state.units = 0;
				thermostat_state.target_temperature = convert_temperature('f', thermostat_state.target_temperature);
				thermostat_state.current_temperature = convert_temperature('f', thermostat_state.current_temperature);
			}
			dataChanged = 1;
		}
		unlock_mutex();
	}

	//Release the buffer memory, close the send handle
	gre_io_free_buffer(nbuffer);
	gre_io_close(handle);
}

int
main(int argc, char **argv) {
	gre_io_t					*send_handle;
	gre_io_serialized_data_t	*nbuffer = NULL;
	thermostat_update_event_t 	event_data;
	int 						ret;
	time_t						timer = time(NULL);
	double						seconds;

	//allocate memory for the thermostat state
	memset(&thermostat_state, 0, sizeof(thermostat_state));
	//set initial state of the demo
	thermostat_state.current_temperature = 16;
	thermostat_state.target_temperature = 16;
	thermostat_state.ac = 0;
	thermostat_state.fan = 0;
	thermostat_state.timer = 0;
	thermostat_state.units = 1; //0-Farenheit 1-Celsius

	if (init_mutex() != 0) {
		fprintf(stderr,"Mutex init failed\n");
		return 0;
	}

	printf("Trying to open the connection to the frontend\n");
	while(1) {
	 // Connect to a channel to send messages (write)
		sleep_ms(SNOOZE_TIME);
		send_handle = gre_io_open(THERMOSTAT_SEND_CHANNEL, GRE_IO_TYPE_WRONLY);
		if(send_handle != NULL) {
			printf("Send channel: %s successfully opened\n", THERMOSTAT_SEND_CHANNEL);
			break;
		}
	}

	if (create_task(receive_thread) != 0) {
		fprintf(stderr,"Thread create failed\n");
		return 0;
	}

	memset(&event_data, 0, sizeof(event_data));

	while(1) {
		sleep_ms(SNOOZE_TIME);
		seconds = difftime(time(NULL),timer);
		lock_mutex();
		if (seconds > 2.0) {
			if (thermostat_state.current_temperature < thermostat_state.target_temperature) {
				thermostat_state.current_temperature += 1;
				timer = time(NULL);
				dataChanged = 1;
			} else if ( thermostat_state.current_temperature > thermostat_state.target_temperature) {
				thermostat_state.current_temperature -= 1;
				timer = time(NULL);
				dataChanged = 1;
			}
		}
		unlock_mutex();

		if (dataChanged) {
			lock_mutex();
			event_data = thermostat_state;
			dataChanged = 0;
			unlock_mutex();

			// Serialize the data to a buffer
			nbuffer = gre_io_serialize(nbuffer, NULL, THERMOSTAT_UPDATE_EVENT, THERMOSTAT_UPDATE_FMT, &event_data, sizeof(event_data));
			if (!nbuffer) {
				fprintf(stderr, "Can't serialized data to buffer, exiting\n");
				break;
			}

			// Send the serialized event buffer
			ret = gre_io_send(send_handle, nbuffer);
			if (ret < 0) {
				fprintf(stderr, "Send failed, exiting\n");
				break;
			}
		}
	}

	//Release the buffer memory, close the send handle
	gre_io_free_buffer(nbuffer);
	gre_io_close(send_handle);
	return 0;
}