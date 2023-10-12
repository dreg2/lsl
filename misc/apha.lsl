//----------------------------------------------------------------------//
// general alpha script                                                 //
//----------------------------------------------------------------------//

float FADE_TIME = 5.0;    // time to fade in or out in seconds
float OUT_TIME  = 5.0;    // time to stay faded out
float IN_TIME   = 5.0;    // time to stay faded in
float TIME_STEP = 0.1;    // time step for fade
float ALPHA_MAX = 0.5;    // maximum alpha
float ALPHA_MIN = 0.0;    // minimun alpha

float alpha;

float fade_step;


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
        alpha = ALPHA_MAX;
        llSetLinkAlpha(LINK_SET, alpha, ALL_SIDES);
        state wait;
        }
    }

state wait
    {
    on_rez(integer start_param)
        {
        llResetScript();
        }

    state_entry()
        {
        if (alpha >= ALPHA_MAX)
            llSetTimerEvent(IN_TIME);
        else
            llSetTimerEvent(OUT_TIME);
        }

    timer()
        {
        state fade;
        }
    }

state fade
    {
    on_rez(integer start_param)
        {
        llResetScript();
        }

    state_entry()
        {
        fade_step = TIME_STEP / FADE_TIME;
        if (alpha >= ALPHA_MAX)
            fade_step = -fade_step;
            
        llSetTimerEvent(TIME_STEP);
        }

    timer()
        {
        alpha += fade_step;
        llSetLinkAlpha(LINK_SET, alpha, ALL_SIDES);

        if (alpha >= ALPHA_MAX)
            {
            alpha = ALPHA_MAX;
            state wait;
            }
        if (alpha <= ALPHA_MIN)
            {
            alpha = ALPHA_MIN;
            state wait;
            }

        llSetTimerEvent(TIME_STEP);
        }
    }


