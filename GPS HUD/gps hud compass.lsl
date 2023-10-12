//------------------------------------------------------------------------//
// GPS HUD - compass module                                               //
//------------------------------------------------------------------------//

// Constants
integer display = 0; // 0 - heading, 1 - track

//
// States
//
default
	{
	on_rez(integer param)
		{
		llResetScript();
		}

	state_entry()
		{
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		if (num != 1)
			return;

		list   message = llParseString2List(str, ["^"], []);
		string command = llStringTrim(llList2String(message, 0), STRING_TRIM);
		list   args    = llList2List(message, 1, -1);

		float curr_angle = llList2Float(args, display) * DEG_TO_RAD;
		llRotateTexture(curr_angle, ALL_SIDES);
		}
	}

