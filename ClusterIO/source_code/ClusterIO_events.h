#define CLUSTER_UPDATE_EVENT "cluster_update"
#define CLUSTER_UPDATE_FMT "2u1 speed 2u1 rpm"
typedef struct {
	uint16_t 		speed;
	uint16_t 		rpm;
} cluster_update_event_t;

#define CLUSTER_SYSTEM_UPDATE_EVENT "cluster_system_update"
#define CLUSTER_SYSTEM_UPDATE_FMT "1u1 fuel 1u1 battery 1u1 oil 1u1 engine_code 4u1 odometer 4u1 trip"
typedef struct {
	uint8_t 		fuel;
	uint8_t 		battery;
	uint8_t 		oil;
	uint8_t         engine_code; 
	uint32_t 		odometer;
	uint32_t 		trip;
} cluster_system_update_event_t;

