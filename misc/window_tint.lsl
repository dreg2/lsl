//----------------------------------------------------------------------//
// change texture on touch                                              //
//----------------------------------------------------------------------//
integer texture_count;
integer texture_index = 0;
integer CHANNEL = -734562;

// display texture
display_texture(integer index)
    {
    string name = llGetInventoryName(INVENTORY_TEXTURE, index);
    if (name != "")
        llSetTexture(name, ALL_SIDES);
    }

default
    {
    changed(integer change)
        {
        // reset script on inventory change
        if (change & CHANGED_INVENTORY)
            llResetScript();
        }

    state_entry()
        {
        // initialize
        texture_index = 0;
        texture_count = llGetInventoryNumber(INVENTORY_TEXTURE);
        if (texture_count == 0)
            llOwnerSay("No textures found in object inventory");
        display_texture(texture_index);
        llListen(CHANNEL, "", NULL_KEY, "");
        }

    listen(integer channel, string name, key id, string message)
        {
        texture_index = (integer)message;
        display_texture(texture_index);
        }

    touch_start(integer total_number)
        {
        // display next texture
        texture_index++;
        if (texture_index >= texture_count)
            texture_index = 0;
        display_texture(texture_index);
        llRegionSay(CHANNEL, (string)texture_index);
        }
    }

