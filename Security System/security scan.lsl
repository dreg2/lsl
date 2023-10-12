//----------------------------------------------------------------------//
// security system - scan module                                        //
//    by Dreg2 Rossini                                                  //
//----------------------------------------------------------------------//
string VERSION = "1.00";

//
// Constants
//

// system constants
string  MODULE_NAME  = "Scan";
integer BCST_MSG_ID  = -1;  // Link message ID for broadcasts
integer MAIN_MSG_ID  = 0;   // Link message ID for main module
integer SCAN_MSG_ID  = 1;   // Link message ID for scan module
integer VL_MSG_ID    = 2;   // Link message ID for visitor list module
integer CHECK_MSG_ID = 3;   // Link message ID for check module
integer CONF_MSG_ID  = 4;   // Link message ID for config module

// default config options
float   DEFAULT_SCAN_RANGE     = 5.0;     // in meters
float   DEFAULT_SCAN_ARC       = PI;      // in radians
float   DEFAULT_SCAN_RATE      = 5.0;     // in seconds
integer DEFAULT_SCAN_PARCEL    = 1;       // limit scan to owned(2), parcel(1) or none(0)

// Fixed constants

// parcel check options
integer NONE    = 0;
integer PARCEL  = 1;
integer OWNED   = 2;

// Runtime constants

//key    CREATOR_KEY; // for debug instant messages

// config options
float   SCAN_RANGE     = DEFAULT_SCAN_RANGE;
float   SCAN_ARC       = DEFAULT_SCAN_ARC;
float   SCAN_RATE      = DEFAULT_SCAN_RATE;
integer SCAN_PARCEL    = DEFAULT_SCAN_PARCEL;

//
// Global variables
//
string  module_status;  // current module status

list prev_key; // list of agent keys found on previous scan

//
// Functions
//

//----------------------------------------------------------------------//
// handle_message - handle link message                                 //
//----------------------------------------------------------------------//
handle_message(string str)
		{
		list   message = llParseString2List(str, ["^"], []);
		string command = llStringTrim(llList2String(message, 0), STRING_TRIM);
		list   args    = llList2List(message, 1, -1);

		if (command == "reset")
			llResetScript();

		else if (command == "status")
			llSay(0, MODULE_NAME + " (" + (string)llGetFreeMemory() + "): " + module_status);

		else if (command == "config")
			{
			set_config(args);
			if (module_status == "active")
				llSensorRepeat("", "", AGENT, SCAN_RANGE, SCAN_ARC, SCAN_RATE);
			}

		else if (command == "activate")
			{
			module_status = "active";
			llSensorRepeat("", "", AGENT, SCAN_RANGE, SCAN_ARC, SCAN_RATE);
			llSay(0, MODULE_NAME + " (" + (string)llGetFreeMemory() + "): " + module_status);
			}

		else if (command == "deactivate")
			{
			module_status = "inactive";
			llSensorRemove();
			llSay(0, MODULE_NAME + " (" + (string)llGetFreeMemory() + "): " + module_status);
			}
		}

//----------------------------------------------------------------------//
// set_config - set config parameter                                    //
//----------------------------------------------------------------------//
set_config(list config)
	{
	string keyword = llList2String(config, 0);
	string value   = llToUpper(llList2String(config, 1));

	if (keyword == "LIST")
		{
		llSay(0, "Scan Range: "  + (string)SCAN_RANGE);
		llSay(0, "Scan Arc: "    + (string)SCAN_ARC);
		llSay(0, "Scan Rate: "   + (string)SCAN_RATE);
		llSay(0, "Scan Parcel: " + (string)SCAN_PARCEL);
		return;
		}

	else if (keyword == "DEFAULT")
		{
		SCAN_RANGE     = DEFAULT_SCAN_RANGE;
		SCAN_ARC       = DEFAULT_SCAN_ARC;
		SCAN_RATE      = DEFAULT_SCAN_RATE;
		SCAN_PARCEL    = DEFAULT_SCAN_PARCEL;
		}

	else if (keyword == "SCAN_RANGE")
		{
		SCAN_RANGE     = (float)value;
		llSay(0, "Scan range set to " + (string)SCAN_RANGE);
		}

	else if (keyword == "SCAN_ARC")
		{
		string units  = llGetSubString(value, -2, -1);
		string number = llGetSubString(value, 0, -3);

		if (value == "PI")
			SCAN_ARC       = PI;
		else if (units == "PI")
			SCAN_ARC       = (float)number * PI;
		else
			SCAN_ARC       = (float)value;

		llSay(0, "Scan arc set to " + (string)SCAN_ARC);
		}

	else if (keyword == "SCAN_RATE")
		{
		SCAN_RATE      = (float)value;
		llSay(0, "Scan rate set to " + (string)SCAN_RATE);
		}

	else if (keyword == "SCAN_PARCEL")
		{
		if (value == "TRUE" || value == "YES" || value == "ON")
			SCAN_PARCEL    = 1;
		else if (value == "FALSE" || value == "NO" || value == "OFF")
			SCAN_PARCEL    = 0;
		else if (value == "OWNED")
			SCAN_PARCEL = 2;
		else
			SCAN_PARCEL    = (integer)value;

		llSay(0, "Scan parcel set to " + (string)SCAN_PARCEL);
		}
	}

