/*
 * This Lua module demonstrates how to extend the Storyboard Lua API with custom functionality.
 */

#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <gre/gre.h>
#include <gre/greio.h>

/**
 * This is a sample function that is invoked by Lua module.
 *
 * @param L The Lua state for this execution, most importantly containing
 *          the stack of arguments passed to the function
 * @return The number of items on the stack to return to Lua script caller.
 */
static int 
sbmodule_hello(lua_State *L) {
    const char *msg = NULL;
	int n;
 
	//Determine how many arguments were pushed on the stack
	n = lua_gettop(L);
	
	//If we have at least one, pull it off the stack as a string
	if(n > 0) {
    	msg = lua_tolstring(L, 1, NULL);		
	}

	//Push a greeting string onto the stack, or nil if missing 
	if(msg) {
		char msgbuf[50];
		snprintf(msgbuf, sizeof(msgbuf), "Hello %s", msg);
		msgbuf[sizeof(msgbuf)-1] = '\0';
		lua_pushlstring(L, msgbuf, strlen(msgbuf));
	} else {
		lua_pushnil(L);
	}

	//One value, nil or string, was pushed as a return value
	return 1;
}

//Register the name to function callback binding
static const luaL_Reg sbmodule_functions[] = {
  {"hello",       sbmodule_hello},
  {NULL, NULL}
};

/**
 * This is the entry point for the Lua dynamic module loader.
 *
 * The name of this function after luaopen_ (ie sbmodule) needs
 * to match the name of the generated library (sbmodule.so|dll).
 */
LUALIB_API int luaopen_sbmodule (lua_State *L) {
  luaL_register(L, "sbmodule", sbmodule_functions);
  return 1;
}

