//----------------------------------------------------------------------//
// visitor list maker networked                                         //
//----------------------------------------------------------------------//

// Constants
string  CONFIG_FILE_NAME     = "config";   // config name file

integer DEFAULT_MASTER       = FALSE;
string  DEFAULT_ID           = "";     // null will use object description
float   DEFAULT_SCAN_RANGE   = 02.0;   // in meters
float   DEFAULT_SCAN_RATE    = 05.0;   // in seconds
float   DEFAULT_ARC_DIV      = 4.0;
integer DEFAULT_CHAT_CHANNEL = 10;
integer DEFAULT_INTR_CHANNEL = 72462;

// Fixed constants
list  LIST_MENU = ["show", "hide", "list", "clear", "reset"];

// Option constants
integer MASTER       = DEFAULT_MASTER;
string  ID           = DEFAULT_ID;
float   SCAN_RANGE   = DEFAULT_SCAN_RANGE;
float   SCAN_RATE    = DEFAULT_SCAN_RATE;
float   ARC_DIV      = DEFAULT_ARC_DIV;
integer CHAT_CHANNEL = DEFAULT_CHAT_CHANNEL;
integer INTR_CHANNEL = DEFAULT_INTR_CHANNEL;
string  ARG_SEP      = ",";
float   SCAN_ARC;

// Global variables
list visitor_scnr;
list visitor_name;
list visitor_time;

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
	CHAT_CHANNEL = DEFAULT_CHAT_CHANNEL;
	INTR_CHANNEL = DEFAULT_INTR_CHANNEL;

	// no file name found
	if (CONFIG_FILE_NAME == "")
		return 1;

	// request first line of file
	config_file_line = 0;
	config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
	return 0;
	}

//----------------------------------------------------------------------//
// find_name - find name on list                                        //
//----------------------------------------------------------------------//
integer find_name(string name)
	{
	integer len = llGetListLength(visitor_name);
	integer i;

	// loop through list looking for a match
	for (i = 0; i < len; i++)
		if (llList2String(visitor_name, i) == name)
			return TRUE;

	return FALSE;
	}