//----------------------------------------------------------------------//
// parcel_check - check for visitor on parcel                           //
//----------------------------------------------------------------------//
integer parcel_check(key agent_key, vector agent_pos)
	{
	// no parcel check to do
	if (SCAN_PARCEL == NONE)
		return TRUE;

	// check for agent on current parcel
	else if (SCAN_PARCEL == PARCEL)
		{
		string curr_parcel_det = llDumpList2String(llGetParcelDetails(llGetPos(),
				[PARCEL_DETAILS_NAME, PARCEL_DETAILS_DESC, PARCEL_DETAILS_OWNER, PARCEL_DETAILS_GROUP, PARCEL_DETAILS_AREA]), ",");
		string agent_parcel_det = llDumpList2String(llGetParcelDetails(agent_pos,
				[PARCEL_DETAILS_NAME, PARCEL_DETAILS_DESC, PARCEL_DETAILS_OWNER, PARCEL_DETAILS_GROUP, PARCEL_DETAILS_AREA]), ",");

		if (llOverMyLand(agent_key) && (llGetAgentSize(agent_key) != ZERO_VECTOR))
			if (curr_parcel_det == agent_parcel_det)
				return TRUE;
		}

	// check for agent on owned parcel
	else if (SCAN_PARCEL == OWNED)
		{
		if (llOverMyLand(agent_key) && (llGetAgentSize(agent_key) != ZERO_VECTOR))
			return TRUE;
		}

	// agent not on parcel
	return FALSE;
	}

//
// States
//

//----------------------------------------------------------------------//
// state default                                                        //
//----------------------------------------------------------------------//
default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		module_status = "active";
		// initialize runtime constants
//		CREATOR_KEY = llGetCreator(); // for debug instant messages
		}

	no_sensor()
		{
		// agent list now consists of agents not found
		integer i;
		integer list_length = llGetListLength(prev_key);
		for (i = 0; i < list_length; i++)
			{
			// send left message to visitor list module for agent
			llMessageLinked(LINK_SET, VL_MSG_ID, "lost^" + (string)llList2Key(prev_key, i), NULL_KEY);
			}

		prev_key = [];
		}

	sensor(integer number_detected)
		{
		list found_key;

		// loop through detected agents
		integer i;
		for (i = 0; i < number_detected; i++)
			{
			// get agent info
			key    det_key  = llDetectedKey(i);
			string det_name = llDetectedName(i);
			vector det_pos  = llDetectedPos(i);

			if (parcel_check(det_key, det_pos))
				{
				// send data to visitor list module
				llMessageLinked(LINK_SET, VL_MSG_ID, "found^" + (string)det_key + "^" + det_name, NULL_KEY);

				// add to found list
				found_key = (found_key=[]) + found_key + [det_key];

				// check if agent was found on previous scan
				integer agent_index = llListFindList(prev_key, [det_key]);
				if (agent_index > -1)
					{
					// agent found on previous scan, delete from previous list
					prev_key = llDeleteSubList(prev_key, agent_index, agent_index);
					}
				}
			}

		// prev_key now consists of agents not found
		integer list_length = llGetListLength(prev_key);
		for (i = 0; i < list_length; i++)
			{
			// send left message to visitor list module for agent
			llMessageLinked(LINK_SET, VL_MSG_ID, "lost^" + (string)llList2Key(prev_key, i), NULL_KEY);
			}

		// set previous list to found agents
		prev_key = found_key;
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		if (num != SCAN_MSG_ID && num != BCST_MSG_ID)
			return;

		handle_message(str);
		}

	}
