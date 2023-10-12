//----------------------------------------------------------------------//
// countdown timer driver                                               //
//----------------------------------------------------------------------//

// Constants
float  UPDATE_TIME     =  1.0; // in seconds

integer DAYS           = 0;
integer HOURS          = 1;
integer MINUTES        = 2;
integer SECONDS        = 3;

integer SECS_PER_MINUTE = 60;
integer SECS_PER_HOUR   = 3600;
integer SECS_PER_DAY    = 86400;

// menu
string MISC_MAIN       = "Main Menu";
string MISC_CLOSE      = "Close";

string MAIN_START      = "Start";
string MAIN_STOP       = "Stop";
string MAIN_CLEAR      = "Clear";
string MAIN_RESET      = "Reset";
string MAIN_DAYS       = "Days";
string MAIN_HOURS      = "Hours";
string MAIN_MINUTES    = "Minutes";
list MAIN_MENU = [MAIN_DAYS, MAIN_HOURS, MAIN_MINUTES, MAIN_STOP, MAIN_RESET, MAIN_CLEAR, MAIN_START];

string DAYS_INC1       = "+1 Day";
string DAYS_DEC1       = "-1 Day";
string DAYS_INC7       = "+5 Days";
string DAYS_DEC7       = "-5 Days";
list DAYS_MENU = [MISC_MAIN, MAIN_HOURS, MAIN_MINUTES, DAYS_INC1, DAYS_DEC1, DAYS_INC7, DAYS_DEC7];

string HOURS_INC1       = "+1 Hour";
string HOURS_DEC1       = "-1 Hour";
string HOURS_INC6       = "+6 Hours";
string HOURS_DEC6       = "-6 Hours";
list HOURS_MENU = [MISC_MAIN, MAIN_DAYS, MAIN_MINUTES, HOURS_INC1, HOURS_DEC1, HOURS_INC6, HOURS_DEC6];

string MINUTES_INC1     = "+1 Minute";
string MINUTES_DEC1     = "-1 Minute";
string MINUTES_INC10    = "+5 Minutes";
string MINUTES_DEC10    = "-5 Minutes";
list MINUTES_MENU = [MISC_MAIN, MAIN_DAYS, MAIN_HOURS, MINUTES_INC1, MINUTES_DEC1, MINUTES_INC10, MINUTES_DEC10];

// globals
integer MENU_CHANNEL;
integer time_offset    = 0; // in seconds
integer time_target    = 0; // in seconds
integer time_remaining = 0; // in seconds

integer current_menu   = 0;

integer running        = 0;

list time_convert(integer time)
    {
    integer days    = time / SECS_PER_DAY;
    integer hours   = (time % SECS_PER_DAY)  / SECS_PER_HOUR;
    integer minutes = (time % SECS_PER_HOUR) / SECS_PER_MINUTE;
    integer seconds = time % SECS_PER_MINUTE;

    return [days, hours, minutes, seconds];
    }

string time_format(list time_list)
    {
    string sdays = llList2String(time_list, DAYS);
    if (llList2Integer(time_list, DAYS) < 10)
        sdays = "0" + sdays;

    string shours = llList2String(time_list, HOURS);
    if (llList2Integer(time_list, HOURS) < 10)
        shours = "0" + shours;

    string sminutes = llList2String(time_list, MINUTES);
    if (llList2Integer(time_list, MINUTES) < 10)
        sminutes = "0" + sminutes;

    string sseconds = llList2String(time_list, SECONDS);
    if (llList2Integer(time_list, SECONDS) < 10)
        sseconds = "0" + sseconds;

    return sdays + ":" + shours + ":" + sminutes + ":" + sseconds;
    }

time_display()
    {
    list time_list = time_convert(time_remaining);

    vector color;
    if (running)
        color = <0.0, 1.0, 0.0>;
    else
        color = <1.0, 1.0, 1.0>;
//llSetText("Time remaining\n" + time_format(time_list), color, 1.0);

    // tell hands hours and minutes
    llMessageLinked(LINK_SET, DAYS,    llList2String(time_list, DAYS),    NULL_KEY);
    llMessageLinked(LINK_SET, HOURS,   llList2String(time_list, HOURS),   NULL_KEY);
    llMessageLinked(LINK_SET, MINUTES, llList2String(time_list, MINUTES), NULL_KEY);
    llMessageLinked(LINK_SET, SECONDS, llList2String(time_list, SECONDS), NULL_KEY);
    }

