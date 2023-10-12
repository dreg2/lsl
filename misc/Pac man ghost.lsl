//----------------------------------------------------------------------//
// Pac Man ghost AV                                                     //
//----------------------------------------------------------------------//

// Contants
float   DISP_DIST  = 0.5; // displacement distance from start pos
float   DISP_TIME  = 2.0; // time for move
integer DISP_STEPS = 10;  // number of steps in move

float   TRANS_MIN_TIME =  90; // minimum time to transition in seconds
float   TRANS_MAX_TIME = 150; // maximum time to transition in seconds

float   BLUE_TIME     = 15.0; // time in blue state

float   FLASH_TIME    = 5.0; // time of flash state
integer FLASH_STEPS   = 20;  // number of flashes

string TEXTURE_1 = "pac man ghost 1";
string TEXTURE_2 = "pac man ghost 2";
string TEXTURE_3 = "pac man ghost 3";
string TEXTURE_4 = "pac man ghost 4";

// Globals

vector START_POS;   // saved start position
float  UP_Z_POS;    // up position
float  DOWN_Z_POS;  // down position

integer cycle_count; // current cycle count
integer min_cycles;  // minimum cycles before transisition
integer max_cycles;  // maximum cycles before transisition
integer cycle_limit; // calculated limit of cycles before transition

integer flash_count; // current count of flashes

integer change_state = 0;

//----------------------------------------------------------------------//
// rand_cycles - random cycle number for transition                     //
//----------------------------------------------------------------------//
integer rand_cycles()
	{
	integer new_cycles;
	new_cycles = (integer)(TRANS_MIN_TIME/DISP_TIME);

	integer diff;
	diff = (integer)(TRANS_MAX_TIME/DISP_TIME) - (integer)(TRANS_MIN_TIME/DISP_TIME);

	new_cycles += (integer)llFrand(diff + 1);
	return new_cycles;
	}

default
	{
	state_entry()
		{
		START_POS = llGetLocalPos();
		UP_Z_POS   = START_POS.z + DISP_DIST;
		DOWN_Z_POS = START_POS.z;
		cycle_limit = rand_cycles();
		state up;
		}
	}

state up
	{
	on_rez(integer start_param)
		{
		llSetPrimitiveParams([PRIM_POSITION, START_POS]);
		llResetScript();
		}

	state_entry()
		{
		cycle_count += 1;
		if ((cycle_count >= cycle_limit) || (change_state))
			{
			llSetTimerEvent(0.0);
			state blue;
			}

		llSetTexture(TEXTURE_1, ALL_SIDES);
//		llSetTimerEvent((DISP_TIME/2.0));
		llSetTimerEvent((DISP_TIME/2.0)/DISP_STEPS);
		}

	timer()
		{
		vector curr_pos;
		curr_pos = llGetLocalPos();

//		curr_pos.z = UP_Z_POS;
		curr_pos.z += (DISP_DIST/DISP_STEPS);
		llSetPrimitiveParams([PRIM_POSITION, curr_pos]);

		if (curr_pos.z >= UP_Z_POS)
			{
			llSetTimerEvent(0.0);
			state down;
			}
		}

	touch_start(integer num_detected)
		{
//		change_state = 1;
		llSetTimerEvent(0.0);
		state blue;
		}

	}

state down
	{
	on_rez(integer start_param)
		{
		llSetPrimitiveParams([PRIM_POSITION, START_POS]);
		llResetScript();
		}

	state_entry()
		{
		llSetTexture(TEXTURE_2, ALL_SIDES);
//		llSetTimerEvent((DISP_TIME/2.0));
		llSetTimerEvent((DISP_TIME/2.0)/DISP_STEPS);
		}

	timer()
		{
		vector curr_pos;
		curr_pos = llGetLocalPos();

//		curr_pos.z = DOWN_Z_POS;
		curr_pos.z -= (DISP_DIST/DISP_STEPS);
		llSetPrimitiveParams([PRIM_POSITION, curr_pos]);

		if (curr_pos.z <= DOWN_Z_POS)
			{
			llSetTimerEvent(0.0);
			state up;
			}
		}

	touch_start(integer num_detected)
		{
		llSetTimerEvent(0.0);
		state blue;
//		change_state = 1;
		}

	}


state blue
	{
	on_rez(integer start_param)
		{
		llSetPrimitiveParams([PRIM_POSITION, START_POS]);
		llResetScript();
		}

	state_entry()
		{
		change_state = 0;
		llSetPrimitiveParams([PRIM_POSITION, START_POS]);
		cycle_count = 0;
		cycle_limit = rand_cycles();
		llSetTexture(TEXTURE_3, ALL_SIDES);
		llSetTimerEvent(BLUE_TIME);
		}

	timer()
		{
		llSetTimerEvent(0.0);
		state flash;
		}
	}

state flash
	{
	on_rez(integer start_param)
		{
		llSetPrimitiveParams([PRIM_POSITION, START_POS]);
		llResetScript();
	 	}

	state_entry()
		{
		llSetTexture(TEXTURE_3, ALL_SIDES);
		llSetTimerEvent(FLASH_TIME/FLASH_STEPS);
		flash_count = 0;
		}

	timer()
		{
		if (flash_count % 2)
			llSetTexture(TEXTURE_3, ALL_SIDES);
		else
			llSetTexture(TEXTURE_4, ALL_SIDES);
		flash_count += 1;
		if (flash_count >= FLASH_STEPS)
			{
			llSetTimerEvent(0.0);
			state up;
			}
		}
	}


