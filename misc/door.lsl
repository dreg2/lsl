//----------------------------------------------------------------------//
//                                                                      //
//----------------------------------------------------------------------//

//
// Constants
//

integer OPEN_TYPE = 0; // 0 = phantom, 1 = rotate ccw, -1 = rotate cw

integer CHANNEL      = 0;      // chat channel for commands
float   OPEN_TIME    = 8.0;    // in seconds

float   OPEN_ALPHA   = 0.5;
float   CLOSED_ALPHA = 1.0;

// fixed constants

// open types
integer PHANTOM =  0;
integer ROTCCW  =  1;
integer ROTCW   = -1;

// door states
integer CLOSE =  0;
integer OPEN  =  1;


//
// Globals
//

integer door_open = 0;
integer locked = FALSE;


//
// Functions
//

// change door
change_door(integer to_state)
	{
	// change phantom door
	if (OPEN_TYPE == PHANTOM)
		phant_door(to_state);

	// open rot door
	else if (to_state == OPEN && !door_open)
		{
		rot_door(OPEN_TYPE);
		door_open = 1;
		}

	// close rot door
	else if (to_state != OPEN && door_open)
		{
		rot_door(OPEN_TYPE * -1);
		door_open = 0;
		}

	// set timer to close door
	if (to_state == OPEN)
		llSetTimerEvent(OPEN_TIME);
	else
		llSetTimerEvent(0.0);
	}

// rotate door
rot_door(integer dir)
	{
	llSetPrimitiveParams([PRIM_PHANTOM, TRUE]);

	// calculate initial rotation
	rotation rot = llGetRot();
	rotation delta = llEuler2Rot(<0.0, 0.0, (dir*PI)/2.5>);

	// apply rotation
	rot = delta * rot;
	llSetRot(rot);

	llSleep(0.25);

	// apply rotation again
	rot = delta * rot;
	llSetRot(rot);

	llSetPrimitiveParams([PRIM_PHANTOM, FALSE]);
	}

// phantom door
phant_door(integer open)
	{
	if (open)
		{
		// set prim to phantom and alpha
		llSetPrimitiveParams([PRIM_PHANTOM, TRUE]);
		llSetAlpha(OPEN_ALPHA, ALL_SIDES);
		}
	else
		{
		// unset prim from phantom and alpha
		llSetPrimitiveParams([PRIM_PHANTOM, FALSE]);
		llSetAlpha(CLOSED_ALPHA, ALL_SIDES);
		}
	door_open = open;
	}

//
// States
//

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// initialize door params
		llSetPrimitiveParams([PRIM_PHANTOM, FALSE]);
		llSetAlpha(CLOSED_ALPHA, ALL_SIDES);

		llListen(CHANNEL, "", NULL_KEY, "");
		}

	touch_start(integer total_number)
		{
		// security check
		if (locked && !llSameGroup(llDetectedKey(0)))
			{
			// ring bell
			llPlaySound("doorbell_02.wav", 1.0);
			return;
			}

		// open or close door
		if (door_open)
			change_door(CLOSE);
		else
			change_door(OPEN);
		}

	listen(integer channel, string name, key id, string message)
		{
		if (channel != CHANNEL || !llSameGroup(id))
			return;

		// lock door
		if (message == "lock")
			{
			locked = TRUE;
			llSay(0, "locked");
			}

		// unlock door
		else if (message == "unlock")
			{
			locked = FALSE;
			llSay(0, "unlocked");
			}
		}

	timer()
		{
		// close door
		change_door(CLOSE);
		}

	}
