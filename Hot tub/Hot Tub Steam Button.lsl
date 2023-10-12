//----------------------------------------------------------------------//
// Hot Tub Steam Button                                                 //
//----------------------------------------------------------------------//

// Constants

integer HOTTUB_CHANNEL = 50;

// button colors
list    LVL_COLOR   = [<0.2, 0.0, 0.0>, <0.4, 0.0, 0.0>, <0.6, 0.0, 0.0>,  <0.8, 0.0, 0.0>];
vector  FLASH_COLOR = <0.8, 0.0, 0.0>;

//
// States
//

default 
	{
	state_entry()
		{
		llSetColor(llList2Vector(LVL_COLOR, 0), ALL_SIDES);
		llListen(HOTTUB_CHANNEL, "", NULL_KEY, "");
		}

	on_rez(integer start_param)
		{
		llResetScript();
		}

	touch_start(integer num_detected)
		{
		llSetColor(FLASH_COLOR, ALL_SIDES);
		llSay(HOTTUB_CHANNEL, "steam button");
		}

	listen(integer channel, string name, key id, string message)
		{
		if (llGetSubString(message, 0, 4) == "steam")
			{
			integer lvl = (integer)llGetSubString(message, 6, 6);
			llSetColor(llList2Vector(LVL_COLOR, lvl), ALL_SIDES);
			}

		else if (message == "reset" || message == "hottub on" || message == "hottub off")
			llResetScript();
		}
	}

