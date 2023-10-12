//----------------------------------------------------------------------//
// security system - check module                                       //
//    by Dreg2 Rossini                                                  //
//----------------------------------------------------------------------//
string VERSION = "1.00";

//
// Constants
//

// system constants
string  MODULE_NAME  = "Check";
integer BCST_MSG_ID  = -1;  // Link message ID for broadcasts
integer MAIN_MSG_ID  = 0;   // Link message ID for main module
integer SCAN_MSG_ID  = 1;   // Link message ID for scan module
integer VL_MSG_ID    = 2;   // Link message ID for visitor list module
integer CHECK_MSG_ID = 3;   // Link message ID for check module
integer CONF_MSG_ID  = 4;   // Link message ID for config module

// default config options
integer DEFAULT_WARN_TYPE      = 1;       // warn type, 0 = none, 1 = dialog, 2 = IM
integer DEFAULT_WARN_TIME      = 15;      // in seconds
integer DEFAULT_EJECT_TYPE     = 1;       // eject type 0 = none, 1 = eject, 2 = teleport home
integer DEFAULT_BAN_FLAG       = TRUE;    // ban flag
float   DEFAULT_BAN_TIME       = 4.0;     // in hours 0.0 = permanent
integer DEFAULT_ALLOW_GROUP    = FALSE;   // allow group members
list    DEFAULT_ALLOWED_AGENTS = [];

integer CHANNEL = -55555; // dummy channel for llDialog

// Fixed constants

// visitor status values
integer NONE    = 0;
integer ALLOWED = 1;
integer WARNED  = 2;
integer EJECTED = 3;
integer LEFT    = 4;

// Runtime constants

// config options
integer WARN_TYPE      = DEFAULT_WARN_TYPE;
integer WARN_TIME      = DEFAULT_WARN_TIME;
integer EJECT_TYPE     = DEFAULT_EJECT_TYPE;
integer BAN_FLAG       = DEFAULT_BAN_FLAG;
float   BAN_TIME       = DEFAULT_BAN_TIME;
integer ALLOW_GROUP    = DEFAULT_ALLOW_GROUP;
list    ALLOWED_AGENTS = DEFAULT_ALLOWED_AGENTS;

