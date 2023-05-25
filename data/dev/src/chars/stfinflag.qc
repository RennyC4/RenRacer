//
// Goldcup Start / Finish flag - decoration
//

void() rally_startfinish_flag =
{
	precache_model ("progs/finish.mdl");
	setmodel(self, "progs/finish.mdl");
	setsize(self, '0 0 0', '0 0 0');
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.origin_z = self.origin_z + 1;
	droptofloor();
};