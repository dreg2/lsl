//------------------------------------------------------------------------//
// simple tour script                                                     //
//------------------------------------------------------------------------//

// Constants

float INTERVAL = 0.4;
float DAMPING  = 0.4;

list COORDS =
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

integer index;
integer running;
vector  Destination;

// states

default
	{
	on_rez(integer p)
		{
		llResetScript();
		}

	state_entry()
		{
		index = 0;
		Destination = llList2Vector(COORDS,index);
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
		}
	 
	timer()
		{
		vector newdest = (llVecNorm(Destination - llGetPos()) * 3) + llGetPos();
		llLookAt(newdest, 1, 1.);
        
        float dist = llVecDist(Destination,llGetPos());

		llMoveToTarget(newdest, DAMPING);

		if (dist <= 5.0)
			{
			index++;
			if (index >= llGetListLength(COORDS))
				index = 0;
            Destination = llList2Vector(COORDS,index);
			}        
		}

	touch_start(integer p)
		{
		key x = llDetectedKey(0);

		if (x == llGetOwner())
			{
			if (running)
				{
				llOwnerSay("Orca stopped");
				running = FALSE;
				llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, FALSE);
				llSetTimerEvent(0.0);
				}
			else
				{
				llOwnerSay("Orca running");
				running = TRUE;
				llSetTimerEvent(INTERVAL);
				llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, TRUE);
				}
			}
		}
	}


