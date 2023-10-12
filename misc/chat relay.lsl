default
	{
	state_entry ()
		{
		llSay(0, "Listener inactive, touch to activate");
		}

	touch_start (integer num_detected)
		{
		state active;
		}
	}

state active
	{
	state_entry ()
		{
		llListen(1, "", NULL_KEY, "");
		llSay(0, "Listener active, touch to deactivate");
		}

	touch_start (integer num_detected)
		{
		state default;
		}

	listen (integer channel, string name, key id, string message)
		{
		llOwnerSay(message);
		}
	}

