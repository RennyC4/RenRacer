//
// Pylon - decoration
//

void() rally_cone_think =
{
	vector v;
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= 40 && self.hitobject_finished < time && targ.realspeed >= 12)
		{
			v_x = (other.velocity_x * 2 + 50 * random());
			v_y = (other.velocity_y * 2 + 50 * random());
			v_z = 250 + 160 * random() + (other.velocity_y + other.velocity_x) * 0.30;

			self.flags = self.flags - (self.flags & FL_ONGROUND);
			self.velocity = v;
			self.avelocity = self.velocity * 0.25;

			sound (self, CHAN_AUTO, "pylon.wav", 1, ATTN_NORM);
			self.hitobject_finished = time + 1;
		}
	}
	frameskip(0.05);
};

void() rally_cone =
{
        precache_model ("progs/cone.mdl");
        precache_sound ("pylon.wav");
		
        setmodel (self, "progs/cone.mdl");
        setsize (self, '-6 -6 -9', '6 6 9');
        self.movetype = MOVETYPE_BOUNCE;
        self.solid = SOLID_NOT;
		self.origin_z = self.origin_z + 1;
		droptofloor();

		self.think = rally_cone_think;
		self.nextthink = time + 0.1;
};