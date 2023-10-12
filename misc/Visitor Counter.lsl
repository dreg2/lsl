
// Constants
float RANGE     = 10.0; // in meters
float RATE      = 10.0;  // in seconds
integer CHANNEL = 10;
 
// Global variables
list visitor_list;

// Functions
integer isNameOnList(string name)
    {
    integer len = llGetListLength(visitor_list);
    integer i;
    for (i = 0; i < len; i++)
        {
        if (llList2String(visitor_list, i) == name)
            {
            return TRUE;
            }
        }

    return FALSE;
    }

// States
default
    {
    state_entry()
        {
        llSay(0, "Visitor List Maker started...");
        llSay(0, "The owner can say '/" + (string)CHANNEL + "help' for instructions.");
        llSensorRepeat( "", "", AGENT, RANGE, PI_BY_TWO, RATE );
//        llListen(CHANNEL, "", llGetOwner(), "");
        llListen(CHANNEL, "", NULL_KEY, "");
        }


    sensor(integer number_detected)
        {
        integer i;
        for (i = 0; i < number_detected; i++)
            {
            if (llDetectedKey(i) != llGetOwner())
                {
                string detected_name = llDetectedName(i);
                if (isNameOnList(detected_name) == FALSE)
                    {
                    llOwnerSay("Added: " + detected_name);
                    visitor_list += detected_name;
                    }
                }
            }    
        }

    listen (integer channel, string name, key id, string message)
        {
        if (channel != CHANNEL)
            return;

//        if (id != llGetOwner())
        if (!llSameGroup(id))
            {
            return;
            }

        if (message == "help")
            {
            llSay(0, "This object records the names of everyone who");
            llSay(0, "comes within "+ (string)RANGE + " meters.");
            llSay(0, "Commands the owner can say:");
            llSay(0, "'/" + (string)CHANNEL + "help'  - Shows these instructions.");
            llSay(0, "'/" + (string)CHANNEL + "list'  - Says the names of all visitors on the list.");
            llSay(0, "'/" + (string)CHANNEL + "reset' - Removes all the names from the list.");
            }

        else if (message == "list")
            {
            llSay(0, "Visitor List:");
            integer len = llGetListLength(visitor_list);
            integer i;
            for (i = 0; i < len; i++)
                {
                llSay(0, llList2String(visitor_list, i));
                }
            llSay( 0, "Total = " + (string)len ); 
            }

        else if (message == "reset")
            {
            visitor_list = llDeleteSubList(visitor_list, 0, llGetListLength(visitor_list));
            llSay(0, "Done resetting.");
            }
        }        
    }



