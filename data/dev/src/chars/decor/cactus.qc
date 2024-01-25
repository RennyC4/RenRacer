//
// Cactus - decoration
//

void() cactus =
{
		if (!self.spawnflags)
		{
			precache_model ("progs/cactus1.mdl");
			setmodel (self, "progs/cactus1.mdl");
			setsize (self, '-9 -9 -17', '10 8 38');
		}
		else if (self.spawnflags & 1)
		{
			precache_model ("progs/cactus2.mdl");
			setmodel (self, "progs/cactus2.mdl");
			setsize (self, '-15 -8 -17', '11 5 46');
		}
		else if (self.spawnflags & 2)
		{
			precache_model ("progs/cactus3.mdl");
			setmodel (self, "progs/cactus3.mdl");
			setsize (self, '-9 -7 -17', '7 5 30');
		}
		else
		{
			precache_model ("progs/cactus4.mdl");
			setmodel (self, "progs/cactus4.mdl");
			setsize (self, '-5 -4 -17', '3 3 10');
		}

        self.movetype = MOVETYPE_NONE;
        self.solid = SOLID_NOT;
		self.origin_z = self.origin_z + 1;
		self.angles_y = random()*360;
		droptofloor();
};