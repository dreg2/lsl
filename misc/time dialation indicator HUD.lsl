//----------------------------------------------------------------------//
// Region time dilation indicator                                       //
//----------------------------------------------------------------------//

// Constants
float  CHECK_TIME      = 1;
float  CHANGE_POINT    = 0.80;

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetTimerEvent(CHECK_TIME);
		}

	timer()
		{
		float time_dilation = llGetRegionTimeDilation();
		if (time_dilation > CHANGE_POINT)
			{
			float value =  1 - (time_dilation - CHANGE_POINT) / (1 - CHANGE_POINT);
			llSetColor(<value, 1.0, 0.0>, ALL_SIDES);
			}
		else
			{
			float value =  (time_dilation / CHANGE_POINT);
			llSetColor(<1.0, value, 0.0>, ALL_SIDES);
			}
		 llSetText("Dilation: " + (string)time_dilation,<1.0, 1.0, 1.0>, 1.0);
		}
	}