menu_display(key id)
    {
    list time_list = time_convert(time_offset);
    if (current_menu == 0)
        llDialog(id, llGetObjectName() + "\n" + time_format(time_list), MAIN_MENU, MENU_CHANNEL);
    else if (current_menu == 1)
        llDialog(id, llGetObjectName() + "\n" + time_format(time_list), DAYS_MENU, MENU_CHANNEL);
    else if (current_menu == 2)
        llDialog(id, llGetObjectName() + "\n" + time_format(time_list), HOURS_MENU, MENU_CHANNEL);
    else if (current_menu == 3)
        llDialog(id, llGetObjectName() + "\n" + time_format(time_list), MINUTES_MENU, MENU_CHANNEL);
    }

menu_proc(key id, string message)
    {
    if (message == MISC_MAIN)
        current_menu = 0;
    else if (message == MAIN_DAYS)
        current_menu = 1;
    else if (message == MAIN_HOURS)
        current_menu = 2;
    else if (message == MAIN_MINUTES)
        current_menu = 3;

    else if (message == DAYS_INC1)
        time_offset += 1 * SECS_PER_DAY;
    else if (message == DAYS_DEC1)
        time_offset -= 1 * SECS_PER_DAY;
    else if (message == DAYS_INC7)
        time_offset += 5 * SECS_PER_DAY;
    else if (message == DAYS_DEC7)
        time_offset -= 5 * SECS_PER_DAY;

    else if (message == HOURS_INC1)
        time_offset += 1 * SECS_PER_HOUR;
    else if (message == HOURS_DEC1)
        time_offset -= 1 * SECS_PER_HOUR;
    else if (message == HOURS_INC6)
        time_offset += 6 * SECS_PER_HOUR;
    else if (message == HOURS_DEC6)
        time_offset -= 6 * SECS_PER_HOUR;

    else if (message == MINUTES_INC1)
        time_offset += 1 * SECS_PER_MINUTE;
    else if (message == MINUTES_DEC1)
        time_offset -= 1 * SECS_PER_MINUTE;
    else if (message == MINUTES_INC10)
        time_offset += 5 * SECS_PER_MINUTE;
    else if (message == MINUTES_DEC10)
        time_offset -= 5 * SECS_PER_MINUTE;

    else if (message == MISC_CLOSE)
        {
        current_menu = 0;
        return;
        }

    time_remaining = time_offset;
    time_display();

    // re-display menu
    menu_display(id);
    }



default
    {
    on_rez(integer start_param)
        {
        llResetScript();
        }

    state_entry()
        {
        current_menu = 0;
        running      = 0;
        llSetLinkPrimitiveParams(LINK_SET, [PRIM_GLOW, ALL_SIDES, 0.0]);
        time_display();

        // start listener
        MENU_CHANNEL = (((integer)llFrand(2147483647) + 1) * -1);
        llListen(MENU_CHANNEL, "", NULL_KEY, "");
        }

    touch_start(integer num_detected)
        {
        // display menu
//        if (llSameGroup(llDetectedKey(0)))
            menu_display(llDetectedKey(0));
        }

    listen (integer channel, string name, key id, string message)
        {
        // verify source of chat
//        if (!llSameGroup(id))
//            return;

        if (message == MAIN_START)
            state countdown;
        else if (message == MAIN_RESET)
            {
            time_remaining = time_offset;
            time_display();
            }
        else if (message == MAIN_CLEAR)
            {
            time_remaining = 0;
            time_offset    = 0;
            time_display();
            }
        else
            menu_proc(id, message);
        }

    }

state countdown
    {
    on_rez(integer start_param)
        {
        llResetScript();
        }

    state_entry()
        {
        if (time_remaining <= 0)
            state default;

        running = 1;
        llSetLinkPrimitiveParams(LINK_SET, [PRIM_GLOW, ALL_SIDES, 0.5]);

        // get target time
        time_target =  llGetUnixTime() + time_remaining;
        time_display();

        // start listener and timer
        MENU_CHANNEL = (((integer)llFrand(2147483647) + 1) * -1);
        llListen(MENU_CHANNEL, "", NULL_KEY, "");
        llSetTimerEvent(UPDATE_TIME);
        }

    touch_start(integer num_detected)
        {
        // display menu
        if (llSameGroup(llDetectedKey(0)))
            menu_display(llDetectedKey(0));
        }

    listen (integer channel, string name, key id, string message)
        {
        // verify source of chat
        if (!llSameGroup(id))
            return;

        if (message == MAIN_STOP)
            state default;
        else if (message == MAIN_RESET)
            {
            time_remaining = time_offset;
            state default;
            }
        else if (message == MAIN_CLEAR)
            {
            time_remaining = 0;
            time_offset    = 0;
            state default;
            }
        else
            menu_proc(id, message);
        }

    timer()
        {
        // calculate remaining time
        integer time_new = llGetUnixTime();
        time_remaining = time_target - time_new;
        if (time_remaining <= 0)
            state default;

        time_display();
        }
    }

