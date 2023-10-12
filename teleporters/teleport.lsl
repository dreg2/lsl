//----------------------------------------------------------------------//
// local warpPos teleport                                               //
//----------------------------------------------------------------------//

// Contstants
vector TEXT_COLOR = <1.0, 1.0, 1.0>;

string TEXT_LINE1 = "Teleport to ";
string TEXT_LINE2 = "Right click and select 'Teleport' to teleport";
string ADD_TEXT   = "Touch to change destination";

// Globals
string  config_file_name;  // name of a notecard in the object's inventory
integer config_file_line;  // current line number
key     config_file_query; // id used to identify dataserver queries

integer dest_index;        // current index on the list
list    dest_desc;         // list of destination descriptions
list    dest_vector;       // list of destination vectors

//
// Functions
//

//----------------------------------------------------------------------//
// set floating text                                                    //
//----------------------------------------------------------------------//
set_text(integer index)
	{
	string  float_text;
	float_text = TEXT_LINE1 + llList2String(dest_desc, index) + "\n" + TEXT_LINE2;
	if (llGetListLength(dest_desc) > 1)
		float_text = float_text + "\n" + ADD_TEXT;
	llSetText(float_text, TEXT_COLOR, 1.0);
	llSay(0, "Destination: " + llList2String(dest_desc, index) + " - " + TEXT_LINE2);
	}

//----------------------------------------------------------------------//
// go_to - go to target position (simplified)                           //
//----------------------------------------------------------------------//
go_to(vector target_pos)
	{
	// call warpPos until target reached
	while (llVecDist(target_pos, llGetPos()) > 0.1)
		warpPos(target_pos);
	}

//----------------------------------------------------------------------//
// warpPos                                                              //
//----------------------------------------------------------------------//
warpPos(vector destpos)
	{
	//R&D by Keknehv Psaltery, 05/25/2006
	//with a little pokeing by Strife, and a bit more
	//some more munging by Talarus Luan
	//Final cleanup by Keknehv Psaltery

	// Compute the number of jumps necessary
	integer jumps = (integer)(llVecDist(destpos, llGetPos()) / 10.0) + 1;

	// Try and avoid stack/heap collisions
	if (jumps > 100)
		jumps = 100;    //  1km should be plenty

	list rules = [PRIM_POSITION, destpos];  //The start for the rules list
	integer count = 1;
	while ((count = count << 1) < jumps)
		rules = (rules=[]) + rules + rules;   //should tighten memory use.

	llSetPrimitiveParams(rules + llList2List(rules, (count - jumps) << 1, count));
	}


//----------------------------------------------------------------------//
// parse_config_line - parse config file line                           //
//----------------------------------------------------------------------//
integer parse_config_line(string line)
	{
	// skip blank lines and comments
	if (line == "" || llGetSubString(line, 0, 0) == "#")
		return 0;

	// look for colon separator
	integer colon_loc = llSubStringIndex(line, ":");
	if (colon_loc == -1)
		return 0;

	// split line into description and destination
	string  desc = llGetSubString(line, 0, colon_loc-1);
	string  dest = llStringTrim(llGetSubString(line, colon_loc+1, -1), STRING_TRIM);

	// add to lists
	dest_desc   = (dest_desc=[])   + dest_desc   + [desc];
	dest_vector = (dest_vector=[]) + dest_vector + [(vector)dest];
	dest_index++;

	return 0;
	}

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
		// initializ prim
		llSetSitText("Teleport");
		llSitTarget(<0.0, 0.0, 0.1>, ZERO_ROTATION);
		llSetText("Inactive", TEXT_COLOR, 1.0);

		// unsit any AV
		if (llAvatarOnSitTarget() != NULL_KEY)
			llUnSit(llAvatarOnSitTarget());

		// set up config
		dest_desc   = [];
		dest_vector = [];
		dest_index  = 0;

		config_file_line = 0;
		config_file_name = llGetInventoryName(INVENTORY_NOTECARD, 0);
		if (config_file_name == "")
			{
			llSay(0, "Configuration notecard not found.");
			}
		else
			{
			config_file_query = llGetNotecardLine(config_file_name, config_file_line);
			}
		}

	dataserver(key query_id, string data)
		{
		// finished reading config
		if (data == EOF)
			state active;

		// parse config line
		parse_config_line(data);

		// read next line
		config_file_line++;
		config_file_query = llGetNotecardLine(config_file_name, config_file_line);
		}

	changed(integer change)
		{
		if (change & CHANGED_INVENTORY)
			llResetScript();
		}
	}

state active
	{
	on_rez(integer start_param)
		{
		llResetScript();
		}

	state_entry()
		{
		// say list of destinations
		llOwnerSay("Loaded Destinations:");
		for (dest_index = 0; dest_index < llGetListLength(dest_desc); dest_index++)
			llOwnerSay(llList2String(dest_desc, dest_index));

		// set to first destination
		dest_index = 0;
		set_text(dest_index);
		}

	touch_start(integer total_number)
		{
		// change to next destination
		dest_index++;
		if (dest_index >= llGetListLength(dest_desc))
			dest_index = 0;
		set_text(dest_index);
		}

	changed(integer change)
		{
		if (change & CHANGED_INVENTORY)
			llResetScript();

		// teleport
		if (change & CHANGED_LINK && llAvatarOnSitTarget() != NULL_KEY)
			{
			vector curr_pos = llGetPos();
			go_to(llList2Vector(dest_vector, dest_index));
			llUnSit(llAvatarOnSitTarget());
			go_to(curr_pos);
			}
		}
	}
