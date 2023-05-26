//
// Start / Finish brush
//

string nextmap;
void() rally_goal_nextmap =
{
	changelevel(nextmap);
};

void() rally_goal_touch =
{
	if (other.owner.driving.classname != "player")
		return;

	//bprint (other.owner.driving.classname);
	//bprint ("\n");

	// Race start
	if (other.owner.driving.checkpoint == 0 && !other.owner.driving.goal_touched)
	{
		other.owner.driving.goal_touched = TRUE; // run once
		other.owner.driving.start_laptime = TRUE; // Start counter

		if (!self.message)
			centerprint(other.owner.driving, "!!! GAS GAS GAS !!!\n");
		else
			centerprint(other.owner.driving, self.message); // custom mapper message
		
		if (other.owner.driving.music != self.music && self.music)
		{
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
			self.think = rally_goal_nextmap;
			self.nextthink = time + 5;

			centerprint(other.owner.driving, "!!! YOU WIN !!!\n");
			bprint (other.owner.driving.netname, " won the race!\n");

			if (other.owner.driving.laptime < other.owner.driving.fastest_lap) // Update best lap time if need be on race finish
				other.owner.driving.fastest_lap = other.owner.driving.laptime;

			local string l5 = ftos(other.owner.driving.fastest_lap);
			if (other.owner.driving.fastest_lap > 0) // Print best time
				sprint (other.owner.driving, "Best Lap: ", l5, "\n");

			local string l6 = ftos(other.owner.driving.overall_time);
				sprint (other.owner.driving, "Overall Time: ", l6, "\n");

			sound (self, CHAN_AUTO, "finish.wav", 1, ATTN_NONE);
			other.owner.driving.start_laptime = FALSE; // Turn off lap time recording
			race_status = RACE_FINISHED;
		}
		else
		{
			other.owner.driving.lap = other.owner.driving.lap + 1;
			other.owner.driving.checkpoint = 0; // Reset lap checkpoint counter

			local string l = ftos(other.owner.driving.lap);
			local string l2 = ftos(self.lap);
			local string l3 = ftos(other.owner.driving.laptime);

			// Record best lap time
			if (!other.owner.driving.fastest_lap)
				other.owner.driving.fastest_lap = other.owner.driving.laptime;
			else
			{
				if (other.owner.driving.laptime < other.owner.driving.fastest_lap) // Update best lap time
					other.owner.driving.fastest_lap = other.owner.driving.laptime;
			}

			local string l4 = ftos(other.owner.driving.fastest_lap);
			if (other.owner.driving.fastest_lap > 0) // Print best time
				sprint (other.owner.driving, "Best Lap: ", l4, "\n");

			other.owner.driving.laptime = 0; // Reset lap time
			centerprint(other.owner.driving, "Lap: ", l, " of ", l2, "\n Lap Time: ", l3);
			sound (self, CHAN_AUTO, "lap.wav", 1, ATTN_NORM);
		}
	}
};

// Supports .message which is used for custom race start centerprints
void() rally_goal =
{
	precache_sound ("lap.wav");
	precache_sound ("finish.wav");

	InitTrigger();
	self.touch = rally_goal_touch;
};