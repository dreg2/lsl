//----------------------------------------------------------------------//
// give inventory                                                       //
//----------------------------------------------------------------------//

// Constants

// inventory types to give out
list    INVENTORY_TYPES = [
			INVENTORY_BODYPART,
			INVENTORY_CLOTHING,
			INVENTORY_LANDMARK,
			INVENTORY_NOTECARD,
			INVENTORY_OBJECT,
			INVENTORY_SCRIPT,
			INVENTORY_SOUND,
			INVENTORY_TEXTURE
			];

// runtime constants
integer INVENTORY_TYPES_COUNT;
string  MY_NAME;


//
// States
//

default
	{
	state_entry()
		{
		// initialze runtime constants
		INVENTORY_TYPES_COUNT = llGetListLength(INVENTORY_TYPES);
		MY_NAME = llGetScriptName();
		}

	touch_start(integer num_detected)
		{
		// loop through all AVs touching
		integer i;
		for (i = 0; i < num_detected; i++)
			{
			key target = llDetectedKey(i);
			integer j;
			integer k;

			// loop through all inventory types
			for (j = 0; j < INVENTORY_TYPES_COUNT; j++)
				{
				// get inventory type and count
				integer type = llList2Integer(INVENTORY_TYPES, j);
				integer type_count = llGetInventoryNumber(type);

				// loop through all inventory items
				for (k = 0; k < type_count; k++)
					{
					string object_name = llGetInventoryName(type, k);
					if (object_name != MY_NAME) // don't give this script out
						{
						// give touching AV inventory item
						llGiveInventory(target, object_name);
						}
					}
				}
			}
		}
	}

