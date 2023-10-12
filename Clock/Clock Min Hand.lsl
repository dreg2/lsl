//----------------------------------------------------------------------//
// clock minute hand                                                    //
//----------------------------------------------------------------------//

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		// make sure message is for us
		if (num != 2)
			return;

		// calculate new rotation
		float    minutes   = (float)str;
		vector   curr_rot  = llRot2Euler(llGetLocalRot());
		float    new_angle = (float)minutes * (TWO_PI / 60.0);
		rotation new_rot   = llEuler2Rot(<curr_rot.x, curr_rot.y, new_angle>);

		// set new rotation
		llSetLocalRot(new_rot);
		}
	}

