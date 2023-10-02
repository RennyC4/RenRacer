//
// RennyC: Modified from AI Cafe
//

void() waypoint_touch =
{
	if (other.owner.driving.waypoint >= self.waypoint)
		return;
	if (other.owner.driving.classname != "player")
		return;

	other.owner.driving.last_waypoint = self.waypoint; // Stash it for bot teleporting reasons
	other.owner.driving.waypoint = self.waypoint;
	other.owner.driving.goalentity = world; // find next waypoint

	if (cvar("developer") == 2)
		sprint (other.owner.driving, "Waypoint_touch: ", ftos(self.waypoint), " / ", ftos(total_waypoints), "\n");
};

void(vector org, float which, optional float cnt) create_waypoint =
{
	entity wp = spawn();
	wp.classname = "bot_waypoint";
	wp.solid = SOLID_TRIGGER;
	wp.movetype = MOVETYPE_NONE;
	wp.flags = FL_ITEM; // bigger touch box
	wp.touch = waypoint_touch;
	wp.waypoint_speed = cnt;

	if (cvar("developer") == 2)
		setmodel (wp, "progs/s_debug.spr");
	else
		setmodel (wp, "*null");

	setorigin(wp, org);
	setsize (wp, '-128 -128 -128', '128 128 128'); // bigger touch box

	total_waypoints = total_waypoints + 1;
	wp.waypoint = total_waypoints;
};

// Mapper placed entity
void() bot_waypoint =
{
	if (ragewar)
	{
		remove(self);
		return;
	}
	self.classname = "bot_waypoint";
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.flags = FL_ITEM; // bigger touch box
	self.touch = waypoint_touch;

	if (cvar("developer") == 2)
		setmodel (self, "progs/s_debug.spr");
	else
		setmodel (self, "*null");

	setsize (self, '-128 -128 -128', '128 128 128'); // bigger touch box

	total_waypoints = total_waypoints + 1;
};

