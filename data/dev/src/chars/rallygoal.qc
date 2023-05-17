//
// Start / Finish brush
//

string nextmap;
void() rally_goal_nextmap =
{
	changelevel (nextmap);
};

void() rally_goal_touch =
{
	if (other.owner.driving.classname != "player")
		return;

	//bprint (other.owner.driving.classname);
	//bprint ("\n");

	if (other.owner.driving.checkpoint == self.checkpoint)
	{
		if (other.owner.driving.lap == self.lap)
		{
			nextmap = mapname;
			self.touch = SUB_Null;
			self.think = rally_goal_nextmap;
			self.nextthink = time + 5;
			centerprint(other.owner.driving, "!!! YOU WIN !!!\n");
			bprint (other.owner.driving.netname, " won the race!\n");
			sound (self, CHAN_AUTO, "finish.wav", 1, ATTN_NONE);
		}
		else
		{
			other.owner.driving.lap = other.owner.driving.lap + 1;
			other.owner.driving.checkpoint = 0; // Reset lap checkpoint

			local string l = ftos(other.owner.driving.lap);
			local string l2 = ftos(self.lap);
			centerprint5(other.owner.driving, "Lap: ", l, " of ", l2, "\n");
			sound (self, CHAN_AUTO, "lap.wav", 1, ATTN_NORM);
		}
	}
};

void() rally_goal =
{
	precache_sound ("lap.wav");
	precache_sound ("finish.wav");

	InitTrigger();
	self.touch = rally_goal_touch;
};