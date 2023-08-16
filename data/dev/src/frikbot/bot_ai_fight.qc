.float bot_hunttarget_finished;
.float bot_huntitem_finished;
float(entity targ) range;
void(float rear) Fire_Freeze;

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

	makevectors_mdl(self.v_angle);

	//
	// Driving logic
	//

	// Bot wall bump
	if (self.bot_hitwall && self.keys == KEY_MOVEFORWARD && self.realspeed <= 3 && self.bot_backup_finished < time)
		self.bot_backup_finished = time + 0.3 + random()*0.3;

	if (self.bot_backup_finished > time)
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
		//self.velocity = v_forward * -9999; // Backward
	}
	else // forward
	{
		//
		// Turbo logic (hit player, remove napalm fire, etc)
		//

		float rangetest = range(self.goalentity);
		float er = self.realang_x * -1;
		if (self.goalentity.origin_z > self.origin_z && (er > 10 && er < 60) && infront(self.goalentity, 0.7) || (self.onfire_finished > time || self.frozen_finished > time)
		|| (infront(self.goalentity, 0.8) && visible(self.goalentity) && self.turbo_fuel > 0 && rangetest != RANGE_CLOSE))
			self.button0 = TRUE;
		else
			self.button0 = FALSE;

		self.keys = KEY_MOVEFORWARD;
		//self.velocity = v_forward * 9999; // Forward
	}

	//
	// Get player to hunt
	//

	if (!self.enemy && self.bot_huntitem_finished < time)
	{
		self.enemy = BotGetClosestPlayer();
		if (self.enemy)
			self.goalentity = self.enemy;
	}

	//
	// Out of ammo routine
	//

	if (self.ammo_firerocket < 1 && self.ammo_homingrocket < 1 && self.ammo_powerrocket < 1 && self.ammo_napalm < 1 && self.ammo_rico < 1 && self.ammo_remote < 1 && self.ammo_freeze < 1)
	{
		self.goalentity = Bot_FindClosestItem();
		self.bot_huntitem_finished = time + 3;
	}

	//
	// Bot firing / targetting
	//

	if (self.goalentity || self.enemy)
	{
		if (visible(self.enemy) && self.enemy.cloak_finished < time && self.enemy.invulnerable_finished < time && self.frozen_finished < time)
		{
			if (infront(self.enemy, 0.75) && self.invulnerable_finished < time)
			{
				rangetest = range(self.enemy);
				// AI Special Command moves
				if (self.energy >= 80 && (rangetest == RANGE_NEAR || rangetest == RANGE_CLOSE) && random() < 0.05)
				{
					Fire_Freeze(FALSE);
					self.energy = self.energy - 80;
				}
				if (self.ammo_special > 0)
				{
					// Car specific special weapons logic
					if (self.vehicle == VEH_HOTROD && rangetest == RANGE_CLOSE && !self.waterlevel)
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_WRAITH && rangetest != RANGE_FAR)
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_ROADBASTARD && (rangetest == RANGE_NEAR || rangetest == RANGE_CLOSE))
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_SKYSCRAPER && (rangetest == RANGE_NEAR || rangetest == RANGE_CLOSE))
						self.button0 = TRUE; // Turbo ram into player to activate special
					if (self.vehicle == VEH_REDRAGE && rangetest != RANGE_FAR)
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_LAWBREAKER && (rangetest == RANGE_NEAR || rangetest == RANGE_CLOSE))
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					//
				}
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
				if (self.ammo_napalm > 0 && (rangetest == RANGE_CLOSE || rangetest == RANGE_NEAR))
				{
					self.weapon = WEP_NAPALM;
					self.button4 = TRUE;
				}
				if (self.ammo_rico > 0)
				{
					self.weapon = WEP_RICOCHET;
					self.button4 = TRUE;
				}
				if (self.ammo_remote > 0 || self.plyrremote) // TODO: Needs logic on how to use remotes
				{
					self.weapon = WEP_REMOTE;
					self.button4 = TRUE;
				}
				if (self.ammo_freeze > 0 && (rangetest == RANGE_CLOSE || rangetest == RANGE_NEAR))
				{
					self.weapon = WEP_FREEZE;
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