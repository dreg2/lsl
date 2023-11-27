//------------------------------------------------------------------------//
// simple tour script                                                     //
//------------------------------------------------------------------------//

// Constants

float TIME_STEP  = 0.4; // in seconds
float DIST_STEP  = 3.0; // in meters
float MOVE_TAU   = 0.4; // in seconds

list DEST_COORDS =
	[
	<193.8, 92.0,  23.0>,
	<171.5, 62.1,  23.0>,
	<148.1, 61.0,  23.0>,
	<131.8, 72.8,  23.0>,
	<131.0, 93.6,  23.0>,
	<144.7, 105.,  23.0>,
	<153.7, 76.0,  23.0>,
	<156.0, 48.0,  23.0>,
	<150.5, 30.2,  23.0>,
	<132.0, 23.0,  23.0>,
	<101.8, 40.9,  23.0>,
	<50.8,  108.4, 23.0>,
	<52.5,  123.5, 23.0>,
	<79.2,  161.9, 23.0>,
	<107.1, 173.8, 23.0>,
	<145.8, 178.8, 23.0>,
	<178.8, 159.3, 23.0>,
	<193.4, 147.1, 23.0>,
	<196.4, 116.8, 23.0>
	];

// globals

integer dest_index;
vector  destination;

// states

default
	{
	on_rez(integer p)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetTimerEvent(0.0);
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
		llOwnerSay("stopped");
		}

	touch_start(integer p)
		{
		state move;
		}
	}

move
	{
	on_rez(integer p)
		{
		llResetScript();
		}

	state_entry()
		{
		dest_index = 0;
		destination = llList2Vector(DEST_COORDS, dest_index);
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, TRUE);
		llOwnerSay("running");
		llSetTimerEvent(TIME_STEP);
		}

	timer()
		{
		vector newdest = (llVecNorm(destination - llGetPos()) * DIST_STEP) + llGetPos();
		llLookAt(newdest, 1, 1.);

        float dist = llVecDist(destination, llGetPos());

		llMoveToTarget(newdest, MOVE_TAU);

		if (dist <= 5.0)
			{
			dest_index++;
			if (dest_index >= llGetListLength(DEST_COORDS))
				dest_index = 0;
            destination = llList2Vector(DEST_COORDS, dest_index);
			}        
		}

	touch_start(integer p)
		{
		state default;
		}
	}
