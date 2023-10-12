//----------------------------------------------------------------------//
// radio tuner                                                          //
//----------------------------------------------------------------------//

//
// Constants
//

string  CONFIG_FILE_NAME = "stations";     // name of config file
vector  TEXT_COLOR = <1.0, 1.0, 1.0>;
vector  ERROR_TEXT_COLOR = <1.0, 0.0, 0.0>;
float   TEXT_ALPHA = 1.0;

integer CHANNEL;
string  PARCEL_NAME;
key     PARCEL_OWNER_KEY;
key     OWNER_KEY;

//
// Globals
//

list station_name = [];
list station_url  = [];

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

	// look for colon separator
	integer sep_loc = llSubStringIndex(line, ",");
	if (sep_loc == -1)
		{
		llSay(0, "Invalid station line, no comma found: \"" + line + "\"");
		return;
		}

	// save name and URL
	string name = llGetSubString(line, 0, sep_loc-1);
	string url  = llGetSubString(line, sep_loc+1, -1);

	// check for full list
	integer list_count = llGetListLength(station_name);
	if (list_count >= 12)
		{
		llSay(0, "Over station limit of 12, cannot add \"" + name + "\"");
		return;
		}

	// check name length
	if (llStringLength(name) > 24)
		{
		llSay(0, "Name must be less than 24 characters, cannot add \"" + name + "\"");
		return;
		}

	// check unique name
	if (llListFindList(station_name, [name]) >= 0)
		{
		llSay(0, "Duplicate station name, cannot add: \"" + name + "\"");
		return;
		}

	// add to station list
	station_name = (station_name=[]) + station_name + [name];
	station_url  = (station_url=[])  + station_url  + [url];
	llSay(0, "Added \"" + llList2String(station_name, list_count) + "\" using URL \"" + llList2String(station_url, list_count) + "\"");
	}


//----------------------------------------------------------------------//
// proc_command - process command                                       //
//----------------------------------------------------------------------//
integer proc_command(string command)
	{
	integer station_index = llListFindList(station_name, [command]);
	if (station_index > -1)
		{
		llSay(0, "Station set to " + llList2String(station_name, station_index));
		llSetParcelMusicURL(llList2String(station_url, station_index));
		set_hover_text(llList2String(station_name, station_index));
		}

	// no command match found
	return station_index;
	}

//----------------------------------------------------------------------//
// set_hover_text - set object hover text                               //
//----------------------------------------------------------------------//
set_hover_text(string text)
	{
	string hover_text = llGetObjectName() + "\nNow playing" + "\n" + text;
	llSetText(hover_text, TEXT_COLOR, TEXT_ALPHA);
	}

//
// States
//

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
		CHANNEL = (((integer)llFrand(2147483647) + 1) * -1);

		llSay(0, "Radio initializing for " + PARCEL_NAME + "...");
		llSetText(llGetObjectName() + " initializing....", TEXT_COLOR, TEXT_ALPHA);

		// check owner matches parcel owner
		if (PARCEL_OWNER_KEY != OWNER_KEY)
			{
			llSetText(llGetObjectName() + " must be owned by\nthe parcel owner to function", ERROR_TEXT_COLOR, TEXT_ALPHA);
			llSay(0, "This radio system is not owned by the parcel owner.");
			llSay(0, "This radio will not function unless it is owned by the parcel owner.");
			return;
			}

		// check for config notecard
		if (llGetInventoryType(CONFIG_FILE_NAME) != INVENTORY_NOTECARD)
			{
			llSetText(llGetObjectName() + " does not have 'stations' notecard", ERROR_TEXT_COLOR, TEXT_ALPHA);
			llSay(0, "Cannot find 'stations' notecard");
			return;
			}

		// config
		init_config();
		}

	touch_start(integer total_number)
		{
		// present dialog menu
		string current_name = llList2String(station_name, current_station);
		if (llSameGroup(llDetectedKey(0)))
			llDialog(llDetectedKey(0), llGetObjectName() + " for " + PARCEL_NAME
						+ "\nCurrently playing " + llList2String(station_name, current_station),
						station_name, CHANNEL);
		}

	listen (integer channel, string name, key id, string message)
		{
		// verify source of chat
		if (!llSameGroup(id))
			return;

		// process command
		current_station = proc_command(message);
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
			llListen(CHANNEL, "", NULL_KEY, "");
			llSay(0, "Radio ready for " + PARCEL_NAME + ". Touch for menu.");
			llSetText(llGetObjectName() + " ready\nTouch for menu", TEXT_COLOR, TEXT_ALPHA);
			return;
			}

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
		}

	}
