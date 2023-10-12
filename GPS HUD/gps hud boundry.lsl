//------------------------------------------------------------------------//
// GPS HUD - boundry module                                               //
//------------------------------------------------------------------------//

// Constants
integer BOUNDRY_INDEX = 0; // 0 - Sim, 2 - parcel

vector GOOD_COLOR = <0.0, 1.0, 0.0>;
vector CAUT_COLOR = <1.0, 1.0, 0.0>;
vector WARN_COLOR = <1.0, 0.0, 0.0>;

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
		if (num != 2)
			return;

		list   message = llParseStringKeepNulls(str, ["^"], []);
		string command = llStringTrim(llList2String(message, 0), STRING_TRIM);
		list   args    = llList2List(message, 1, -1);

		integer level = llList2Integer(args, BOUNDRY_INDEX);
		if (level == 2)
			llSetColor(WARN_COLOR, ALL_SIDES);
		else if (level == 1)
			llSetColor(CAUT_COLOR, ALL_SIDES);
		else
			llSetColor(GOOD_COLOR, ALL_SIDES);
		}
	}

