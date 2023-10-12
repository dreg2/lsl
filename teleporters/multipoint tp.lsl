//----------------------------------------------------------------------//
// local multi-point teleport                                           //
//----------------------------------------------------------------------//

// Constants
vector TEXT_COLOR  = <1.0, 1.0, 1.0>;

string TEXT_LINE1 = "Teleport to ";
string TEXT_LINE2 = "Right click and select 'Teleport' to teleport";
string ADD_TEXT   = "Touch to change destination";

// Globals
string  config_file_name;
integer config_file_line;     // current line number
key     config_query_id;      // dataserver query id
integer listen_handle;        // handle for listener

list    wp_vector;
list    wp_type;
integer wp_index;

list    dest_desc;
list    dest_beg_index;
list    dest_wp_count;
integer dest_index;

string  float_text;

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

	// split line into keyword and value
	string  keyword = llToUpper(llGetSubString(line, 0, colon_loc-1));
	string  value   = llGetSubString(line, colon_loc+1, -1);

	if (keyword == "DESC")
		{
		dest_desc      = (dest_desc=[])      + dest_desc      + [value];
		dest_beg_index = (dest_beg_index=[]) + dest_beg_index + [wp_index];
		dest_wp_count  = (dest_wp_count=[])  + dest_wp_count  + [0];
		dest_index++;
		}

	else if (keyword == "WARP" || keyword == "MOVE")
		{
		wp_type    = (wp_type=[])   + wp_type   + [keyword];
		wp_vector  = (wp_vector=[]) + wp_vector + [(vector)value];
		integer count = llList2Integer(dest_wp_count, (dest_index-1)) + 1;
		dest_wp_count = llListReplaceList(dest_wp_count, [count], (dest_index-1), (dest_index-1));
		wp_index++;
		}
	else
		{
		llSay(0, "Unknown keyword: " + keyword);
		}

	return 0;
	}

//----------------------------------------------------------------------//
// teleport                                                             //
//----------------------------------------------------------------------//
integer teleport()
	{
	// get indexes into wp lists
	integer beg_index  = llList2Integer(dest_beg_index, dest_index);
	integer end_index  = beg_index + llList2Integer(dest_wp_count, dest_index) - 1;

	// create forward list
	list    fwd_vector  = [llGetPos()] + llList2List(wp_vector, beg_index, end_index);
	list    vector_typ  = llList2List(wp_type, beg_index, end_index);
	integer list_length = llGetListLength(fwd_vector);

	// create reverse list
	list    rev_vector = fwd_vector;
	integer index;

	// fix reverse list
	for (index = (list_length-1); index > 0; index--)
		{
		// convert relative vector to absolute, previous absolute vector to relative
		vector tmp1 = llList2Vector(rev_vector, index);
		vector tmp2 = llList2Vector(rev_vector, index-1);
		integer change = FALSE;
		if (tmp1.x < 0.0)
			{
			tmp1.x = 256.0 + tmp1.x;
			tmp2.x = 256.0 + tmp2.x;
			change = TRUE;
			}
		else if (tmp1.x >= 256)
			{
			tmp1.x = tmp1.x - 256.0;
			tmp2.x = tmp2.x - 256.0;
			change = TRUE;
			}
		if (tmp1.y < 0.0)
			{
			tmp1.y = 256.0 + tmp1.y;
			tmp2.y = 256.0 + tmp2.y;
			change = TRUE;
			}
		else if (tmp1.y >= 256.0)
			{
			tmp1.y = tmp1.y - 256.0;
			tmp2.y = tmp2.y - 256.0;
			change = TRUE;
			}
		if (change)
			{
			rev_vector = llListReplaceList(rev_vector, [tmp2, tmp1], index-1, index);
			index--;
			}
		}

	// teleport by waypoints
	for (index = 1; index < list_length; index++)
		{
		if (llList2String(vector_typ, index-1) == "WARP")
			{
			warpPos(llList2Vector(fwd_vector, index));
//llOwnerSay("Warp to " + (string)llList2Vector(fwd_vector, index));
			}
		else if (llList2String(vector_typ, index-1) == "MOVE")
			{
			llSetPos(llList2Vector(fwd_vector, index));
//llOwnerSay("Move to " + (string)llList2Vector(fwd_vector, index));
			}
		else
			llOwnerSay("Index " + (string)index + " failed");
//llSleep(3.0);
		}

	// unsit av
	llUnSit(llAvatarOnSitTarget());
//llOwnerSay("At dest");

	// return object by inverted route
	for (index = (list_length-2); index >= 0; index--)
		{
		if (llList2String(vector_typ, index) == "WARP")
			{
			warpPos(llList2Vector(rev_vector, index));
//llOwnerSay("Warp to " + (string)llList2Vector(rev_vector, index));
			}
		else if (llList2String(vector_typ, index) == "MOVE")
			{
			llSetPos(llList2Vector(rev_vector, index));
//llOwnerSay("Move to " + (string)llList2Vector(rev_vector, index));
			}
		else
			llOwnerSay("Index " + (string)index + " failed");
//llSleep(3.0);
		}
//llOwnerSay("At home");

	return 0;
	}

