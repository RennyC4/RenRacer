//
// Markers cars are supposed to driven over / near to trigger
//

void() marker_think =
{
	float OK = 0;
	entity oldself;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= self.radius)
		{
			if (/*visible(targ) &&*/ cvar("developer") != 1 && targ.origin_z >= self.origin_z)
			{
				if (targ.goal_touched && race_status == RACE_STARTED) // Player has to drive through the goals before markers are activated
				{
					if (self.checkpoint == 1) // first check point
					{
						if (targ.checkpoint == 0)
						{
							targ.checkpoint = self.checkpoint;
							targ.checkpoint_lastpos = targ.origin;
							targ.checkpoint_lastpos_ang = targ.angles;
							self.enemy = targ;
						}
					}
					else if (self.checkpoint > 1)
					{
						if (targ.checkpoint == (self.checkpoint - 1))
						{
							targ.checkpoint = self.checkpoint;
							targ.checkpoint_lastpos = targ.origin;
							targ.checkpoint_lastpos_ang = targ.angles;
							self.enemy = targ;
						}
						if (self.checkpoint > targ.checkpoint)
						{
							if (!targ.checkpoint)
							{
								centerprint (targ, "/P^1^bWrong Way!\n\n^2!!! Try again !!!\n");
								targ.clearcprint_finished = time + 2;
								oldself = self;
								self = targ;
								self.angles = self.spawn_loc_angles;
								self.fixangle = TRUE;
								self.waypoint = 0;
								TeleportPhysObject(self.driving, self.spawn_loc, self.spawn_loc_angles, FALSE);
								spawn_telesfx(self);
								spawn_televfx(self);
								self.teleport_finished = time + 2;
								self = oldself;
							}
							else
							{
								centerprint (targ, "/P^1^bCheckpoint Missed!\n\n^2!!! Try again !!!\n");
								targ.clearcprint_finished = time + 2;
								oldself = self;
								self = targ;
								self.angles = self.checkpoint_lastpos_ang;
								self.fixangle = TRUE;
								TeleportPhysObject(self.driving, self.checkpoint_lastpos, self.checkpoint_lastpos_ang, TRUE);
								spawn_telesfx(self);
								spawn_televfx(self);
								self.teleport_finished = time + 2;
								self = oldself;
							}
						}
					}

					if (self.enemy) // Do check point confirm
					{
						if (cvar("developer") == 2)
							sprint (targ, "CheckPoint_touch: ", ftos(self.checkpoint), " / ", ftos(total_checkpoints), "\n");

						self.enemy.effects = EF_MUZZLEFLASH;
						self.cnt = TRUE; // Start animation
						self.effects = self.effects | EF_DIMLIGHT;
						string l = ftos(self.enemy.laptime);
						l = sprintf("%.2f", self.enemy.laptime); // cut down numbers
						centerprint (self.enemy, "/P^4[^bCheckpoint^b]\n", "^7Time: ^5", l, "\n");
						self.enemy.clearcprint_finished = time + 1;
						sound (self, CHAN_AUTO, "checkpoint.wav", 1, ATTN_NORM);
						self.enemy = world;
					}
				}
				else if (race_status != RACE_FINISHED)
				{
					centerprint (targ, "/PYou must drive through the starting goal to properly start the race!");
					oldself = self;
					self = targ;
					self.angles = self.spawn_loc_angles;
					self.fixangle = TRUE;
					self.waypoint = 0;
					TeleportPhysObject(self.driving, self.spawn_loc, self.spawn_loc_angles, FALSE);
					spawn_telesfx(self);
					spawn_televfx(self);
					self.teleport_finished = time + 2;
					self = oldself;
					targ.clearcprint_finished = time + 2.5;
				}
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
	if (ragewar)
	{
		remove(self);
		return;
	}
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

	if (total_checkpoints < self.checkpoint) // Don't double count checkpoints on diverging paths, messes up bot AI
		total_checkpoints = total_checkpoints + 1;
};