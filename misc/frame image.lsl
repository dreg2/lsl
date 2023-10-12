//----------------------------------------------------------------------//
// frame image                                                          //
//----------------------------------------------------------------------//
string FRAME_TEXTURE_UUID = "a25bebc8-4739-453d-d44e-fc522cf95488";

float frame_ratio = 0.05;

default
	{
	state_entry()
		{
		list prim_params = llGetPrimitiveParams([PRIM_SIZE]);

		float  aspect_ratio;
		vector taper;
		vector prim_size = llList2Vector(prim_params, 0);

		if (prim_size.x > prim_size.y)
			{
			aspect_ratio = prim_size.x / prim_size.y;
			taper = <1.0 - frame_ratio, 1.0 - (frame_ratio * aspect_ratio), 0.0>;
			}
		else
			{
			aspect_ratio = prim_size.y / prim_size.x;
			taper = <1.0 - (frame_ratio * aspect_ratio), 1 - frame_ratio, 0.0>;
			}

		llSetPrimitiveParams([
			PRIM_SIZE, <prim_size.x, prim_size.y, 0.01>,
			PRIM_TYPE, PRIM_TYPE_BOX, 0, <0.0, 1.0, 0.0>, 0.0, <0.0, 0.0, 0.0>, taper, <0.0, 0.0, 0.0>,
			PRIM_TEXTURE, 1, FRAME_TEXTURE_UUID, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,
			PRIM_TEXTURE, 2, FRAME_TEXTURE_UUID, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,
			PRIM_TEXTURE, 3, FRAME_TEXTURE_UUID, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,
			PRIM_TEXTURE, 4, FRAME_TEXTURE_UUID, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0
			]);

		llRemoveInventory(llGetScriptName());
		}
	}

