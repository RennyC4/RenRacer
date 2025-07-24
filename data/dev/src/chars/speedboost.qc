//
// Speed Booster, drive over it and you'll be pushed
//

void() speedboost_touch =
{
	if (other.owner.driving.classname != "player")
		return;
	if (other.owner.driving.speedboost_finished > time)
		return;

	sound (self, CHAN_AUTO, "spdboost.wav", 1, ATTN_NORM);
	other.owner.driving.speed = self.speed;
	other.owner.driving.speedboost_finished = time + self.speedboost_finished;
};

void() speedboost =
{
	precache_model ("progs/bsp/spdboost.bsp");
	setmodel(self, "progs/bsp/spdboost.bsp");

	self.movetype = MOVETYPE_NONE;
	self.classname = "speedboost";
	self.effects = EF_FULLBRIGHT;
	self.origin_z = self.origin_z + 1;
	droptofloor();

	// speed = how fast
	// speedboost_finished = how long

	if (!self.speed)
		self.speed = 5000;
	if (!self.speedboost_finished)
		self.speedboost_finished = time + 1;

	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model); // link into world

	self.touch = speedboost_touch;
};