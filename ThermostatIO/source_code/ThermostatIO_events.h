#define DECREASE_TEMPERATURE_EVENT "decrease_temperature"
#define DECREASE_TEMPERATURE_FMT "2u1 num 2u1 unit"
typedef struct {
	uint16_t 		num;
	uint16_t 		unit;
} decrease_temperature_event_t;

#define INCREASE_TEMPERATURE_EVENT "increase_temperature"
#define INCREASE_TEMPERATURE_FMT "2u1 num 2u1 unit"
typedef struct {
	uint16_t 		num;
	uint16_t 		unit;
} increase_temperature_event_t;

#define THERMOSTAT_UPDATE_EVENT "thermostat_update"
#define THERMOSTAT_UPDATE_FMT "2s1 target_temperature 2s1 current_temperature 1u1 ac 1u1 fan 1u1 timer 1u1 units"
typedef struct {
	int16_t 		target_temperature;
	int16_t 		current_temperature;
	uint8_t 		ac;
	uint8_t 		fan;
	uint8_t 		timer;
	uint8_t 		units;
} thermostat_update_event_t;

#define TOGGLE_AC_EVENT "toggle_ac"

#define TOGGLE_FAN_EVENT "toggle_fan"

#define TOGGLE_TIMER_EVENT "toggle_timer"

#define TOGGLE_UNITS_EVENT "toggle_units"

