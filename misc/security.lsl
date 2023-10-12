//----------------------------------------------------------------------//
// security system                                                      //
//    by Dreg2 Rossini                                                  //
//----------------------------------------------------------------------//

//
// Constants
//

string  CONFIG_FILE_NAME = "config";     // name config file

// Default config options
float   DEFAULT_SCAN_RANGE     = 50.0;    // in meters
float   DEFAULT_SCAN_ARC       = PI;      // in radians
float   DEFAULT_SCAN_RATE      = 1.0;     // in seconds
integer DEFAULT_SCAN_PARCEL    = 1;       // limit scan to parcel(1) or not(0)
integer DEFAULT_LIST_TIME      = 0;       // time limit on visitors list in seconds units, 0 - indefinite
integer DEFAULT_WARN_TYPE      = 1;       // warn type, 0 = IM, 1 = dialog
integer DEFAULT_WARN_TIME      = 15;      // in seconds
integer DEFAULT_CHANNEL        = 12;      // command chat channel
integer DEFAULT_EJECT_TYPE     = 1;       // eject type 0 = none, 1 = eject, 2 = teleport home
integer DEFAULT_BAN_FLAG       = TRUE;    // ban flag
float   DEFAULT_BAN_TIME       = 4.0;     // in hours 0.0 = permanent
list    DEFAULT_ALLOWED_AGENTS = [];

//
// Fixed constants
//

// menus
list MENU_INACTIVE = ["Allowed", "Visitors", "Reset", "Activate", "Config"];
list MENU_ACTIVE   = ["Allowed", "Visitors", "Reset", "Deactivate", "Config"];

// visitor status values
integer NONE    = 0;
integer ALLOWED = 1;
integer WARNED  = 2;
integer EJECTED = 3;
integer LEFT    = 4;

// runtime constants
string PARCEL_NAME;
key    PARCEL_OWNER_KEY;
key    OWNER_KEY;
//key    CREATOR_KEY; // for debug instant messages

// config options
float   SCAN_RANGE     = DEFAULT_SCAN_RANGE;
float   SCAN_ARC       = DEFAULT_SCAN_ARC;
float   SCAN_RATE      = DEFAULT_SCAN_RATE;
integer SCAN_PARCEL    = DEFAULT_SCAN_PARCEL;
integer LIST_TIME      = DEFAULT_LIST_TIME;
integer WARN_TYPE      = DEFAULT_WARN_TYPE;
integer WARN_TIME      = DEFAULT_WARN_TIME;
integer CHANNEL        = DEFAULT_CHANNEL;
integer EJECT_TYPE     = DEFAULT_EJECT_TYPE;
integer BAN_FLAG       = DEFAULT_BAN_FLAG;
float   BAN_TIME       = DEFAULT_BAN_TIME;
list    ALLOWED_AGENTS = DEFAULT_ALLOWED_AGENTS;

//
// Global variables
//

integer config_file_line;     // current line number
key     config_query_id;      // dataserver query id
integer listen_handle;        // handle for listener

// visitors lists
list visitor_key;      // visitor key
list visitor_name;     // visitor name
list visitor_status;   // visitor status flag
list visitor_wrntime;  // remaining time before ejection
list visitor_chktime;  // visitor checked timestamp
list visitor_unxtime;  // visitor unix timestamp (for calculations)

//
// Functions
//

//----------------------------------------------------------------------//
// format_time - format timestamp for printing                          //
//----------------------------------------------------------------------//
string format_timestamp(string timestamp)
	{
	list temp = llParseString2List(timestamp, ["T",":","Z","."] , []);
	string format_time = llList2String(temp, 0)
		+ " " + llList2String(temp, 1) + ":" + llList2String(temp, 2) + ":" + llList2String(temp, 3);
	return format_time;
	}

