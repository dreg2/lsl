//----------------------------------------------------------------------//
// Sky Diving Pod                                                       //
//----------------------------------------------------------------------//

// Constants
list    TARGET_ALTITUDES = ["500", "1000", "1500", "2000", "2500", "3000", "3500"];
float   TARGET_SPEED    = 500.0;

vector  TEXT_COLOR = <1.0, 1.0, 1.0>;
float   TEXT_ALPHA = 1.0;

vector  SIT_TARGET = <0.2, 0.0, 0.5>;

integer MENU_CHANNEL = 72465;
string  MENU_GO = "Go!";

// WarpPos constants
float   MAX_WARPPOS_MOVE  = 10.0;
integer MAX_WARPPOS_JUMPS = 100;

// Run time constants
vector  START_POS;

// Globals
key agent_key;
integer target_altitude = 500;
list menu;


//----------------------------------------------------------------------//
// go_to - go to target position (simplified)                           //
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
	//R&D by Keknehv Psaltery, 05/25/2006
	//with a little pokeing by Strife, and a bit more
	//some more munging by Talarus Luan
	//Final cleanup by Keknehv Psaltery

	// Compute the number of jumps necessary
	integer jumps = (integer)(llVecDist(destpos, llGetPos()) / MAX_WARPPOS_MOVE) + 1;

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
// dips_dialog - display dialog menu                                    //
//----------------------------------------------------------------------//
disp_dialog()
	{
	llDialog(agent_key, "Current alititude: " + (string)target_altitude + "\nChoose Atltitude", menu, MENU_CHANNEL);
	}


default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		agent_key = NULL_KEY;
		llSetText("Sit for menu", TEXT_COLOR, TEXT_ALPHA);
		llSitTarget(SIT_TARGET, ZERO_ROTATION);
		llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Y | STATUS_ROTATE_Z, FALSE);
		START_POS = llGetPos();
		menu = TARGET_ALTITUDES + [MENU_GO];
		}

	changed(integer change)
		{
		if (change & CHANGED_LINK)
			{
			agent_key = llAvatarOnSitTarget();
			if (agent_key)
				state ascend;
			}
		}
	}

state ascend
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("Touch for menu", TEXT_COLOR, TEXT_ALPHA);
		disp_dialog();
		llListen(MENU_CHANNEL, "", NULL_KEY, "");
		}

	touch_start(integer num_detected)
		{
		if (llDetectedKey(0) == agent_key)
			disp_dialog();
		}

	listen(integer channel, string name, key id, string message)
		{
		if (id != agent_key)
			return;

		if (message == MENU_GO)
			{
			vector target_pos = START_POS;
			target_pos.z = target_altitude;
			go_to(target_pos);
			state at_destination;
			}
		else
			{
			target_altitude = (integer)message;
			disp_dialog();
			}
		}

	changed(integer change)
		{
		if (change & CHANGED_LINK)
			{
			agent_key = llAvatarOnSitTarget();
			if (agent_key == NULL_KEY)
				state default;
			}
		}
	}

state at_destination
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetTimerEvent(3.0);
		}

	timer()
		{
		llUnSit(agent_key);
		state descend;
		}
	}

state descend
	{
	state_entry()
		{
		go_to(START_POS);
		state default;
		}
	}

