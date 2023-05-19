//
// Markers cars are supposed to driven over / near to trigger
//

void() marker_think =
{
	local float OK = 0;

	local entity targ = searchradius(self.origin, 100);
	while (targ)
	{
		if (targ.classname == "player")
		{
			if (self.checkpoint == 1) // first check point
			{
				if (targ.checkpoint == 0)
				{
					targ.checkpoint = self.checkpoint;
					OK = TRUE;
				}
			}
			else if (self.checkpoint > 1)
			{
				if (targ.checkpoint == (self.checkpoint - 1))
				{
					targ.checkpoint = self.checkpoint;
					OK = TRUE;
				}
			}

			if (OK) // Do check point confirm
			{
				self.cnt = TRUE; // Start animation
				self.effects = self.effects | EF_DIMLIGHT;
				local string l = ftos(targ.laptime);
				centerprint (targ, "! Checkpoint !\n", "\n Time: ", l, "\n");
				sound (self, CHAN_AUTO, "checkpoint.wav", 1, ATTN_NORM);
			}
		}
		targ = targ.chain;
	}

	if (self.cnt) // Animation on
	{
		if (self.frame < 6)
		{
			if (self.animation_finished < time)
			{
				self.frame = self.frame + 1;
				self.animation_finished = time + 0.1;
			}
		}
		else
		{
			self.effects = 0;
			self.cnt = FALSE;
			self.frame = 0;
		}
	}

	self.angles_y = self.angles_y + 0.5;
	frameskip(0.01);
};

void() rally_marker =
{
	precache_model ("progs/marker.mdl");
	precache_sound ("checkpoint.wav");

	setmodel(self, "progs/marker.mdl");
	setsize(self, '-60 -60 0', '60 60 0');
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.classname = "marker";
	droptofloor();

	self.think = marker_think;
	self.nextthink = time + 0.1;
};