//----------------------------------------------------------------------//
// init_config - initialize config from config file                     //
//----------------------------------------------------------------------//
integer init_config()
	{
	// default config values
	SCAN_RANGE     = DEFAULT_SCAN_RANGE;
	SCAN_ARC       = DEFAULT_SCAN_ARC;
	SCAN_RATE      = DEFAULT_SCAN_RATE;
	SCAN_PARCEL    = DEFAULT_SCAN_PARCEL;
	LIST_TIME      = DEFAULT_LIST_TIME;
	WARN_TYPE      = DEFAULT_WARN_TYPE;
	WARN_TIME      = DEFAULT_WARN_TIME;
	CHANNEL        = DEFAULT_CHANNEL;
	EJECT_TYPE     = DEFAULT_EJECT_TYPE;
	BAN_FLAG       = DEFAULT_BAN_FLAG;
	BAN_TIME       = DEFAULT_BAN_TIME;
	ALLOWED_AGENTS = DEFAULT_ALLOWED_AGENTS;

	// no file name found
	if (CONFIG_FILE_NAME == "")
		return 1;

	// request first line of file
	config_file_line = 0;
	config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
	return 0;
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

	if (keyword == "SCAN_RANGE")
		{
		SCAN_RANGE     = (float)value;
		llSay(0, "Scan range set to " + (string)SCAN_RANGE);
		}

	else if (keyword == "SCAN_ARC")
		{
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
		SCAN_PARCEL    = (integer)value;
		llSay(0, "Scan parcel set to " + (string)SCAN_PARCEL);
		}

	else if (keyword == "LIST_TIME")
		{
		LIST_TIME      = (integer)value;
		llSay(0, "List time set to " + (string)LIST_TIME);
		}

	else if (keyword == "WARN_TYPE")
		{
		WARN_TYPE      = (integer)value;
		llSay(0, "Warn type set to " + (string)WARN_TYPE);
		}

	else if (keyword == "WARN_TIME")
		{
		WARN_TIME      = (integer)value;
		llSay(0, "Warn time set to " + (string)WARN_TIME);
		}

	else if (keyword == "CHANNEL")
		{
		CHANNEL        = (integer)value;
		llSay(0, "Channel set to " + (string)CHANNEL);
		}

	else if (keyword == "EJECT_TYPE")
		{
		EJECT_TYPE     = (integer)value;
		llSay(0, "Eject type set to " + (string)EJECT_TYPE);
		}

	else if (keyword == "BAN_FLAG")
		{
		BAN_FLAG       = (integer)value;
		llSay(0, "Ban flag set to " + (string)BAN_FLAG);
		}

	else if (keyword == "BAN_TIME")
		{
		BAN_TIME       = (float)value;
		llSay(0, "Ban time set to " + (string)BAN_TIME);
		}

	else if (keyword == "ALLOWED_AGENT")
		{
		ALLOWED_AGENTS = (ALLOWED_AGENTS=[]) + ALLOWED_AGENTS + (string)value;
		llSay(0, "Agent added: " + llList2String(ALLOWED_AGENTS, llGetListLength(ALLOWED_AGENTS)-1));
		}

	else
		{
		llSay(0, "Unknown keyword: " + keyword);
		}

	return 0;
	}


//----------------------------------------------------------------------//
// check_visitor - check visitor and allow or eject                     //
//----------------------------------------------------------------------//
integer check_visitor(integer agent_index)
	{
	// get agent data from the lists
	key     agent_key    = llList2Key(visitor_key, agent_index);
	string  agent_name   = llList2String(visitor_name, agent_index);

	// check allowed list and group
	if (llListFindList(ALLOWED_AGENTS, [agent_name]) > -1 || llSameGroup(agent_key))
		{
		// set allowed flag
		visitor_status = llListReplaceList(visitor_status, [ALLOWED], agent_index, agent_index);
		return 1;
		}

	integer agent_status = llList2Integer(visitor_status, agent_index);
	integer unix_time = llGetUnixTime();

	// not allowed, warn
	if (agent_status != WARNED)
		{
		agent_status = WARNED;
		visitor_status  = llListReplaceList(visitor_status,  [agent_status], agent_index, agent_index);
		visitor_wrntime = llListReplaceList(visitor_wrntime, [unix_time],    agent_index, agent_index);
		if (WARN_TYPE == 0)
			{
			llInstantMessage(agent_key, "***** Warning ***** You are on a private parcel");
			llInstantMessage(agent_key, "You have " + (string)WARN_TIME + " seconds to leave " + PARCEL_NAME);
			}
		else
			{
			llDialog(agent_key,
					"\n***** Warning *****"
					+ "\nYou are on a private parcel"
					+ "\nYou have " + (string)WARN_TIME + " seconds to leave " + PARCEL_NAME,
				[], CHANNEL);
			}
		}

	// eject when past warn time
	if (unix_time - llList2Integer(visitor_wrntime, agent_index) > WARN_TIME)
		{
		// eject visitor
		if (EJECT_TYPE == 1)
			{
			llEjectFromLand(agent_key);
			llInstantMessage(agent_key, "You have been ejected from " + PARCEL_NAME);
			}

		// teleport visitor home
		else if (EJECT_TYPE == 2)
			{
			llTeleportAgentHome(agent_key);
			llInstantMessage(agent_key, "You have been teleported home from " + PARCEL_NAME);
			}


		// ban visitor
		if (BAN_FLAG == TRUE)
			{
			llAddToLandBanList(agent_key, BAN_TIME);
			llInstantMessage(agent_key, "You have been banned from " + PARCEL_NAME);
			}

		// set ejected flag
		visitor_status = llListReplaceList(visitor_status, [EJECTED], agent_index, agent_index);
		}

	return -1;
	}


