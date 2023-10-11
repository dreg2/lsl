//----------------------------------------------------------------------//
// radio setter                                                         //
//----------------------------------------------------------------------//

// Constants
vector  TEXT_COLOR = <1.0, 1.0, 1.0>;
vector  ERROR_TEXT_COLOR = <1.0, 0.0, 0.0>;
float   TEXT_ALPHA = 1.0;
integer REMOTE_CHANNEL = 62;

// Run-time Constants
string PARCEL_NAME;

// Globals
string station_url  = "";
string station_name = "";

//
// Functions
//

//----------------------------------------------------------------------//
// set_station - set parcel music station                               //
//----------------------------------------------------------------------//
set_station(string url, string name)
	{
	station_url  = url;
	station_name = name;

	llSetParcelMusicURL(url);
	llMessageLinked(LINK_SET, 0, "S^STATION^" + name, NULL_KEY);
	llRegionSay(REMOTE_CHANNEL, "S^STATION^" + name);
	llSay(0, "Station set to " + name);
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
		// initialize runtime constants
		list lstParcelDetails = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME, PARCEL_DETAILS_OWNER]);
		PARCEL_NAME           = llList2String(lstParcelDetails, 0);
		key PARCEL_OWNER_KEY  = llList2Key(lstParcelDetails, 1);
		key OWNER_KEY         = llGetOwner();
//		CREATOR_KEY           = llGetCreator(); // for debug instant messages

		// check owner matches parcel owner
		if (PARCEL_OWNER_KEY != OWNER_KEY)
			{
			llSay(0, "This radio system is not owned by the parcel owner.");
			llSay(0, "This radio will not function unless it is owned by the parcel owner.");
			return;
			}

		llListen(REMOTE_CHANNEL, "", NULL_KEY, "");
		}

	listen (integer channel, string name, key id, string message)
		{
		list command = llParseString2List(message, ["^"], []);

		// only process messages from tuner
		if (llList2String(command, 0) == "T")
			{
			if (llList2String(command, 1) == "HANDSHAKE")
				{
				// handshake request, reply
				llRegionSay(REMOTE_CHANNEL, "S^STATION^" + station_name);
				}

			if (llList2String(command, 1) == "STATION")
				{
				// station change request
				set_station(llList2String(command, 2), llList2String(command, 3));
				}
			}
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		list command = llParseString2List(str, ["^"], []);

		// only process messages from tuner
		if (llList2String(command, 0) == "T")
			{
			if (llList2String(command, 1) == "HANDSHAKE")
				{
				// handshake request, reply
				llMessageLinked(LINK_SET, 0, "S^STATION^" + station_name, NULL_KEY);
				}

			else if (llList2String(command, 1) == "STATION")
				{
				// station request
				set_station(llList2String(command, 2), llList2String(command, 3));
				}
			}
		}

	changed(integer change)
		{
		if (change & CHANGED_OWNER)
			llResetScript();
		}

	}
