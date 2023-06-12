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
		create_waypoint ('191.518402 -257.623688 100.162201', 1, 30);
		create_waypoint ('223.221359 -801.661377 141.881393', 2, 30);
		create_waypoint ('257.115265 -1388.687256 40.937359', 3, 30);
		create_waypoint ('927.801270 -1400.887817 24.912018', 4, 0);
		create_waypoint ('2464.722412 -1081.564087 89.380791', 5, 0);
		create_waypoint ('2992.607422 -1089.071045 85.259979', 6, 70);
		create_waypoint ('3681.865479 -1280.789917 49.766087', 7, 60);
		create_waypoint ('3921.801758 -959.127930 37.059212', 8, 50);
		create_waypoint ('3753.573242 -536.586609 45.390129', 9, 0);
		create_waypoint ('3266.762695 551.670410 41.041550', 10, -1); // Turbo
		create_waypoint ('2428.826172 2186.593018 42.795670', 11, -1);
		create_waypoint ('1846.024780 3251.740967 38.333588', 12, -1);
		create_waypoint ('1393.526611 3567.623047 43.731049', 13, 40);
		create_waypoint ('821.743042 3576.213379 58.550194', 14, 50);
		create_waypoint ('398.123810 3308.475098 145.414688', 15, 50);
		create_waypoint ('119.048058 2901.648193 228.227402', 16, 40);
		create_waypoint ('-7.531377 2611.833740 281.272217', 17, 30);
		create_waypoint ('-4.642148 2097.029297 361.653961', 18, 0);
		create_waypoint ('67.520638 1669.263428 497.545715', 19, 0);
	}
};