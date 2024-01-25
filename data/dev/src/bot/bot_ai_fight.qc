.float bot_hunttarget_finished;
.float bot_huntitem_finished;
float(entity targ) range;
void(float rear) Fire_Freeze;
void() Fire_Landmine;
void(float type, float rear) CarAttack;
void() Fire_Shield;

entity() BotGetClosestPlayer =
{
	float bestd = 9999999999999;
	entity bestv = world;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (targ == self || targ.health < 1 || targ.invulnerable_finished > time || targ.observer)
			continue; // skip

		//vector heading = targ.origin - self.origin;
		vector heading = realorigin(targ) - self.origin;
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

// bots possibly only go for a health item if their at 1/4 health
entity() Bot_FindClosestItem =
{
	float bestd = 9999999999999;
	entity bestv = world;

	for (entity thing = world;(thing = find(thing, netname, "item"));)
	{
		if (thing.solid == SOLID_NOT || (thing.classname == "item_health" && self.health > self.max_health / 2))
			continue; // skip
			
		//vector heading = thing.origin - self.origin;
		vector heading = realorigin(thing) - self.origin;
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

.vector Last_RW_Waypoint; // first waypoint taken
.vector Last_RW_Waypoint2; // second last waypoint taken
.vector Last_RW_Waypoint3; // Last waypoint taken
entity() Bot_FindClosestRW_Waypoint =
{
	float bestd = 9999999999999;
	entity bestv = world;

	for (entity thing = world;(thing = find(thing, classname, "rw_bot_waypoint"));)
	{
		if (thing.origin == self.Last_RW_Waypoint || thing.origin == self.Last_RW_Waypoint2 || thing.origin == self.Last_RW_Waypoint3)
			continue; // skip

		vector heading = realorigin(thing) - self.origin;
		float d = heading * heading;

		if (d < bestd)
		{
			bestd = d;
			bestv = thing;
		}

		if (bestv)
			return thing;
	}
	return world;
};

.float goalentity_bad_finished; // goalentity cycle
.float rw_check_waypoint; // one time check
float rw_use_waypoint_system; // global flag, waypoints exist
void() bot_ai_fight =
{
	if (race_status != RACE_STARTED)
		return;

	// Turn waypoint mode on if they exist
	if (!self.rw_check_waypoint)
	{
		for (entity targ = world;(targ = find(targ, classname, "rw_bot_waypoint"));)
			rw_use_waypoint_system = TRUE;
		self.rw_check_waypoint = TRUE;
	}

	makevectors(self.v_angle);

	//
	// Driving logic
	//

	// Traceline: Test if bot is going to fall to their death
	// TODO: Should only check when all 4 wheels are on the ground, remove false-positives
	if (self.realspeed > 5 && rw_use_waypoint_system)
	{
		float test1, test2, distance = 0;

		vector remove_bad_axis = self.realang;
		remove_bad_axis_x = 0;
		remove_bad_axis_z = 0;
		makevectors(remove_bad_axis);

		if (!self.backward)
		{
			vector start = self.origin + v_forward * (50 + self.realspeed);
			vector end = self.origin + v_forward * (self.realspeed * 6);

			traceline (start, end, TRUE, self); // 1st trace forward

			//bprint (trace_ent.owner.driving.classname, "\n"); // 
			if (trace_fraction < 1 && !trace_ent.owner.driving)
				test1 = TRUE; // hit something
			else
				test1 = FALSE; // go to next check

			if (!test1)
			{
				vector test2_vec = trace_endpos;

				distance = 1000; // how far to check downward
				start = test2_vec;
				end = test2_vec - (v_up * distance);
				traceline (start, end, TRUE, self); // 2nd trace (down)

				if (trace_fraction < 1)
					test2 = TRUE; // hit something
				else
					test2 = FALSE;
			}

			if (!test1 && !test2) // this is a drop
			{
				if (self.goalentity && self.goalentity.classname != "rw_bot_waypoint") // mark goalentity as bad for 6 seconds, unless its a player
				{
					if (self.goalentity.classname == "player")
					{
						self.goalentity.goalentity_bad_finished = time + 3;
						//bprint ("Set 1\n");
					}
					else
					{
						self.goalentity.goalentity_bad_finished = time + 6;
						//bprint ("Set 2\n");
					}
					self.goalentity = world;
					//bprint ("Change goal entity\n");
				}
				self.button0 = FALSE;
				self.bot_backup_finished = time + (self.realspeed / 25); // FIXME: This formula is bad
			}
		}
		//TODO: Add backward check!
		// Same thing but tell the bot to move forward!
	}

	// Bot wall bump
	if (self.bot_hitwall && self.keys == KEY_MOVEFORWARD && self.realspeed <= 5 && self.bot_backup_finished < time)
		self.bot_backup_finished = time + 0.3 + random()*0.3;

	if (self.bot_backup_finished > time)
	{
		if (random() < 0.5)
		{
			if (rw_use_waypoint_system)
			{
				self.goalentity_waypoint = Bot_FindClosestRW_Waypoint();
				//if (visible(self.goalentity_waypoint))
					self.goalentity = self.goalentity_waypoint;
			}
			else
			{
				self.enemy = BotGetClosestPlayer(); // Find new target while backing up
				if (self.enemy)
					self.goalentity = self.enemy;
			}
		}
		else
			self.goalentity = Bot_FindClosestItem();

		self.button0 = FALSE;
		self.keys = KEY_MOVEBACK;
	}
	else // forward
	{
		//
		// Turbo logic (hit player, remove napalm fire, etc)
		//

		float rangetest = range(self.goalentity);
		float er = self.realang_x * -1;
		if (self.goalentity.origin_z > self.origin_z && (er > 10 && er < 60) && infront(self.goalentity, 0.7) || (self.onfire_finished > time || self.frozen_finished > time || self.slow_finished > time)
		|| (infront(self.goalentity, 0.8) && visible(self.goalentity) && self.turbo_fuel > 0 && rangetest != RANGE_CLOSE))
			self.button0 = TRUE;
		else
			self.button0 = FALSE;

		self.keys = KEY_MOVEFORWARD;
	}

	//
	// Get player to hunt
	//

	if (!self.enemy && self.bot_huntitem_finished < time)
	{
		if (rw_use_waypoint_system)
		{
			self.goalentity_waypoint = Bot_FindClosestRW_Waypoint();
			//if (visible(self.goalentity_waypoint))
				self.goalentity = self.goalentity_waypoint;
			/*
			else
			{
				self.enemy = BotGetClosestPlayer();
				if (self.enemy)
					self.goalentity = self.enemy;
			}
			*/
		}
		else
		{
			self.enemy = BotGetClosestPlayer();
			if (self.enemy)
				self.goalentity = self.enemy;
		}
	}

	//
	// Out of ammo routine
	//

	if (self.ammo_firerocket < 1 && self.ammo_homingrocket < 1 && self.ammo_powerrocket < 1 && self.ammo_napalm < 1 && self.ammo_rico < 1 && self.ammo_remote < 1 && self.ammo_freeze < 1)
	{
		if (rw_use_waypoint_system)
		{
			self.goalentity_waypoint = Bot_FindClosestRW_Waypoint();
			//if (visible(self.goalentity_waypoint))
				self.goalentity = self.goalentity_waypoint;
			/*
			else
			{
				self.goalentity = Bot_FindClosestItem();
				self.bot_huntitem_finished = time + 3;
			}
			*/
		}
		else
		{
			self.goalentity = Bot_FindClosestItem();
			self.bot_huntitem_finished = time + 3;
		}
	}

	//
	// Bot firing / targetting
	//

	if (self.goalentity || self.enemy)
	{
		if (visible(self.enemy) && self.enemy.cloak_finished < time && self.enemy.invulnerable_finished < time && /*self.frozen_finished < time &&*/ self.blind_finished < time && self.invulnerable_finished < time)
		{
			// AI Special Command move - Cloak
			if (self.health < (self.max_health / 3) && self.commandspcl_finished < time && random() < 0.012 && self.energy >= 50 && self.frozen_finished < time)
			{
				self.energy -= 50;
				self.cloak_finished = time + 5;
				sound (self, CHAN_BODY, "combat/cloak.wav", 1, ATTN_NORM);
				self.commandspcl_finished = time + 5;
			}
			// AI Special Command move - Rear attack
			if (behind(self.enemy, 0.90) && self.commandspcl_finished < time && random() < 0.025 && self.frozen_finished < time)
			{
				CarAttack(1, TRUE);
				self.commandspcl_finished = time + 1;
			}
			if (infront(self.enemy, 0.75))
			{
				rangetest = range(self.enemy);
				// AI Special Command move - Shield
				if ((self.health < (self.max_health / 2) || self.frozen_finished > time) && self.commandspcl_finished < time && random() < 0.018 && self.energy >= 50)
				{
					self.energy -= 50;
					self.shield_finished = time + 3;
					Fire_Shield();
					self.commandspcl_finished = time + 3;
					if (self.frozen_finished > time) // Shield breaks ice
						self.frozen_finished = time;
				}
				// AI Special Command move - Freeze
				if (self.energy >= 80 && (rangetest == RANGE_NEAR || rangetest == RANGE_CLOSE) && random() < 0.025 && self.commandspcl_finished < time && self.frozen_finished < time)
				{
					Fire_Freeze(FALSE);
					self.energy -= 80;
					self.commandspcl_finished = time + 1;					
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
					if (self.vehicle == VEH_RAZORBACK && rangetest != RANGE_FAR)
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_MINCEMEAT && rangetest != RANGE_FAR)
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_STREETKING && (rangetest == RANGE_NEAR || rangetest == RANGE_CLOSE))
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_SANDROAMER && (rangetest == RANGE_NEAR || rangetest == RANGE_CLOSE))
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_THOROGOOD && rangetest != RANGE_FAR)
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
					}
					if (self.vehicle == VEH_NIGHTSHADE && rangetest != RANGE_FAR)
					{
						self.weapon = WEP_SPECIAL;
						self.button4 = TRUE;
						self.button0 = TRUE; // Turbo ram into player while firing special
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
			{
				if (rw_use_waypoint_system)
				{
					self.goalentity_waypoint = Bot_FindClosestRW_Waypoint();
					//if (visible(self.goalentity_waypoint))
						self.goalentity = self.goalentity_waypoint;
				}
				else
					self.goalentity = self.enemy;
			}
		}
		else
		{
			// AI Special Command move - Landmine, randomly drop one here and there while item hunting
			if (self.energy >= 33 && self.frozen_finished < time && random() < 0.001 && self.commandspcl_finished < time && self.frozen_finished < time)
			{
				Fire_Landmine();
				self.energy -= 33;
				self.commandspcl_finished = time + 1;
			}
			//bprint ("BOT: Can't see enemy, hunting item\n");
			self.button3 = FALSE;
			self.button4 = FALSE;
			if (rw_use_waypoint_system)
			{
				self.goalentity_waypoint = Bot_FindClosestRW_Waypoint();
				//if (visible(self.goalentity_waypoint))
					self.goalentity = self.goalentity_waypoint;
			}
			else
				self.goalentity = Bot_FindClosestItem();
			self.enemy = BotGetClosestPlayer(); // Find new target while item hunting
			if (self.bot_huntitem_finished < time)
				self.bot_huntitem_finished = time + 3;
		}
	}
	else
	{
		if (rw_use_waypoint_system)
		{
			self.goalentity_waypoint = Bot_FindClosestRW_Waypoint();
			self.goalentity = self.goalentity_waypoint;
		}
		else
		{
			if (random() < 0.5)
				self.goalentity = Bot_FindClosestItem();
			else
			{
				self.enemy = BotGetClosestPlayer(); // Find new target
				if (self.enemy)
					self.goalentity = self.enemy;
			}
		}
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