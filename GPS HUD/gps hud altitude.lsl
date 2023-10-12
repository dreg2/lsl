//------------------------------------------------------------------------//
// GPS HUD - altitude module                                              //
//------------------------------------------------------------------------//

// Constants
vector TEXT_COLOR = <1.0, 1.0, 1.0>;

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
		if (num != 3)
			return;

		list   message = llParseString2List(str, ["^"], []);
		string command = llStringTrim(llList2String(message, 0), STRING_TRIM);
		list   args    = llList2List(message, 1, -1);

		string text = "AGL: " + llList2String(args, 0) + "   "
					+ "AWL: " + llList2String(args, 1) + "   "
					+ "ATL: " + llList2String(args, 2) + "\n"
					+ "Depth: " + llList2String(args, 3) + "\n"
					+ "ROC: " + llList2String(args, 4);

		llSetText(text, TEXT_COLOR, 1.0);
		}
	}

