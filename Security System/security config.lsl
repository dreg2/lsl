//----------------------------------------------------------------------//
// security system - config module                                      //
//    by Dreg2 Rossini                                                  //
//----------------------------------------------------------------------//
string VERSION = "1.00";

//
// Constants
//

// system constants
string  MODULE_NAME  = "Config";
integer BCST_MSG_ID  = -1;  // Link message ID for broadcasts
integer MAIN_MSG_ID  = 0;   // Link message ID for main module
integer SCAN_MSG_ID  = 1;   // Link message ID for scan module
integer VL_MSG_ID    = 2;   // Link message ID for visitor list module
integer CHECK_MSG_ID = 3;   // Link message ID for check module
integer CONF_MSG_ID  = 4;   // Link message ID for config module

string  CONFIG_FILE_NAME = "config";     // name of config file

// Fixed constants


// Runtime constants

//key    CREATOR_KEY; // for debug instant messages

//
// Global variables
//

string module_status;

integer config_file_line;     // current line number
key     config_query_id;      // dataserver query id
integer listen_handle;        // handle for listener

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

		else if (command == "activate")
			module_status = "active";

		else if (command == "deactivate")
			module_status = "inactive";

		else if (command == "reconfig")
			init_config();

		}

//----------------------------------------------------------------------//
// init_config - initialize config from config file                     //
//----------------------------------------------------------------------//
init_config()
	{
	// no file name found
	if (CONFIG_FILE_NAME == "")
		{
		llSay(0, "Config notecard not found");
		return;
		}

	// tell other modules to initialize for config
	llMessageLinked(LINK_SET, BCST_MSG_ID, "init", NULL_KEY);

	// request first line of file
	config_file_line = 0;
	config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
	return;
	}

//----------------------------------------------------------------------//
// parse_config_line - parse config file line                           //
//----------------------------------------------------------------------//
parse_config_line(string line)
	{
	// skip blank lines and comments
	if (line == "" || llGetSubString(line, 0, 0) == "#")
		return;

	// look for colon separator
	integer colon_loc = llSubStringIndex(line, ":");
	if (colon_loc == -1)
		{
		llSay(0, "Invalid config line:" + line);
		return;
		}

	// split line into keyword and value
	string  keyword   = llToUpper(llStringTrim(llGetSubString(line, 0, colon_loc-1), STRING_TRIM));
	string  value     = llStringTrim(llGetSubString(line, colon_loc+1, -1), STRING_TRIM);

	// send config info to other scripts
	llMessageLinked(LINK_SET, BCST_MSG_ID, "config^" + keyword + "^" + value, NULL_KEY);

	return;
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

		// config
		init_config();
		}

	changed(integer change)
		{
		if (change & CHANGED_INVENTORY)
			if (module_status == "active")
				init_config();
		}

	dataserver(key query_id, string data)
		{
		// finished reading config
		if (data == EOF)
			return;

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		if (num != CONF_MSG_ID && num != BCST_MSG_ID)
			return;

		handle_message(str);
		}
	}
