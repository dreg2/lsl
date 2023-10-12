//----------------------------------------------------------------------//
// clock hour hand                                                      //
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
		if (num != 1)
			return;
			
		// calculate rotation
		float    hours     = (float)str;
		vector   curr_rot  = llRot2Euler(llGetLocalRot());
		float    new_angle = (float)hours * (TWO_PI / 12.0);
		rotation new_rot   = llEuler2Rot(<curr_rot.x, curr_rot.y, new_angle>);

		// set new rotation
		llSetLocalRot(new_rot);
		}
	}

