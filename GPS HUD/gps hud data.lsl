//------------------------------------------------------------------------//
// GPS HUD - data module                                                  //
//------------------------------------------------------------------------//

// link message formats
// DI^C^T^TS           Directional indicator message: Compass(0-360), Track(0-360), Track Speed
// BC^SW^SO:N^PW       Boundry Crossing message: Sim Warn(0,1,2),Sim Crossing(Old:New),Parcel Warn(0,1,2)
// AL^AG^AW^AT^WD^ROC  Altitude message: Above Ground, Above Water, Above Terrain, Water Depth, Rate of Climb
// WI^DI^SP            Wind message: Direction(0-360), Speed

// Constants
float TIMER_INTERVAL = 2.0;

float MPS_TO_KNOTS = 1.94385;
float MPS_TO_MPH   = 2.23964;
float MPS_TO_KPH   = 3.60000;
float M_TO_F       = 3.28084;

float  CAUT_TIME = 10.0;
float  WARN_TIME =  5.0;

// Globals
vector curr_sim_pos;
string curr_sim_name;
vector curr_lcl_pos;
vector curr_gbl_pos;
vector curr_rot;
float  curr_ground_alt;
float  curr_water_alt;
vector curr_wind;

vector prev_sim_pos;
string prev_sim_name;
vector prev_lcl_pos;
vector prev_gbl_pos;
vector prev_rot;

//
// functions
//

//------------------------------------------------------------------------//
// fixedPrecsion - convert float to fixed precision string                //
//------------------------------------------------------------------------//
string fixedPrecision(float input, integer precision)
	{
	if ((precision = (precision - 7 - (precision < 1))) & 0x80000000)
		return llGetSubString((string)input, 0, precision);
	return (string)input;
	}

//------------------------------------------------------------------------//
// math_to_nav - convert angle from math (-PI,PI) to navigation (0,360)   //
//------------------------------------------------------------------------//
float math_to_nav(float angle)
	{
	// convert from math polar system to navigational polar system
	angle = ((angle - (PI)) * -1.0) - (PI_BY_TWO);
	if (angle < 0)
		angle += (TWO_PI);

	// contvert radians to degrees
	angle *= RAD_TO_DEG;

	return angle;
	}

//------------------------------------------------------------------------//
// cart_to_polar - convert cartesian coordinate to polar coordinate       //
//------------------------------------------------------------------------//
vector cart_to_polar(vector cart)
	{
	vector polar;

	// get polar vector magnitude
	polar.x = llSqrt((cart.x * cart.x) + (cart.y * cart.y));

	// get polar vector angle
	if (cart.x != 0.0)
		polar.y = llAtan2(cart.y, cart.x);
	else
		polar.y = PI_BY_TWO;

	// convert to navigation angle
	polar.y = math_to_nav(polar.y);

	return polar;
	}

//------------------------------------------------------------------------//
// get_data - get current position data                                   //
//------------------------------------------------------------------------//
get_data()
	{
	curr_sim_pos  = llGetRegionCorner();
	curr_sim_name = llGetRegionName();
	curr_lcl_pos  = llGetPos();
	curr_gbl_pos  = curr_sim_pos + curr_lcl_pos;
	curr_rot      = llRot2Euler(llGetRot());
	curr_ground_alt = llGround(<0.0, 0.0, 0.0>);
	curr_water_alt  = llWater(<0.0, 0.0, 0.0>);
	curr_wind       = llWind(ZERO_VECTOR);
	}

