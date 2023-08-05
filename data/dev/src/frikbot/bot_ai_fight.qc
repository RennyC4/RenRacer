.float bot_hunttarget_finished;
.float bot_huntitem_finished;

entity() BotGetClosestPlayer =
{
	float bestd = 9999999999999;
	entity bestv = world;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (targ == self || targ.health < 1 || targ.invulnerable_finished > time || targ.observer)
			continue; // skip

		vector heading = targ.origin - self.origin;
		float d = heading * heading;

		if (d < bestd)
		{
			bestd = d;
			bestv = targ;
		}

		if (bestv)
			return targ;
	}
	return world;
};

entity() Bot_FindClosestItem =
{
	float bestd = 9999999999999;
	entity bestv = world;

	for (entity thing = world;(thing = find(thing, netname, "item"));)
	{
		if (thing.solid == SOLID_NOT)
			continue; // skip
			
		vector heading = thing.origin - self.origin;
		float d = heading * heading;

		if (d < bestd)
		{
			bestd = d;
			bestv = thing;
		}

		if (bestv)
		{
			if (thing.solid == SOLID_TRIGGER)
				return thing;
		}
	}
	return world;
};

.float startmatch;
void() bot_ai_fight =
{
	if (race_status != RACE_STARTED)
		return;

	makevectors_mdl(self.realang);

	// Get rid of fire
	if (self.onfire_finished > time)
		self.button0 = TRUE;
	else
		self.button0 = FALSE;

	// Get player to hunt
	if (!self.enemy && self.bot_huntitem_finished < time)
	{
		self.enemy = BotGetClosestPlayer();
		if (self.enemy)
			self.goalentity = self.enemy;
	}

	// Out of ammo, go search for some
	if (self.ammo_firerocket < 1 && self.ammo_homingrocket < 1 && self.ammo_powerrocket < 1 && self.ammo_napalm < 1)
	{
		self.goalentity = Bot_FindClosestItem();
		self.bot_huntitem_finished = time + 3;
	}

	// Bot hit wall, backup for a sec
	if (self.bot_hitwall && self.keys == KEY_MOVEFORWARD && self.realspeed <= 3 && self.bot_backup_finished < time)
		self.bot_backup_finished = time + 0.3 + random()*0.3;

	if (self.goalentity)
	{
		if (visible(self.enemy) && self.enemy.cloak_finished < time && self.enemy.invulnerable_finished < time)
		{
			if (infront(self.enemy, 0.75))
			{
				if (self.ammo_firerocket > 0)
				{
					self.weapon = WEP_ROCKET;
					self.button4 = TRUE;
				}
				if (self.ammo_homingrocket > 0)
				{
					self.weapon = WEP_HROCKET;
					self.button4 = TRUE;
				}
				if (self.ammo_powerrocket > 0)
				{
					self.weapon = WEP_PROCKET;
					self.button4 = TRUE;
				}
				if (self.ammo_napalm > 0)
				{
					self.weapon = WEP_NAPALM;
					self.button4 = TRUE;
				}
				self.button3 = TRUE; // Fire machine guns
			}
			else
			{
				self.button3 = FALSE;
				self.button4 = FALSE;
			}
			if (self.bot_huntitem_finished < time)
				self.goalentity = self.enemy;
		}
		else
		{
			//bprint ("BOT: Can't see enemy, hunting item\n");
			self.button3 = FALSE;
			self.button4 = FALSE;
			self.goalentity = Bot_FindClosestItem();
			self.enemy = BotGetClosestPlayer(); // Find new target while item hunting
			if (self.bot_huntitem_finished < time)
				self.bot_huntitem_finished = time + 3;
		}
		if (self.bot_backup_finished < time)
		{
			self.keys = KEY_MOVEFORWARD;
			self.bot_wishvel = v_forward * 9999; // Forward
		}
		else // backing up
		{
			if (random() < 0.5)
			{
				self.enemy = BotGetClosestPlayer(); // Find new target while backing up
				if (self.enemy)
					self.goalentity = self.enemy;
			}
			else
				self.goalentity = Bot_FindClosestItem();

			self.button0 = FALSE;
			self.keys = KEY_MOVEBACK;
			self.bot_wishvel = v_forward * -9999; // Back
		}
	}
	else
	{
		self.enemy = BotGetClosestPlayer(); // Find new target
		if (self.enemy)
			self.goalentity = self.enemy;
		else
			self.goalentity = Bot_FindClosestItem();
	}

	bot_angle_set();

	// Debugging prints
//	bprint (self.goalentity.classname, "\n");
//	local string d1 = ftos (self.goalentity.origin_x);
//	local string d2 = ftos (self.goalentity.origin_y);
//	local string d3 = ftos (self.goalentity.origin_z);
//	bprint (d1, "\n");
//	bprint (d2, "\n");
//	bprint (d3, "\n");	
};