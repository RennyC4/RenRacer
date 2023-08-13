void() bot_ai_race =
{
	if (race_status != RACE_STARTED)
		return;

	makevectors_mdl(self.v_angle);

	//
	// Bot searches for stuff
	//

	if (!self.goal_touched) // Bot searches for start/finish flag to start race
	{
		if (!self.goalentity)
		{
			GetGoalPoint(); // Get goal entities position, only needs to be done once
			self.goalentity = self.goalentity_goal;
			//bprint ("Beginning goal entity set\n");
		}
	}
	else
	{
		if (!self.goalentity)
			GetCheckPoint(); // Bot gets first goalentity waypoint after hitting beginning goal
		else
		{
			self.goalentity_time = self.goalentity_time + 1; // Bot counts how long its taking to reach goal
			//bprint (ftos(self.goalentity_time), "\n");

			if (self.checkpoint == self.goalentity.checkpoint) // Find next target
			{
				//if (self.findcheckpoint_fail > 1) // Reached the end of valid checkpoints
				if (self.checkpoint == total_checkpoints)
				{
					self.goalentity = self.goalentity_goal;
					self.goalentity_time = 0; // reset goalentity timer
					//bprint("Go for Goal!\n");
				}
				else
				{
					GetCheckPoint();
					if (self.goalentity != self.goalentity_checkpoint)
					{
						self.goalentity = self.goalentity_checkpoint;
						self.goalentity_time = 0; // reset goalentity timer
					}
					//bprint ("GetCheckPoint\n");
				}
				//self.findcheckpoint_fail = self.findcheckpoint_fail + 1;
			}
		}
	}

	//
	// Goalentity is set management: Compare distances - switch to closest
	//

	if (self.goalentity.classname != "bot_waypoint_goal")
	{
		if (self.checkpoint == total_checkpoints) // Start searching for goal point once all checkpoints are hit
		{
			local float findgp = FindGoalPoint();
			if (findgp)
			{
				self.goalentity = self.goalentity_goal;
				self.goalentity_time = 0; // reset goalentity timer
				//bprint ("Bot is going for goal point\n");
			}
		}
		if (self.goalentity_checkpoint || self.goalentity_waypoint)
		{
			local float check_dist_wp;
			if (!self.goalentity_waypoint)
				check_dist_wp = 9999999; // Waypoints don't always exist, checkpoints do
			else
				check_dist_wp = vlen(self.origin - self.goalentity_waypoint.origin);

			local float check_dist_cp = vlen(self.origin - self.goalentity_checkpoint.origin);

			if (check_dist_cp > check_dist_wp) // waypoint is closer than checkpoint/marker
			{
				if (self.goalentity != self.goalentity_waypoint)
				{
					if (self.goalentity)
						self.old_goalentity = self.goalentity; // Stash it

					if (self.goalentity_waypoint.waypoint == self.waypoint + 1)
					{
						self.goalentity = self.goalentity_waypoint;
						self.goalentity_time = 0; // reset goalentity timer
						//bprint ("Dist: Goal entity set to waypoint\n");
					}
					else
					{
						if (self.goalentity != self.goalentity_checkpoint)
						{
							self.goalentity = self.goalentity_checkpoint;
							self.goalentity_time = 0; // reset goalentity timer
							//bprint ("Dist: Had to switch to checkpoint\n");
						}
					}
				}
			}
			else // checkpoint/marker is closer than waypoint
			{
				if (self.goalentity != self.goalentity_checkpoint)
				{
					if (self.goalentity)
						self.old_goalentity = self.goalentity; // Stash it

					if (self.checkpoint < total_checkpoints) // Bot hasn't ran out of valid checkpoints yet...
					{
						if (self.goalentity != self.goalentity_checkpoint)
						{
							self.goalentity = self.goalentity_checkpoint;
							self.goalentity_time = 0; // reset goalentity timer
							//bprint ("Dist: Goal entity switch to CheckPoint\n");
						}
					}
				}
			}
		}
	}

	//
	// Normal driving routine
	//

	if (self.goalentity)
	{
		float r = vlen(self.origin - self.goalentity.origin) * 0.1; // Find distance to goalentity target

		// Debug distance to goalentity
		// local string f = ftos(self.realspeed);
		// local string n = ftos(r);
		// bprint ("Speed: ", f, " Dist: ", n, "\n");

		// Back up for randomly for a second, hit a wall/obstacle
		if (self.goal_touched && /*self.bot_hitwall &&*/ (self.keys == KEY_MOVEFORWARD || (self.button0 && self.turbo_fuel > 0)) && self.realspeed <= 3)
		{
			self.velocity = v_forward * -9999;
			self.keys = KEY_MOVEBACK;
			self.bot_backup_finished = time + 0.3 + random()*0.3;
		}

		if (self.bot_backup_finished < time)
		{
			if (self.bot_search_finished < time) // Bot searches while driving
			{
				if (self.goalentity.classname == "marker")				
					FindWayPoint(); // Find waypoints along the way
				if (self.goalentity.classname == "bot_waypoint")
					FindCheckPointDriving(); // Always looks for visible checkpoints

				if (race_status == RACE_STARTED)
				{
					if (!visible(self.goalentity))
						self.bot_search_count = self.bot_search_count + 1; // count till targ switch
					else
						self.bot_search_count = 0;
				}

				// Bot is stuck / lost, or is taking too long to hit its goal
				if (self.bot_search_count >= 15 || self.goalentity_time >= 30)
				{
					for (entity targ = world;(targ = find(targ, classname, "player"));)
					{
						if (!visible(targ) && targ.trail.cnt && (targ.checkpoint > self.checkpoint || targ.waypoint > self.waypoint))
						{
							// Steal player stats & update goal entities
							if (targ.checkpoint > self.checkpoint)
							{
								self.checkpoint = targ.checkpoint;
								GetCheckPoint();
							}
							if (targ.waypoint > self.waypoint)
							{
								self.waypoint = targ.waypoint;
								FindWayPoint();
							}
							if (targ.lap > self.lap)
								self.lap = targ.lap;

							self.checkpoint_lastpos = targ.checkpoint_lastpos;
							self.angles_y = targ.trail.angles_y;
							self.fixangle = TRUE; // Is this needed?
							//
							self.goalentity_time = 0;
							self.bot_search_count = 0;
							self.collide_finished = time + 1; // Don't bump player on teleport
							makevectors(self.realang);
							car_teleport(self, targ.trail.origin, TRUE, FALSE);
							self.bot_search_count = 0;

							if (cvar("developer") == 2)							
								bprint ("Teleported bot to player trail entity\n");
						}
					}
				}
				self.bot_search_finished = time + 0.1;
			}

			if (self.goalentity.classname == "bot_waypoint_goal")
				local float goforgoal = TRUE;
			else
				goforgoal = FALSE;

			if (r >= 100) // Far from goal
			{
				if (goforgoal)
				{
					if (infront(self.goalentity, 0.7) && visible(self.goalentity))
					{
						if (self.turbo_fuel >= 0)
							self.button0 = TRUE;
					}
					else
						self.button0 = FALSE;
				}
				else
				{
					if (infront(self.goalentity, 0.8) && visible(self.goalentity) && self.turbo_fuel > 0 && r >= 125)
						self.button0 = TRUE; // Bot normal turbo
					else
						self.button0 = FALSE;
				}
				self.velocity = v_forward * 9999; // Forward
				self.keys = KEY_MOVEFORWARD;
			}
			else // Close to goal
			{
				if (self.realspeed > 50)
				{
					if (!goforgoal)
					{
						if (self.waypoint_speed != 999)
						{
							self.velocity = v_forward * -9999; // Back
							self.keys = KEY_MOVEBACK; // Slow down, coming in too fast!
						}
						//bprint ("Moving in too hot!\n");
					}
					else
					{
						self.velocity = v_forward * 9999; // Forward
						self.keys = KEY_MOVEFORWARD;
					}
				}
				else
				{
					if (!self.goal_touched) // Go for goal point
					{
						self.button0 = TRUE;
						self.velocity = v_forward * 9999; // Forward
						self.keys = KEY_MOVEFORWARD;
					}
					else
					{
						if (self.realspeed < 50)
						{
							self.velocity = v_forward * 9999; // Forward
							self.keys = KEY_MOVEFORWARD;
						}
						else
						{
							if (self.waypoint_speed != 999)
							{
								self.velocity = v_forward * -9999; // Back
								self.keys = KEY_MOVEBACK;
							}
						}
						self.button0 = FALSE;
					}
				}
	
				// Adhere to waypoint set speeds when close to waypoint/marker
				if (self.waypoint_speed > 0)
				{
					if (self.realspeed > self.waypoint_speed)
					{
						self.velocity = v_forward * -9999; // Back
						self.keys = KEY_MOVEBACK;
					}
					else
					{
						self.velocity = v_forward * 9999; // Forward
						self.keys = KEY_MOVEFORWARD;
					}
					// 999 Speed waypoint tells bot to turbo, but only if facing goal entity & visible
					if (self.waypoint_speed == 999 && infront(self.goalentity, 0.992) && visible(self.goalentity))
					{
						if (self.turbo_fuel > 0)
						{
							self.button0 = TRUE;
							self.velocity = v_forward * 9999; // Forward
							self.keys = KEY_MOVEFORWARD;
							//bprint ("Waypoint says to Turbo\n");
						}
						else
							self.button0 = FALSE;
					}
				}
			}

			// Fight inclines
			if (self.goalentity.origin_z > self.origin_z && self.angles_x >= 5 && infront(self.goalentity, 0.7))
			{
				self.velocity = v_forward * 9999; // Forward
				self.keys = KEY_MOVEFORWARD;
				if (self.turbo_fuel >= 0)
					self.button0 = TRUE;
				//bprint ("Fighting an incline\n");
			}
		}
		else // backing up
		{
			self.button0 = FALSE;
			self.velocity = v_forward * -9999; // Back
			self.keys = KEY_MOVEBACK;
		}

		bot_angle_set();

		// AI cheats, can always turbo
		if (self.turbo_fuel < 100)
			self.turbo_fuel = 100;

		/*
		// Debugging prints
		bprint (self.goalentity.classname, "\n");
		local string d1 = ftos (self.goalentity.origin_x);
		local string d2 = ftos (self.goalentity.origin_y);
		local string d3 = ftos (self.goalentity.origin_z);
		bprint (d1, "\n");
		bprint (d2, "\n");
		bprint (d3, "\n");
		*/
	}
};