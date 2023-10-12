//----------------------------------------------------------------------//
// Hot Tub Shower Button                                                //
//----------------------------------------------------------------------//

// Constants

integer HOTTUB_CHANNEL = 50;
vector  ON_COLOR    = <0.0, 1.0, 0.0>;
vector  OFF_COLOR   = <0.0, 0.5, 0.0>;
vector  FLASH_COLOR = <0.0, 1.0, 0.0>;

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
		llSay(HOTTUB_CHANNEL, "shower button");
		llSetColor(FLASH_COLOR, ALL_SIDES);
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message ==  "shower on")
			llSetColor(ON_COLOR, ALL_SIDES);

		else if (message == "shower off")
			llSetColor(OFF_COLOR, ALL_SIDES);

		else if (message == "reset" || message == "hottub on" || message == "hottub off")
			llResetScript();
		}
	}

