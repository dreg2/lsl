//----------------------------------------------------------------------//
// Sky Build - Component                                                //
//----------------------------------------------------------------------//

// Constants
integer CTRL_CHANNEL = -72463;

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// start listener for base
		llListen(CTRL_CHANNEL, "", NULL_KEY, "");
		}

	listen(integer channel, string name, key id, string message)
		{
		// report position
		if (message == "REPORT")
			llRegionSay(CTRL_CHANNEL, "POS:" + llGetObjectName() + ":" + (string)llGetPos());

		// lock component
		else if (message == "LOCK")
			state ready;
		}
	}


state ready
	{
	on_rez(integer start_param)
		{
		// start listener for derezz
		llListen(start_param, "", NULL_KEY, "DEREZZ");
		}

	listen(integer channel, string name, key id, string message)
		{
		// derezz object
		if (message == "DEREZZ")
			llDie();
		}


	}
