//----------------------------------------------------------------------//
// color test                                                           //
//----------------------------------------------------------------------//
float SLEEP_TIME = 0.1;
float COLOR_STEP = 0.1;

default
    {
    state_entry()
        {
        integer round = 0;
        while(1)
            {
            vector color;
            float new_color;
            for (new_color = 0.0; new_color < 1.0; new_color += COLOR_STEP)
                {
                if (round == 0)
                    color = <new_color, 0.0, 1.0>;
                else if (round == 1)
                    color = <1.0, new_color, 0.0>;
                else
                    color = <0.0, 1.0, new_color>;
                llSetColor(color, ALL_SIDES);
                llSleep(SLEEP_TIME);
                }

            for (new_color = 1.0; new_color > 0.0; new_color -= COLOR_STEP)
                {
                if (round == 0)
                    color = <1.0, 0.0, new_color>;
                else if (round == 1)
                    color = <new_color, 1.0, 0.0>;
                else
                    color = <0.0, new_color, 1.0>;
                llSetColor(color, ALL_SIDES);
                llSleep(SLEEP_TIME);
                }
            round++;
            if (round > 2)
                round = 0;

            }
        }
    }


