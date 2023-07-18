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
	// Back up for randomly for a second, hit a wall/obstacle
	if ((self.keys == KEY_MOVEFORWARD || (self.button0 && self.turbo_fuel > 0)) && self.realspeed <= 3)
		self.bot_backup_finished = time + 0.3 + random()*0.6;

	// Out of ammo, go search for some
	if (self.ammo_firerocket < 1 && self.ammo_homingrocket < 1 && self.ammo_powerrocket < 1 && self.ammo_napalm < 1 && self.ammo_rico < 1)
	{
		self.goalentity = Bot_FindClosestItem();
		self.bot_huntitem_finished = time + 3;
	}

	if (!self.enemy && self.bot_huntitem_finished < time)
		self.enemy = BotGetClosestPlayer();

	if (self.enemy && self.enemy.health > 0 && self.enemy.invulnerable_finished < time)
	{
		if (visible(self.enemy) && self.enemy.cloak_finished < time)
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
				if (self.ammo_rico > 0)
				{
					self.weapon = WEP_RICOCHET;
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
	}
	else
	{
		self.enemy = BotGetClosestPlayer(); // Find new target
		if (self.enemy)
			self.goalentity = self.enemy;
	}

	if (self.bot_backup_finished < time)
	{
		if (self.goalentity)
			self.keys = KEY_MOVEFORWARD;
	}
	else
		self.keys = KEY_MOVEBACK;


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