string PARCEL_NAME;       // name of parcel
key    PARCEL_OWNER_KEY;  // key of parcel owner
key    OWNER_KEY;         // key of object owner

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
		string command = llStringTrim(llList2String(message, 0), STRING_TRIM);
		list   args    = llList2List(message, 1, -1);

		if (command == "reset")
			llResetScript();

		else if (command == "status")
			llSay(0, MODULE_NAME + " (" + (string)llGetFreeMemory() + "): " + module_status);

		else if (command == "allowed")
			{
			integer list_length = llGetListLength(ALLOWED_AGENTS);
			integer index;
			llSay(0, MODULE_NAME + " (" + (string)llGetFreeMemory() + "): Allowed Agents");
			for (index = 0; index < list_length; index++)
				llSay(0, llList2String(ALLOWED_AGENTS, index));
			}

		else if (command == "init")
			ALLOWED_AGENTS = [];

		else if (command == "config")
			set_config(args);

		else if (command == "activate" && (PARCEL_OWNER_KEY == OWNER_KEY))
			{
			module_status = "active";
			llSay(0, MODULE_NAME + " (" + (string)llGetFreeMemory() + "): " + module_status);
			}

		else if (command == "deactivate")
			{
			module_status = "inactive";
			llSay(0, MODULE_NAME + " (" + (string)llGetFreeMemory() + "): " + module_status);
			}

		else if (command == "check")
			{
			if (module_status == "active")
				check_visitor(args);
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
		llSay(0, "Warn Type: "   + (string)WARN_TYPE);
		llSay(0, "Warn Time: "   + (string)WARN_TIME);
		llSay(0, "Eject Type: "  + (string)EJECT_TYPE);
		llSay(0, "Ban Flag: "    + (string)BAN_FLAG);
		llSay(0, "Ban Time: "    + (string)BAN_TIME);
		return;
		}

	else if (keyword == "DEFAULT")
		{
		WARN_TYPE      = DEFAULT_WARN_TYPE;
		WARN_TIME      = DEFAULT_WARN_TIME;
		EJECT_TYPE     = DEFAULT_EJECT_TYPE;
		BAN_FLAG       = DEFAULT_BAN_FLAG;
		BAN_TIME       = DEFAULT_BAN_TIME;
		ALLOWED_AGENTS = DEFAULT_ALLOWED_AGENTS;
		}

	else if (keyword == "WARN_TYPE")
		{
		if (value == "NONE")
			WARN_TYPE      = 0;
		else if (value == "DIALOG")
			WARN_TYPE      = 1;
		else if (value == "IM")
			WARN_TYPE      = 2;
		else
			WARN_TYPE      = (integer)value;

		llSay(0, "Warn type set to " + (string)WARN_TYPE);
		}

	else if (keyword == "WARN_TIME")
		{
		WARN_TIME      = (integer)value;
		llSay(0, "Warn time set to " + (string)WARN_TIME);
		}

	else if (keyword == "EJECT_TYPE")
		{
		if (value == "NONE")
			EJECT_TYPE     = 0;
		else if (value == "EJECT")
			EJECT_TYPE     = 1;
		else if (value == "TP" || value == "TELEPORT")
			EJECT_TYPE     = 2;
		else
			EJECT_TYPE     = (integer)value;

		llSay(0, "Eject type set to " + (string)EJECT_TYPE);
		}

	else if (keyword == "BAN_FLAG")
		{
		if (value == "TRUE" || value == "YES" || value == "ON")
			BAN_FLAG       = 1;
		else if (value == "FALSE" || value == "NO" || value == "OFF")
			BAN_FLAG       = 0;
		else
			BAN_FLAG       = (integer)value;
		llSay(0, "Ban flag set to " + (string)BAN_FLAG);
		}

	else if (keyword == "BAN_TIME")
		{
		BAN_TIME       = (float)value;
		llSay(0, "Ban time set to " + (string)BAN_TIME);
		}

	else if (keyword == "ALLOW_GROUP")
		{
		if (value == "TRUE" || value == "YES" || value == "ON")
			ALLOW_GROUP       = 1;
		else if (value == "FALSE" || value == "NO" || value == "OFF")
			ALLOW_GROUP       = 0;
		else
			ALLOW_GROUP       = (integer)value;
		llSay(0, "Allow group flag set to " + (string)ALLOW_GROUP);
		}

	else if (keyword == "ALLOWED_AGENT")
		{
		ALLOWED_AGENTS = (ALLOWED_AGENTS=[]) + ALLOWED_AGENTS + llList2String(config, 1);
		llSay(0, "Agent added: " + llList2String(ALLOWED_AGENTS, llGetListLength(ALLOWED_AGENTS)-1));
		}
	}

//----------------------------------------------------------------------//
// check_visitor - check visitor and allow or eject                     //
//----------------------------------------------------------------------//
integer check_visitor(list args)
	{
	key     agent_key      = llList2Key(args, 0);
	string  agent_name     = llList2String(args, 1);
	integer agent_status   = llList2Integer(args, 2);
	integer agent_warntime = llList2Integer(args, 3);

	integer curr_time = llGetUnixTime();

	// check allowed list and group
	if (llListFindList(ALLOWED_AGENTS, [agent_name]) > -1 || (ALLOW_GROUP == TRUE && llSameGroup(agent_key)))
		{
		//  update visitor list
		llMessageLinked(LINK_SET, VL_MSG_ID, "update"
			+ "^" + (string)agent_key
			+ "^" + (string)ALLOWED
			+ "^" + (string)0
			, NULL_KEY);

		return 1;
		}

	// not allowed, warn
	if (agent_status != WARNED)
		{
		agent_status = WARNED;
		agent_warntime = curr_time;
		string warning = "\n***** Warning *****"
					+ "\n\tYou are on a private parcel"
					+ "\n\tYou have " + (string)WARN_TIME + " seconds to leave " + PARCEL_NAME;
		if (WARN_TYPE == 1)
			llDialog(agent_key, warning, [], CHANNEL);
		else if (WARN_TYPE == 2)
			llInstantMessage(agent_key, warning);
		}

	// eject when past warn time
	if ((agent_warntime > 0) && ((curr_time - agent_warntime) > WARN_TIME))
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
		agent_status = EJECTED;
		}

	//  update visitor list
	llMessageLinked(LINK_SET, VL_MSG_ID, "update"
		+ "^" + (string)agent_key
		+ "^" + (string)agent_status
		+ "^" + (string)agent_warntime
		, NULL_KEY);

	return -1;
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
		module_status = "inactive";

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
		}

	changed(integer change)
		{
		if ((change & CHANGED_OWNER))
			state default;
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		if (num != CHECK_MSG_ID && num != BCST_MSG_ID)
			return;

		handle_message(str);
		}

	}
