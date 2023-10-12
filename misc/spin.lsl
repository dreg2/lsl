//------------------------------------------------------------------------//
// spin - spin object                                                     //
//------------------------------------------------------------------------//

// Constants
vector SPIN_AXIS = <1.0, 1.0, 1.0>;  // x,y,z
float  SPIN_TIME = 240.0;            // in seconds for complete revolution

default
	{
	state_entry()
		{
		llTargetOmega(SPIN_AXIS, (PI/SPIN_TIME), 1.0);
		}
	}

