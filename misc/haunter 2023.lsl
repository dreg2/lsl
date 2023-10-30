//------------------------------------------------------------------------//
// simple follower script                                                 //
//------------------------------------------------------------------------//

// Constants
vector OFFSET = <-1.5, 0.5, 1.0>; // <forward, left, up>
float SCAN_TIME = 10.0;
float LIST_AGE_MAX = 18; // in SCAN_TIME units
float UPDATE_TIME = 0.3;
float HAUNT_TIME = 15.0;

float ROT_STRENGTH = 1.0; //tweaks the way object turns
float ROT_DAMPING  = 0.2; //tweaks the way object turns
float MOVE_TAU     = 0.2;
float SPEED_FACTOR = 0.5;

vector HOME_POS;

// Globals
key detected_agent;
integer listen_handle;

list agent_key;
list agent_count;

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		HOME_POS = llGetPos();
		state scan;
		}
	}

// scan for agent to follow
state scan
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llMoveToTarget(HOME_POS, MOVE_TAU);
		llSleep(1.0);

		listen_handle = llListen(0, "", NULL_KEY, "");
		llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Y | STATUS_ROTATE_Z, TRUE);
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
		llSensorRepeat("", NULL_KEY, AGENT, 96.0, PI, SCAN_TIME);
		}

	sensor(integer num_detected)
		{                
		integer i;
		integer agent_index;

		for (i = 0; i < num_detected; i++)
			{
			detected_agent = llDetectedKey(i);

			// new agent, add to list and follow
			if ((agent_index = llListFindList(agent_key, [detected_agent])) == -1)
				{
				agent_key   = agent_key + [detected_agent];
				agent_count = agent_count + [0];

				llSensorRemove();
				state follow;
				}
			else
				{
				// agent aleady followed, increment scan count
				agent_count = llListReplaceList(agent_count, [llList2Integer(agent_count, agent_index ) + 1], agent_index, agent_index);

				// count limit reached, remove from list
					if (llList2Integer(agent_count, agent_index) > LIST_AGE_MAX) 
					{
					agent_key   = llDeleteSubList(agent_key, agent_index, agent_index);
					agent_count = llDeleteSubList(agent_count, agent_index, agent_index);
					}
				}
			}
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message == "follow")
			{
			llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, TRUE);
			llSensorRepeat("", detected_agent, AGENT, 96.0, PI, SCAN_TIME);
			}
		else if (message == "stop")
			{
			llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
			llSensorRemove();
			}
		}
	}

// follow found agent 
state follow
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		listen_handle = llListen(0, "", NULL_KEY, "");

		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, TRUE);
		llSensorRepeat("", detected_agent, AGENT, 96.0, PI, UPDATE_TIME);
		llSetTimerEvent(HAUNT_TIME);
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message == "follow")
			{
			llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, TRUE);
			llSensorRepeat("", detected_agent, AGENT, 96.0, PI, UPDATE_TIME);
			}
		else if (message == "stop")
			{
			llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
			llSensorRemove();
			}
		else if (message == "unfollow")
			{
			state scan;
			}
		}

	sensor(integer num_detected)
		{                
		if (llDetectedPos(0) == ZERO_VECTOR) // this keeps your object from flying away when owners change or when rezzzed.
			return;

		// OFFSET * llDetectedRot(0) makes the OFFSET relative to the rotation of the followed object.
		// llDetectedVel(0) * 0.5  makes the objects compensate for you movement speed.
		vector new_pos = llDetectedPos(0) + OFFSET * llDetectedRot(0) + llDetectedVel(0) * SPEED_FACTOR;

		llMoveToTarget(new_pos, MOVE_TAU);
		llRotLookAt(llDetectedRot(0), ROT_STRENGTH, ROT_DAMPING);
		}

	no_sensor()
		{
		state scan;
		}

	timer()
		{
		state scan;
		}
	}
