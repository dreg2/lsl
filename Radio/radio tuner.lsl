//----------------------------------------------------------------------//
// radio tuner                                                          //
//----------------------------------------------------------------------//

// Constants
vector  TEXT_COLOR = <1.0, 1.0, 1.0>;
vector  ERROR_TEXT_COLOR = <1.0, 0.0, 0.0>;
float   TEXT_ALPHA = 1.0;
string  CONFIG_FILE_NAME = "stations";     // name of config file
integer REMOTE_CHANNEL = 62;

// Runtime Constants
integer DIALOG_CHANNEL;
integer SETTER_PRESENT = FALSE;
string  BUTTON_PREV = "< Prev";
string  BUTTON_HOME = "> Home <";
string  BUTTON_NEXT = "Next >";

// Globals
list station_name = [];
list station_url  = [];
integer list_head = 0;
integer list_max  = 0;
list dialog_buttons = [BUTTON_PREV, BUTTON_HOME, BUTTON_NEXT];

key current_agent;
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
		llSay(0, "Invalid station line, no comma found: \"" + line + "\"");
		return;
		}

	// save name and URL
	string name = llGetSubString(line, 0, sep_loc-1);
	string url  = llGetSubString(line, sep_loc+1, -1);

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
	list_max = llGetListLength(station_name);
	llSay(0, "Added \"" + llList2String(station_name, list_max-1) + "\" using URL \"" + llList2String(station_url, list_max-1) + "\"");
	}

//----------------------------------------------------------------------//
// set_hover_text - set object hover text                               //
//----------------------------------------------------------------------//
set_hover_text(string text)
	{
	string hover_text = llGetObjectName() + "\nNow playing" + "\n" + text;
	llSetText(hover_text, TEXT_COLOR, TEXT_ALPHA);
	}

//----------------------------------------------------------------------//
// set_station - set parcel music station                               //
//----------------------------------------------------------------------//
set_station(string url, string name)
	{
	if (!SETTER_PRESENT)
		llRegionSay(REMOTE_CHANNEL, "T^STATION^" + url + "^" + name);
	else
		llMessageLinked(LINK_SET, 0, "T^STATION^" + url + "^" + name, NULL_KEY);
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


//----------------------------------------------------------------------//
// create_dialog - create dialog array                                  //
//----------------------------------------------------------------------//
create_dialog()
	{
	integer station_index = list_head;
	integer i;

	dialog_buttons = [BUTTON_PREV, BUTTON_HOME, BUTTON_NEXT];

	for (i = 0; i < 9; i++)
		{
		dialog_buttons = dialog_buttons + [llList2String(station_name, station_index)];
		station_index++;
		if (station_index >= list_max)
			return;
		}

	return;
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
		// initialize runtime constants
		DIALOG_CHANNEL = (((integer)llFrand(2147483647) + 1) * -1);

		// check for config notecard
		if (llGetInventoryType(CONFIG_FILE_NAME) != INVENTORY_NOTECARD)
			{
			llSay(0, "Cannot find '" + CONFIG_FILE_NAME + "' notecard");
			return;
			}

		// config
		init_config();
		}

	touch_start(integer total_number)
		{
		current_agent = llDetectedKey(0);

		if (SETTER_PRESENT && !llSameGroup(current_agent))
			return;

		// present dialog menu
		string current_name = llList2String(station_name, current_station);
		create_dialog();
		llDialog(current_agent, llGetObjectName(), dialog_buttons, DIALOG_CHANNEL);
		}

	listen (integer channel, string name, key id, string message)
		{
		if (channel == DIALOG_CHANNEL)
			{
			if (message == BUTTON_PREV)
				{
				// prev button pressed
				list_head = list_head - 9;
				if (list_head < 0)
					list_head = 0;
				create_dialog();
				llDialog(current_agent, llGetObjectName(), dialog_buttons, DIALOG_CHANNEL);
				}
			else if (message == BUTTON_HOME)
				{
				// home button pressed
				list_head = 0;
				create_dialog();
				llDialog(current_agent, llGetObjectName(), dialog_buttons, DIALOG_CHANNEL);
				}
			else if (message == BUTTON_NEXT)
				{
				// next button pressed
				list_head = list_head + 9;
				if (list_head >= list_max)
					list_head = 0;
				create_dialog();
				llDialog(current_agent, llGetObjectName(), dialog_buttons, DIALOG_CHANNEL);
				}
			else
				// station button pressed
				find_station(message);
			}

		else if (channel == REMOTE_CHANNEL)
			{
			list command = llParseString2List(message, ["^"], []);

			if (llList2String(command, 0) == "S" && llList2String(command, 1) == "STATION")
				set_hover_text(llList2String(command, 2));
			}
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		list command = llParseString2List(str, ["^"], []);

		if (llList2String(command, 0) == "S")
			SETTER_PRESENT = TRUE;

		if (llList2String(command, 0) == "S" && llList2String(command, 1) == "STATION")
			set_hover_text(llList2String(command, 2));
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
			llListen(REMOTE_CHANNEL, "", NULL_KEY, "");
			llMessageLinked(LINK_SET, 0, "T^HANDSHAKE", NULL_KEY); // let setter know we are here
			llRegionSay(REMOTE_CHANNEL, "T^HANDSHAKE");
			llSay(0, llGetObjectName() + " ready. Touch for menu.");
			return;
			}

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(CONFIG_FILE_NAME, config_file_line);
		}
	}
