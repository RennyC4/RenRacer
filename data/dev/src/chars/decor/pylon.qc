//
// Pylon - decoration
//

void() rally_cone_think =
{
	local vector v;
	local entity targ = searchradius(self.origin, 40);
	while (targ)
	{
		if (targ.classname == "player" && self.hitobject_finished < time && targ.realspeed >= 12)
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
		targ = targ.chain;
	}
	frameskip(0.01);
};

void() rally_cone =
{
        precache_model ("progs/cone.mdl");
        precache_sound ("pylon.wav");
		
        setmodel (self, "progs/cone.mdl");
        setsize (self, '-2 -2 -3', '2 2 3');
        self.movetype = MOVETYPE_BOUNCE;
        self.solid = SOLID_NOT;
		droptofloor();

		self.think = rally_cone_think;
		self.nextthink = time + 0.1;
};