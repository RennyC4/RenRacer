//+--------+
//|Peds    |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Pedestrians to run down													   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void(vector org, vector dir, float size) ThrowBlood;

void(float speed) pedestrian_move =
{
	makevectors(self.angles);

	if (self.think_finished < time || self.cnt2 > 2)
	{
		self.cnt2 = 0;
		self.angles_y = random()*360;
		self.think_finished = time + 1 + random()*4;
	}
	if (self.oldorigin == self.origin)
		self.cnt2 += 1;

	self.oldorigin = self.origin;
	walkmove(self.angles_y, speed);
};

void() pedestrian_death =
{
	//
	// Pedestrian 1 death frames
	//
	if (self.frame < 32)
		self.frame += 1;
	//
	//
	//

	if (vlen(self.velocity) < 1 || self.flags & FL_ONGROUND || self.flags & FL_PARTIALGROUND || self.origin == self.oldorigin || checkground(self))
	{
		self.frame = 32; // Needs to be set to the final death frame in each pedestrian model
		self.avelocity = '0 0 0';
		self.angles_x = 0;
		self.takedamage = DAMAGE_NO;
		self.deadflag = DEAD_DEAD;
		self.think = SUB_Remove;
		self.nextthink = time + 15.2; // Dead body clean up
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

	sound (self, CHAN_AUTO, "combat/hitped.wav", 1, ATTN_NORM);

	self.modelflags = 32; // blood modelflag

	if (!self.owner.spawnflags) // Business Man
		self.frame = 16; // Set to first death frame
	if (self.owner.spawnflags & 1) // Jumping flag dude
		self.frame = 16;
	if (self.owner.spawnflags & 2) // Jiving weirdo
		self.frame = 16;
	if (self.owner.spawnflags & 4) // Lazy chair lad
		self.frame = 1;

	self.movetype = MOVETYPE_TOSS;
	self.avelocity = '200 200 0'; // spin in air
	
	// Velocity handling
	self.velocity = self.velocity + 10 * v_forward * 35;
	self.velocity = self.velocity + 90 * '0 0 6';

	for (float i = 0; i < 4; i = i+1)
		ThrowBlood(self.origin, other.velocity, 0.75);
	self.think = pedestrian_death;
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
	if (other.owner.driving.realspeed <= 5)
		return;

	if (self.owner.cnt > 0)
		self.owner.cnt -= 1;

	makevectors(self.angles);
	if (other.owner.driving)
		self.angles_y = vectoyaw(other.owner.driving.origin - self.origin);

	self.touch = SUB_Null;
	self.th_die();
};

//
// Pedestrian: Business man
//

void() pedestrian1_think =
{
	if (self.frame < 14)
		self.frame ++;
	else
		self.frame = 0;

	pedestrian_move(2.5);
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
		ped.owner = self;
		ped.classname = "pedestrian";
		ped.health = 1;
		ped.th_die = pedestrian_die;

		setmodel(ped, "progs/ped1.mdl");
		setsize(ped, '-7 -14 -29', '7 11 15');
		setorigin(ped, self.origin + v_up * 16);

		ped.think = pedestrian1_think;
		ped.nextthink = time + 0.1;

		self.cnt += 1; // 3 peds max per spawner
	}
	self.nextthink = time + 60 + random()*30; // spawn timer
};

//
// Pedestrian: Jumping flag dude
//

void() pedestrian2_think =
{
	if (self.frame == 3) self.velocity += '0 0 275';
	if (self.frame < 14)
		self.frame ++;
	else
		self.frame = 0;
	
	frameskip(0.1);
};

void() spawn_pedestrian2 =
{
	if (self.cnt < 1)
	{
		entity ped = spawn();

		ped.movetype = MOVETYPE_STEP;
		ped.takedamage = DAMAGE_YES;
		ped.solid = SOLID_TRIGGER;
		ped.touch = pedestrian_touch;
		ped.owner = self;
		ped.classname = "pedestrian";
		ped.alpha = 0;
		ped.health = 1;
		ped.th_die = pedestrian_die;

		setmodel(ped, "progs/ped2.mdl");
		setsize(ped, '-7 -14 -29', '7 11 15');
		setorigin(ped, self.origin + v_up * 16);

		ped.think = pedestrian2_think;
		ped.nextthink = time;

		self.cnt += 1; // 3 peds max per spawner
	}
	self.nextthink = time + 60 + random()*30; // spawn timer
};

//
// Pedestrian: Jiving guy
//

void() pedestrian3_think =
{
	if (self.frame < 14)
		self.frame ++;
	else
		self.frame = 0;

	pedestrian_move(10);
	frameskip(0.1);
};

void() spawn_pedestrian3 =
{
	if (self.cnt < 2)
	{
		entity ped = spawn();

		ped.movetype = MOVETYPE_STEP;
		ped.takedamage = DAMAGE_YES;
		ped.solid = SOLID_TRIGGER;
		ped.touch = pedestrian_touch;
		ped.scale = 0.9;
		ped.owner = self;
		ped.classname = "pedestrian";
		ped.alpha = 0;
		ped.health = 1;
		ped.th_die = pedestrian_die;

		setmodel(ped, "progs/ped3.mdl");
		setsize(ped, '-7 -14 -23', '7 11 15');
		setorigin(ped, self.origin + v_up * 16);

		ped.think = pedestrian3_think;
		ped.nextthink = time;

		self.cnt += 1; // 3 peds max per spawner
	}
	self.nextthink = time + 60 + random()*30; // spawn timer
};

//
// Pedestrian: Lazy chair lad
//

void() pedestrian4_think =
{
	if (self.alpha < 1)
		self.alpha += 0.1;	
	frameskip(0.1);
};

void() spawn_pedestrian4 =
{
	if (self.cnt < 1)
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
		ped.think = pedestrian4_think;
		ped.nextthink = time;

		setmodel(ped, "progs/ped4.spr");
		setsize(ped, '-8 -8 -8', '8 8 8');
		setorigin(ped, self.origin);

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

	self.classname = "pedestrian_spawner";
	setmodel(self, string_null);
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;

	if (!self.spawnflags) // Business man
	{
		precache_model ("progs/ped1.mdl");
		self.think = spawn_pedestrian1;
		self.nextthink = time + 0.2;
	}

	if (self.spawnflags & 1) // Jumping flag dude
	{
		precache_model ("progs/ped2.mdl");
		self.think = spawn_pedestrian2;
		self.nextthink = time + 0.2;
	}

	if (self.spawnflags & 2) // Jiving guy
	{
		precache_model ("progs/ped3.mdl");
		self.think = spawn_pedestrian3;
		self.nextthink = time + 0.2;
	}

	if (self.spawnflags & 4) // Lazy chair lad
	{
		precache_model ("progs/ped4.spr");
		self.think = spawn_pedestrian4;
		self.nextthink = time + 0.2;
	}
};