//----------------------------------------------------------------------//
// expire_lists - reset timers for visitors not found                   //
//----------------------------------------------------------------------//
integer expire_lists()
	{
	integer index;
	integer list_length = llGetListLength(visitor_key);
	integer unix_time = llGetUnixTime();

	// loop backwards through the lists to keep index correct
	for (index = list_length - 1; index >= 0; index--)
		{
		// purge visitor from list if older than LIST_TIME
		if (((unix_time - llList2Integer(visitor_unxtime, index)) > LIST_TIME) && LIST_TIME)
			{
			// delete from list
			visitor_key     = llDeleteSubList(visitor_key, index, index);
			visitor_name    = llDeleteSubList(visitor_name, index, index);
			visitor_status  = llDeleteSubList(visitor_status, index, index);
			visitor_wrntime = llDeleteSubList(visitor_wrntime, index, index);
			visitor_chktime = llDeleteSubList(visitor_chktime, index, index);
			visitor_unxtime = llDeleteSubList(visitor_unxtime, index, index);
			}

		// change status to "left" if visitor warned and not detected
		else if ((llList2Integer(visitor_status, index) == WARNED) && ((unix_time - llList2Integer(visitor_unxtime, index)) > (WARN_TIME)))
			{
			visitor_status = llListReplaceList(visitor_status, [LEFT], index, index);
			}
		}


	return 0;
	}

//----------------------------------------------------------------------//
// check_visitor_list - find or add agent on visitor list               //
// returns index into agent list                                        //
//----------------------------------------------------------------------//
integer check_visitor_list(integer detected_number)
	{
	// get agent key and name
	key     detected_key  = llDetectedKey(detected_number);

	// if agent is not on parcel
	if (!(llOverMyLand(detected_key) && llGetAgentSize(detected_key) != ZERO_VECTOR) && SCAN_PARCEL)
		{
		return -1;
		}

	string  detected_name = llDetectedName(detected_number);
	string  time_stamp = llGetTimestamp();
	integer unix_time  = llGetUnixTime();

	// check if agent is already on the list
	integer agent_index = llListFindList(visitor_name, [detected_name]);

	// add agent if not on the list
	if (agent_index == -1)
		{
		// add agent to the list
		visitor_key     = (visitor_key=[])     + visitor_key     + [detected_key];
		visitor_name    = (visitor_name=[])    + visitor_name    + [detected_name];
		visitor_status  = (visitor_status=[])  + visitor_status  + [NONE];
		visitor_wrntime = (visitor_wrntime=[]) + visitor_wrntime + [0];
		visitor_chktime = (visitor_chktime=[]) + visitor_chktime + [time_stamp];
		visitor_unxtime = (visitor_unxtime=[]) + visitor_unxtime + [unix_time];
		agent_index = llGetListLength(visitor_name) - 1;
		}
	else
		{
		// update time stamps
		visitor_chktime = llListReplaceList(visitor_chktime, [time_stamp], agent_index, agent_index);
		visitor_unxtime = llListReplaceList(visitor_unxtime, [unix_time], agent_index, agent_index);
		}

	return agent_index;
	}

