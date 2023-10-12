//------------------------------------------------------------------------//
// simple follower script                                                 //
//------------------------------------------------------------------------//

// Constants
vector OFFSET = <0.0, 1.0, 1.0>; //<forward,left,up>
float UPDATE_TIME = 0.3;

float ROT_STRENGTH = 1.0; //tweaks the way object turns
float ROT_DAMPING  = 0.2; //tweaks the way object turns
float MOVE_TAU     = 0.2;
float SPEED_FACTOR = 0.5;

// Globals

default
	{
	on_rez(integer param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Y | STATUS_ROTATE_Z, TRUE);
		llSetStatus(STATUS_PHYSICS | STATUS_PHANTOM, TRUE);
		llSleep(0.2);

		llListen(0, "", llGetOwner(), "");
		llSensorRepeat("", llGetOwner(), AGENT, 96.0, PI, UPDATE_TIME);
		}


	listen(integer chnl, string name, key id, string txt)
		{
		if (txt == "follow")
			{
			llSensorRepeat("", llGetOwner(), AGENT, 96.0, PI, UPDATE_TIME);
			}
		else if (txt == "stop")
			{
			llSensorRemove();
			}
		}

	no_sensor()
		{
		llSensorRemove();
		}

	sensor(integer sensed_objects)
		{                
		if (llDetectedPos(0) == ZERO_VECTOR) // this keeps your object from flying away when owners change or when rezzzed.
			return;

		//OFFSET * llDetectedRot(0) makes the OFFSET relative to the rotation of the followed object.
		//llDetectedVel(0) * 0.5  makes the objects compensate for you movement speed.

		vector new_pos = llDetectedPos(0) + OFFSET * llDetectedRot(0) + llDetectedVel(0) * SPEED_FACTOR;

		llMoveToTarget(new_pos, MOVE_TAU);
		llRotLookAt(llDetectedRot(0), ROT_STRENGTH, ROT_DAMPING);
		llSetTimerEvent(0.0); // turns off the die timer
		}
	}



