//
// Pedestrian
//

// Death
void() pedestrian_touch =
{
	sound (self, CHAN_AUTO, "combat/splat.wav", 1, ATTN_NORM);
	self.touch = SUB_Null;
	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
};

void() pedestrian_think =
{
	if (self.animation_finished < time)
	{
		if (self.frame < 3)
			self.frame += 1;
		else
			self.frame = 0;
		self.animation_finished = time + 0.25;
	}
	walkmove(self.angles_y, 5);
	self.angles_y += 5;
	frameskip(0.1);
};

void() pedestrian =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/ped1.spr");
	precache_sound ("misc/splat.wav");

	setmodel(self, "progs/ped1.spr");
	setsize(self, '0 0 -22', '0 0 0');
	self.movetype = MOVETYPE_STEP;
	self.solid = SOLID_TRIGGER;
	self.touch = pedestrian_touch;
	self.origin_z = self.origin_z + 1;
	self.scale = 0.75;
	droptofloor();

	self.think = pedestrian_think;
	self.nextthink = time + 0.1;
};