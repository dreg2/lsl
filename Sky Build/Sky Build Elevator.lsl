//----------------------------------------------------------------------//
// Sky Build - Elevator                                                 //
//----------------------------------------------------------------------//

// Constants
vector SIT_TARGET_VEC = <0.30, 0.00, 0.60>;
vector SIT_TARGET_ROT = <0.00, 0.00, 0.00>;

vector  TEXT_COLOR = <1.0, 1.0, 1.0>;
float   TEXT_ALPHA = 1.0;

vector  REZ_OFFSET = <0.0, 0.0, -0.5>;
integer AWAY_TIME  = 600;

// Run time constants
integer COMM_CHANNEL;
integer MENU_MAIN_CHANNEL;
integer MENU_ALT_CHANNEL;
integer MENU_BLD_CHANNEL;
vector  HOME_POS;

// globals
float   target_altitude;
string  target_build;
key     agent;
integer build_rezzed;

// Dialog Menus
string MENU_ALL_HOME    = "Go Home";
string MENU_ALL_MAIN    = "Main Menu";
string MENU_ALL_PREV    = "< PREV";
string MENU_ALL_NEXT    = "NEXT >";

// main menu
string MENU_MAIN_DES = "Main Menu";
string MENU_MAIN_ALT = "Altitude";
string MENU_MAIN_BLD = "Build";
list   MENU_MAIN     = [MENU_ALL_HOME, MENU_MAIN_ALT, MENU_MAIN_BLD];

// altitude menu
string  MENU_ALT_DES = "Select Altitude Menu";
list    MENU_ALT_LST = ["100", "200", "300", "400", "500", "600", "700", "800", "900", "1000",
			"1500", "2000", "2500", "3000", "3500", "4000"];
list    MENU_ALT     = [];
integer MENU_ALT_COUNT;
integer MENU_ALT_PAGE_MAX;
integer menu_alt_page = 0;

// build menu
string  MENU_BLD_DES = "Select Build Menu";
list    MENU_BLD     = [];
integer MENU_BLD_COUNT;
integer MENU_BLD_PAGE_MAX;
integer menu_bld_page = 0;

//----------------------------------------------------------------------//
// disp_alt_menu - display the altitude menu                            //
//----------------------------------------------------------------------//
disp_alt_menu()
	{
	// clear menu
	MENU_ALT = [];

	// check index bounds
	if (menu_alt_page > MENU_ALT_PAGE_MAX)
		menu_alt_page = 0;
	else if (menu_alt_page < 0)
		menu_alt_page = MENU_ALT_PAGE_MAX;

	// set up loop
	integer start_index = menu_alt_page * 9;
	integer end_index   = start_index + 9;
	if (end_index > MENU_ALT_COUNT)
		end_index = MENU_ALT_COUNT;

	// load dialog menu entries
	integer index;
	for (index = start_index; index < end_index; index++)
		{
		MENU_ALT = (MENU_ALT=[]) + MENU_ALT + [llList2String(MENU_ALT_LST, index)];
		}

	// add bottom buttons and display
	MENU_ALT = [MENU_ALL_PREV, MENU_ALL_MAIN, MENU_ALL_NEXT] + MENU_ALT;
	llDialog(agent, MENU_ALT_DES + ": " + (string)(menu_alt_page+1), MENU_ALT, MENU_ALT_CHANNEL);
	}

//----------------------------------------------------------------------//
// proc_alt_menu - process altitude menu button press                   //
//----------------------------------------------------------------------//
float proc_alt_menu(string message)
	{
	if (message == MENU_ALL_PREV)
		{
		// previous button
		menu_alt_page--;
		disp_alt_menu();
		return -1.0;
		}

	else if (message == MENU_ALL_NEXT)
		{
		// next button
		menu_alt_page++;
		disp_alt_menu();
		return -1.0;
		}

	else if (llListFindList(MENU_ALT, [message]) >= 0)
		{
		// altitude button
		return (float)message;
		}

	return -1;
	}

