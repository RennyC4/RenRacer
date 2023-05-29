//
// Goldcup Start / Finish flag 
//

// spawnflag 1:
// The same as rally_goal_touch, except it spawns at the bottom of
// the goal flag and uses findradius(); - mostly used for hmp maps
// since adding brush entities is more difficult
void() rally_goal_proxy_think =
{
	local entity targ = findradius(self.origin, 175);
	while (targ)
	{
		// Race start
		if (targ.classname == "player" && fisible(targ) && cvar("developer") != 1)
		{
			if (targ.checkpoint == 0 && !targ.goal_touched)
			{
				targ.goal_touched = TRUE; // run once
				targ.start_laptime = TRUE; // Start counter

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
		}

		if (targ.checkpoint == self.checkpoint)
		{
			if (targ.lap == self.lap)
			{
				// Setup map change
				nextmap = mapname;
				self.think = rally_goal_nextmap;
				self.nextthink = time + 5;

				centerprint(targ, "/P^3!!! ^3^bYOU WIN^b^7 ^3!!!\n");
				bprint (targ.netname, " won the race!\n");

				if (targ.laptime < targ.fastest_lap) // Update best lap time if need be on race finish
					targ.fastest_lap = targ.laptime;

				local string l5 = ftos(targ.fastest_lap);
				if (targ.fastest_lap > 0) // Print best time
					sprint (targ, "Best Lap: ", l5, "\n");

				local string l6 = ftos(targ.overall_time);
					sprint (targ, "Overall Time: ", l6, "\n");

				sound (self, CHAN_AUTO, "finish.wav", 1, ATTN_NONE);
				sound (self, CHAN_AUTO, "camera.wav", 1, ATTN_NONE);
				stuffcmd(targ, "wf\n");
				targ.start_laptime = FALSE; // Turn off lap time recording
				race_status = RACE_FINISHED;
				return; // needed otherwise map change happens immediately
			}
			else
			{
				targ.lap = targ.lap + 1;
				targ.checkpoint = 0; // Reset lap checkpoint counter

				local string l = ftos(targ.lap);
				local string l2 = ftos(self.lap);
				local string l3 = ftos(targ.laptime);

				// Record best lap time
				if (!targ.fastest_lap)
					targ.fastest_lap = targ.laptime;
				else
				{
					if (targ.laptime < targ.fastest_lap) // Update best lap time
						targ.fastest_lap = targ.laptime;
				}

				local string l4 = ftos(targ.fastest_lap);
				if (targ.fastest_lap > 0) // Print best time
					sprint (targ, "Best Lap: ", l4, "\n");

				targ.laptime = 0; // Reset lap time

				if (targ.lap == self.lap)
					centerprint(targ, "/P^b^1!! FINAL LAP !!^b\n", "^7Lap Time: ^4", l3);
				else
					centerprint(targ, "/PLap [^3", l, " ^7/ ^1", l2, "^7]\n ^7Lap Time: ^4", l3);

				targ.clearcprint_finished = time + 2;
				sound (self, CHAN_AUTO, "lap.wav", 1, ATTN_NORM);
			}
		}
		targ = targ.chain;
	}
	frameskip(0.01);
};

void() rally_startfinish_flag =
{
	precache_model ("progs/finish.mdl");
	precache_sound ("lap.wav");
	precache_sound ("finish.wav");

	setmodel(self, "progs/finish.mdl");
	setsize(self, '0 0 0', '0 0 0');
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.origin_z = self.origin_z + 1;
	droptofloor();
	
	local entity botpoint = spawn();
	botpoint.classname = "bot_waypoint_goal";
	setmodel (botpoint, string_null);
	setorigin (botpoint, self.origin);

	if (self.spawnflags & 1)
	{
		local entity goal = spawn();
		setmodel (goal, string_null);
		setorigin (goal, self.origin);

		if (!self.checkpoint)
			error("No checkpoint value set on spawnflag 1 - rally_startfinish_flag\n");
		else
			goal.checkpoint = self.checkpoint;

		if (!self.lap)
			goal.lap = 2;
		else
			goal.lap = self.lap;
		
		if (self.music)
			goal.music = self.music;
		if (self.message)
			goal.message = self.message;

		goal.think = rally_goal_proxy_think;
		goal.nextthink = time + 0.1;
	}
};