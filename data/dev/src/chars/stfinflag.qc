//
// Start / Finish flag 
//

// spawnflag 1:
// The same as rally_goal_touch, except it spawns at the bottom of
// the goal flag and uses findradius(); - mostly used for hmp maps
// since adding brush entities is more difficult

void() rally_goal_proxy_think =
{
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= self.radius)
		{ 	// Race start
			if (targ && visible(targ) && cvar("developer") != 1)
			{
				if (targ.checkpoint == 0 && !targ.goal_touched)
				{
					targ.goal_touched = TRUE; // run once
					targ.start_laptime = TRUE; // Start counter
					targ.checkpoint_lastpos = targ.origin + v_up * 64;

					if (!self.message)
						centerprint(targ, "!!! GAS GAS GAS !!!\n");
					else
						centerprint(targ, self.message); // custom mapper message
				
					if (targ.music != self.music && self.music)
					{
						if (checkextension("DP_QC_SPRINTF"))
							stuffcmd (targ, sprintf("music %s\n", self.music));
						targ.music = self.music;
					}
				}

				if (targ.checkpoint == self.checkpoint)
				{
					if (targ.lap == self.lap)
					{
						// Setup map change
						nextmap = mapname;
						if (clienttype(targ) == CLIENTTYPE_BOT)
						{
							for (entity plyr = world;(plyr = find(plyr, classname, "player"));)
							{
								if (clienttype(plyr) == CLIENTTYPE_REAL)
								{
									stuffcmd(plyr, "play youlose.wav\n");
									stuffcmd(plyr, "play crowdboo.wav\n");
									stuffcmd(plyr, "music sound/music/racelose.ogg\n");
									centerprint(plyr, "/P^1\n!!! ^bYOU LOSE^b ^1!!!\n\n^3^b\nTry again!\n");
								}
							}
							self.think = rally_goal_samemap; // players lost race, restart
						}
						else
							self.think = rally_goal_nextmap;
						self.nextthink = time + 10;

						if (targ.laptime < targ.fastest_lap) // Update best lap time if need be on race finish
							targ.fastest_lap = targ.laptime;

						string l5 = ftos(targ.fastest_lap);
						l5 = sprintf("%.2f", targ.fastest_lap); // cut down numbers
						if (targ.fastest_lap > 0) // Print fastest lap time
							bprint(targ.netname, "'s Fastest Lap: ", l5, "\n");

						string l6 = ftos(targ.overall_time);
						l6 = sprintf("%.2f", targ.overall_time); // cut down numbers
						bprint(targ.netname, "'s Overall Time: ", l6, "\n");

						centerprint(targ, "/P^3!!! ^3^bYOU WIN^b^7 ^3!!!\n\n^7Fastest Lap: ", l5, "\n Overall Time: ", l6, "\n");
						stuffcmd (targ, "play youwin.wav\n");
						bprint (targ.netname, " won the race!\n");

						sound (self, CHAN_AUTO, "finish.wav", 1, ATTN_NONE);
						sound (self, CHAN_AUTO, "camera.wav", 1, ATTN_NONE);
						stuffcmd(targ, "wf\n");
						targ.start_laptime = FALSE; // Turn off lap time recording
						race_status = RACE_FINISHED;

						targ.music = "sound/music/racewin.ogg";
						stuffcmd (targ, sprintf("music %s\n", targ.music));

						return; // needed otherwise map change happens immediately
					}
					else
					{
						targ.lap = targ.lap + 1;
						targ.frags = targ.lap; // FIXME: Hack for CSQC reading players 'frags' on scoreboard
						targ.checkpoint = 0; // Reset lap checkpoint counter

						string l = ftos(targ.lap);
						string l2 = ftos(self.lap);
						string l3 = ftos(targ.laptime);
						l3 = sprintf("%.2f", targ.laptime); // cut down numbers

						// Record best lap time
						if (!targ.fastest_lap)
							targ.fastest_lap = targ.laptime;
						else
						{
							if (targ.laptime < targ.fastest_lap) // Update best lap time
							{
								if (targ.lap != self.lap) // Don't play fastlap.wav over finallap.wav
								{
									float conflict = TRUE;
									stuffcmd (targ, "play fastlap.wav\n");
								}
								targ.fastest_lap = targ.laptime;
							}
						}

						string l4 = ftos(targ.fastest_lap);
						l4 = sprintf("%.2f", targ.fastest_lap); // cut down numbers
						if (targ.fastest_lap > 0 && targ.lap > 1) // Print fastest lap time
							sprint (targ, "Fastest Lap: ", l4, "\n");

						targ.laptime = 0; // Reset lap time
						targ.waypoint = 0; // Reset bot waypoints
						targ.bot_search_count = 0; // Reset bot search counter
						targ.findcheckpoint_fail = 0; // Reset bot 'end of checkpoints' check/counter
						targ.goalentity = world; // Reset bot goalentity
						targ.checkpoint_lastpos = targ.origin + v_up * 64;

						if (targ.lap == self.lap)
						{
							stuffcmd (targ, "play finallap.wav\n");
							centerprint(targ, "/P^b^1!! FINAL LAP !!^b\n", "^7Lap Time: ^4", l3);
						}
						else
						{
							centerprint(targ, "/PLap [^3", l, " ^7/ ^1", l2, "^7]\n ^7Lap Time: ^4", l3);
							if (!conflict)
								stuffcmd (targ, "play lap.wav\n");
						}
						targ.clearcprint_finished = time + 2;
					}
				}
			}
		}
	}

	if (self.sound_finished < time && self.cnt > 6)
	{
		sound (self, CHAN_AUTO, "windyflag.wav", 1, ATTN_NORM);
		self.sound_finished = time + 25;
	}
	if (self.cnt < 10)
		self.cnt = self.cnt + 1;

	frameskip(0.01);
};

void() rally_startfinish_flag =
{
	if (ragewar)
	{
		remove(self);
		return;
	}

	precache_model ("progs/finish.mdl");
	precache_sound ("lap.wav");
	precache_sound ("finish.wav");
	precache_sound ("windyflag.wav");

	setmodel(self, "progs/finish.mdl");
	setsize(self, '0 0 0', '0 0 0');
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.origin_z = self.origin_z + 1;
	droptofloor();
	
	entity botpoint = spawn();
	botpoint.classname = "bot_waypoint_goal";
	setmodel (botpoint, string_null);
	setorigin (botpoint, self.origin);
	botpoint.flags = FL_FINDABLE_NONSOLID; // Needed for findradius to find me

	if (self.spawnflags & 1)
	{
		entity goal = spawn();
		setmodel (goal, string_null);
		setorigin (goal, self.origin);
		goal.origin_z = goal.origin_z + 1;
		goal.flags = FL_FINDABLE_NONSOLID; // Needed for findradius to find me

		if (!self.checkpoint)
			error("No checkpoint value set on spawnflag 1 - rally_startfinish_flag\n");
		else
			goal.checkpoint = self.checkpoint;

		goal.lap = self.lap;

		if (self.music)
			goal.music = self.music;
		if (self.message)
			goal.message = self.message;
		if (!goal.radius)
			goal.radius = 200;

		goal.think = rally_goal_proxy_think;
		goal.nextthink = time + 0.1;
	}
};