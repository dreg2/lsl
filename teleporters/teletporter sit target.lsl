vector offset = <0.0, 0.0, 5.0>; 

string text_value  = "2nd Deck";
vector text_color = <0.0, 1.0, 0.0>;
float  text_alpha = 1.0;
string sit_text   = "Teleport";

default
	{
	state_entry()
		{
		llSetText(text_value, text_color, text_alpha);
		llSetSitText(sit_text);
		llSitTarget(offset, ZERO_ROTATION);
		}

	changed(integer change)
		{
		if (change & CHANGED_LINK)
			{
			key av_key = llAvatarOnSitTarget();
			if (av_key != NULL_KEY)
				{
				llSleep(0.2);
				llUnSit(av_key);
				}
			}
		}
	}

