//----------------------------------------------------------------------//
// radio setter                                                         //
//----------------------------------------------------------------------//

//
// Constants
//

vector  TEXT_COLOR = <1.0, 1.0, 1.0>;
vector  ERROR_TEXT_COLOR = <1.0, 0.0, 0.0>;
float   TEXT_ALPHA = 1.0;

integer REMOTE_CHANNEL = 62;

string PARCEL_NAME;

//
// Functions
//

//----------------------------------------------------------------------//
// set_hover_text - set object hover text                               //
//----------------------------------------------------------------------//
set_hover_text(string text)
	{
	string hover_text = llGetObjectName() + "\nNow playing" + "\n" + text;
	llSetText(hover_text, TEXT_COLOR, TEXT_ALPHA);
	}

//----------------------------------------------------------------------//
// set_station - set parcel music station                               //
//----------------------------------------------------------------------//
set_station(string url, string name)
	{
	llSetParcelMusicURL(url);
	set_hover_text(name);
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
		// tell remote script we are here
		llMessageLinked(LINK_SET, 0, "SETTER", NULL_KEY);

		// initialize runtime constants
		list lstParcelDetails = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME, PARCEL_DETAILS_OWNER]);
		PARCEL_NAME      = llList2String(lstParcelDetails, 0);
		key PARCEL_OWNER_KEY = llList2Key(lstParcelDetails, 1);
		key OWNER_KEY        = llGetOwner();
//		CREATOR_KEY = llGetCreator(); // for debug instant messages
		llSetText("", <0.0, 0.0, 0.0>, 0.0);

		llSay(0, "Radio initializing for " + PARCEL_NAME + "...");
		llSetText(llGetObjectName() + " initializing....", TEXT_COLOR, TEXT_ALPHA);

		// check owner matches parcel owner
		if (PARCEL_OWNER_KEY != OWNER_KEY)
			{
			llSetText(llGetObjectName() + " must be owned by\nthe parcel owner to function", ERROR_TEXT_COLOR, TEXT_ALPHA);
			llSay(0, "This radio system is not owned by the parcel owner.");
			llSay(0, "This radio will not function unless it is owned by the parcel owner.");
			return;
			}

		llListen(REMOTE_CHANNEL, "", NULL_KEY, "");
		llSetText(llGetObjectName() + " ready\nTouch for menu", TEXT_COLOR, TEXT_ALPHA);
		llSay(0, llGetObjectName() + " ready for " + PARCEL_NAME + ".");
		}

	listen (integer channel, string name, key id, string message)
		{
		list command = llParseString2List(message, ["^"], []);

		// ignore messages from other setters
		if (llList2String(command, 0) == "S")
			return;

		// only process messages from remote
		if (llList2String(command, 0) == "R")
			{
			if (llList2String(command, 1) == "HANDSHAKE")
				{
				// handshake request, reply
				llRegionSay(REMOTE_CHANNEL, "S^PARCEL^" + PARCEL_NAME);
				return;
				}
			else if (llList2String(command, 1) == "STATION")
				{
				// station change request
				set_station(llList2String(command, 2), llList2String(command, 3));
				}
			}
		}

	link_message(integer sender_num, integer num, string str, key id)
		{
		list command = llParseString2List(str, ["^"], []);

		// only process messages from remote
		if (llList2String(command, 0) == "R")
			{
			if (llList2String(command, 1) == "HANDSHAKE")
				{
				// handshake request, reply
				llMessageLinked(LINK_SET, 0, "S^HANDSHAKE", NULL_KEY);
				return;
				}
			else if (llList2String(command, 1) == "STATION")
				{
				// station change request
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
