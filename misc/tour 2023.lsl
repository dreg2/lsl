//------------------------------------------------------------------------//
// simple tour script                                                     //
//------------------------------------------------------------------------//

// Constants

float TIME_STEP  = 0.3; // in seconds
float DIST_STEP  = 2.0; // in meters
float MOVE_TAU   = 0.4; // in seconds
float PROX_THR   = 5.0; // in meters

list DEST_COORDS =
	[
	<138.0, 58.0, 3801.0>,
	<168.0, 58.0, 3801.0>,
	<168.0, 28.0, 3801.0>,
	<138.0, 28.0, 3801.0>
	];


// globals

integer dest_index;
vector  destination;
integer listen_handle;

// states

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		dest_index = 0;
		llOwnerSay("default");
		state stop;
		}
	}

state stop
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetTimerEvent(0.0);
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
		llOwnerSay("stopped");
		listen_handle = llListen(0, "", NULL_KEY, "");
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message == "move")
			{
			state move;
			}
		}

	touch_start(integer num_detected)
		{
		state move;
		}
	}

state move
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		destination = llList2Vector(DEST_COORDS, dest_index);
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, TRUE);
		llOwnerSay("running");
		listen_handle = llListen(0, "", NULL_KEY, "");
		llSetTimerEvent(TIME_STEP);
		}

	timer()
		{
		vector new_dest = (llVecNorm(destination - llGetPos()) * DIST_STEP) + llGetPos();
        float distance  = llVecDist(destination, llGetPos());

//		llLookAt(new_dest, 1, 1.);
		llMoveToTarget(new_dest, MOVE_TAU);

		if (distance <= PROX_THR)
			{
			dest_index++;
			if (dest_index >= llGetListLength(DEST_COORDS))
				dest_index = 0;
            destination = llList2Vector(DEST_COORDS, dest_index);
			}        
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message == "stop")
			{
			state stop;
			}
		}

	touch_start(integer num_detected)
		{
		state stop;
		}
	}
