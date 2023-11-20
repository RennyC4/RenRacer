//
// Start / Finish flag - Brush format
//

string nextmap;

// Players lost vs Bots
void() rally_goal_samemap =
{
	changelevel(mapname); // repeat level
};

void() rally_goal_nextmap =
{
	if (world.model == "maps/map1.bsp")
		nextmap = "map2";
	if (world.model == "maps/map2.hmp")
		nextmap = "map3";
	if (world.model == "maps/map3.hmp")
		nextmap = "map4";
	if (world.model == "maps/map4.hmp")
		nextmap = "map5";
	if (world.model == "maps/map5.bsp")
		nextmap = "map6";
	if (world.model == "maps/map6.hmp")
		nextmap = "map1";
	changelevel(nextmap);
};

void() rally_goal_touch =
{
	if (other.owner.driving.classname != "player")
		return;

	// Race start
	if (other.owner.driving.checkpoint == 0 && !other.owner.driving.goal_touched)
	{
		other.owner.driving.goal_touched = TRUE; // run once
		other.owner.driving.start_laptime = TRUE; // Start counter
		other.owner.checkpoint_lastpos = other.owner.origin + v_up * 64;

		if (!self.message)
			centerprint(other.owner.driving, "!!! GAS GAS GAS !!!\n");
		else
			centerprint(other.owner.driving, self.message); // custom mapper message
		
		if (other.owner.driving.music != self.music && self.music)
		{
			if (checkextension("DP_QC_SPRINTF"))
				stuffcmd (other.owner.driving, sprintf("music %s\n", self.music));
			other.owner.driving.music = self.music;
		}
	}

	if (other.owner.driving.checkpoint == self.checkpoint)
	{
		if (other.owner.driving.lap == self.lap)
		{
			// Setup map change
			nextmap = mapname;
			self.touch = SUB_Null;
			if (clienttype(other.owner.driving) == CLIENTTYPE_BOT)
			{
				for (entity targ = world;(targ = find(targ, classname, "player"));)
				{
					if (clienttype(targ) == CLIENTTYPE_REAL)
					{
						stuffcmd(targ, "play youlose.wav\n");
						stuffcmd(targ, "play crowdboo.wav\n");
						stuffcmd(targ, "music sound/music/racelose.ogg\n");
						centerprint(targ, "/P^1\n!!! ^bYOU LOSE^b ^1!!!\n\n^3^b\nTry again!\n");
					}
				}
				self.think = rally_goal_samemap; // players lost race, restart
			}
			else
				self.think = rally_goal_nextmap;
			self.nextthink = time + 10;

			if (other.owner.driving.laptime < other.owner.driving.fastest_lap) // Update best lap time if need be on race finish
				other.owner.driving.fastest_lap = other.owner.driving.laptime;

			string l5 = ftos(other.owner.driving.fastest_lap);
			l5 = sprintf("%.2f", other.owner.driving.fastest_lap); // cut down numbers
			if (other.owner.driving.fastest_lap > 0) // Print fastest lap time
				bprint(other.owner.driving.netname, "'s Fastest lap: ", l5, "\n");

			string l6 = ftos(other.owner.driving.overall_time);
			l6 = sprintf("%.2f", other.owner.driving.overall_time); // cut down numbers
			bprint(other.owner.driving.netname, "'s Overall Time: ", l6, "\n");

			centerprint(other.owner.driving, "/P^3!!! ^3^bYOU WIN^b^7 ^3!!!\n\n^7Fastest Lap: ", l5, "\n Overall Time: ", l6, "\n");
			stuffcmd (other.owner.driving, "play youwin.wav\n");
			bprint (other.owner.driving.netname, " won the race!\n");

			sound (self, CHAN_AUTO, "finish.wav", 1, ATTN_NONE);
			sound (self, CHAN_AUTO, "camera.wav", 1, ATTN_NONE);
			stuffcmd(other.owner.driving, "wf\n");
			other.owner.driving.start_laptime = FALSE; // Turn off lap time recording

			other.owner.driving.music = "sound/music/racewin.ogg";
			stuffcmd (other.owner.driving, sprintf("music %s\n", other.owner.driving.music));

			race_status = RACE_FINISHED;
		}
		else
		{
			other.owner.driving.lap = other.owner.driving.lap + 1;
			other.owner.driving.frags = other.owner.driving.lap; // FIXME: Hack for CSQC reading players 'frags' on scoreboard
			other.owner.driving.checkpoint = 0; // Reset lap checkpoint counter

			string l = ftos(other.owner.driving.lap);
			string l2 = ftos(self.lap);
			string l3 = ftos(other.owner.driving.laptime);
			l3 = sprintf("%.2f", other.owner.driving.laptime); // cut down numbers

			// Record best lap time
			if (!other.owner.driving.fastest_lap)
				other.owner.driving.fastest_lap = other.owner.driving.laptime;
			else
			{
				if (other.owner.driving.laptime < other.owner.driving.fastest_lap) // Update best lap time
				{
					if (other.owner.driving.lap != self.lap) // Don't play fastlap over finallap
					{
						stuffcmd (other.owner.driving, "play fastlap.wav\n");
						float conflict = TRUE;
					}
					other.owner.driving.fastest_lap = other.owner.driving.laptime;
				}
			}

			string l4 = ftos(other.owner.driving.fastest_lap);
			l4 = sprintf("%.2f", other.owner.driving.fastest_lap); // cut down numbers
			if (other.owner.driving.fastest_lap > 0 && other.owner.driving.lap > 1) // Print fastest lap time
				sprint (other.owner.driving, "Fastest Lap: ", l4, "\n");

			other.owner.driving.laptime = 0; // Reset lap time
			other.owner.driving.waypoint = 0; // Reset bot waypoints
			other.owner.driving.bot_search_count = 0; // Reset bot search counter
			other.owner.driving.findcheckpoint_fail = 0; // Reset bot 'end of checkpoints' check/counter
			other.owner.driving.goalentity = world; // Reset bot goalentity
			other.owner.checkpoint_lastpos = other.owner.origin + v_up * 64;

			if (other.owner.driving.lap == self.lap)
			{
				stuffcmd (other.owner.driving, "play finallap.wav\n");
				centerprint(other.owner.driving, "/P^b^1!! FINAL LAP !!^b\n", "^7Lap Time: ^4", l3);
			}
			else
			{
				centerprint(other.owner.driving, "/PLap [^3", l, " ^7/ ^1", l2, "^7]\n ^7Lap Time: ^4", l3);
				if (!conflict)
					stuffcmd (other.owner.driving, "play lap.wav\n");
			}
			other.owner.driving.clearcprint_finished = time + 2;
		}
	}
};

void() rally_goal_think =
{
	if (self.sound_finished < time && self.cnt > 6)
	{
		sound (self, CHAN_AUTO, "windyflag.wav", 1, ATTN_NORM);
		self.sound_finished = time + 25;
	}
	if (self.cnt < 10)
		self.cnt = self.cnt + 1;
	self.nextthink = self.ltime + 1;
};

// Supports .message which is used for custom race start centerprints
void() rally_goal =
{
	if (ragewar)
	{
		remove(self);
		return;
	}

	precache_sound ("lap.wav");
	precache_sound ("finish.wav");
	precache_sound ("windyflag.wav");

	InitTrigger();
	self.touch = rally_goal_touch;
	self.think = rally_goal_think;
	self.nextthink = self.ltime + 1;
};