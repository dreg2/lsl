//------------------------------------------------------------------------//
//                                                                        //
// tip jar script                                                         //
//                                                                        //
//------------------------------------------------------------------------//

// Constants
vector  HOVER_TEXT_COLOR = <1.0, 1.0, 1.0>; // hover text color vector
float   OWNER_CUT        = 0.50;            // percentage of tip the owner keeps

integer LISTEN_CHANNEL;

// Fixed Constants
list OWNER_MENU_OPTIONS = ["List", "Logout", "Reset"];
list AGENT_MENU_OPTIONS = ["List", "Logout"];

// Globals
string  hover_text     = "";        // hover text

key     owner_key      = NULL_KEY;  // key of owner
key     logged_in_key  = NULL_KEY;  // key of logged in agent
string  logged_in_name = "";        // name of logged in agent

integer tip_amount     = 0;         // amount of tip
integer tip_total      = 0;         // total tips received

key     tipper_key     = NULL_KEY;  // agent key of tipper
list    tipper_name    = [];        // list of tipper names
list    tipper_total   = [];        // list of tipper amounts

key     query_id_key   = NULL_KEY;  // query id key for request agent data

//------------------------------------------------------------------------//
// default state                                                          //
//------------------------------------------------------------------------//
default
	{
	on_rez(integer start_param)
		{
		// reset script when rezzed
		llResetScript();
		}

	state_entry()
		{
		// ask owner for permission to debit
		owner_key = llGetOwner();
		llRequestPermissions(owner_key, PERMISSION_DEBIT);

		// generate random channel for menu
		LISTEN_CHANNEL = (integer)llFrand(50000 - 10000) + 10000;
		}

	touch_start(integer num_detected)
		{
		// if touched by owner get debit permission
		if (llDetectedKey(0) == owner_key)
			{
			llRequestPermissions(owner_key, PERMISSION_DEBIT);
			}
		}

	run_time_permissions(integer perm)
		{
		// go to not_logged_in state if permission granted
		if (PERMISSION_DEBIT & perm)
			{
			state not_logged_in;
			}
		else
			{
			hover_text = "Permission not granted";
			llSetText(hover_text, HOVER_TEXT_COLOR, 1);
			llOwnerSay("Tip jar has not been granted debit permission");
			}
		}
	}

//------------------------------------------------------------------------//
// no agent logged in state                                               //
//------------------------------------------------------------------------//
state not_logged_in
	{
	state_entry()
		{
		// initialize global variables
		tipper_name  = [];
		tipper_total = [];
		tip_total    = 0;

		// set hover text and announce readiness
		hover_text = "Not in use";
		llSetText(hover_text, HOVER_TEXT_COLOR, 1);
		llOwnerSay("Tip jar is inactive");
		}

	touch_start(integer num_detected)
		{
		// log in touching agent
		if (llDetectedGroup(0))
			{
			logged_in_key = llDetectedKey(0);
			state logged_in;
			}
		}
	}

//------------------------------------------------------------------------//
// agent logged in state                                                  //
//------------------------------------------------------------------------//
state logged_in
	{
	state_entry()
		{
		// initialize log in
		logged_in_name = llKey2Name(logged_in_key);

		// set hover text and announce readiness
		hover_text = logged_in_name + "'s tip jar";
		llSetText(hover_text, HOVER_TEXT_COLOR, 1);
		llOwnerSay("Tip jar is active for " + logged_in_name);

		// start listener for commands
		llListen(LISTEN_CHANNEL, "", NULL_KEY, "");
		}

	touch_start(integer num_detected)
		{
		// give dialog menu
		string menu_text = logged_in_name + "'s Tip Jar\n"
				+ "Memory: " + (string)llGetFreeMemory() + "\n"
				+ "Channel: " + (string)LISTEN_CHANNEL;
		if (llDetectedKey(0) == owner_key)
			 llDialog(llDetectedKey(0), menu_text, OWNER_MENU_OPTIONS, LISTEN_CHANNEL);
		else if (llDetectedKey(0) == logged_in_key)
			 llDialog(llDetectedKey(0), menu_text, AGENT_MENU_OPTIONS, LISTEN_CHANNEL);
		}

	listen(integer channel, string name, key id, string message)
		{
		// only get messages from logged-in agent, owner or myself
		if (id != logged_in_key && id != owner_key && id != llGetKey())
			return;

		string command = llToLower(message);

		// list all tippers and amounts
		if (command == "list")
			{
			integer list_length = llGetListLength(tipper_name);
			llInstantMessage(id, (string)list_length + " total tippers:");
			integer i;
			if (list_length > 0)
				{
				for (i = 0; i < list_length; i++)
					{
					llInstantMessage(id, llList2String(tipper_name, i) + ": $" + llList2String(tipper_total, i));
					}
				}
			llInstantMessage(id, "Total tips : $" + (string)tip_total);
			return;
			}

		// clear tippers list
		if (command == "clear")
			{
			tipper_name  = [];
			tipper_total = [];
			return;
			}

		// logout agent
		if (command == "logout")
			{
			logged_in_key = NULL_KEY;
			state not_logged_in;
			return;
			}

		// reset script
		if (command == "reset" && id == owner_key)
			{
			llResetScript();
			return;
			}
		}

	money(key id, integer amount)
		{
		tip_amount   = amount;    // save amount of tip
		tipper_key   = id;        // save tipper key
		query_id_key = llRequestAgentData(id, DATA_NAME); // request agent data for tipper
		}

	dataserver(key queryid, string data)
		{
		if (query_id_key != queryid)
			return;  // query isn't ours

		// add tip to total
		tip_total += tip_amount;

		// add new tipper to list or update dup tipper total
		integer tipper_total_tmp = 0; // save tipper total
		integer tipperIndex = llListFindList(tipper_name, [data]);
		if (tipperIndex >= 0)
			{
			tipper_total_tmp = llList2Integer(tipper_total, tipperIndex) + tip_amount;
			tipper_total     = llListReplaceList(tipper_total, [tipper_total_tmp], tipperIndex, tipperIndex);
			}
		else
			{
			tipper_total_tmp = tip_amount;
			tipper_name      = (tipper_name=[])  + tipper_name  + [data];
			tipper_total     = (tipper_total=[]) + tipper_total + [tip_amount];
			}

		// pay logged-in agent
		if (OWNER_CUT < 1.0)
			{
			integer logged_in_cut = (integer)((float)tip_amount - ((float)tip_amount * OWNER_CUT));
			if (logged_in_cut > 0)
				{
				llGiveMoney(logged_in_key, logged_in_cut);
				}
			}

		// update hover text, notify tipper and agent
		hover_text = logged_in_name + "'s tip jar\n"
				+ "Last Tip: $" + (string)tip_amount + "\n"
				+ "Total tips: $" + (string)tip_total;
		llSetText(hover_text, HOVER_TEXT_COLOR, 1);
		llInstantMessage(logged_in_key, data + " tipped $" + (string)tip_amount
				+ " for a total of $" + (string)tipper_total_tmp
				+ ".  Your total tips so far are $" + (string)tip_total);
		llInstantMessage(tipper_key, logged_in_name + " thanks you for the tip, " + llGetSubString(data, 0, llSubStringIndex(data, " ")));
		}
	}

