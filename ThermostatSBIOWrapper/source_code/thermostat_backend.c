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
#include <gre/sbio_wrapper.h>
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
	int converted_temp = 0;

	if(unit == 'c') {
		converted_temp = (int)(((float)temperature - 32.0) * (5.0/9.0));
	} else if (unit == 'f') {
		converted_temp = (int)(((float)temperature * (9.0/5.0)) + 32.0);
	}
	return converted_temp;
}

void
increase_temperature(const char *event_name, char *event_format, void *event_data, int event_data_size, void *user_data) {
	lock_mutex(); 
	increase_temperature_event_t *uidata = (increase_temperature_event_t *)event_data;
	thermostat_state.target_temperature = thermostat_state.target_temperature + uidata->num;
	dataChanged = 1;
	unlock_mutex(); 
}

void
decrease_temperature(const char *event_name, char *event_format, void *event_data, int event_data_size, void *user_data) {
	lock_mutex(); 
	decrease_temperature_event_t *uidata = (decrease_temperature_event_t *)event_data;
	thermostat_state.target_temperature = thermostat_state.target_temperature - uidata->num;
	dataChanged = 1;
	unlock_mutex();
}

void
toggle_ac(const char *event_name, char *event_format, void *event_data, int event_data_size, void *user_data) {
	lock_mutex(); 
	if (thermostat_state.ac == 0) {
		thermostat_state.ac = 1;
	} else {
		thermostat_state.ac = 0;
	}
	dataChanged = 1;
	unlock_mutex(); 
}

void
toggle_fan(const char *event_name, char *event_format, void *event_data, int event_data_size, void *user_data) {
	lock_mutex(); 
	if (thermostat_state.fan == 0) {
		thermostat_state.fan = 1;
	} else {
		thermostat_state.fan = 0;
	}
	dataChanged = 1;
	unlock_mutex(); 
}

void
toggle_timer(const char *event_name, char *event_format, void *event_data, int event_data_size, void *user_data) {
	lock_mutex(); 
	if (thermostat_state.timer == 0) {
		thermostat_state.timer = 1;
	} else {
		thermostat_state.timer = 0;
	}
	dataChanged = 1;
	unlock_mutex(); 
}

void
toggle_units(const char *event_name, char *event_format, void *event_data, int event_data_size, void *user_data) {
	lock_mutex();
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
	unlock_mutex(); 
}

int
main(int argc, char **argv) {
	sbio_channel_handle_t *send_handle;
	sbio_channel_handle_t *receive_handle; 
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
		ret = sbio_create_send_channel(THERMOSTAT_SEND_CHANNEL, 0, &send_handle);
		if(ret == 0) {
			printf("Send channel: %s successfully opened\n", THERMOSTAT_SEND_CHANNEL);
			break;
		}
	}

	ret = sbio_create_receive_channel(THERMOSTAT_RECEIVE_CHANNEL, 0, &receive_handle);
	if(ret != 0) {
		printf("Unable to create receive channel\n");
		return -1; 
	}

	sbio_add_event_callback(receive_handle, INCREASE_TEMPERATURE_EVENT, increase_temperature, NULL);
	sbio_add_event_callback(receive_handle, DECREASE_TEMPERATURE_EVENT, decrease_temperature, NULL);
	sbio_add_event_callback(receive_handle, TOGGLE_AC_EVENT, toggle_ac, NULL);
	sbio_add_event_callback(receive_handle, TOGGLE_FAN_EVENT, toggle_fan, NULL);
	sbio_add_event_callback(receive_handle, TOGGLE_TIMER_EVENT, toggle_timer, NULL);
	sbio_add_event_callback(receive_handle, TOGGLE_UNITS_EVENT, toggle_units, NULL);

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
			
			ret = sbio_send_event(send_handle, THERMOSTAT_UPDATE_EVENT, THERMOSTAT_UPDATE_FMT, &event_data, sizeof(event_data));
			if (ret != 0) {
				fprintf(stderr, "Send failed, exiting\n");
				break;
			}
		}
	}

	sbio_destroy_channel(send_handle);
	sbio_destroy_channel(receive_handle);
	return 0;
}