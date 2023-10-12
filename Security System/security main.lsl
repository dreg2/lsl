//----------------------------------------------------------------------//
// security system - main module                                        //
//    by Dreg2 Rossini                                                  //
//----------------------------------------------------------------------//
string VERSION = "1.00";

//
// Constants
//

// system constants
string  MODULE_NAME  = "Main";
integer BCST_MSG_ID  = -1;  // Link message ID for broadcasts
integer MAIN_MSG_ID  = 0;   // Link message ID for main module
integer SCAN_MSG_ID  = 1;   // Link message ID for scan module
integer VL_MSG_ID    = 2;   // Link message ID for visitor list module
integer CHECK_MSG_ID = 3;   // Link message ID for check module
integer CONF_MSG_ID  = 4;   // Link message ID for config module

// default config options
integer DEFAULT_CHANNEL        = 12;      // command chat channel

// Fixed constants

// menus
list MENU_1 = ["Off", "Visitors", "Advanced", "On"];
list MENU_2 = ["Scan Off", "Check Off", "Reset", "Scan On", "Check On", "Status", "Config", "Reconfig", "Allowed"];

// Runtime constants

string PARCEL_NAME; // name of parcel
//key    CREATOR_KEY; // for debug instant messages

// config options
integer CHANNEL        = DEFAULT_CHANNEL;

//
// Global variables
//

string module_status;

//
// Functions
//

//----------------------------------------------------------------------//
// handle_message - handle link message                                 //
//----------------------------------------------------------------------//
handle_message(string str)
		{
		list   message = llParseString2List(str, ["^"], []);
		string command = llList2String(message, 0);
		list   args    = llList2List(message, 1, -1);

		if (command == "reset")
			llResetScript();

		else if (command == "status")
			llSay(0, MODULE_NAME + " (" + (string)llGetFreeMemory() + "): " + module_status);

		else if (command == "config")
			set_config(args);

		else if (command == "activate")
			module_status = "active";

		else if (command == "deactivate")
			module_status = "inactive";
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
		llSay(0, "Channel: "   + (string)CHANNEL);
		return;
		}

	else if (keyword == "DEFAULT")
		{
		CHANNEL        = DEFAULT_CHANNEL;
		}

	else if (keyword == "CHANNEL")
		{
		CHANNEL      = (integer)value;
		llListen(CHANNEL, "", NULL_KEY, "");
		llSay(0, "Channel set to " + (string)CHANNEL);
		}
	}

//----------------------------------------------------------------------//
// proc_command - process command                                       //
//----------------------------------------------------------------------//
integer proc_command(string command, key id)
	{
	// advanced - display advanced menu
	if (command == "advanced")
		{
		llDialog(id, "Security System for " + PARCEL_NAME, MENU_2, CHANNEL);
		return TRUE;
		}
	// scan on - turn on scanner
	if (command == "scan on")
		{
		llMessageLinked(LINK_SET, SCAN_MSG_ID, "activate", NULL_KEY);
		return TRUE;
		}

	// scan off - turn off scanner
	else if (command == "scan off")
		{
		llMessageLinked(LINK_SET, SCAN_MSG_ID, "deactivate", NULL_KEY);
		return TRUE;
		}

	// check on - turn on check
	if (command == "check on" || command == "on")
		{
		llMessageLinked(LINK_SET, CHECK_MSG_ID, "activate", NULL_KEY);
		return TRUE;
		}
	// check off - turn off check
	else if (command == "check off" || command == "off")
		{
		llMessageLinked(LINK_SET, CHECK_MSG_ID, "deactivate", NULL_KEY);
		return TRUE;
		}

	// reset - reset scripts
	else if (command == "reset")
		{
		llMessageLinked(LINK_SET, BCST_MSG_ID, "reset", NULL_KEY);
		return TRUE;
		}

	// visitors - say list of visitors
	else if (command == "visitors")
		{
		llMessageLinked(LINK_SET, VL_MSG_ID, "visitors", NULL_KEY);
		return TRUE;
		}

	// config - display config
	else if (command == "config")
		{
		llMessageLinked(LINK_SET, BCST_MSG_ID, "config^LIST", NULL_KEY);
		return TRUE;
		}

	// reconfig - reconfig scripts
	else if (command == "reconfig")
		{
		llMessageLinked(LINK_SET, CONF_MSG_ID, "reconfig", NULL_KEY);
		return TRUE;
		}

	// status - display status
	else if (command == "status")
		{
		llMessageLinked(LINK_SET, BCST_MSG_ID, "status", NULL_KEY);
		return TRUE;
		}

	// allowed - display allowed agents
	else if (command == "allowed")
		{
		llMessageLinked(LINK_SET, BCST_MSG_ID, "allowed", NULL_KEY);
		return TRUE;
		}

	// no command match found
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
		list lstParcelDetails = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME]);
		PARCEL_NAME      = llList2String(lstParcelDetails, 0);
//		CREATOR_KEY = llGetCreator(); // for debug instant messages

		llListen(CHANNEL, "", NULL_KEY, "");
		}

	touch_start(integer total_number) 
		{
		// present dialog menu
		if (llSameGroup(llDetectedKey(0)))
			llDialog(llDetectedKey(0), "Security System for " + PARCEL_NAME, MENU_1, CHANNEL);
		}

	listen (integer channel, string name, key id, string message)
		{
		// verify source of chat
		if (channel != CHANNEL || !llSameGroup(id))
			return;

		// convert message to lower case command
		string command = llToLower(message);

		// process command
		proc_command(command, id);
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		if (num != MAIN_MSG_ID && num != BCST_MSG_ID)
			return;

		handle_message(str);
		}
	}

