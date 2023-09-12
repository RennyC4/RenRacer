//+--------+
//|Peds    |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Pedestrians to run down													   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void(vector org, float size) ThrowBlood;

void() pedestrian_fly_die =
{
	if (self.alpha > 0.1)
		self.alpha -= 0.1;
	else
	{
		remove(self);
		return;
	}
	frameskip(0.1);
};

void() pedestrian_die =
{
	float tt = ceil(random() * 3);
	if (tt == 1)
		sound(self, CHAN_AUTO, "combat/death1.wav", 1, ATTN_NORM); 
	else if (tt == 2)
		sound(self, CHAN_AUTO, "combat/death2.wav", 1, ATTN_NORM);
	else if (tt == 3)
		sound(self, CHAN_AUTO, "combat/death3.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_AUTO, "combat/death4.wav", 1, ATTN_NORM);

	float i;
	for (i = 0; i < 4; i = i+1)
		ThrowBlood(self.origin, 0.75);

	sound (self, CHAN_AUTO, "combat/splat.wav", 1, ATTN_NORM); // TODO: needs new sound

	if (!self.spawnflags)
	{
		self.frame = 0;
		setmodel(self, "progs/ped1_d.spr"); // death sprite
	}

	self.movetype = MOVETYPE_NOCLIP;
	self.velocity = '0 0 0';
	self.velocity_x = other.velocity_x;
	self.velocity_y = other.velocity_y;
	self.velocity_z = 250;
	self.think = pedestrian_fly_die;
	self.nextthink = time + 0.2;
};

// Death
void() pedestrian_touch =
{
	if (!other)
		return;
	if (other.classname == self.classname)
		return;
	if (!other.owner.driving)
		return;

	if (self.owner.cnt > 0)
		self.owner.cnt -= 1;

	self.touch = SUB_Null;
	self.th_die();
};

void() pedestrian_think =
{
	if (self.alpha < 1)
		self.alpha += 0.1;
	if (self.animation_finished < time)
	{
		if (self.frame < 3)
			self.frame += 1;
		else
			self.frame = 0;
		self.animation_finished = time + 0.25;
	}
	if (self.think_finished < time || self.cnt2 > 2)
	{
		self.cnt2 = 0;
		self.angles_y = random()*360;
		self.think_finished = time + 1 + random()*4;
	}
	if (self.oldorigin == self.origin)
		self.cnt2 += 1;

	self.oldorigin = self.origin;
	walkmove(self.angles_y, 5);
	
	frameskip(0.1);
};

void() spawn_pedestrian1 =
{
	if (self.cnt < 2)
	{
		entity ped = spawn();

		ped.movetype = MOVETYPE_STEP;
		ped.takedamage = DAMAGE_YES;
		ped.solid = SOLID_TRIGGER;
		ped.touch = pedestrian_touch;
		ped.scale = 0.75;
		ped.owner = self;
		ped.classname = "pedestrian";
		ped.alpha = 0;
		ped.health = 1;
		ped.th_die = pedestrian_die;

		setmodel(ped, "progs/ped1.spr");
		setsize(ped, '8 8 -22', '8 8 8');
		setorigin(ped, self.origin);

		ped.think = pedestrian_think;
		ped.nextthink = time;

		self.cnt += 1; // 3 peds max per spawner
	}
	self.nextthink = time + 60 + random()*30; // spawn timer
};

void() pedestrian =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}

	precache_model ("progs/ped1.spr");
	precache_model ("progs/ped1_d.spr");
	precache_sound ("misc/splat.wav");

	self.classname = "pedestrian_spawner";
	setmodel(self, string_null);
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;

	if (!self.spawnflags) // Business man
	{
		self.think = spawn_pedestrian1;
		self.nextthink = time + 0.2;
	}
};