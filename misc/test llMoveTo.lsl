//------------------------------------------------------------------------//
// test llMoveTo                                                          //
//------------------------------------------------------------------------//

// Constants
vector OFFSET = <10.0, 10.0, 0.0>; // <forward, left, up>

float ROT_STRENGTH = 1.0; //tweaks the way object turns
float ROT_DAMPING  = 0.2; //tweaks the way object turns
float MOVE_TAU     = 10.0;
float SPEED_FACTOR = 0.5;

vector HOME_POS;
vector DEST_POS;

integer AT_HOME;

// Globals
key agent_key;
integer listen_handle;

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		HOME_POS = llGetPos();
		DEST_POS = HOME_POS + OFFSET;
		AT_HOME  = TRUE;
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
		state ready;
		}

//	changed(integer change)
//		{
//		if (change & CHANGED_LINK)
//			{
//			agent_key = llAvatarOnSitTarget();
//			if (agent_key)
//				state ready;
//			}
//		}
	}

// 
state ready
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
//		llMoveToTarget(HOME_POS, MOVE_TAU);

		llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Y | STATUS_ROTATE_Z, TRUE);
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);

		listen_handle = llListen(0, "", NULL_KEY, "");
llSay(0, "State ready");
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message == "go")
			{
			llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, TRUE);

			if (AT_HOME == TRUE)
				{
				llMoveToTarget(DEST_POS, MOVE_TAU);
llSay(0, "Move to " + (string)DEST_POS);
				AT_HOME = FALSE;
				}
			else
				{
				llMoveToTarget(HOME_POS, MOVE_TAU);
llSay(0, "Move to " + (string)HOME_POS);
				AT_HOME = TRUE;
				}

//			llRotLookAt(llDetectedRot(0), ROT_STRENGTH, ROT_DAMPING);
			}

		else if (message == "stop")
			{
llSay(0, "stop received");
			llMoveToTarget(HOME_POS, MOVE_TAU);
			llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
			state default;
			}
		}

	at_target(integer tnum, vector targetpos, vector ourpos)
		{
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
llSay(0, "target position: " + (string)targetpos + ", object is now at: " + (string)ourpos);
		}
	}
