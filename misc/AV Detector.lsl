//----------------------------------------------------------------------//
// AV detector                                                          //
//----------------------------------------------------------------------//

// Constants
float SCAN_RATE = 1.0;
float SCAN_RANGE = 96.0;
vector TEXT_COLOR = <0.0, 0.0, 0.0>;
string NULL_CHAR = "_";

default
	{
	on_rez(integer param)
		{
		llResetScript();
		}

	state_entry()
		{
		// initialize
		llSetText("Initializing...", TEXT_COLOR, 1.0);
		llSetTimerEvent(SCAN_RATE);
//		llSensorRepeat("", "", AGENT, SCAN_RANGE, PI, SCAN_RATE);
		}

	timer()
		{
		llSensor("", "", AGENT, SCAN_RANGE, PI);
		}

	no_sensor()
		{
		// no agents found
		llSetText("No Agents", TEXT_COLOR, 1.0);
		}

	sensor(integer num)
		{
		string text = "";
		integer count = 1;
		vector pos = llGetPos();

		// loop through found agents
		integer index;
		for (index = 0; index < 9; index++)
			{
			if (index < num)
				{
				list flags = [];
				key det_key = llDetectedKey(index);
				integer info = llGetAgentInfo(det_key);

				// set up agent status flags
				if (info & AGENT_AWAY)
					flags += ["A"];
				else if (info & AGENT_BUSY)
					flags += ["B"];
				else
					flags += [NULL_CHAR];

				if (info & AGENT_TYPING)
					flags += ["T"];
				else
					flags += [NULL_CHAR];

				if (info & AGENT_FLYING)
					flags += ["F"];
				else if (info & AGENT_IN_AIR)
					flags += ["H"];
				else if (info & AGENT_CROUCHING)
					flags += ["C"];
				else if (info & AGENT_ON_OBJECT)
					flags += ["O"];
				else if (info & AGENT_SITTING)
					flags += ["S"];
				else if (info & AGENT_WALKING)
					flags += ["W"];
				else
					flags += [NULL_CHAR];

				if (info & AGENT_ALWAYS_RUN)
					flags += ["R"];
				else
					flags += [NULL_CHAR];

				if (info & AGENT_MOUSELOOK)
					flags += ["M"];
				else
					flags += [NULL_CHAR];

				if (info & AGENT_SCRIPTED)
					flags += ["S"];
				else if (info & AGENT_ATTACHMENTS)
					flags += ["A"];
				else
					flags += [NULL_CHAR];

				// add to floating text
				text += (string)count + " "
					+ llDetectedName(index)
					+ " " + llDumpList2String(flags,"") + " "
					+ (string)(llRound(llVecDist(pos, llDetectedPos(index)))) + "\n";
				count++;
				}
			else
				text += " \n";

			}

		if (num > 9)
			text += "More";
		else
			text += " \n";

		llSetText(text, TEXT_COLOR, 1.0);
		}
	}