//----------------------------------------------------------------------//
// parse_config_line - parse config file line                           //
//----------------------------------------------------------------------//
integer parse_config_line(string line)
	{
	// skip blank lines and comments
	if (line == "" || llGetSubString(line, 0, 0) == "#")
		return 0;

	// look for colon separator
	integer colon_loc = llSubStringIndex(line, ":");
	if (colon_loc == -1)
		return 0;

	// split line into keyword and value
	string  keyword   = llGetSubString(line, 0, colon_loc-1);
	string  value     = llGetSubString(line, colon_loc+1, -1);

	if (keyword == "MASTER")
		{
		MASTER     = (float)value;
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

	else if (keyword == "CHAT_CHANNEL")
		{
		CHAT_CHANNEL        = (integer)value;
		llSay(0, "Chat channel set to " + (string)CHAT_CHANNEL);
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

	return 0;
	}

//
// States
//
default
	{
	on_rez(integer start_param)
		{
		if (MASTER)
			llShout(INTR_CHANNEL, "scanner reset");

		// reset script
		llResetScript();
		}

	state_entry()
		{
		// clear lists
		visitor_scnr  = [];
		visitor_name  = [];
		visitor_time  = [];

		// get config
		init_config();
		}

	touch_start(integer total_number)
		{
		// present dialog menu
		if (MASTER && llSameGroup(llDetectedKey(0)))
			llDialog(llDetectedKey(0), "Visitor list maker\nFree Memory: " + (string)llGetFreeMemory(), LIST_MENU, CHAT_CHANNEL);
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
			if (!find_name(detected_name))
				{
				visitor_scnr = (visitor_scnr=[]) + visitor_scnr + [ID];
				visitor_time = (visitor_time=[]) + visitor_time + [detected_time];
				visitor_name = (visitor_name=[]) + visitor_name + [detected_name];

				// give info to other scanners
				llShout(INTR_CHANNEL, "add " + ID + ARG_SEP + detected_name + ARG_SEP + detected_time);
				}
			}
		}

	listen (integer channel, string name, key id, string message)
		{
		// check for allowed group
		if (!llSameGroup(id))
			return;

		// add message
		if (llGetSubString(message, 0, 3) == "add ")
			{
			// parse "add"
			string  remain   = llGetSubString(message, 4, -1);
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
			if (!find_name(new_name))
				{
				visitor_scnr = (visitor_scnr=[]) + visitor_scnr + [new_scnr];
				visitor_name = (visitor_name=[]) + visitor_name + [new_name];
				visitor_time = (visitor_time=[]) + visitor_time + [new_time];
				}
			}

		// reset master
		else if (message == "reset")
			{
			if (MASTER)
				{
				llShout(INTR_CHANNEL, "scanner reset");
				llResetScript();
				}
			}

		// reset slave
		else if (message == "scanner reset")
			{
			if (!MASTER)
				llResetScript();
			}

		// clear master lists
		else if (message == "clear")
			{
			if (MASTER)
				{
				llShout(INTR_CHANNEL, "scanner clear");
				visitor_scnr  = [];
				visitor_name  = [];
				visitor_time  = [];
				llWhisper(0, "List cleared.");
				}
			return;
			}

		// clear slave lists
		else if (message == "scanner clear")
			{
			if (!MASTER)
				{
				visitor_scnr  = [];
				visitor_name  = [];
				visitor_time  = [];
				}
			return;
			}

		// tell slaves to show
		else if (message == "show")
			{
			if (MASTER)
				{
				llShout(INTR_CHANNEL, "scanner show");
				llWhisper(0, "Scanners are visible.");
				}
			return;
			}

		// make slave visible
		else if (message == "scanner show")
			{
			if (!MASTER)
				{
				llSetText(ID, <1.0, 1.0, 1.0>, 1.0);
				llSetAlpha(1.0, ALL_SIDES);
				}
			return;
			}

		// tell slaves to hide
		else if (message == "hide")
			{
			if (MASTER)
				{
				llShout(INTR_CHANNEL, "scanner hide");
				llWhisper(0, "Scanners are hidden.");
				}
			return;
			}

		// make slave hidden
		else if (message == "scanner hide")
			{
			if (!MASTER)
				{
				llSetText("", <0.0, 0.0, 0.0>, 0.0);
				llSetAlpha(0.0, ALL_SIDES);
				}
			return;
			}

		// display help
		else if (message == "help")
			{
			llWhisper(0, "Commands the owner can say:");
			llWhisper(0, "'/" + (string)CHAT_CHANNEL + "help'  - Shows these instructions.");
			llWhisper(0, "'/" + (string)CHAT_CHANNEL + "list'  - Says the names of all visitors on the list.");
			llWhisper(0, "'/" + (string)CHAT_CHANNEL + "clear' - Removes all the names from the list.");
			llWhisper(0, "'/" + (string)CHAT_CHANNEL + "reset' - Resets the scanner.");
			llWhisper(0, "'/" + (string)CHAT_CHANNEL + "hide'  - Hide scanners.");
			llWhisper(0, "'/" + (string)CHAT_CHANNEL + "show'  - Show scanners.");
			}

		// display list of visitors
		else if (message == "list")
			{
			llWhisper(0, "Visitor List:");
			integer len = llGetListLength(visitor_name);
			integer i;
			for (i = 0; i < len; i++)
				llWhisper(0, llList2String(visitor_scnr, i) + ": " + llList2String(visitor_time, i) + ": " + llList2String(visitor_name, i));
			llWhisper(0, "Total = " + (string)len );
			}
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
				llSay(0, "Say '/" + (string)CHAT_CHANNEL + "help' for instructions.");
				chat_handle = llListen(CHAT_CHANNEL, "", NULL_KEY, "");
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

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
		}
	}
