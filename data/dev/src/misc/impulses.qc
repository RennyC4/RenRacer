/*
+--------+
|Impulses|
+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Handle and execute "Impulse" commands - as entered from console.           |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

void() CheckImpulses =
{
	if (self.impulse >= 1 && self.impulse <= 4)
		ChangeWeapon();
	if (self.impulse == 100)
		headlights_toggle();
	if (self.impulse == 10)
		CycleWeaponForward();
	if (self.impulse == 11)
		CycleWeaponBackward();

	// Functions not related to gameplay
	if (self.impulse == 101) // WIP: Change car angles instantly
	{
		makevectors (self.angles);
		car_angle(self.angles);
	}
	if (self.impulse == 102)
	{
		create_waypoint(self.origin, total_waypoints, 0);
		bprint("Waypoint #: ", ftos(total_waypoints), "\n");
	}
	if (self.impulse == 103)
	{
		local entity way = find(world, classname, "bot_waypoint");
		while (way)
		{
			bprint("create_waypoint (");
			bprint(vtos(way.origin));
			bprint(", ");
			bprint(ftos(way.waypoint));
			bprint(", ");
			bprint(ftos(way.speed));
			bprint(");\n");
			way = find(way, classname, "bot_waypoint");
		}
	}

	self.impulse = 0;
};