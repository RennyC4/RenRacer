void(float type) countdown_announce =
{
	entity head = world, ent = world;
	string f = ftos(countdown_count);
	float runonce;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (!targ.observer)
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
	}
};

float bots_loaded;
void() countdown_think = // Race start countdown
{
	//
	// Spawn bots for racing
	//

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (!bots_loaded)
		{
			entity oself = self;
			self = targ;

			if (human_players == 1 && !ragewar)
			{
				float g = cvar("sv_playerslots");
				for (float i = 0; i < g-1; i = i+1)
					BotConnect();
			}
			self = oself;
			bots_loaded = TRUE;
		}
	}
	//

	//
	// Do Count Down
	//

	if (countdown_finished < time && countdown_count > -1)
	{
		string f = ftos(countdown_count);
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