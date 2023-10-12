//----------------------------------------------------------------------//
// clock driver                                                         //
//----------------------------------------------------------------------//

// Constants
float  UPDATE_TIME     =  1.0; // in seconds

// menu
string TIME_ZONE_INC   = "+1 Hour";
string TIME_ZONE_DEC   = "-1 Hour";
string TIME_ZONE_INC6  = "+6 Hours";
string TIME_ZONE_DEC6  = "-6 Hours";
list   TIME_ZONE_MENU  = [TIME_ZONE_DEC, TIME_ZONE_INC, "OK", TIME_ZONE_DEC6, TIME_ZONE_INC6];

// Globals
integer time_zone_delta = 0;
integer CHANNEL;

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// start listener and timer
		CHANNEL = (((integer)llFrand(2147483647) + 1) * -1);
		llListen(CHANNEL, "", NULL_KEY, "");
		llSetTimerEvent(UPDATE_TIME);
		}

	touch_start(integer num_detected)
		{
		// display menu
		if (llSameGroup(llDetectedKey(0)))
			llDialog(llDetectedKey(0), llGetObjectName() + "\n Current time zone: " + (string)time_zone_delta, TIME_ZONE_MENU, CHANNEL);
		}

	listen (integer channel, string name, key id, string message)
		{
		// verify source of chat
		if (!llSameGroup(id))
			return;

		// set time zone delta
		if (message == TIME_ZONE_INC)
			time_zone_delta += 1;
		else if (message == TIME_ZONE_DEC)
			time_zone_delta -= 1;
		else if (message == TIME_ZONE_INC6)
			time_zone_delta += 6;
		else if (message == TIME_ZONE_DEC6)
			time_zone_delta -= 6;
		else if (message == "OK")
			return;

		// re-display menu
		llDialog(id, llGetObjectName() + "\n Current time zone: " + (string)time_zone_delta, TIME_ZONE_MENU, CHANNEL);
		}

	timer()
		{
		// get time and calculate hours and minutes
		float time = llGetGMTclock();
		float hours = (time / 3600.0) + (float)time_zone_delta;
		float minutes = ((integer)time % 3600) / 60.0;

		// tell hands hours and minutes
		llMessageLinked(LINK_SET, 1, (string)hours, NULL_KEY);
		llMessageLinked(LINK_SET, 2, (string)minutes, NULL_KEY);
		}
	}

