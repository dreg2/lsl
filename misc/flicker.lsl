//----------------------------------------------------------------------//
// lightning prim flicker                                               //
//----------------------------------------------------------------------//

float   OUT_TIME  = 5.0;    // time to stay faded out
float   IN_TIME   = 1.0;    // time to stay faded in
integer FLICK_NUM = 3;      // number of flickers

float   TIME_STEP = 0.1;    // time step for fade

float   ALPHA_MAX = 1.0;    // maximum alpha
float   ALPHA_MIN = 0.0;    // minimun alpha

float   alpha;
integer count;


//
// States
//

default
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		state wait;
		}
	}

state wait
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		llSetTimerEvent(OUT_TIME);
		llSetLinkAlpha(LINK_SET, ALPHA_MIN, ALL_SIDES);
		llSetPrimitiveParams([
				PRIM_GLOW, ALL_SIDES, 0.00,
				PRIM_FULLBRIGHT, ALL_SIDES, FALSE,
				PRIM_POINT_LIGHT, FALSE, <1.0, 1.0, 1.0>, 1.0, 20.0, 0.00
				]);
		}

	timer()
		{
		state flicker;
		}
	}

state flicker
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		count = 0;
		alpha = ALPHA_MIN;
		llSetLinkAlpha(LINK_SET, alpha, ALL_SIDES);
		llSetTimerEvent(TIME_STEP);
		}

	timer()
		{
		llSetLinkAlpha(LINK_SET, alpha, ALL_SIDES);

		if (alpha >= ALPHA_MAX)
			{
			// flicker on
			llSetPrimitiveParams([
				PRIM_GLOW, ALL_SIDES, 0.25,
				PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
				PRIM_POINT_LIGHT, TRUE, <1.0, 1.0, 1.0>, 1.0, 20.0, 0.00
				]);
			alpha = ALPHA_MIN;
			count++;
			}
		else
			{
			// flicker off
			llSetPrimitiveParams([
				PRIM_GLOW, ALL_SIDES, 0.00,
				PRIM_FULLBRIGHT, ALL_SIDES, FALSE,
				PRIM_POINT_LIGHT, FALSE, <1.0, 1.0, 1.0>, 1.0, 20.0, 0.00
				]);
			alpha = ALPHA_MAX;
			}

		if (count >= FLICK_NUM)
			state wait;

		llSetTimerEvent(TIME_STEP);
		}
	}

