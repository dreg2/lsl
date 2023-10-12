//------------------------------------------------------------------------//
// set agent camera                                                       //
//------------------------------------------------------------------------//

// This will let us follow behind with a loose camera.
list camera_params =
    [
    CAMERA_ACTIVE,             TRUE,
    CAMERA_BEHINDNESS_ANGLE,   0.0,
    CAMERA_BEHINDNESS_LAG,     0.2,
    CAMERA_DISTANCE,           3.0,
    CAMERA_PITCH,              10.0,
//  CAMERA_FOCUS,              <0,0,0>, // region-relative position
    CAMERA_FOCUS_LAG,          0.05,
    CAMERA_FOCUS_LOCKED,       FALSE,
    CAMERA_FOCUS_THRESHOLD,    0.0,
    CAMERA_FOCUS_OFFSET,       <-7.0, 0.0, 3.0>,
//  CAMERA_POSITION,           <0,0,0>, // region-relative position
    CAMERA_POSITION_LAG,       0.3,
    CAMERA_POSITION_LOCKED,    FALSE,
    CAMERA_POSITION_THRESHOLD, 0.0
    ];

default
    {
    state_entry()
        {
	// clear offsets
        llSetCameraEyeOffset(<0.0, 0.0, 0.0>);
        llSetCameraAtOffset(<0.0, 0.0, 0.0>);
        }

    on_rez(integer param)
        {
        llResetScript();
        }

    changed(integer change)
        {
        if (!(change & CHANGED_LINK))
            return;

	// agent sat
        key agent = llAvatarOnSitTarget();
        if (agent)
            {
            llRequestPermissions(agent, PERMISSION_CONTROL_CAMERA);
            }
        }

    run_time_permissions(integer perm)
        {
	// set camera
        if (perm & PERMISSION_CONTROL_CAMERA)
            {
//            llClearCameraParams();
            llSetCameraParams(camera_params);
            }
        }
    }



