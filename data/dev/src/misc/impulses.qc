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
	if (self.vehicle == VEH_HOTROD)
		self.vehicle = VEH_WRAITH;
	else if (self.vehicle == VEH_WRAITH)
		self.vehicle = VEH_ROADBASTARD;
	else if (self.vehicle == VEH_ROADBASTARD)
		self.vehicle = VEH_SKYSCRAPER;
	else if (self.vehicle == VEH_SKYSCRAPER)
		self.vehicle = VEH_REDRAGE;
	else if (self.vehicle == VEH_REDRAGE)
		self.vehicle = VEH_LAWBREAKER;
	else if (self.vehicle == VEH_LAWBREAKER)
		self.vehicle = VEH_RAZORBACK;
	else if (self.vehicle == VEH_RAZORBACK)
		self.vehicle = VEH_MINCEMEAT;
	else if (self.vehicle == VEH_MINCEMEAT)
		self.vehicle = VEH_STREETKING;
	else if (self.vehicle == VEH_STREETKING)
		self.vehicle = VEH_SANDROAMER;
	else if (self.vehicle == VEH_SANDROAMER)
		self.vehicle = VEH_THOROGOOD;
	else if (self.vehicle == VEH_THOROGOOD)
		self.vehicle = VEH_NIGHTSHADE;
	else if (self.vehicle == VEH_NIGHTSHADE)
		self.vehicle = VEH_HOTROD;
};

void() CarSwap_Backward =
{
	if (self.vehicle == VEH_NIGHTSHADE)
		self.vehicle = VEH_THOROGOOD;
	else if (self.vehicle == VEH_THOROGOOD)
		self.vehicle = VEH_SANDROAMER;
	else if (self.vehicle == VEH_SANDROAMER)
		self.vehicle = VEH_STREETKING;
	else if (self.vehicle == VEH_STREETKING)
		self.vehicle = VEH_MINCEMEAT;
	else if (self.vehicle == VEH_MINCEMEAT)
		self.vehicle = VEH_RAZORBACK;
	else if (self.vehicle == VEH_RAZORBACK)
		self.vehicle = VEH_LAWBREAKER;
	else if (self.vehicle == VEH_LAWBREAKER)
		self.vehicle = VEH_REDRAGE;
	else if (self.vehicle == VEH_REDRAGE)
		self.vehicle = VEH_SKYSCRAPER;
	else if (self.vehicle == VEH_SKYSCRAPER)
		self.vehicle = VEH_ROADBASTARD;
	else if (self.vehicle == VEH_ROADBASTARD)
		self.vehicle = VEH_WRAITH;
	else if (self.vehicle == VEH_WRAITH)
		self.vehicle = VEH_HOTROD;
	else if (self.vehicle == VEH_HOTROD)
		self.vehicle = VEH_NIGHTSHADE;
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