void() load_waypoints =
{
	if (ragewar)
		return;

	if (world.model == "maps/map1.bsp")
	{
		create_waypoint ('1172.890991 1320.857056 -96.970322', 1, 0);
		create_waypoint ('566.564392 1549.128540 -97.974670', 2, 0);
		create_waypoint ('104.788315 1070.905273 -96.970680', 3, 0);
		create_waypoint ('76.440895 -565.337891 -96.971107', 4, 0);
		create_waypoint ('949.710999 -953.419189 -96.975060', 5, 0);
		create_waypoint ('1402.754761 -728.587646 -96.991348', 6, 0);
	}
	if (world.model == "maps/map2.hmp")
	{
		create_waypoint ('217.083267 -424.322693 136.092682', 1, 0);
		create_waypoint ('223.221359 -801.661377 141.881393', 2, 0);
		create_waypoint ('530.514282 -1434.244141 45.007530', 3, 0);
		create_waypoint ('2464.722412 -1081.564087 89.380791', 4, 999);
		create_waypoint ('3950.287109 -664.548462 39.808529', 5, 0);
		create_waypoint ('3266.762695 551.670410 41.041550', 6, 999);
		create_waypoint ('2428.826172 2186.593018 42.795670', 7, 999);
		create_waypoint ('1393.526611 3567.623047 43.731049', 8, 30);
		create_waypoint ('821.743042 3576.213379 58.550194', 9, 0);
		create_waypoint ('398.123810 3308.475098 145.414688', 10, 0);
		create_waypoint ('59.144436 2879.968994 238.697983', 11, 0);
		create_waypoint ('-63.726654 2320.773193 313.729980', 12, 0);
		create_waypoint ('126.149734 1572.912476 540.592224', 13, 999);
	}

	//Map 3 doesn't need waypoints :P Feel free to make em though!

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
	if (world.model == "maps/map5.bsp")
	{
		create_waypoint ('-394.522705 2883.736328 -161.973694', 1, 0);
		create_waypoint ('413.792389 3694.978027 -161.970810', 2, 0);
		create_waypoint ('650.538086 3842.674805 -161.971527', 3, 0);
		create_waypoint ('1065.070679 -891.112183 -187.257477', 4, 0);
		create_waypoint ('1072.810547 -1574.483521 -12.393329', 5, 0);
		create_waypoint ('807.292480 -2080.817383 10.029276', 6, 0);
		create_waypoint ('-8.546608 -2057.396240 10.030962', 7, 0);
		create_waypoint ('-49.463600 1143.843506 10.023750', 8, 999);
		create_waypoint ('608.235718 1295.157471 16.537247', 9, 999);
		create_waypoint ('1634.795288 1843.409180 -81.209518', 10, 999);
		create_waypoint ('2470.459473 2051.182861 18.481325', 11, 999);
		create_waypoint ('2834.474365 1464.317383 317.830811', 12, 0);
		create_waypoint ('3277.467773 899.919739 378.026031', 13, 0);
		create_waypoint ('3184.002930 106.491257 378.023285', 14, 0);
		create_waypoint ('1979.684082 163.677139 358.284943', 15, 999);
		create_waypoint ('584.318420 351.638092 350.004181', 16, 999);
		create_waypoint ('-3012.979248 584.095276 94.020882', 17, 0);
		create_waypoint ('-3213.184814 883.770874 94.026741', 18, 0);
		create_waypoint ('-3355.623291 1285.458862 94.021469', 19, 0);
		create_waypoint ('-3295.248291 1593.715820 94.029434', 20, 0);
		create_waypoint ('-3082.248047 3846.853516 -94.097610', 21, 0);
		create_waypoint ('-2716.353760 3280.215576 -97.973328', 22, 999);
		create_waypoint ('-2695.660156 2762.509033 64.864914', 23, 999);
		create_waypoint ('-2540.764404 1423.690918 -141.978973', 24, 0);
		create_waypoint ('-2438.664063 887.632446 -161.976135', 25, 40);
		create_waypoint ('-2097.854736 1150.464966 -161.974533', 25, 999);
	}
	if (world.model == "maps/map6.hmp")
	{
		create_waypoint ('-377.431732 3164.977051 45.362740', 1, 0);
		create_waypoint ('-3384.450195 3674.796143 47.766289', 2, 0);
		create_waypoint ('-3847.130859 3745.930420 62.035694', 3, 0);
		create_waypoint ('-5605.280762 3512.557617 -238.969391', 4, 0);
		create_waypoint ('-5132.209961 2351.520020 -92.084473', 5, 0);
		create_waypoint ('-4498.779297 2664.303711 110.770355', 6, 0);
		create_waypoint ('-3666.307861 2769.408447 97.979736', 7, 0);
		create_waypoint ('-2116.846191 2560.293701 30.409962', 8, 0);
		create_waypoint ('-1431.369141 2297.425049 31.679417', 9, 0);
		create_waypoint ('-1305.988281 1334.136597 113.095413', 10, 0);
		create_waypoint ('-2330.503174 364.381744 231.403290', 11, 0);
		create_waypoint ('-2967.969727 435.528778 339.779816', 12, 0);
		create_waypoint ('-3458.409424 1200.826660 275.255463', 13, 999); // Big jump
		create_waypoint ('-3793.837646 2044.151245 517.827148', 14, 999);
		create_waypoint ('-4148.678711 4447.390137 278.082916', 15, 999);
		create_waypoint ('-2576.551270 5964.144043 163.015335', 16, 0);
		create_waypoint ('-1858.195068 5979.387695 192.988266', 17, 0);
		create_waypoint ('-1188.728516 6236.786621 50.489887', 18, 0);
		create_waypoint ('-14.577902 6627.393066 30.227440', 19, 0);
		create_waypoint ('12.695010 5872.824219 30.183933', 20, 0);
		create_waypoint ('-623.307068 5168.094727 84.585373', 21, 0);
		create_waypoint ('813.829895 3834.084473 32.539841', 22, 0);
		create_waypoint ('1588.232910 1789.710815 29.971247', 23, 0);
		create_waypoint ('1495.014526 22.003996 31.182093', 24, 0);
		create_waypoint ('1567.884155 -2742.682861 -447.257751', 25, 0);
		create_waypoint ('895.988831 -3389.896240 -340.129700', 26, 0);
		create_waypoint ('-161.584656 -3053.484619 -180.986481', 27, 0);
		create_waypoint ('-57.154488 -1874.461548 4.123002', 28, 0);
	}
};