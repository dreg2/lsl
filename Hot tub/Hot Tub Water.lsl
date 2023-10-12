//----------------------------------------------------------------------//
// Hot Tub Water                                                        //
//----------------------------------------------------------------------//

// Constants

integer HOTTUB_CHANNEL  = 50;   // Channel the tub will talk on

float   WATER_OFFSET = 0.75;    // Offset between full and empty.
float   STEP_SIZE    = 0.05;    // Size of steps for water fill/empty
float   STEP_DELAY   = 0.01;    // Time delay between steps

string  FILL_SOUND  = "water.wav";
string  EMPTY_SOUND = "lowater.wav";
string  WATER_SOUND = "littlewater.wav";
float   VOLUME      = 0.5;

// Fixed constants
integer UP   = TRUE;
integer DOWN = FALSE;

// globals

integer steam_level;   // Current steam level (0 - 3)
integer water_level;

//
// Functions
//

//----------------------------------------------------------------------//
// Set steam particle level -                                           //
//----------------------------------------------------------------------//
set_steam_level(integer level)
	{
	// sanity check argument
	if (level > 3 || level < 0)
		level = 0;

	// set global steam level and announce
	steam_level = level;
	llSay(HOTTUB_CHANNEL, "steam " + (string) steam_level);

	// for level 0 shut off steam
	if (level == 0)
		{
		llParticleSystem([]);
		return;
		}

	// lists for levels
	list src_burst_speed_min  = [0.3, 0.5, 1.0];
	list src_burst_speed_max  = [1.0, 1.5, 1.9];
	list part_start_alpha     = [0.3, 0.35, 0.6];
	list part_end_alpha       = [0.01, 0.05, 0.10];
	list part_start_scale     = [<2.0, 2.0, 2.0>, <2.0, 2.0, 2.0>, <2.1, 2.1, 2.1>];
	list part_end_scale       = [<0.2, 0.2, 0.2>, <0.2, 0.2, 0.2>, <0.3, 0.3, 0.3>];
	list part_src_accel       = [< 0.0, 0.0, -1.0>,  < 0.0, 0.0, -3.0>, < 0.0, 0.0, -3.0>];
	list src_burst_part_count = [35, 35, 38];

	// set steam particle system
	integer index = level - 1;
	llParticleSystem([
		PSYS_PART_FLAGS,
		PSYS_PART_INTERP_COLOR_MASK
			| PSYS_PART_INTERP_SCALE_MASK
			| PSYS_PART_FOLLOW_VELOCITY_MASK
			| PSYS_PART_EMISSIVE_MASK
			| PSYS_PART_BOUNCE_MASK,

		PSYS_SRC_PATTERN,
		PSYS_SRC_PATTERN_EXPLODE,
		PSYS_PART_MAX_AGE,           2.0,
		PSYS_SRC_BURST_SPEED_MIN,    llList2Float(src_burst_speed_min, index),
		PSYS_SRC_BURST_SPEED_MAX,    llList2Float(src_burst_speed_max, index),
		PSYS_PART_START_ALPHA,       llList2Float(part_start_alpha, index),
		PSYS_PART_END_ALPHA,         llList2Float(part_end_alpha, index),
		PSYS_PART_START_COLOR,       <0.8, 0.8, 0.8>,
		PSYS_PART_END_COLOR,         <0.5, 0.5, 0.5>,
		PSYS_PART_START_SCALE,       llList2Vector(part_start_scale, index),
		PSYS_PART_END_SCALE,         llList2Vector(part_end_scale, index),
		PSYS_SRC_ACCEL,              llList2Vector(part_src_accel, index),
		PSYS_SRC_BURST_RATE,         0.05,
		PSYS_SRC_BURST_RADIUS,       1.0,
		PSYS_SRC_BURST_PART_COUNT,   llList2Integer(src_burst_part_count, index),
		PSYS_SRC_OUTERANGLE,         0.4,
		PSYS_SRC_INNERANGLE,         0.55,
		PSYS_SRC_OMEGA,              <0.0, 0.0, 0.0>,
		PSYS_SRC_MAX_AGE,            0.0
		]);
	}

//----------------------------------------------------------------------//
// Set water level                                                      //
//----------------------------------------------------------------------//
change_water_level(integer new_level)
	{
	// get position and calculate steps
	vector old_pos = llGetPos();
	vector new_pos = old_pos;

	// determine if going up or down
	float step;
	if (new_level == UP && water_level == DOWN)
		{
		step = STEP_SIZE;
		new_pos.z += WATER_OFFSET;
		water_level = UP;
		llLoopSound(FILL_SOUND, VOLUME);
		}
	else if (new_level == DOWN && water_level == UP)
		{
		step = -STEP_SIZE;
		new_pos.z -= WATER_OFFSET;
		water_level = DOWN;
		llLoopSound(EMPTY_SOUND, VOLUME);
		}
	else
		return;

	// change water level in steps
	integer steps = llAbs((integer)(WATER_OFFSET / STEP_SIZE));
	integer i;
	for (i = 0; i < steps; ++i)
		{
		old_pos.z += step;
		llSetPos(old_pos);
		llSleep(STEP_DELAY);
		}

	// get into final position
	llSetPos(new_pos);
	llLoopSound(WATER_SOUND, VOLUME);

	// announce
	if (water_level == UP)
		llSay(HOTTUB_CHANNEL, "water up");
	else
		llSay(HOTTUB_CHANNEL, "water down");
	}

//
// States
//

default
	{
	state_entry()
		{
		// initialize water
		water_level = DOWN;
		llSay(HOTTUB_CHANNEL, "water down");
		llSetTextureAnim(ANIM_ON | SMOOTH | ROTATE | LOOP, ALL_SIDES, 0, 0, 1.0, 1000, 0.07);
		llLoopSound(WATER_SOUND, VOLUME);

		// set steam off
		set_steam_level(0);

		// start listeners
		llListen(HOTTUB_CHANNEL, "", "", "");
		llListen(0, "", NULL_KEY, "");
		}

	on_rez(integer start_param)
		{
		llResetScript();
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message == "water button")
			{
			if (water_level == UP)
				{
				change_water_level(DOWN);
				set_steam_level(0);
				}
			else
				{
				change_water_level(UP);
				}
			}

		else if (message == "water die")
			llDie();

		else if (message == "steam button")
			{
			steam_level++;
			set_steam_level(steam_level);
			}

		else if (message == "sound off")
			llStopSound();

		else if (message == "reset" || message == "hottub off")
			llDie();
		}
	}

