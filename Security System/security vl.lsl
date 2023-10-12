//----------------------------------------------------------------------//
// security system - visitor list module                                //
//    by Dreg2 Rossini                                                  //
//----------------------------------------------------------------------//
string VERSION = "1.00";

//
// Constants
//

// system constants
string  MODULE_NAME  = "Vistor List";
integer BCST_MSG_ID  = -1;  // Link message ID for broadcasts
integer MAIN_MSG_ID  = 0;   // Link message ID for main module
integer SCAN_MSG_ID  = 1;   // Link message ID for scan module
integer VL_MSG_ID    = 2;   // Link message ID for visitor list module
integer CHECK_MSG_ID = 3;   // Link message ID for check module
integer CONF_MSG_ID  = 4;   // Link message ID for config module

// default config options
integer DEFAULT_LIST_TIME      = 0;       // time limit on visitors list in seconds units, 0 - indefinite
float   EXPIRE_RATE            = 60.0;    // in seconds

// Fixed constants

// visitor status values
integer NONE    = 0;
integer ALLOWED = 1;
integer WARNED  = 2;
integer EJECTED = 3;
integer LEFT    = 4;

// runtime constants
//key    CREATOR_KEY; // for debug instant messages

// config options
integer LIST_TIME      = DEFAULT_LIST_TIME;

//
// Global variables
//

string module_status;

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
			set_config(args);

		else if (command == "activate")
			module_status = "active";

		else if (command == "deactivate")
			module_status = "inactive";

		else if (command == "visitors")
			print_list();

		else if (module_status == "active")
			{
			if (command == "found")
				found_agent(args);

			else if (command == "update")
				update_agent(args);

			else if (command == "lost")
				lost_agent(args);
			}

		}

//----------------------------------------------------------------------//
// set_config - set config parameter                                    //
//----------------------------------------------------------------------//
set_config(list config)
	{
	string keyword = llList2String(config, 0);
	string value   = llList2String(config, 1);

	if (keyword == "LIST")
		{
		llSay(0, "List Time: "  + (string)LIST_TIME);
		return;
		}

	else if (keyword == "DEFAULT")
		{
		LIST_TIME = DEFAULT_LIST_TIME;
		}

	else if (keyword == "LIST_TIME")
		{
		string units  = llToUpper(llGetSubString(value, -1, -1));
		string number = llGetSubString(value, 0, -2);

		if (units == "D")
			LIST_TIME = (integer)number * 86400;
		else if (units == "H")
			LIST_TIME = (integer)number * 3600;
		else if (units == "M")
			LIST_TIME = (integer)number * 60;
		else
			LIST_TIME = (integer)value;

		llSay(0, "List time set to " + (string)LIST_TIME);
		}

	}

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
// found_agent - add visitor to list                                    //
//----------------------------------------------------------------------//
found_agent(list args)
	{
	key     agent_key      = llList2Key(args, 0);
	string  agent_name     = llList2String(args, 1);

	// check if agent is already on the list
	integer agent_index = llListFindList(visitor_key, [agent_key]);

	// add agent if not on the list
	if (agent_index == -1)
		{
		// add agent to the list
		visitor_key     = (visitor_key=[])     + visitor_key     + [agent_key];
		visitor_name    = (visitor_name=[])    + visitor_name    + [agent_name];
		visitor_status  = (visitor_status=[])  + visitor_status  + [NONE];
		visitor_wrntime = (visitor_wrntime=[]) + visitor_wrntime + [0];
		visitor_chktime = (visitor_chktime=[]) + visitor_chktime + [llGetTimestamp()];
		visitor_unxtime = (visitor_unxtime=[]) + visitor_unxtime + [llGetUnixTime()];
		agent_index = llGetListLength(visitor_key) - 1;
		}
	else
		{
		// update timestamps
		visitor_chktime = llListReplaceList(visitor_chktime, [llGetTimestamp()], agent_index, agent_index);
		visitor_unxtime = llListReplaceList(visitor_unxtime, [llGetUnixTime()],  agent_index, agent_index);
		}

	// Send data to check module
	llMessageLinked(LINK_SET, CHECK_MSG_ID, "check"
		+ "^" + (string)agent_key
		+ "^" + agent_name
		+ "^" + llList2String(visitor_status, agent_index)
		+ "^" + llList2String(visitor_wrntime, agent_index)
		, NULL_KEY);
	}

//----------------------------------------------------------------------//
// update_agent - update agent info                                     //
//----------------------------------------------------------------------//
update_agent(list args)
	{
	key     agent_key      = llList2Key(args, 0);
	integer agent_status   = llList2Integer(args, 1);
	integer agent_wrntime  = llList2Integer(args, 2);

	// find agent on list
	integer agent_index = llListFindList(visitor_key, [agent_key]);

	if (agent_index > -1)
		{
		visitor_status  = llListReplaceList(visitor_status,  [agent_status], agent_index, agent_index);
		visitor_wrntime = llListReplaceList(visitor_wrntime, [agent_wrntime], agent_index, agent_index);
		visitor_chktime = llListReplaceList(visitor_chktime, [llGetTimestamp()], agent_index, agent_index);
		visitor_unxtime = llListReplaceList(visitor_unxtime, [llGetUnixTime()], agent_index, agent_index);
		}
	}

//----------------------------------------------------------------------//
// lost_agent - change agent status to left                             //
//----------------------------------------------------------------------//
lost_agent(list args)
	{
	key     agent_key      = llList2Key(args, 0);

	// find agent on list
	integer agent_index = llListFindList(visitor_key, [agent_key]);

	if (agent_index > -1)
		{
		// if agent warned changed to left
		if (llList2Integer(visitor_status, agent_index) == WARNED)
			visitor_status  = llListReplaceList(visitor_status, [LEFT], agent_index, agent_index);
		}
	}

//----------------------------------------------------------------------//
// print_list - print out visitor list                                  //
//----------------------------------------------------------------------//
print_list()
	{
	llSay(0, "Visitor List:");
	integer len = llGetListLength(visitor_key);
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
			status = "Warned and Left";
		else
			status = "Not checked";

		llSay(0, format_timestamp(llList2String(visitor_chktime, i)) + " " + llList2String(visitor_name, i) + ": " + status);
		}

	llSay(0, "Total visitors: " + (string)len ); 
	}

//----------------------------------------------------------------------//
// expire_list - expire visitors list                                   //
//----------------------------------------------------------------------//
expire_list()
	{
	integer index;
	integer list_length = llGetListLength(visitor_key);
	integer curr_time = llGetUnixTime();

	// loop backwards through the lists to keep index correct
	for (index = list_length - 1; index >= 0; index--)
		{
		// purge visitor from list if older than LIST_TIME
		if (((curr_time - llList2Integer(visitor_unxtime, index)) > LIST_TIME) && LIST_TIME)
			{
			// delete from list
			visitor_key     = llDeleteSubList(visitor_key, index, index);
			visitor_name    = llDeleteSubList(visitor_name, index, index);
			visitor_status  = llDeleteSubList(visitor_status, index, index);
			visitor_wrntime = llDeleteSubList(visitor_wrntime, index, index);
			visitor_chktime = llDeleteSubList(visitor_chktime, index, index);
			visitor_unxtime = llDeleteSubList(visitor_unxtime, index, index);
			}
		}
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
//		CREATOR_KEY = llGetCreator(); // for debug instant messages
		llSetTimerEvent(EXPIRE_RATE);
		}

	timer()
		{
		expire_list();
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		if (num != VL_MSG_ID && num != BCST_MSG_ID)
			return;

		handle_message(str);
		}
	}
