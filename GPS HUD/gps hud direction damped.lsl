//------------------------------------------------------------------------//
// GPS HUD - direction module                                             //
//------------------------------------------------------------------------//

// Constants
vector TEXT_COLOR = <1.0, 1.0, 1.0>;
integer DAMP_COUNT    = 3;
integer WEIGHT_FACTOR = 2;

// list for damping
list heading_l;
list track_l;
list speed_l;
integer idx = 0;

//------------------------------------------------------------------------//
// fixedPrecsion - convert float to fixed precision string                //
//------------------------------------------------------------------------//
string fixedPrecision(float input, integer precision)
	{
	if ((precision = (precision - 7 - (precision < 1))) & 0x80000000)
		return llGetSubString((string)input, 0, precision);
	return (string)input;
	}

//
// States
//
default
	{
	on_rez(integer param)
		{
		llResetScript();
		}

	state_entry()
		{
		// create damping average lists
		for (idx = 0; idx < DAMP_COUNT; idx++)
			{
			heading_l += [0];
			track_l   += [0];
			speed_l   += [0];
			}
		idx = 0;
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		if (num != 1)
			return;

		list   message = llParseString2List(str, ["^"], []);
		string command = llStringTrim(llList2String(message, 0), STRING_TRIM);
		list   args    = llList2List(message, 1, -1);

		integer arg_heading = llList2Integer(args, 0);
		integer arg_track   = llList2Integer(args, 1);
		float   arg_speed   = llList2Float(args, 2);

		// get damp list averagaes
		integer i;
		integer heading_a = 0;
		integer track_a   = 0;
		float   speed_a   = 0;
		for (i = 0; i < DAMP_COUNT; i++)
			{
			heading_a += llList2Integer(heading_l, i);
			track_a   += llList2Integer(track_l, i);
			speed_a   += llList2Float(speed_l, i);
			}
		heading_a /= DAMP_COUNT;
		track_a   /= DAMP_COUNT;
		speed_a   /= DAMP_COUNT;

		// factor in latest weighted values
		integer heading_w = arg_heading * WEIGHT_FACTOR;
		heading_a += heading_w;
		heading_a /= (WEIGHT_FACTOR + 1);

		integer track_w   = arg_track   * WEIGHT_FACTOR;
		track_a   += track_w;
		track_a   /= (WEIGHT_FACTOR + 1);

		float   speed_w   = arg_speed   * WEIGHT_FACTOR;
		speed_a   += speed_w;
		speed_a   /= (WEIGHT_FACTOR + 1);
		

		string text = "Heading: " + (string)heading_a + "\n"
					+ "Track: " + (string)track_a + "\n"
					+ "Speed: " + fixedPrecision(speed_a, 1);
		llSetText(text, TEXT_COLOR, 1.0);

		// put latest values into damping list
		heading_l = llListReplaceList(heading_l, [arg_heading], idx, idx);
		track_l   = llListReplaceList(track_l, [arg_track], idx, idx);
		speed_l   = llListReplaceList(speed_l, [arg_speed], idx, idx);

		idx++;
		if (idx >= DAMP_COUNT)
			idx = 0;

		}
	}