//
// States
//
default
	{
	on_rez(integer param)
		{
		llResetScript();
		}

	state_entry()
		{
		// initialize globals
		get_data();
		prev_sim_pos  = curr_sim_pos;
		prev_sim_name = curr_sim_name;
		prev_lcl_pos  = curr_lcl_pos;
		prev_gbl_pos  = curr_gbl_pos;
		prev_rot      = curr_rot;

		llSetTimerEvent(TIMER_INTERVAL);
		}

	timer()
		{
		// get current position data
		get_data();

		// create and send link messages
		string message;

		// Directional indicator message
		// DI^C^T^TS        Directional indicator message: Compass(0-360),Track(0-360),Track Speed
		message = "DI^";

		// calculate speed vector
		vector speed_cart  = (curr_gbl_pos - prev_gbl_pos) / TIMER_INTERVAL;
		vector speed_polar = cart_to_polar(speed_cart);
		speed_polar.x *= MPS_TO_KNOTS;

		message += (string)(llRound(math_to_nav(curr_rot.z))) + "^"
				+ (string)(llRound(speed_polar.y)) + "^"
				+ fixedPrecision(speed_polar.x, 1);

		llMessageLinked(LINK_SET, 1, message, NULL_KEY);


		// Boundry crossing message
		// BC^SW^SO^N^PW    Boundry Crossing message: Sim Warn(0,1,2),Sim Crossing(Old:New),Parcel Warn(0,1,2)
		message = "BC^";

		// calculate what the position will be in CAUT_TIME and WARN_TIME seconds
		vector caut_pos = curr_lcl_pos + (speed_cart * CAUT_TIME);
		vector warn_pos = curr_lcl_pos + (speed_cart * WARN_TIME);

		// set text color
		if (warn_pos.x > 256.0 || warn_pos.x < 0 || warn_pos.y > 256.0 || warn_pos.y < 0)
			message += "2^";
		else if (caut_pos.x > 256.0 || caut_pos.x < 0 || caut_pos.y > 256.0 || caut_pos.y < 0)
			message += "1^";
		else
			message += "0^";

		// detect sim crossing
		if (curr_sim_pos != prev_sim_pos)
			message += prev_sim_name + ":" + curr_sim_name + "^";
		else
			message += "^";

		// check for "no entry" parcel ahead
		if (llGetParcelFlags(warn_pos) & (PARCEL_FLAG_USE_ACCESS_GROUP | PARCEL_FLAG_USE_ACCESS_LIST))
			message += "2";
		else if (llGetParcelFlags(caut_pos) & (PARCEL_FLAG_USE_ACCESS_GROUP | PARCEL_FLAG_USE_ACCESS_LIST))
			message += "1";
		else
			message += "0";

		llMessageLinked(LINK_SET, 2, message, NULL_KEY);


		// Altitude message
		// AL^AG^AW^AT^WD^ROC  Altitude message: Above Ground, Above Water, Above Terrain, Water Depth, Rate of Climb
		message = "AL^";

		// determine altitudes
		float alt_agl = curr_gbl_pos.z - curr_ground_alt;
		float alt_awl = curr_gbl_pos.z - curr_water_alt;
		float alt_atl = alt_agl;
		float wat_dep = 0.0;
		if (alt_agl > alt_awl)
			{
			alt_atl = alt_awl;
			wat_dep = alt_agl - alt_awl;
			}

		message += fixedPrecision(alt_agl, 1) + "^"
				+ fixedPrecision(alt_awl, 1) + "^"
				+ fixedPrecision(alt_atl, 1) + "^"
				+ fixedPrecision(wat_dep, 1) + "^"
				+ fixedPrecision(speed_cart.z, 1);

		llMessageLinked(LINK_SET, 3, message, NULL_KEY);


		// Wind message
		// WI^DI^SP         Wind message: Direction(0-360), Speed
		message = "WI^";

		// determine wind
		vector wind_polar = cart_to_polar(curr_wind);
		wind_polar.y -= 180.0;
		if (wind_polar.y < 0)
			wind_polar.y += 360.0;
		wind_polar.x *= MPS_TO_KNOTS;

		message += (string)(llRound(wind_polar.y)) + "^" + fixedPrecision(wind_polar.x, 1);

		llMessageLinked(LINK_SET, 4, message, NULL_KEY);


		// save previous position information
		prev_sim_pos  = curr_sim_pos;
		prev_sim_name = curr_sim_name;
		prev_lcl_pos  = curr_lcl_pos;
		prev_gbl_pos  = curr_gbl_pos;
		prev_rot      = curr_rot;
		}
	}

