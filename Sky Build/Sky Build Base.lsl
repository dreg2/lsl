//----------------------------------------------------------------------//
// Sky Build - Base                                                     //
//----------------------------------------------------------------------//

// Constants
integer CTRL_CHANNEL = -72463;

// menu
string MENU_OPT_RECORD = "Record";
string MENU_OPT_LOCK   = "Lock";
list   MENU          = [MENU_OPT_RECORD, MENU_OPT_LOCK];

// Run Time Constants
integer MENU_CHANNEL;
vector  BASE_POS;

// globals
list obj_name;
list obj_offset;

//----------------------------------------------------------------------//
// parse_pos - parse pos message and store results                      //
//----------------------------------------------------------------------//
parse_pos(string pos_message)
	{
	list   message = llParseString2List(pos_message, [":"], []);
	string command = llStringTrim(llList2String(message, 0), STRING_TRIM);
	string name    = llStringTrim(llList2String(message, 1), STRING_TRIM);
	vector pos     = (vector)llStringTrim(llList2String(message, 2), STRING_TRIM);
	vector offset  = pos - BASE_POS;

	obj_name   = (obj_name=[])   + obj_name   + [name];
	obj_offset = (obj_offset=[]) + obj_offset + [offset];
	llSay(0, "Recorded '" + name + "' at offset " + (string)offset);
	}

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// initialize globals
		obj_name   = [];
		obj_offset = [];

		// initialize run time constants
		BASE_POS   = llGetPos();
		MENU_CHANNEL = (((integer)llFrand(2147483647) + 1) * -1);

		// start listeners
		llListen(MENU_CHANNEL, "", NULL_KEY, "");
		llListen(CTRL_CHANNEL, "", NULL_KEY, "");
		}

	touch_start(integer num_detected)
		{
		// display menu
//		if (llSameGroup(llDetectedKey(0)))
			llDialog(llDetectedKey(0), llGetObjectName() + "\n", MENU, MENU_CHANNEL);
		}

	listen(integer channel, string name, key id, string message)
		{
		// message from component
		if (channel == CTRL_CHANNEL)
			{
			// record component position
			if (llSubStringIndex(message, "POS:") == 0)
				parse_pos(message);
			}

		// message from menu
		else if (channel == MENU_CHANNEL)
			{
			if (message == MENU_OPT_RECORD)
				{
				// tell components to send positions
				obj_name   = [];
				obj_offset = [];
				llRegionSay(CTRL_CHANNEL, "REPORT");
				}

			else if (message == MENU_OPT_LOCK)
				{
				// lock components
				llRegionSay(CTRL_CHANNEL, "LOCK");
				llSay(0, "Components locked");
				state ready;
				}
				
			}
		}
	}

state ready
	{
	on_rez(integer start_param)
		{
//		if (start_param == 0)
//			return;

		// start listener
		llListen(start_param, "", NULL_KEY, "DEREZZ");

		// rezz recorded objects
		integer index;
		integer list_length = llGetListLength(obj_name);
		for (index = 0; index < list_length; index++)
			{
			llRezAtRoot(llList2String(obj_name, index), llGetPos() + llList2Vector(obj_offset, index), ZERO_VECTOR, ZERO_ROTATION, start_param);
			}
		}

	listen(integer channel, string name, key id, string message)
		{
		// derezz this object
		if (message == "DEREZZ")
			llDie();
		}
	}

