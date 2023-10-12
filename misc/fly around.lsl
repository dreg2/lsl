//----------------------------------------------------------------------//
// fly around pose ball                                                 //
//----------------------------------------------------------------------//

string ANIMATION = "fly";
vector SIT_OFFSET = <0.0, 0.0, 50.0>;
vector SIT_ROT    = <0.0, 0.0, 0.0>;
vector ROT_AXIS   = <0.0, 1.0, 0.0>;
float  ROT_TIME   = 30.0; // in seconds

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// initialize object
		llSetText("Fly around " + (string)llGetLinkNumber(), <1.0, 1.0, 1.0>, 1.0);
		llSetSitText("Fly");
		llSitTarget(SIT_OFFSET, llEuler2Rot(SIT_ROT));
		llSetAlpha(1.0, ALL_SIDES);

		// if only prim or root prim, start rotation
		if (llGetLinkNumber() < 2)
			llTargetOmega(ROT_AXIS, ((2*PI)/ROT_TIME), 1.0);
		}

	changed(integer change)
		{
		// check for changed link (sit)
		if (!(change & CHANGED_LINK))
			return;

		// get agent key
		key agent = llAvatarOnSitTarget();

		if (agent)
			{
			// avatar has sat on object
			llRequestPermissions(agent, PERMISSION_TRIGGER_ANIMATION);
			}

		else if (llGetPermissions() & PERMISSION_TRIGGER_ANIMATION)
			{
			// avatar has unsat from object
			llSetAlpha(1.0, ALL_SIDES);
//			llStopAnimation(ANIMATION);
			}
		}

	run_time_permissions(integer perm)
		{
		// check for permission given
		if (perm & PERMISSION_TRIGGER_ANIMATION)
			{
			llStopAnimation("sit");
			llStartAnimation(ANIMATION);
			llSetAlpha(0.0, ALL_SIDES);
			}
		}
	}

