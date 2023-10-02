//
// Flare - dynamnic light decoration
//

void() flare_lightup =
{
	self.effects = EF_BRIGHTLIGHT;
};

void() flare =
{
        precache_model ("progs/flare.mdl");
		
        setmodel (self, "progs/flare.mdl");
        setsize (self, '-10 -2 -2', '10 2 2');
        self.movetype = MOVETYPE_NONE;
        self.solid = SOLID_NOT;
		self.origin_z = self.origin_z + 1;

		self.pflags = PFLAGS_FULLDYNAMIC | PFLAGS_CORONA;
		self.color = [2, 1, 1];
		self.light_lev = 500;

		droptofloor();
	
		makevectors(self.angles);
		local entity lit = spawn();
		setmodel(lit, "*null");
		setorigin(lit, self.origin + v_up * 100);
		lit.think = flare_lightup;
		lit.nextthink = time + 1;
};