void(float type) countdown_announce =
{
	local entity y, head, ent = world;
	head = world;

	local string f = ftos(countdown_count);

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (!type)
		{
			if (!deathmatch)
				centerprint (targ, "/PRACE STARTS IN\n\n[^1^b", f, "^b^7]\n");
			else
				centerprint (targ, "/PRAGE WAR STARTS IN\n\n[^1^b", f, "^b^7]\n");
		}
		else
			centerprint (targ, "^1! GO GO GO !\n");
	}
};

.float spawncar;
void() countdown_think = // Race start countdown
{
	local entity oself;

	//
	// Remove all bots if human_players > 1
	//

	if (!self.cnt)
	{
		for (entity targ = world;(targ = find(targ, classname, "player"));)
		{
			if (targ.ishuman)
				human_players = human_players + 1;
		}

		if (human_players == 1) // Add bots
		{
			local float i;
			local float g = cvar("sv_playerslots");
			for (i = 0; i < g-1; i = i+1)
				BotConnect(0, 0, 0);
		}
		self.cnt = TRUE; // run loop once
	}
	//

	//
	// Spawn players cars
	//
	
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (!targ.spawncar)
		{
			oself = self;
			self = targ;
			local entity car = hotrod();
			makevectors(targ.angles);
			car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
			Car_InitVehicle(car);
			self = oself;
			targ.spawncar = TRUE;
		}
	}
	//

	//
	// Do Count Down
	//

	if (countdown_finished < time && countdown_count > -1)
	{
		local string f = ftos(countdown_count);
		if (countdown_count > 0)
		{
			if (countdown_count == 3)
				sound (self, CHAN_AUTO, "3.wav", 1, ATTN_NONE);
			if (countdown_count == 2)
				sound (self, CHAN_AUTO, "2.wav", 1, ATTN_NONE);
			sound (self, CHAN_AUTO, "cntdwn.wav", 1, ATTN_NONE);
			if (countdown_count == 1)
				sound (self, CHAN_AUTO, "1.wav", 1, ATTN_NONE);
			countdown_announce(0);
		}
		else
		{
			sound (self, CHAN_AUTO, "gogo.wav", 1, ATTN_NONE);
			countdown_announce(1);
			race_status = RACE_STARTED;
		}
		countdown_count = countdown_count - 1;
		countdown_finished = time + 1;
		if (countdown_count < 0) // Done my job, goodbye!
		{
			remove(self);
			return;
		}
	}
	//

	frameskip(0.1);
};

void() spawn_car_countdown =
{
	local entity cd = spawn();
	cd.think = countdown_think;
	cd.nextthink = time + 0.1;
};