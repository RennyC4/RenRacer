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
		create_waypoint ('217.083267 -424.322693 136.092682', 1, 0);
		create_waypoint ('223.221359 -801.661377 141.881393', 2, 0);
		create_waypoint ('530.514282 -1434.244141 45.007530', 3, 0);
		create_waypoint ('2464.722412 -1081.564087 89.380791', 4, 0);
		create_waypoint ('3950.287109 -664.548462 39.808529', 5, 0);
		create_waypoint ('3266.762695 551.670410 41.041550', 6, 0);
		create_waypoint ('2428.826172 2186.593018 42.795670', 7, 0);
		create_waypoint ('1393.526611 3567.623047 43.731049', 8, 0);
		create_waypoint ('821.743042 3576.213379 58.550194', 9, 0);
		create_waypoint ('398.123810 3308.475098 145.414688', 10, 0);
		create_waypoint ('187.623047 1566.915894 547.794617', 11, 0);
	}
};