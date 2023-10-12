//----------------------------------------------------------------------//
// Hot Tub Shower Head                                                  //
//----------------------------------------------------------------------//

// Constants

integer HOTTUB_CHANNEL = 50;

// Fixed constants
integer ON  = TRUE;
integer OFF = FALSE;

// Globals

integer jet_state;

//
// functions
//

//----------------------------------------------------------------------//
// change jet state                                                     //
//----------------------------------------------------------------------//
change_jet(integer new_state)
	{
	if (jet_state == ON && new_state == OFF)
		{
		llParticleSystem([]);
		jet_state = OFF;
		llSay(HOTTUB_CHANNEL, "shower off");
		return;
		}
		
	else if (jet_state == OFF && new_state == ON)
		{
		llParticleSystem([
			PSYS_PART_FLAGS,
				PSYS_PART_EMISSIVE_MASK
				| PSYS_PART_FOLLOW_VELOCITY_MASK
				| PSYS_PART_INTERP_SCALE_MASK
				| PSYS_PART_INTERP_COLOR_MASK,

			PSYS_SRC_PATTERN,
			PSYS_SRC_PATTERN_ANGLE_CONE,

			PSYS_SRC_BURST_RATE,        0.1,
			PSYS_SRC_BURST_PART_COUNT,  20,
			PSYS_PART_MAX_AGE,          0.75,
			PSYS_SRC_MAX_AGE,           0.00,

			PSYS_SRC_ACCEL,             <0.00, 0.00, 0.00>,

			PSYS_SRC_BURST_SPEED_MIN,   3.0,
			PSYS_SRC_BURST_SPEED_MAX,   6.0,
			PSYS_SRC_OMEGA,             <0,0,0>,
			PSYS_SRC_ANGLE_BEGIN,       0*DEG_TO_RAD,
			PSYS_SRC_ANGLE_END,         15*DEG_TO_RAD,

			PSYS_PART_START_SCALE,      <0.00, 1.00, 0.00>,
			PSYS_PART_END_SCALE,        <0.10, 0.15, 0.00>,
			PSYS_PART_START_COLOR,      <1.00, 1.00, 1.00>,
			PSYS_PART_END_COLOR,        <1.00, 1.00, 1.00>,
			PSYS_PART_START_ALPHA,      1.0,
			PSYS_PART_END_ALPHA,        0.0,
			PSYS_SRC_TEXTURE, llGetInventoryName(INVENTORY_TEXTURE, 0)
			]);

		jet_state = ON;
		llSay(HOTTUB_CHANNEL, "shower on");
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
		llListen(HOTTUB_CHANNEL, "", NULL_KEY, "");
		}

	on_rez(integer start_param)
		{
		llResetScript();
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message ==  "shower button")
			{
			change_jet(!jet_state);
			}

		else if (message == "reset" || message == "hottub on" || message == "hottub off")
			llResetScript();
		}
	}

