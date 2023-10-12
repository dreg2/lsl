//----------------------------------------------------------------------//
// security system hud                                                  //
//----------------------------------------------------------------------//

// menu
string MENU_ON   = "On";
string MENU_OFF  = "Off";
list   MENU  = [MENU_ON, MENU_OFF];

integer CHANNEL = 12;

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		}

	touch_start(integer num_detected)
		{
		// display menu
		llDialog(llDetectedKey(0), llGetObjectName() + "\n", MENU, CHANNEL);
		}

	listen (integer channel, string name, key id, string message)
		{
		// send message to security system
		if (message == MENU_ON)
			llRegionSay(CHANNEL, "Check On");
		else if (message == MENU_OFF)
			llRegionSay(CHANNEL, "Check Off");
		}

	}