//----------------------------------------------------------------------//
// disp_bld_menu - display the build menu                               //
//----------------------------------------------------------------------//
disp_bld_menu()
	{
	// clear menu
	MENU_BLD = [];

	// check index bounds
	if (menu_bld_page > MENU_BLD_PAGE_MAX)
		menu_bld_page = 0;
	else if (menu_bld_page < 0)
		menu_bld_page = MENU_BLD_PAGE_MAX;

	// set up loop
	integer start_index = menu_bld_page * 9;
	integer end_index   = start_index + 9;
	if (end_index > MENU_BLD_COUNT)
		end_index = MENU_BLD_COUNT;

	// load dialog menu entries
	integer index;
	for (index = start_index; index < end_index; index++)
		{
		MENU_BLD = (MENU_BLD=[]) + MENU_BLD + [llGetInventoryName(INVENTORY_OBJECT, index)];
		}

	// add bottom buttons and display
	MENU_BLD = [MENU_ALL_PREV, MENU_ALL_MAIN, MENU_ALL_NEXT] + MENU_BLD;
	llDialog(agent, MENU_BLD_DES + ": " + (string)(menu_bld_page+1), MENU_BLD, MENU_BLD_CHANNEL);
	}

//----------------------------------------------------------------------//
// proc_bld_menu - process build menu button press                      //
//----------------------------------------------------------------------//
string proc_bld_menu(string message)
	{
	if (message == MENU_ALL_PREV)
		{
		// previous button
		menu_bld_page--;
		disp_bld_menu();
		return "";
		}

	else if (message == MENU_ALL_NEXT)
		{
		// next button
		menu_bld_page++;
		disp_bld_menu();
		return "";
		}

	else if (llListFindList(MENU_BLD, [message]) >= 0)
		{
		// build button
		return message;
		}

	return "";
	}

//----------------------------------------------------------------------//
// go_to - go to target position                                        //
//----------------------------------------------------------------------//
go_to(vector target_pos)
	{
	// call warpPos until target reached
	while (llVecDist(target_pos, llGetPos()) > 0.1)
		warpPos(target_pos);
	}

//----------------------------------------------------------------------//
// warpPos                                                              //
//----------------------------------------------------------------------//
warpPos(vector destpos)
	{
	float   MAX_MOVE_DIST     = 10.0;
	integer MAX_WARPPOS_JUMPS = 100;

	//R&D by Keknehv Psaltery, 05/25/2006
	//with a little pokeing by Strife, and a bit more
	//some more munging by Talarus Luan
	//Final cleanup by Keknehv Psaltery

	// Compute the number of jumps necessary
	integer jumps = (integer)(llVecDist(destpos, llGetPos()) / MAX_MOVE_DIST) + 1;

	// Try and avoid stack/heap collisions
	if (jumps > MAX_WARPPOS_JUMPS)
		jumps = MAX_WARPPOS_JUMPS;    //  1km should be plenty

	list rules = [PRIM_POSITION, destpos];  //The start for the rules list
	integer count = 1;
	while ((count = count << 1) < jumps)
		rules = (rules=[]) + rules + rules;   //should tighten memory use.

	llSetPrimitiveParams(rules + llList2List(rules, (count - jumps) << 1, count));
	}

//----------------------------------------------------------------------//
// state default - initialize                                           //
//----------------------------------------------------------------------//
default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("default", TEXT_COLOR, TEXT_ALPHA);

		// initialize run-time constants
		COMM_CHANNEL      = (((integer)llFrand(2147483637) + 1) * -1);
		MENU_MAIN_CHANNEL = COMM_CHANNEL - 1;
		MENU_ALT_CHANNEL  = COMM_CHANNEL - 2;
		MENU_BLD_CHANNEL  = COMM_CHANNEL - 3;
		HOME_POS = llGetPos();

		// initialize globals
		menu_alt_page = 0;
		menu_bld_page = 0;

		// set prim params
		llSitTarget(SIT_TARGET_VEC, llEuler2Rot(SIT_TARGET_ROT * DEG_TO_RAD));

		// set up params for altitude menu
		MENU_ALT_COUNT = llGetListLength(MENU_ALT_LST);
		MENU_ALT_PAGE_MAX = MENU_ALT_COUNT / 9;

		// set up params for build menu
		MENU_BLD_COUNT = llGetInventoryNumber(INVENTORY_OBJECT);
		MENU_BLD_PAGE_MAX = MENU_BLD_COUNT / 9;
		}

	changed(integer change)
		{
		HOME_POS = llGetPos();
		if (change & CHANGED_LINK)
			{
			// agent sit
			agent = llAvatarOnSitTarget();
			if (agent)
				{
				disp_alt_menu();
				state home;
				}
			}
		}

	}

