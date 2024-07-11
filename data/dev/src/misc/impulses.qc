/*
+--------+
|Impulses|
+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Handle and execute "Impulse" commands - as entered from console.           |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

void() CarSwap_Forward =
{
	if (!ragewar)
		stuffcmd (self, "play misc/menu_m1.wav\n");
	else
		stuffcmd (self, "play misc/menu_m2.wav\n");

	if (self.vehicle == 0) self.vehicle++;
	else if(self.vehicle >=  1024) self.vehicle = 0;
	else self.vehicle *= 2;
};

void() CarSwap_Backward =
{
	if (!ragewar)
		stuffcmd (self, "play misc/menu_m1.wav\n");
	else
		stuffcmd (self, "play misc/menu_m2.wav\n");

	if (self.vehicle <= 0) self.vehicle = 1024;
	else if(self.vehicle ==  1) self.vehicle = 0;
	else self.vehicle /= 2;
};

void() CheckImpulses =
{
	if (self.impulse >= 1 && self.impulse <= 8)
		ChangeWeapon();
	if (self.impulse == 100)
		headlights_toggle();
	if (self.impulse == 255)
		CarReset();

	if (self.impulse == 95)
	{
		self.vehicle = VEH_SERVANT;
		stuffcmd (self, "play combat/servant.wav\n");
	}

	if (self.impulse == 96)
	{
		self.vehicle = VEH_WARWIENER;
		stuffcmd (self, "play combat/mincemeat.wav\n");
	}

	// Weapon / Car select cycle
	if (self.impulse == 10)
	{
		if (ragewar)
		{
			CycleWeaponForward();
			if (race_status == RACE_NOTSTARTED || self.observer)
				CarSwap_Forward();
		}
		else
		{
			if (race_status == RACE_NOTSTARTED || self.observer)
				CarSwap_Forward();
		}
	}
	if (self.impulse == 11)
	{
		if (ragewar)
		{
			CycleWeaponBackward();
			if (race_status == RACE_NOTSTARTED || self.observer)
				CarSwap_Backward();
		}
		else
		{
			if (race_status == RACE_NOTSTARTED || self.observer)
				CarSwap_Backward();
		}
	}
	//

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

// Registered console commands (defined in main.qc)
float(string cmd) ConsoleCmd =
{
	tokenize(cmd);
	if (argv(0) == "addbot")
		BotConnect();
	if (argv(0) == "removebot")
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
	else
		return FALSE;
	return TRUE;
};