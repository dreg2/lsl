//----------------------------------------------------------------------//
// radio remote                                                         //
//----------------------------------------------------------------------//

//
// Constants
//

string  CONFIG_FILE_NAME = "stations";     // name of config file

integer DIALOG_CHANNEL;
integer REMOTE_CHANNEL = 62;

integer SETTER_PRESENT = FALSE;

//
// Globals
//

list station_name = [];
list station_url  = [];

list parcels      = [];

integer current_station = -1;

integer config_file_line;     // current line number
key     config_query_id;      // dataserver query id

//
// Functions
//

//----------------------------------------------------------------------//
// init_config - initialize config from config file                     //
//----------------------------------------------------------------------//
integer init_config()
	{
	// clear station lists
	station_url  = [];
	station_name = [];

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

	// look for separator
	integer sep_loc = llSubStringIndex(line, ",");
	if (sep_loc == -1)
		{
		llOwnerSay("Invalid station line, no comma found: \"" + line + "\"");
		return;
		}

	// save name and URL
	string name = llGetSubString(line, 0, sep_loc-1);
	string url  = llGetSubString(line, sep_loc+1, -1);

	// check for full list
	integer list_count = llGetListLength(station_name);
	if (list_count >= 12)
		{
		llOwnerSay("Over station limit of 12, cannot add \"" + name + "\"");
		return;
		}

	// check name length
	if (llStringLength(name) > 24)
		{
		llOwnerSay("Name must be less than 24 characters, cannot add \"" + name + "\"");
		return;
		}

	// check unique name
	if (llListFindList(station_name, [name]) >= 0)
		{
		llOwnerSay("Duplicate station name, cannot add: \"" + name + "\"");
		return;
		}

	// add to station list
	station_name = (station_name=[]) + station_name + [name];
	station_url  = (station_url=[])  + station_url  + [url];
	llOwnerSay("Added \"" + llList2String(station_name, list_count) + "\" using URL \"" + llList2String(station_url, list_count) + "\"");
	}

//----------------------------------------------------------------------//
// set_station - set parcel music station                               //
//----------------------------------------------------------------------//
set_station(string url, string name)
	{
	if (!SETTER_PRESENT)
		llRegionSay(REMOTE_CHANNEL, "R^STATION^" + url + "^" + name);
	else
		llMessageLinked(LINK_SET, 0, "R^STATION^" + url + "^" + name, NULL_KEY);
	}


//----------------------------------------------------------------------//
// find_station - find station matching name                            //
//----------------------------------------------------------------------//
integer find_station(string name)
	{
	integer station_index = llListFindList(station_name, [name]);
	if (station_index > -1)
		set_station(llList2String(station_url, station_index), llList2String(station_name, station_index));

	// no name match found
	return station_index;
	}

//
// States
//

default
	{
	on_rez(integer start_param)
		{
		if (!llGetAttached())
			llResetScript();
		}

	attach(key id)
		{
		llResetScript();
		}

	state_entry()
		{
		llMessageLinked(LINK_SET, 0, "R^HANDSHAKE", NULL_KEY); // let setter know we are here

		// initialize runtime constants
		DIALOG_CHANNEL = (((integer)llFrand(2147483647) + 1) * -1);

		// check for config notecard
		if (llGetInventoryType(CONFIG_FILE_NAME) != INVENTORY_NOTECARD)
			{
			llOwnerSay("Cannot find 'stations' notecard");
			return;
			}

		// config
		init_config();
		}

	touch_start(integer total_number)
		{
		if (SETTER_PRESENT && !llSameGroup(llDetectedKey(0)))
			return;

		// present dialog menu
		string current_name = llList2String(station_name, current_station);
		llDialog(llDetectedKey(0), llGetObjectName(), station_name, DIALOG_CHANNEL);
		}

	listen (integer channel, string name, key id, string message)
		{
		// dialog response
		if (channel == DIALOG_CHANNEL)
			{
			// process command
			find_station(message);
			return;
			}

		// network response
		if (channel == REMOTE_CHANNEL)
			{
			// parse response
			}
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		list command = llParseString2List(str, ["^"], []);

		if (llList2String(command, 0) == "S" && llList2String(command, 1) == "HANDSHAKE")
			SETTER_PRESENT = TRUE;
		}

	changed(integer change)
		{
		if (change & CHANGED_INVENTORY)
			llResetScript();
		}

	dataserver(key query_id, string data)
		{
		// finished reading config
		if (data == EOF)
			{
			llListen(DIALOG_CHANNEL, "", NULL_KEY, "");
			llOwnerSay(llGetObjectName() + " ready. Touch for menu.");
			return;
			}

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
		}

	}
