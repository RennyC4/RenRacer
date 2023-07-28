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
	if (self.impulse >= 1 && self.impulse <= 7)
		ChangeWeapon();
	if (self.impulse == 100)
		headlights_toggle();
	if (self.impulse == 10)
		CycleWeaponForward();
	if (self.impulse == 11)
		CycleWeaponBackward();
	if (self.impulse == 20)
		BotConnect();
	if (self.impulse == 21) // Remove bots
	{
		float RunOnce = FALSE;
		for (entity targ = world;(targ = find(targ, classname, "player"));)
		{
			if (clienttype(targ) == CLIENTTYPE_BOT && !RunOnce)
			{
				bot_count = bot_count - 1;
				dropclient(targ);
				RunOnce = TRUE;
			}
		}
	}

	// Functions not related to gameplay
	if (self.impulse == 101) // WIP: Change car angles instantly
		set_carangle(self, '0 0 0');

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