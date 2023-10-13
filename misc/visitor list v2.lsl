//----------------------------------------------------------------------//
// visitor list maker networked v2                                      //
//----------------------------------------------------------------------//

// Constants
string  CONFIG_FILE_NAME     = "config";   // config name file

integer DEFAULT_MASTER       = TRUE;
string  DEFAULT_ID           = "";     // null will use object description
float   DEFAULT_SCAN_RANGE   = 02.0;   // in meters
float   DEFAULT_SCAN_RATE    = 05.0;   // in seconds
float   DEFAULT_ARC_DIV      = 4.0;
integer DEFAULT_MENU_CHANNEL = 10;
integer DEFAULT_INTR_CHANNEL = 72462;

// Fixed constants
list  LIST_MENU = ["show", "hide", "list", "clear", "reset"];

// Option constants
integer MASTER       = DEFAULT_MASTER;
string  ID           = DEFAULT_ID;
float   SCAN_RANGE   = DEFAULT_SCAN_RANGE;
float   SCAN_RATE    = DEFAULT_SCAN_RATE;
float   ARC_DIV      = DEFAULT_ARC_DIV;
integer MENU_CHANNEL = DEFAULT_MENU_CHANNEL;
integer INTR_CHANNEL = DEFAULT_INTR_CHANNEL;
string  ARG_SEP      = "^";
float   SCAN_ARC;

// Global variables
list visitor_scnr;
list visitor_name;
list visitor_time_first;
list visitor_time_last;

integer config_file_line;     // current line number
key     config_query_id;      // dataserver query id

integer chat_handle;
integer intr_handle;

//
// Functions
//

//----------------------------------------------------------------------//
// get_timestamp - return a timestamp                                   //
//----------------------------------------------------------------------//
string get_timestamp()
	{
	list temp = llParseString2List(llGetTimestamp(), ["T",":","Z","."] , []);
	string timestamp = llList2String(temp, 0)
		+ " " + llList2String(temp, 1) + ":" + llList2String(temp, 2) + ":" + llList2String(temp, 3);
	return timestamp;
	}

//----------------------------------------------------------------------//
// init_config - initialize config from config file                     //
//----------------------------------------------------------------------//
integer init_config()
	{
	// default config values
	MASTER       = DEFAULT_MASTER;
	ID           = DEFAULT_ID;
	SCAN_RANGE   = DEFAULT_SCAN_RANGE;
	SCAN_RATE    = DEFAULT_SCAN_RATE;
	ARC_DIV      = DEFAULT_ARC_DIV;
	MENU_CHANNEL = DEFAULT_MENU_CHANNEL;
	INTR_CHANNEL = DEFAULT_INTR_CHANNEL;

	// no file name found
	if (CONFIG_FILE_NAME == "")
		return 1;
//	if (llGetInventoryType(CONFIG_FILE_NAME) == INVENTORY_NONE)
//		return 1;

	// request first line of file
	config_file_line = 0;
	config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
	return 0;
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

	if (keyword == "MASTER")
		{
		MASTER     = (integer)value;
		llSay(0, "Master set to " + (string)MASTER);
		}

	else if (keyword == "SCAN_RANGE")
		{
		SCAN_RANGE     = (float)value;
		llSay(0, "Scan range set to " + (string)SCAN_RANGE);
		}

	else if (keyword == "SCAN_RATE")
		{
		SCAN_RATE      = (float)value;
		llSay(0, "Scan rate set to " + (string)SCAN_RATE);
		}

	else if (keyword == "ARC_DIV")
		{
		ARC_DIV       = (float)value;
		llSay(0, "Arc div set to " + (string)ARC_DIV);
		}

	else if (keyword == "MENU_CHANNEL")
		{
		MENU_CHANNEL        = (integer)value;
		llSay(0, "Chat channel set to " + (string)MENU_CHANNEL);
		}

	else if (keyword == "INTR_CHANNEL")
		{
		INTR_CHANNEL        = (integer)value;
		llSay(0, "Intr channel set to " + (string)INTR_CHANNEL);
		}

	else
		{
		llSay(0, "Unknown keyword: " + keyword);
		}

	return;
	}

