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
	//Map 3 doesn't need waypoints
	if (world.model == "maps/map4.hmp")
	{
		create_waypoint ('2570.022461 48.822002 98.845512', 1, 0);
		create_waypoint ('4795.454590 -696.619141 80.021294', 2, 0);
		create_waypoint ('5042.677734 -1578.677124 29.121984', 3, 0);
		create_waypoint ('5771.185059 -3020.462158 -1.022110', 4, 0);
		create_waypoint ('6499.431641 -3120.728516 -25.940228', 5, 0);
		create_waypoint ('7228.246582 -3174.535400 40.506615', 6, 0);
		create_waypoint ('7906.353516 -3065.700195 84.591217', 7, 0);
		create_waypoint ('8954.932617 -2562.991943 79.996696', 8, 0);
		create_waypoint ('9359.413086 -1730.908813 80.008774', 9, 0);
		create_waypoint ('9459.157227 -995.408386 80.015190', 10, 0);
		create_waypoint ('9260.497070 -111.490952 80.028465', 11, 0);
		create_waypoint ('8841.306641 448.249512 79.940918', 12, 0);
		create_waypoint ('8073.095215 742.948303 80.075500', 13, 0);
		create_waypoint ('7332.110840 837.476257 80.015305', 14, 0);
		create_waypoint ('6334.925293 1415.384521 80.026230', 15, 0);
		create_waypoint ('6157.149902 2129.878906 80.030235', 16, 0);
		create_waypoint ('5976.526367 2761.610107 80.139618', 17, 0);
		create_waypoint ('5128.552734 4092.226563 80.003036', 18, 0);
		create_waypoint ('4529.466797 4370.201172 80.013237', 19, 0);
		create_waypoint ('3828.676025 4321.774902 79.960617', 20, 0);
		create_waypoint ('2792.727051 4197.863770 80.105263', 21, 0);
		create_waypoint ('2046.547607 4101.342285 80.020477', 22, 0);
		create_waypoint ('1129.700073 3962.163330 80.022820', 23, 0);
		create_waypoint ('341.800476 3772.329590 80.016403', 24, 0);
		create_waypoint ('-355.292084 3446.994141 80.027214', 25, 0);
		create_waypoint ('-1062.782349 3159.570801 80.030357', 26, 0);
		create_waypoint ('-1907.804688 2807.549561 79.928093', 27, 0);
		create_waypoint ('-2591.923096 2224.722900 80.022209', 28, 0);
		create_waypoint ('-3047.137207 1639.668335 80.006744', 29, 0);
		create_waypoint ('-3093.156006 347.607605 82.021332', 30, 0);
		create_waypoint ('-2184.194336 120.288292 80.131767', 31, 0);
		create_waypoint ('-1335.923828 -21.575169 79.930626', 32, 0);
		create_waypoint ('-503.848053 9.834307 80.031143', 33, 0);
	}
};