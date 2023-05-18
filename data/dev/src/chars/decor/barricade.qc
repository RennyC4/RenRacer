//
// Barricade - decoration
//

void() rally_barricade_think =
{
	local vector v;
	local entity targ = searchradius(self.origin, 50);
	while (targ)
	{
		if (targ.classname == "player" && self.hitobject_finished < time && targ.realspeed >= 20)
		{
			v_x = (other.velocity_x * 2 + 50 * random());
			v_y = (other.velocity_y * 2 + 50 * random());
			v_z = 250 + 160 * random() + (other.velocity_y + other.velocity_x) * 0.30;

			self.flags = self.flags - (self.flags & FL_ONGROUND);
			self.velocity = v / 1.5;
			self.avelocity = self.velocity * 0.25;

			sound (self, CHAN_AUTO, "barricade.wav", 1, ATTN_NORM);
			self.hitobject_finished = time + 1;
		}
		targ = targ.chain;
	}
	frameskip(0.01);
};

void() rally_barricade =
{
        precache_model("progs/barricade.mdl");
		precache_sound("barricade.wav");
        setmodel (self, "progs/barricade.mdl");
        setsize (self, '-4 -4 -5', '4 4 5');
        self.movetype = MOVETYPE_TOSS;
        self.solid = SOLID_SLIDEBOX;
		droptofloor();

		self.think = rally_barricade_think;
		self.nextthink = time + 0.1;
};