//----------------------------------------------------------------------//
// proc_command - process command                                       //
//----------------------------------------------------------------------//
integer proc_command(key id, string command)
	{
	// help - say help
//	if (command == "help")
//		{
//		llSay(0, "Security system help:");
//		llSay(0, "Touch for menu");
//		llSay(0, "Chat commands:");
//		llSay(0, "'/" + (string)CHANNEL + "help'       - Shows these instructions.");
//		llSay(0, "'/" + (string)CHANNEL + "activate'   - Activates security");
//		llSay(0, "'/" + (string)CHANNEL + "deactivate' - Deactivates security");
//		llSay(0, "'/" + (string)CHANNEL + "visitors'   - Says the names of all visitors.");
//		llSay(0, "'/" + (string)CHANNEL + "reset'      - Resets the script");
//		return TRUE;
//		}

	// allowed - say list of allowed visitors
	if (command == "allowed")
		{
		llSay(0, "Allowed List at " + PARCEL_NAME + ":");
		integer len = llGetListLength(ALLOWED_AGENTS);
		integer i;

		// loop through allowed visitors list
		for (i = 0; i < len; i++)
			{
			llSay(0, llList2String(ALLOWED_AGENTS, i));
			}

		llSay(0, "Total allowed: " + (string)len ); 
		return TRUE;
		}

	// visitors - say list of visitors
	else if (command == "visitors")
		{
		llSay(0, "Visitor List at " + PARCEL_NAME + ":");
		integer len = llGetListLength(visitor_name);
		integer i;

		// loop through visitors list
		for (i = 0; i < len; i++)
			{
			string status;

			if (llList2Integer(visitor_status, i) == ALLOWED)
				status = "Allowed";
			else if (llList2Integer(visitor_status, i) == WARNED)
				status = "Warned";
			else if (llList2Integer(visitor_status, i) == EJECTED)
				status = "Ejected";
			else if (llList2Integer(visitor_status, i) == LEFT)
				status = "Left";
			else
				status = "Not checked";

			llSay(0, format_timestamp(llList2String(visitor_chktime, i)) + " " + llList2String(visitor_name, i) + ": " + status);
			}

		llSay(0, "Total visitors: " + (string)len ); 
		return TRUE;
		}

	// reset - reset script
	else if (command == "reset")
		{
		llResetScript();
		return TRUE;
		}

	// config - display config
	else if (command == "config")
		{
		llSay(0, "Current configuration:");
		llSay(0, "Scan Range: "  + (string)SCAN_RANGE);
		llSay(0, "Scan Arc: "    + (string)SCAN_ARC);
		llSay(0, "Scan Rate: "   + (string)SCAN_RATE);
		llSay(0, "Scan Parcel: " + (string)SCAN_PARCEL);
		llSay(0, "List Time: "   + (string)LIST_TIME);
		llSay(0, "Warn Type: "   + (string)WARN_TYPE);
		llSay(0, "Warn Time: "   + (string)WARN_TIME);
		llSay(0, "Channel: "     + (string)CHANNEL);
		llSay(0, "Eject Type: "  + (string)EJECT_TYPE);
		llSay(0, "Ban Flag: "    + (string)BAN_FLAG);
		llSay(0, "Ban Time: "    + (string)BAN_TIME);

		return TRUE;
		}

	// no command match found
	return FALSE;
	}

//
// States
//

//----------------------------------------------------------------------//
// state default - initialize script                                    //
//----------------------------------------------------------------------//
default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// initialize runtime constants
		list lstParcelDetails = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME, PARCEL_DETAILS_OWNER]);
		PARCEL_NAME      = llList2String(lstParcelDetails, 0);
		PARCEL_OWNER_KEY = llList2Key(lstParcelDetails, 1);
		OWNER_KEY        = llGetOwner();
//		CREATOR_KEY = llGetCreator(); // for debug instant messages

		// check owner matches parcel owner
		if (PARCEL_OWNER_KEY != OWNER_KEY)
			{
			llSay(0, "This security system is not owned by the parcel owner.");
			llSay(0, "This system will not function unless it is owned by the parcel owner.");
			return;
			}

		llSay(0, "Security initializing for " + PARCEL_NAME + "...");

		// config
		init_config();
		}

	changed(integer change)
		{
		if ((change & CHANGED_OWNER))
			llResetScript();
		}

	dataserver(key query_id, string data)
		{
		// finished reading config
		if (data == EOF)
			state inactive;

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
		}
	}

//----------------------------------------------------------------------//
// state inactive - security is not activated                           //
//----------------------------------------------------------------------//
state inactive
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// announce and start sensor and listen
		llSay(0, "Security ** INACTIVE ** for " + PARCEL_NAME + "...");
