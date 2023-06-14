//
// Markers cars are supposed to driven over / near to trigger
//

void() marker_think =
{
	local float OK = 0;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= self.radius)
		{
			if (targ.classname == "player" && visible(targ) && cvar("developer") != 1)
			{
				if (targ.goal_touched && race_status == RACE_STARTED) // Player has to drive through the goals before markers are activated
				{
					if (self.checkpoint == 1) // first check point
					{
						if (targ.checkpoint == 0)
						{
							targ.checkpoint = self.checkpoint;
							self.enemy = targ;
						}
					}
					else if (self.checkpoint > 1)
					{
						if (targ.checkpoint == (self.checkpoint - 1))
						{
							targ.checkpoint = self.checkpoint;
							self.enemy = targ;
						}
					}

					if (self.enemy) // Do check point confirm
					{
						if (cvar("developer") == 2)
							sprint (targ, "CheckPoint_touch: ", ftos(self.checkpoint), "\n");

						self.enemy.effects = EF_MUZZLEFLASH;
						self.cnt = TRUE; // Start animation
						self.effects = self.effects | EF_DIMLIGHT;
						local string l = ftos(self.enemy.laptime);
						l = sprintf("%.2f", self.enemy.laptime); // cut down numbers
						centerprint (self.enemy, "/P^4[^bCheckpoint^b]\n", "^7Time: ^5", l, "\n");
						self.enemy.clearcprint_finished = time + 1;
						sound (self, CHAN_AUTO, "checkpoint.wav", 1, ATTN_NORM);
						self.enemy = world;
					}
				}
				else if (race_status != RACE_FINISHED)
					centerprint (targ, "You must drive through the starting goal to properly start the race!");
			}
		}
	}

	if (self.cnt) // Animation on
	{
		if (self.frame < 5)
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
	self.effects = EF_FULLBRIGHT;
	self.origin_z = self.origin_z + 1;
	self.flags = FL_FINDABLE_NONSOLID; // Needed for findradius to find me
	droptofloor();

	self.think = marker_think;
	self.nextthink = time + 0.1;

	if (!self.radius)
		self.radius = 250;
	if (!self.checkpoint)
		error("rally_marker with no checkpoint value set\n");
};