//----------------------------------------------------------------------//
// warPos - from LSL Wiki                                               //
//----------------------------------------------------------------------//
warpPos(vector destpos)
	{
	//R&D by Keknehv Psaltery, 05/25/2006
	//with a little pokeing by Strife, and a bit more
	//some more munging by Talarus Luan
	//Final cleanup by Keknehv Psaltery

	// Compute the number of jumps necessary
	integer jumps = (integer)(llVecDist(destpos, llGetPos()) / 10.0) + 1;

	// Limit jumps to avoid stack/heap collisions
	if (jumps > 100)
		jumps = 100;    //  1km should be plenty

	list rules = [PRIM_POSITION, destpos];  //The start for the rules list
	integer count = 1;
	while ((count = count << 1) < jumps)
		rules = (rules=[]) + rules + rules;   //should tighten memory use.

	llSetPrimitiveParams(rules + llList2List(rules, (count - jumps) << 1, count));
	if (llVecDist(llGetPos(), destpos) > .001) //Failsafe
		while (--jumps) 
			llSetPos(destpos);
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
		// initialize
		llSetSitText("Teleport");
		llSitTarget(<0.0, 0.0, 0.1>, ZERO_ROTATION);
		llSetText("Inactive", TEXT_COLOR, 1.0);

		// unsit any AV
		if (llAvatarOnSitTarget() != NULL_KEY)
			llUnSit(llAvatarOnSitTarget());

		// clear config globals
		wp_vector = [];
		wp_type   = [];
		wp_index  = 0;

		dest_desc      = [];
		dest_beg_index = [];
		dest_wp_count  = [];
		dest_index     = 0;

		// get config file name
		config_file_name = llGetInventoryName(INVENTORY_NOTECARD, 0);
		if (config_file_name == "")
			{
			llSay(0,"Configuration notecard not found.");
			return;
			}

		// request first line of file
		config_file_line = 0;
		config_query_id = llGetNotecardLine(config_file_name, config_file_line);
		}

	dataserver(key query_id, string data)
		{
		// finished reading config
		if (data == EOF)
			{
			if (llGetListLength(wp_vector) > 0)
				state active;
			else
				llSay(0, "No valid destinations found");
			return;
			}

		// parse line from config file
		parse_config_line(data);
		config_file_line++;
		config_query_id = llGetNotecardLine(config_file_name, config_file_line);
		}

	changed(integer change)
		{
		// check for changed config file
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
		// announce loaded destinations
		llOwnerSay("Loaded destinations:");
		for (dest_index = 0; dest_index < llGetListLength(dest_desc); dest_index++)
			llOwnerSay(llList2String(dest_desc, dest_index));

		// set up first destination
		dest_index = 0;
		set_text(dest_index);
		}

	touch_start(integer total_number)
		{
		dest_index++;
		if (dest_index >= llGetListLength(dest_desc))
			dest_index = 0;
		set_text(dest_index);
		}

	changed(integer change)
		{
		// check for changed config file
		if (change & CHANGED_INVENTORY)
			llResetScript();

		// check for change link
		else if (change & CHANGED_LINK)
			{
			// check for AV sit
			if (llAvatarOnSitTarget() == NULL_KEY)
				return;

			// teleport
			teleport();
			}
		}
	}
