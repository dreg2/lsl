//----------------------------------------------------------------------//
// Region time dilation indicator                                       //
//----------------------------------------------------------------------//

// Constants
float  CHECK_TIME      = 1;
float  EXCELLENT       = 0.90;
vector EXCELLENT_COLOR = <0.0, 1.0, 0.0>;
float  GOOD            = 0.60;
vector GOOD_COLOR      = <1.0, 1.0, 0.0>;
vector POOR_COLOR      = <1.0, 0.0, 0.0>;

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
		if (time_dilation > EXCELLENT)
			llSetColor(EXCELLENT_COLOR, ALL_SIDES);
		else if (time_dilation <= EXCELLENT && time_dilation > GOOD)
			llSetColor(GOOD_COLOR, ALL_SIDES);
		else
			llSetColor(POOR_COLOR, ALL_SIDES);
		}
	}
