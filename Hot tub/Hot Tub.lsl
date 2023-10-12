//----------------------------------------------------------------------//
// Hot Tub                                                              //
//----------------------------------------------------------------------//

// Constants
integer  HOTTUB_CHANNEL = 50;               // Chat channel for commands
float    WATER_Z_OFFSET =  0.40;            // Initial water z axis offset
float    COVER_Z_OFFSET = -1.00;            // Initial cover z axis offset

// globals
string   water_name = "Hot Tub - Water";
string   cover_name = "Hot Tub - Cover";

//
// Functions
//

//----------------------------------------------------------------------//
// rez_water - rezz the water                                           //
//----------------------------------------------------------------------//
rez_water()
	{
	// kill current water
	llSay(HOTTUB_CHANNEL, "water die");

	// get initial position and rotation and rezz the water
	vector   water_pos = llGetPos() + <0.0, 0.0, WATER_Z_OFFSET>;
	rotation water_rot = llGetRot();  
	llRezObject(water_name, water_pos, ZERO_VECTOR, water_rot, 0);  
	}

//----------------------------------------------------------------------//
// rez_cover - rez hot tub cover                                        //
//----------------------------------------------------------------------//
rez_cover()
	{
	// kill current cover
	llSay(HOTTUB_CHANNEL, "cover die");

	// get initial position and rotation and rezz the cover
	vector   cover_pos = llGetPos() + <0.0, 0.0, COVER_Z_OFFSET>;
	rotation cover_rot = llGetRot();  
	llRezObject(cover_name, cover_pos, ZERO_VECTOR, cover_rot, 0);  
	}

//
// States
//
default
	{
	state_entry()
		{
		// initialize
		rez_cover();

		// listen for commands
		llListen(HOTTUB_CHANNEL, "" , NULL_KEY, "");
		}

	on_rez(integer start_param)
		{
		// reset script
		llResetScript();
		}

	moving_end()
		{
		// initialize
		llSay(HOTTUB_CHANNEL, "water die");
		rez_cover();
		}

	listen(integer channel, string name, key id, string message)
		{
		if (message == "reset")
			rez_cover();

		else if (message == "hottub on")
			rez_water();

		}
	}
