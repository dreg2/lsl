default
	{
	state_entry()
		{
		state not_running;
		}
	}

state running
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("", <0.0, 0.0, 0.0>, 0.0);
		llSetAlpha(0.0, ALL_SIDES);
		llParticleSystem([
				PSYS_PART_FLAGS,   PSYS_PART_INTERP_COLOR_MASK
						| PSYS_PART_INTERP_SCALE_MASK
						| PSYS_PART_BOUNCE_MASK
						| PSYS_PART_FOLLOW_SRC_MASK
						| PSYS_PART_EMISSIVE_MASK
						| PSYS_PART_INTERP_COLOR_MASK
						| PSYS_PART_INTERP_SCALE_MASK
						| PSYS_PART_BOUNCE_MASK
						| PSYS_PART_FOLLOW_SRC_MASK
						| PSYS_PART_EMISSIVE_MASK,
				PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
				PSYS_PART_START_COLOR, <0.25, 0.25, 0.25>,    PSYS_PART_END_COLOR, <0.25, 0.25, 0.25>,
				PSYS_PART_START_ALPHA, 0.25,                  PSYS_PART_END_ALPHA, 0.0,
				PSYS_PART_START_SCALE, <1.0, 1.0, 1.0>,       PSYS_PART_END_SCALE, <5.0, 5.0, 5.0>,
				PSYS_PART_MAX_AGE, 30.0,
				PSYS_SRC_ACCEL, <0.0, 0.0, 0.0>,
				PSYS_SRC_TEXTURE, "Fog 1",
				PSYS_SRC_BURST_RATE, 1.00,
				PSYS_SRC_ANGLE_BEGIN, 90.0*DEG_TO_RAD, PSYS_SRC_ANGLE_END, 90.0*DEG_TO_RAD,
				PSYS_SRC_BURST_PART_COUNT, 15,
				PSYS_SRC_BURST_SPEED_MIN, 0.45, PSYS_SRC_BURST_SPEED_MAX, 0.65,
				PSYS_SRC_MAX_AGE, 0.0
				]);
		}

	touch_start(integer num_detected)
		{
		state not_running;
		}
	}

state not_running
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetText("Touch to start the Fog Machine", <1.0, 1.0, 1.0>, 1.0);
		llSetAlpha(1.0, ALL_SIDES);
		llParticleSystem([]);
		}

	touch_start(integer num_detected)
		{
		state running;
		}
	}

