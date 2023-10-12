//----------------------------------------------------------------------//
// hinged plane                                                         //
//----------------------------------------------------------------------//

// Constants
float   OPEN_TIME = 10.0;  // number of seconds to keep open (0 to disable).
integer DIRECTION = 1;     // 1 = ccw, -1 = cw

// Fixed Constants
integer OPEN_DIR  = 1;
integer CLOSE_DIR = -1;


// Functions
rot_prim(integer dir)
	{
	llSetLocalRot(llEuler2Rot(<0, 0, (DIRECTION*dir) * PI/2>) * llGetLocalRot());
	}


// States
default 
	{
	on_rez(integer start_param) 
		{
		llResetScript();
		}

	state_entry() 
		{
		state closed;
		}
	}

state closed 
	{
	on_rez(integer start_param) 
		{
		llResetScript();
		}

	state_entry() 
		{
		}

	touch_start(integer total_number) 
		{
		rot_prim(OPEN_DIR);
		state open;
		}
	}

state open 
	{
	on_rez(integer start_param) 
		{
		llResetScript();
		}

	state_entry() 
		{
		llSetTimerEvent(OPEN_TIME);
		}

	touch_start(integer num) 
		{
		rot_prim(CLOSE_DIR);
		state closed;
		}

	timer() 
		{
		rot_prim(CLOSE_DIR);
		state closed;
		}

	moving_start() 
		{
		rot_prim(CLOSE_DIR);
		state closed;
		}

	state_exit() 
		{
		llSetTimerEvent(0);
		}
	}

