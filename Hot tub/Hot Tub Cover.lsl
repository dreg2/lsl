//----------------------------------------------------------------------//
// Hot Tub Cover                                                        //
//----------------------------------------------------------------------//

// Constants
float   OPEN_DZ      = 4.0;  // delta z to move for open
integer CHANNEL      = 50;   // chat channel to listen for messages

// fixed constants
integer OPEN   = TRUE;
integer CLOSED = FALSE;

// Globals
integer cover_state = CLOSED;

//
// Functions
//

//----------------------------------------------------------------------//
// change_cover - open or close cover                                   //
//----------------------------------------------------------------------//
change_cover(integer new_state)
	{
	if (new_state == OPEN && cover_state == CLOSED)
		{
		// open the cover
		llSay(CHANNEL, "hottub on");
		llSetPrimitiveParams([PRIM_PHANTOM, TRUE]);
		llSetPos(llGetPos() + <0, 0, OPEN_DZ>);
		cover_state = OPEN;
		}

	else if (new_state == CLOSED && cover_state == OPEN)
		{
		// close the cover
		llSay(CHANNEL, "hottub off");
		llSetPrimitiveParams([PRIM_PHANTOM, FALSE]);
		llSetPos(llGetPos() + <0, 0, -OPEN_DZ>);
		cover_state = CLOSED;
		}
	}

//
// States
//

default
	{
	state_entry()
		{
		// initialize as closed
		cover_state = CLOSED;
		llListen(CHANNEL, "", NULL_KEY, "");
		llSay(CHANNEL, "cover");
		}

	on_rez(integer start_param)
		{
		llResetScript();
		}

	touch_start(integer num_detected)
		{
		// change state of cover
		change_cover(!cover_state);
		}

	listen (integer channel, string name, key id, string message)
		{
		// open message
		if (message == "open")
			change_cover(OPEN);

		// close message
		else if (message == "close")
			change_cover(CLOSED);

		else if (message == "cover die")
			llDie();
		}
	}
