//----------------------------------------------------------------------//
// Hot Tub Jets Button                                                  //
//----------------------------------------------------------------------//

// Constants

integer HOTTUB_CHANNEL = 50;
vector  ON_COLOR    = <0.7, 0.7, 0.0>;
vector  OFF_COLOR   = <0.4, 0.4, 0.0>;
vector  FLASH_COLOR = <0.9, 0.9, 0.0>;

//
// states
//

default
	{
	state_entry()
		{
		llSetColor(OFF_COLOR, ALL_SIDES);
		llListen(HOTTUB_CHANNEL, "", NULL_KEY, "");
		}

	on_rez(integer start_param)
		{
		llResetScript();
		}

	touch_start(integer num_detected)
		{
		llSay(HOTTUB_CHANNEL, "jets button");
		llSetColor(FLASH_COLOR, ALL_SIDES);
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message ==  "jets on")
			llSetColor(ON_COLOR, ALL_SIDES);    

		else if (message == "jets off")
			llSetColor(OFF_COLOR, ALL_SIDES);    

		else if (message == "reset" || message == "hottub on" || message == "hottub off")
			llResetScript();
		}
	}