//----------------------------------------------------------------------//
// proc_command - process command                                       //
//----------------------------------------------------------------------//
proc_command(string command)
	{
	// add command
	if (llGetSubString(command, 0, 3) == "add ")
		{
		// parse "add"
		string  remain   = llGetSubString(command, 4, -1);
		integer sep_loc  = llSubStringIndex(remain, ARG_SEP);
		string  new_scnr = llGetSubString(remain, 0, sep_loc-1);

		// parse name
		remain           = llGetSubString(remain, sep_loc+1, -1);
		sep_loc          = llSubStringIndex(remain, ARG_SEP);
		string  new_name = llGetSubString(remain, 0, sep_loc-1);

		// parse timestamp
		remain           = llGetSubString(remain, sep_loc+1, -1);
		string  new_time = remain;

		// add to list if not found
		integer visitor_index = 0;
		if ((visitor_index = llListFindList(visitor_name, [new_name])) == -1)
			{
			visitor_scnr       = (visitor_scnr=[]) + visitor_scnr + [new_scnr];
			visitor_name       = (visitor_name=[]) + visitor_name + [new_name];
			visitor_time_first = (visitor_time_first=[]) + visitor_time_first + [new_time];
			visitor_time_last  = (visitor_time_last=[]) + visitor_time_last + [new_time];
			}
		else
			{
			visitor_time_last = llListReplaceList(visitor_time_last, [new_time], visitor_index, visitor_index);
			}
		}

	// reset master
	else if (command == "reset")
		{
		if (MASTER)
			{
			llRegionSay(INTR_CHANNEL, "scanner reset");
			llResetScript();
			}
		}

	// reset slave
	else if (command == "scanner reset")
		{
		if (!MASTER)
			llResetScript();
		}

	// clear master lists
	else if (command == "clear")
		{
		if (MASTER)
			{
			llRegionSay(INTR_CHANNEL, "scanner clear");
			visitor_scnr       = [];
			visitor_name       = [];
			visitor_time_first = [];
			visitor_time_last  = [];
			llWhisper(0, "List cleared.");
			}
		return;
		}

	// clear slave lists
	else if (command == "scanner clear")
		{
		if (!MASTER)
			{
			visitor_scnr        = [];
			visitor_name        = [];
			visitor_time_first  = [];
			visitor_time_last   = [];
			}
		return;
		}

	// tell slaves to show
	else if (command == "show")
		{
		if (MASTER)
			{
			llRegionSay(INTR_CHANNEL, "scanner show");
			llWhisper(0, "Scanners are visible.");
			}
		return;
		}

	// make slave visible
	else if (command == "scanner show")
		{
		if (!MASTER)
			{
			llSetText(ID, <1.0, 1.0, 1.0>, 1.0);
			llSetAlpha(1.0, ALL_SIDES);
			}
		return;
		}

	// tell slaves to hide
	else if (command == "hide")
		{
		if (MASTER)
			{
			llRegionSay(INTR_CHANNEL, "scanner hide");
			llWhisper(0, "Scanners are hidden.");
			}
		return;
		}

	// make slave hidden
	else if (command == "scanner hide")
		{
		if (!MASTER)
			{
			llSetText("", <0.0, 0.0, 0.0>, 0.0);
			llSetAlpha(0.0, ALL_SIDES);
			}
		return;
		}

	// display help
	else if (command == "help")
		{
		llWhisper(0, "Commands the owner can say:");
		llWhisper(0, "'/" + (string)MENU_CHANNEL + "help'  - Shows these instructions.");
		llWhisper(0, "'/" + (string)MENU_CHANNEL + "list'  - Says the names of all visitors on the list.");
		llWhisper(0, "'/" + (string)MENU_CHANNEL + "clear' - Removes all the names from the list.");
		llWhisper(0, "'/" + (string)MENU_CHANNEL + "reset' - Resets the scanner.");
		llWhisper(0, "'/" + (string)MENU_CHANNEL + "hide'  - Hide scanners.");
		llWhisper(0, "'/" + (string)MENU_CHANNEL + "show'  - Show scanners.");
		}

	// display list of visitors
	else if (command == "list")
		{
		llWhisper(0, "Visitor List:");
		integer len = llGetListLength(visitor_name);
		integer i;
		for (i = 0; i < len; i++)
			llWhisper(0, llList2String(visitor_scnr, i) + ": "
				+ llList2String(visitor_time_first, i) + ": "
				+ llList2String(visitor_time_last, i) + ": "
				+ llList2String(visitor_name, i));
		llWhisper(0, "Total = " + (string)len );
		}
	}

