//----------------------------------------------------------------------//
// Hot Tub Jet                                                          //
//----------------------------------------------------------------------//

// Constants

integer HOTTUB_CHANNEL = 50;
string  JET_SOUND      = "bubbling_water.wav";
float   VOLUME         = 0.2;

// Fixed contstants
integer ON   = TRUE;
integer OFF  = FALSE;

// Globals

integer jet_state;

//
// functions
//

//----------------------------------------------------------------------//
// change jet state                                                    //
//----------------------------------------------------------------------//
change_jet(integer new_state)
	{
	if (new_state == OFF)
		{
		llParticleSystem([]);
		llStopSound();
		jet_state = OFF;
		llSay(HOTTUB_CHANNEL, "jets off");
		return;
		}
		
	else if (new_state == ON)
		{
		llParticleSystem([
			PSYS_PART_FLAGS,
				PSYS_PART_EMISSIVE_MASK
				| PSYS_PART_FOLLOW_VELOCITY_MASK
				| PSYS_PART_INTERP_SCALE_MASK
				| PSYS_PART_INTERP_COLOR_MASK,

			PSYS_SRC_PATTERN,
			PSYS_SRC_PATTERN_ANGLE_CONE,

			PSYS_SRC_BURST_RATE,        0.06,
			PSYS_SRC_BURST_PART_COUNT,  8,
			PSYS_PART_MAX_AGE,          3.00,
			PSYS_SRC_MAX_AGE,           0.0005,

			PSYS_SRC_ACCEL,             <0.00, 0.00, 0.00>,

			PSYS_SRC_BURST_SPEED_MIN,   0.50,
			PSYS_SRC_BURST_SPEED_MAX,   1.00,
			PSYS_SRC_OMEGA,             <0.00, 0.00, 0.00>,
			PSYS_SRC_ANGLE_BEGIN,       0*DEG_TO_RAD,
			PSYS_SRC_ANGLE_END,         15*DEG_TO_RAD,

			PSYS_PART_START_SCALE,      <0.03, 0.03, 0.03>,
			PSYS_PART_END_SCALE,        <.30, .30, .30>,
			PSYS_PART_START_COLOR,      <0.50, 0.50, 1.00>,
			PSYS_PART_END_COLOR,        <1.70, 1.70, 1.70>,
			PSYS_PART_START_ALPHA,      1.0,
			PSYS_PART_END_ALPHA,        .0,
			PSYS_SRC_TEXTURE, llGetInventoryName(INVENTORY_TEXTURE, 0)
			]);


		llLoopSound(JET_SOUND, VOLUME);
		jet_state = ON;
		llSay(HOTTUB_CHANNEL, "jets on");
		return;
		}
	}

//
// states
//

default
	{
	state_entry()
		{
		jet_state = OFF;
		change_jet(jet_state);
		llListen(HOTTUB_CHANNEL, "", NULL_KEY, "");
		}

	on_rez(integer start_param)
		{
		llResetScript();
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message ==  "jets button")
			change_jet(!jet_state);

		else if (message == "sound off")
			llStopSound();

		else if (message == "reset" || message == "hottub on" || message == "hottub off")
			{
			llResetScript();
			}
		}
	}