//		llSay(0, "Say '/" + (string)CHANNEL + "help' for instructions.");
		llSay(0, "Touch to for menu");
		llSensorRepeat( "", "", AGENT, SCAN_RANGE, SCAN_ARC, SCAN_RATE);
		listen_handle = llListen(CHANNEL, "", NULL_KEY, "");
		}

	touch_start(integer total_number) 
		{
		// present dialog menu
		if (llSameGroup(llDetectedKey(0)))
			llDialog(llDetectedKey(0),
				"Security System for " + PARCEL_NAME + "\n Status: ** INACTIVE **\n Memory: " + (string)llGetFreeMemory(),
				MENU_INACTIVE, CHANNEL);
		}

	no_sensor()
		{
		// expire visitor lists
		expire_lists();
		}

	sensor(integer number_detected)
		{
		// loop through detected avs
		integer i;
		for (i = 0; i < number_detected; i++)
			{
			// check or add agent on visitor list
			integer agent_index = check_visitor_list(i);
			}

		// expire visitor lists
		expire_lists();
		}

	listen (integer channel, string name, key id, string message)
		{
		// verify source of chat
		if (channel != CHANNEL || !llSameGroup(id))
			return;

		// convert message to lower case command
		string command = llToLower(message);

		// process command
		if (command == "activate")
			state active;
		else
			proc_command(id, command);
		}

	changed(integer change)
		{
		if (!(change & CHANGED_INVENTORY))
			return;

		// re-initialize config
		llSay(0, "Security reading changed config for " + PARCEL_NAME + " ...");
		llListenRemove(listen_handle);
		llSensorRemove();
		init_config();
		}

	dataserver(key query_id, string data)
		{
		// finished reading config
		if (data == EOF)
			{
			llSensorRepeat( "", "", AGENT, SCAN_RANGE, SCAN_ARC, SCAN_RATE);
			listen_handle = llListen(CHANNEL, "", NULL_KEY, "");
			return;
			}

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
		}
	}


//----------------------------------------------------------------------//
// state active - security is activated                                 //
//----------------------------------------------------------------------//
state active
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// announce and start sensor and listen
		llSay(0, "Security ** ACTIVE ** for " + PARCEL_NAME + " ...");
//		llSay(0, "Say '/" + (string)CHANNEL + "help' for instructions.");
		llSay(0, "Touch to for menu");
		llSensorRepeat( "", "", AGENT, SCAN_RANGE, SCAN_ARC, SCAN_RATE);
		listen_handle = llListen(CHANNEL, "", NULL_KEY, "");
		}

	touch_start(integer total_number) 
		{
		// present dialog menu
		if (llSameGroup(llDetectedKey(0)))
			llDialog(llDetectedKey(0), 
				"Security System for " + PARCEL_NAME + "\n Status: ** ACTIVE **\n Memory: " + (string)llGetFreeMemory(),
				MENU_ACTIVE, CHANNEL);
		}

	no_sensor()
		{
		// expire visitor lists
		expire_lists();
		}

	sensor(integer number_detected)
		{
		// loop through detected agents
		integer i;
		for (i = 0; i < number_detected; i++)
			{
			// find or add agent on visitor list
			integer agent_index = check_visitor_list(i);

			if (agent_index != -1)
				{
				// check agent
				check_visitor(agent_index);
				}
			}

		// expire visitor lists
		expire_lists();
		}

	listen (integer channel, string name, key id, string message)
		{
		// verify source of chat
		if (channel != CHANNEL || !llSameGroup(id))
			return;

		// convert message to lower case command
		string command = llToLower(message);

		// process command
		if (command == "deactivate")
			state inactive;
		else
			proc_command(id, command);
		}

	changed(integer change)
		{
		if (!(change & CHANGED_INVENTORY))
			return;

		// re-initialize config
		llSay(0, "Security reading changed config for " + PARCEL_NAME + " ...");
		llListenRemove(listen_handle);
		llSensorRemove();
		init_config();
		}

	dataserver(key query_id, string data)
		{
		// finished reading config
		if (data == EOF)
			{
			llSensorRepeat( "", "", AGENT, SCAN_RANGE, SCAN_ARC, SCAN_RATE);
			listen_handle = llListen(CHANNEL, "", NULL_KEY, "");
			return;
			}

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
		}
	}