//----------------------------------------------------------------------//
// state home - at home position                                        //
//----------------------------------------------------------------------//
state home
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("home", TEXT_COLOR, TEXT_ALPHA);

		// start listener
		llListen(MENU_ALT_CHANNEL, "", NULL_KEY, "");
		}

	touch_start(integer num_detected)
		{
		// display altitude menu
		disp_alt_menu();
		}

	listen(integer channel, string name, key id, string message)
		{
		// ignore other AVs
		if (id != agent)
			return;

		// altitude menu button
		if (channel == MENU_ALT_CHANNEL)
			{
			if ((target_altitude = proc_alt_menu(message)) > 0.0)
				state ascend;
			}
		}

	changed(integer change)
		{
		if (change & CHANGED_LINK)
			{
			// agent unsit
			agent = llAvatarOnSitTarget();
			if (agent == NULL_KEY)
				state default;
			}
		}
	}

//----------------------------------------------------------------------//
// state ascend - ascend to requested altitude                          //
//----------------------------------------------------------------------//
state ascend
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("ascend", TEXT_COLOR, TEXT_ALPHA);

		// derezz and move to target altitude
		llRegionSay(COMM_CHANNEL, "DEREZZ");
		vector target_pos = HOME_POS;
		target_pos.z = target_altitude;
		go_to(target_pos);

		agent = llAvatarOnSitTarget();
		if (agent == NULL_KEY)
			state descend;
		else
			state target;
		}
	}

//----------------------------------------------------------------------//
// state target - at target altitude                                    //
//----------------------------------------------------------------------//
state target
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("target", TEXT_COLOR, TEXT_ALPHA);

		build_rezzed = 0;

		// setup listeners
		llListen(MENU_MAIN_CHANNEL, "", NULL_KEY, "");
		llListen(MENU_ALT_CHANNEL, "", NULL_KEY, "");
		llListen(MENU_BLD_CHANNEL, "", NULL_KEY, "");

		disp_bld_menu();
		}

	touch_start(integer num_detected)
		{
		// display main menu if touched
		if (llDetectedKey(0) == agent)
			llDialog(agent, MENU_MAIN_DES, MENU_MAIN, MENU_MAIN_CHANNEL);
		}

	listen(integer channel, string name, key id, string message)
		{
		// ignore other AVs
		if (id != agent)
			return;

		// derezz and descend to home position
		else if (message == MENU_ALL_HOME)
			state descend;

		// display main menu
		else if (message == MENU_ALL_MAIN)
			llDialog(agent, MENU_MAIN_DES, MENU_MAIN, MENU_MAIN_CHANNEL);

		// display altitude menu
		else if (message == MENU_MAIN_ALT)
			disp_alt_menu();

		// display build menu
		else if (message == MENU_MAIN_BLD)
			disp_bld_menu();

		// altitude menu buttons
		else if (channel == MENU_ALT_CHANNEL)
			{
			if ((target_altitude = proc_alt_menu(message)) >= 0.0)
				state ascend;
			}

		// build menu buttons
		else if (channel == MENU_BLD_CHANNEL)
			{
			if ((target_build = proc_bld_menu(message)) != "")
				{
				// derezz old build and rezz new one
				llRegionSay(COMM_CHANNEL, "DEREZZ");
				llRezAtRoot(target_build, llGetPos() + REZ_OFFSET, ZERO_VECTOR, ZERO_ROTATION, COMM_CHANNEL);
				build_rezzed = 1;
				}
			}

		}

	changed(integer change)
		{
		if (change & CHANGED_LINK)
			{
			// agent unsit
			agent = llAvatarOnSitTarget();
			if (agent == NULL_KEY)
				if (build_rezzed)
					state target_nosit;
				else
					state descend;
			}
		}
	}

//----------------------------------------------------------------------//
// state target_nosit - at target, agent not sitting                    //
//----------------------------------------------------------------------//
state target_nosit
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("target_nosit", TEXT_COLOR, TEXT_ALPHA);

		// check for agent nearby
		llSensorRepeat("", agent, AGENT, 50.0, PI, (AWAY_TIME - 2.0));
		llSetTimerEvent(AWAY_TIME);
		}

	sensor(integer num_detected)
		{
		// agent nearby, reset timer
		llSetTimerEvent(AWAY_TIME);
		}

	timer()
		{
		// return to home position
		llSensorRemove();
		state descend;
		}

	changed(integer change)
		{
		if (change & CHANGED_LINK)
			{
			// agent sit
			agent = llAvatarOnSitTarget();
			if (agent)
				state target;
			}
		}
	}

//----------------------------------------------------------------------//
// state descend - descend to home position                             //
//----------------------------------------------------------------------//
state descend
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("descend", TEXT_COLOR, TEXT_ALPHA);

		// derezz and descend to home position
		llRegionSay(COMM_CHANNEL, "DEREZZ");
		go_to(HOME_POS);

		agent = llAvatarOnSitTarget();
		if (agent == NULL_KEY)
			state default;
		else
			state home;
		}

	}

