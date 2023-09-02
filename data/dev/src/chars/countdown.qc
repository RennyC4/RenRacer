void(float type) countdown_announce =
{
	entity head = world, ent = world;
	string f = ftos(countdown_count);
	float runonce;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (!type)
		{
			if (!ragewar)
				centerprint (targ, "/PRACE STARTS IN\n\n[^1^b", f, "^b^7]\n");
			else
				centerprint (targ, "/PRAGE WAR STARTS IN\n\n[^1^b", f, "^b^7]\n");
		}
		else
		{
			if (!ragewar)
				centerprint (targ, "^1! GO GO GO !\n");
			else
				centerprint (targ, "^1! KILL KILL KILL !\n");
			if (!runonce)
			{
				if (!ragewar)
					bprint ("Race Started!\n");
				else
					bprint ("Rage War Begins!\n");
				runonce = TRUE;
			}
		}
	}
};

.float bots_loaded;
void() countdown_think = // Race start countdown
{
	//
	// Spawn bots, players/bots cars, spawn radar blip
	//
	
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (!targ.spawncar)
		{
			entity oself = self;
			self = targ;

			if (human_players == 1 && !ragewar && !self.bots_loaded)
			{
				BotConnect();
				self.bots_loaded = TRUE;
			}
			// Put cars in game
			if (self.vehicle == VEH_HOTROD)
				entity car = hotrod();
			if (self.vehicle == VEH_WRAITH)
				car = wraith();
			if (self.vehicle == VEH_ROADBASTARD)
				car = roadbastard();
			if (self.vehicle == VEH_SKYSCRAPER)
				car = skyscraper();
			if (self.vehicle == VEH_REDRAGE)
				car = redrage();
			if (self.vehicle == VEH_LAWBREAKER)
				car = lawbreaker();
			if (self.vehicle == VEH_RAZORBACK)
				car = razorback();
			if (self.vehicle == VEH_TACOLOCO)
				car = tacoloco();
			if (self.vehicle == VEH_STREETKING)
				car = streetking();

			makevectors(targ.angles);
			if (self.vehicle != VEH_SKYSCRAPER && self.vehicle != VEH_TACOLOCO)
				car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
			else // skyscraper+tacoloco are big boys and needs the extra height on spawn
			{
				setorigin(self, self.origin + v_up * 32);
				car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
			}
			Car_InitVehicle(car);
			self = oself;
			targ.spawncar = TRUE;
			Spawn_RadarBlip(targ);
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
			{
				if (!ragewar)
					sound (self, CHAN_AUTO, "3.wav", 1, ATTN_NONE);
				else
					sound (self, CHAN_AUTO, "combat/rw3.wav", 1, ATTN_NONE);
			}
			if (countdown_count == 2)
			{
				if (!ragewar)
					sound (self, CHAN_AUTO, "2.wav", 1, ATTN_NONE);
				else
					sound (self, CHAN_AUTO, "combat/rw2.wav", 1, ATTN_NONE);
			}
			if (countdown_count == 1)
			{
				if (!ragewar)
					sound (self, CHAN_AUTO, "1.wav", 1, ATTN_NONE);
				else
					sound (self, CHAN_AUTO, "combat/rw1.wav", 1, ATTN_NONE);
			}
			sound (self, CHAN_AUTO, "cntdwn.wav", 1, ATTN_NONE);
			countdown_announce(0);
		}
		else
		{
			if (!ragewar)
				sound (self, CHAN_AUTO, "gogo.wav", 1, ATTN_NONE);
			else
				sound (self, CHAN_AUTO, "combat/killkill.wav", 1, ATTN_NONE);				
			countdown_announce(1);
			race_status = RACE_STARTED;
			if (ragewar) // Start ragewar music on round start
			{
				if (world.model == "maps/dm1.bsp")
					self.music = "sound/music/dm1.ogg";
				if (world.model == "maps/dm2.bsp")
					self.music = "sound/music/dm2.ogg";
				if (world.model == "maps/dm3.bsp")
					self.music = "sound/music/dm3.ogg";
				
				for (entity targ = world;(targ = find(targ, classname, "player"));)
				{
					if (checkextension("DP_QC_SPRINTF"))
						stuffcmd (targ, sprintf("music %s\n", self.music));
				}
			}
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