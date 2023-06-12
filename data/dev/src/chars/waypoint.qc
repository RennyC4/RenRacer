//
// RennyC: Modified from AI Cafe
//

void() waypoint_touch =
{
	if (other.owner.driving.waypoint >= self.waypoint)
		return;

	other.owner.driving.waypoint = self.waypoint;
	other.owner.driving.goalentity = world; // find next waypoint

	if (cvar("developer") == 2)
		sprint (other.owner.driving, "Waypoint_touch: ", ftos(self.waypoint), " / ", ftos(other.owner.driving.waypoint), "\n");
};

void(vector org, float which, optional float cnt) create_waypoint =
{
	local entity wp = spawn();
	wp.classname = "bot_waypoint";
	wp.solid = SOLID_TRIGGER;
	wp.movetype = MOVETYPE_NONE;
	wp.flags = FL_ITEM; // bigger touch box
	wp.touch = waypoint_touch;
	wp.waypoint_speed = cnt;

	if (cvar("developer") == 2)
		setmodel (wp, "progs/s_debug.spr");
	else
		setmodel (wp, "progs/null.spr");

	setorigin(wp, org);
	setsize (wp, VEC_HULL2_MIN, VEC_HULL2_MAX); // bigger touch box

	total_waypoints = total_waypoints + 1;
	wp.waypoint = total_waypoints;
};

void() load_waypoints =
{
	if (world.model == "maps/map2.hmp")
	{
		create_waypoint ('223.221359 -801.661377 141.881393', 1, 30);
		create_waypoint ('2464.722412 -1081.564087 89.380791', 2, 0);
		create_waypoint ('2992.607422 -1089.071045 85.259979', 3, 70);
		create_waypoint ('3753.573242 -536.586609 45.390129', 4, 0);
		create_waypoint ('3266.762695 551.670410 41.041550', 5, 0);
		create_waypoint ('2428.826172 2186.593018 42.795670', 6, 0);
		create_waypoint ('1846.024780 3251.740967 38.333588', 7, 0);
		create_waypoint ('1393.526611 3567.623047 43.731049', 8, 75);
		create_waypoint ('821.743042 3576.213379 58.550194', 9, 50);
		create_waypoint ('398.123810 3308.475098 145.414688', 10, 50);
		create_waypoint ('119.048058 2901.648193 228.227402', 11, 40);
		create_waypoint ('-7.531377 2611.833740 281.272217', 12, 0);
		create_waypoint ('-4.642148 2097.029297 361.653961', 13, 0);
		create_waypoint ('67.520638 1669.263428 497.545715', 14, 0);
	}
};