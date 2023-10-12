//----------------------------------------------------------------------//
// Hot Tub Water Button                                                 //
//----------------------------------------------------------------------//

// Constants

integer HOTTUB_CHANNEL = 50;             // Commmand channel for hottub
vector  UP_COLOR       = <0.0, 0.2, 1.0>;
vector  DOWN_COLOR     = <0.0, 0.2, 0.5>;
vector  FLASH_COLOR    = <0.0, 0.5, 1.0>;

//
// States
//

default
	{
	state_entry()
		{
		llSetColor(DOWN_COLOR, ALL_SIDES);
		llListen(HOTTUB_CHANNEL, "", NULL_KEY, "");
		}

	on_rez(integer start_param)
		{
		llResetScript();
		}

	touch_start(integer num_detected)
		{
		llSetColor(FLASH_COLOR, ALL_SIDES);
		llSay(HOTTUB_CHANNEL, "water button");
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message == "water up")
			llSetColor(UP_COLOR, ALL_SIDES);

		else if (message == "water down")
			llSetColor(DOWN_COLOR, ALL_SIDES);

		else if (message == "reset" || message == "hottub on" || message == "hottub off")
			llResetScript();
		}
	}