//
// States
//
default
	{
	on_rez(integer start_param)
		{
		if (MASTER)
			llRegionSay(INTR_CHANNEL, "scanner reset");

		// reset script
		llResetScript();
		}

	state_entry()
		{
		// clear lists
		visitor_scnr       = [];
		visitor_name       = [];
		visitor_time_first = [];
		visitor_time_last  = [];

		// get config
		init_config();
		}

	touch_start(integer total_number)
		{
		// present dialog menu
		if (MASTER && llSameGroup(llDetectedKey(0)))
			llDialog(llDetectedKey(0), "Visitor list maker\nFree Memory: " + (string)llGetFreeMemory(), LIST_MENU, MENU_CHANNEL);
		}

	sensor(integer number_detected)
		{
		integer i;
		// loop through detected agents
		for (i = 0; i < number_detected; i++)
			{
			string detected_name = llDetectedName(i);
			string detected_time = get_timestamp();

			// add to list if not found
			integer visitor_index = 0;
			if (llListFindList(visitor_name, [detected_name]) == -1)
				{
				visitor_scnr       = (visitor_scnr=[]) + visitor_scnr + [ID];
				visitor_name       = (visitor_name=[]) + visitor_name + [detected_name];
				visitor_time_first = (visitor_time_first=[]) + visitor_time_first + [detected_time];
				visitor_time_last  = (visitor_time_last=[]) + visitor_time_last + [detected_time];
				}
			else
				{
				visitor_time_last = llListReplaceList(visitor_time_last, [detected_time], visitor_index, visitor_index);
				}

			// give info to other scanners
			llRegionSay(INTR_CHANNEL, "add " + ID + ARG_SEP + detected_name + ARG_SEP + detected_time);
			}
		}

	listen (integer channel, string name, key id, string message)
		{
		// check for allowed group
		if (!llSameGroup(id))
			return;

		proc_command(message);
		}

	changed(integer change)
		{
		// check for changed config
		if (!(change & CHANGED_INVENTORY))
			return;

		// re-initialize config
		llListenRemove(intr_handle);
		llListenRemove(chat_handle);
		llSensorRemove();
		init_config();
		}

	dataserver(key query_id, string data)
		{
		// finished reading config
		if (data == EOF)
			{
			// initialize constants
			if (ID == "")
				ID = llGetObjectDesc();
			SCAN_ARC = PI / ARC_DIV;
			llSetAlpha(1.0, ALL_SIDES);

			if (MASTER)
				{
				// set up master
				llSetText("", <0.0, 0.0, 0.0>, 0.0);
				llSay(0, "Visitor List Maker started");
				llSay(0, "Say '/" + (string)MENU_CHANNEL + "help' for instructions.");
				chat_handle = llListen(MENU_CHANNEL, "", NULL_KEY, "");
				}
			else
				{
				// set up slave
				llSetText(ID, <1.0, 1.0, 1.0>, 1.0);
				llSay(0, ID + " started");
				llSensorRepeat("", NULL_KEY, AGENT, SCAN_RANGE, SCAN_ARC, SCAN_RATE);
				}

			// listen for interobject chat
			intr_handle = llListen(INTR_CHANNEL, "", NULL_KEY, "");
			}
		else
			{
			// parse line from config file
			parse_config_line(data);
			config_file_line++;
			config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
			}
		}
	}
