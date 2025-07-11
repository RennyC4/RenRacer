/*
+--------+
|Impulses|
+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Handle and execute "Impulse" commands - as entered from console.           |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

void() CarSelection_Update =
{
	if (ragewar)
	{
		if (self.vehicle == VEH_HOTROD)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1HotRod^7\nSpecial Weapon: ^5Flame Thrower^7\n\nSpecial: [**** ]\nSpeed: [**   ]\nHandling: [**   ]\nArmor: [***  ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_WRAITH)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Wraith^7\nSpecial Weapon: ^5Spectral Missile^7\n\nSpecial: [***  ]\nSpeed: [**** ]\nHandling: [**** ]\nArmor: [*    ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_ROADBASTARD)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Road Bastard^7\nSpecial Weapon: ^5Boomerang^7\n\nSpecial: [***  ]\nSpeed: [***  ]\nHandling: [***  ]\nArmor: [***  ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_SKYSCRAPER)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Sky Scraper^7\nSpecial Weapon: ^5Big Crush^7\n\nSpecial: [**** ]\nSpeed: [*    ]\nHandling: [*    ]\nArmor: [**** ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_REDRAGE)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Red Rage^7\nSpecial Weapon: ^5Crimson Beam^7\n\nSpecial: [*    ]\nSpeed: [*****]\nHandling: [*****]\nArmor: [*     ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_LAWBREAKER)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Law Breaker^7\nSpecial Weapon: ^5Tazer Shock^7\n\nSpecial: [***  ]\nSpeed: [**** ]\nHandling: [***  ]\nArmor: [**    ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_RAZORBACK)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Razorback^7\nSpecial Weapon: ^5Jingo Missiles^7\n\nSpecial: [***  ]\nSpeed: [**   ]\nHandling: [**   ]\nArmor: [****  ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_MINCEMEAT)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Mince Meat^7\nSpecial Weapon: ^5SplatterDog^7\n\nSpecial: [***  ]\nSpeed: [*    ]\nHandling: [*    ]\nArmor: [**** ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_STREETKING)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Street King^7\nSpecial Weapon: ^5King Turret^7\n\nSpecial: [***  ]\nSpeed: [**** ]\nHandling: [***  ]\nArmor: [***   ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_SANDROAMER)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Sand Roamer^7\nSpecial Weapon: ^5Sand Storm^7\n\nSpecial: [**** ]\nSpeed: [***  ]\nHandling: [**   ]\nArmor: [***  ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_THOROGOOD)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Thorogood^7\nSpecial Weapon: ^5Hell Spawn^7\n\nSpecial: [*****]\nSpeed: [**** ]\nHandling: [*****]\nArmor: [*     ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
		if (self.vehicle == VEH_NIGHTSHADE)
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Nightshade^7\nSpecial Weapon: ^5Time Shifter^7\n\nSpecial: [*   ]\nSpeed: [*    ]\nHandling: [*   ]\nArmor: [*****]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
	}
	else
	{
		if (self.vehicle == VEH_HOTROD)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1HotRod^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_WRAITH)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Wraith^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_ROADBASTARD)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Road Bastard^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_SKYSCRAPER)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Sky Scraper^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_REDRAGE)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Red Rage^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_LAWBREAKER)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Law Breaker^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_RAZORBACK)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Razorback^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_MINCEMEAT)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Mince Meat^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_STREETKING)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Street King^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_SANDROAMER)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Sand Roamer^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_THOROGOOD)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Thorogood^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
		if (self.vehicle == VEH_NIGHTSHADE)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Nightshade^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
	}
};

void() CarSwap_Forward =
{
	if (!ragewar)
		stuffcmd (self, "play misc/menu_m1.wav\n");
	else
		stuffcmd (self, "play misc/menu_m2.wav\n");

	if (!self.vehicle)
		self.vehicle++;
	else if (self.vehicle >=  1024)
		self.vehicle = 0;
	else
		self.vehicle *= 2;

	CarSelection_Update();
};

void() CarSwap_Backward =
{
	if (!ragewar)
		stuffcmd (self, "play misc/menu_m1.wav\n");
	else
		stuffcmd (self, "play misc/menu_m2.wav\n");

	if (self.vehicle <= 0)
		self.vehicle = 1024;
	else if (self.vehicle ==  1)
		self.vehicle = 0;
	else
		self.vehicle /= 2;

	CarSelection_Update();
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

	//if (self.impulse == 16) // test
	//	DoDamage(self, self, 10, self.classname);

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