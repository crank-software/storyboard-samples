/*
 * Copyright 2017, Crank Software Inc. All Rights Reserved.
 *
 * For more information email info@cranksoftware.com.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h> // for usleep
#endif

#include <gre/greio.h>
#include "ClusterIO_events.h"

#define MAX_SPEED 200
#define MIN_SPEED 0

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

void send_system_codes_initialize(gre_io_t *send_handle) {
	gre_io_serialized_data_t    *nbuffer = NULL;
	cluster_system_update_event_t event_data;
	int 						ret;

	event_data.fuel = 0;
	event_data.battery = 0; 
	event_data.oil = 0; 
	event_data.engine_code = 1; 
	event_data.odometer = 0; 
	event_data.trip = 0; 

	// Serialize the data to a buffer
	nbuffer = gre_io_serialize(nbuffer, NULL, CLUSTER_SYSTEM_UPDATE_EVENT, CLUSTER_SYSTEM_UPDATE_FMT, &event_data, sizeof(event_data));
	if (!nbuffer) {
		fprintf(stderr, "Can't serialized data to buffer, exiting\n");
		return;
	}

	// Send the serialized event buffer
	ret = gre_io_send(send_handle, nbuffer);
	if (ret < 0) {
		fprintf(stderr, "Send failed, exiting\n");
	} 
	//Release the buffer memory
	gre_io_free_buffer(nbuffer);
}

void send_system_codes_startup(gre_io_t *send_handle) {
	gre_io_serialized_data_t    *nbuffer = NULL;
	cluster_system_update_event_t event_data;
	int 						ret;

	event_data.fuel = 75;        // fuel pecentage 
 	event_data.battery = 80;     // battery change pecentage 
	event_data.oil = 100;          // oil level 
	event_data.engine_code = 0;  // no engine codes set
	event_data.odometer = 89024; // odometer reading 
	event_data.trip = 2007;      // trip obometer reading   

	// Serialize the data to a buffer
	nbuffer = gre_io_serialize(nbuffer, NULL, CLUSTER_SYSTEM_UPDATE_EVENT, CLUSTER_SYSTEM_UPDATE_FMT, &event_data, sizeof(event_data));
	if (!nbuffer) {
		fprintf(stderr, "Can't serialized data to buffer, exiting\n");
		return;
	}

	// Send the serialized event buffer
	ret = gre_io_send(send_handle, nbuffer);
	if (ret < 0) {
		fprintf(stderr, "Send failed, exiting\n");
	}
	//Release the buffer memory
	gre_io_free_buffer(nbuffer);
}
 

int 
main(int argc, char **argv) {
	gre_io_t                    *send_handle;
    gre_io_serialized_data_t    *nbuffer = NULL;
	cluster_update_event_t 		event_data;
	int 						count_up = 1;
	int 						ret;

	 // Connect to a channel to send messages (write)
	send_handle = gre_io_open("cluster", GRE_IO_TYPE_WRONLY);
    if (send_handle == NULL) {
        fprintf(stderr, "Can't open send channel\n");
        return 0;
	}

	memset(&event_data, 0, sizeof(event_data));
	send_system_codes_initialize(send_handle);
	sleep_ms(1000);
	send_system_codes_startup(send_handle);

	while (1) {
		// Simulate data acquisition ...
		sleep_ms(80);
		if (count_up) {
			event_data.speed = (event_data.speed + 1) % MAX_SPEED;
			event_data.rpm = (event_data.rpm + 50) % 10000;
			if (event_data.speed == MAX_SPEED - 1) {
				count_up = 0;
			}
		}
		else {
			event_data.speed = (event_data.speed - 1) % MAX_SPEED;
			event_data.rpm = (event_data.rpm - 50) % 10000;
			if (event_data.speed == MIN_SPEED) {
				count_up = 1;
			}
		}
		// Serialize the data to a buffer
		nbuffer = gre_io_serialize(nbuffer, NULL, CLUSTER_UPDATE_EVENT, CLUSTER_UPDATE_FMT, &event_data, sizeof(event_data));
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

	//Release the buffer memory, close the send handle
	gre_io_free_buffer(nbuffer);
	gre_io_close(send_handle);

	return 0;
}
