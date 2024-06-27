//+--------+
//|Peds    |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Pedestrians to run down													   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

/*
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14 walk15
$frame death1 death2 death3 death4 death5 death6 death7 death8 death9
$frame death10 death11 death12 death13 death14 death15 death16 death17 death18
*/





void(vector org, vector dir, float size) ThrowBlood;

void(float speed) pedestrian_move =
{
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

/*
void()	ped_walk1	=[	$walk1,	ped_walk2	] {	pedestrian_move(5);};
void()	ped_walk2	=[	$walk2,	ped_walk3	] {	pedestrian_move(5);};
void()	ped_walk3	=[	$walk3,	ped_walk4	] {	pedestrian_move(5);};
void()	ped_walk4	=[	$walk4,	ped_walk5	] {	pedestrian_move(5);};
void()	ped_walk5	=[	$walk5,	ped_walk6	] {	pedestrian_move(5);};
void()	ped_walk6	=[	$walk6,	ped_walk7	] {	pedestrian_move(5);};
void()	ped_walk7	=[	$walk7,	ped_walk8	] {	pedestrian_move(5);};
void()	ped_walk8	=[	$walk8,	ped_walk9	] {	pedestrian_move(5);};
void()	ped_walk9	=[	$walk9,	ped_walk10	] {	pedestrian_move(5);};
void()	ped_walk10	=[	$walk10,	ped_walk11	] {	pedestrian_move(5);};
void()	ped_walk11	=[	$walk11,	ped_walk12	] {	pedestrian_move(5);};
void()	ped_walk12	=[	$walk12,	ped_walk13	] {	pedestrian_move(5);};
void()	ped_walk13	=[	$walk13,	ped_walk14	] {	pedestrian_move(5);};
void()	ped_walk14	=[	$walk14,	ped_walk15	] {	pedestrian_move(5);};
void()	ped_walk15	=[	$walk15,	ped_walk1	] {	pedestrian_move(5);};

void()	ped_die1	=[	$death1,	ped_die2	] {};
void()	ped_die2	=[	$death2,	ped_die3	] {};
void()	ped_die3	=[	$death3,	ped_die4	] {};
void()	ped_die4	=[	$death4,	ped_die5	] {};
void()	ped_die5	=[	$death5,	ped_die6	] {};
void()	ped_die6	=[	$death6,	ped_die7	] {};
void()	ped_die7	=[	$death7,	ped_die8	] {};
void()	ped_die8	=[	$death8,	ped_die9	] {};
void()	ped_die9	=[	$death9,	ped_die10	] {};
void()	ped_die10	=[	$death10,	ped_die11	] {};
void()	ped_die11	=[	$death11,	ped_die12	] {};
void()	ped_die12	=[	$death12,	ped_die13	] {};
void()	ped_die13	=[	$death13,	ped_die14	] {};
void()	ped_die14	=[	$death14,	ped_die15	] {};
void()	ped_die15	=[	$death15,	ped_die16	] {};
void()	ped_die16	=[	$death16,	ped_die17	] {};
void()	ped_die17	=[	$death17,	ped_die18	] {};
void()	ped_die18	=[	$death18,	ped_die18	] {};
*/


void() pedestrian_fly_die =
{
	if (self.frame < 32)
	{
	 self.frame ++;
	frameskip(0.1);
	}
	else 
	{
	self.think = SUB_Remove;
	self.nextthink = time + 15.2;
	}
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

	sound (self, CHAN_AUTO, "combat/hitped.wav", 1, ATTN_NORM); // TODO: needs new sound

	self.modelflags = 32; // blood

	if (!self.owner.spawnflags)
	{
	//ped_die1();
		self.frame = 16;
	//	setmodel(self, "progs/ped1_d.spr"); // death sprite
	}
	if (self.owner.spawnflags & 1) // Jumping flag dude
	{
		self.modelflags = 32; // blood
		self.frame = 0;
	}
	if (self.owner.spawnflags & 2) // Jiving weirdo
	{
		self.modelflags = 32; // blood
		self.frame = 4;
	}
	if (self.owner.spawnflags & 4) // Lazy chair lad
	{
		self.modelflags = 32; // blood
		self.frame = 1;
	}


	//self.movetype = MOVETYPE_NOCLIP;
	self.movetype = MOVETYPE_BOUNCE;
	self.velocity = '0 0 0';
	self.velocity_x = other.velocity_x;
	self.velocity_y = other.velocity_y;
	self.velocity_z = 500;
	//self.effects = EF_ADDITIVE;
	self.think = pedestrian_fly_die;
	//self.nextthink = time + 5.2;

	for (float i = 0; i < 4; i = i+1)
		ThrowBlood(self.origin, other.velocity, 0.75);
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

	self.angles_y = vectoyaw(other.origin - self.origin); // TODO: doesn't work, at least not very well (make ped face car that hits em)

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

	//ped_walk1();
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
		//ped.scale = 0.80;
		ped.owner = self;
		ped.classname = "pedestrian";
		//ped.alpha = 0;
		ped.health = 1;
		//ped.th_walk = ped_walk1;
		ped.th_die = pedestrian_die;

		//setmodel(ped, "progs/ped1.spr");
		setmodel(ped, "progs/pedsuit.mdl"); 
		setsize(ped, '-8 -8 -22', '8 8 18');
		setorigin(ped, self.origin);

		ped.think = pedestrian1_think;
		ped.nextthink = time;

		self.cnt += 1; // 3 peds max per spawner
	}
	self.nextthink = time + 60 + random()*30; // spawn timer
};

//
// Pedestrian: Jumping flag dude
//

void() pedestrian2_think =
{
	if (self.alpha < 1)
		self.alpha += 0.1;
	if (self.animation_finished < time)
	{
		if (self.frame < 1)
			self.frame += 1;
		else
			self.frame = 0;
		self.animation_finished = time + 0.25;
	}
	
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
		ped.scale = 0.75;
		ped.owner = self;
		ped.classname = "pedestrian";
		ped.alpha = 0;
		ped.health = 1;
		ped.th_die = pedestrian_die;

		setmodel(ped, "progs/ped2.spr");
		setsize(ped, '-8 -8 -22', '8 8 8');
		setorigin(ped, self.origin);

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
	if (self.alpha < 1)
		self.alpha += 0.1;
	if (self.animation_finished < time)
	{
		if (!self.frags)
			self.frame += 1;
		else
			self.frame -= 1;
		
		if (self.frame > 2)
			self.frags = TRUE;
		else if (self.frame < 1)
			self.frags = FALSE;

		self.animation_finished = time + 0.25;
	}
	pedestrian_move(3);
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
		ped.scale = 0.75;
		ped.owner = self;
		ped.classname = "pedestrian";
		ped.alpha = 0;
		ped.health = 1;
		ped.th_die = pedestrian_die;

		setmodel(ped, "progs/ped3.spr");
		setsize(ped, '-8 -8 -22', '8 8 8');
		setorigin(ped, self.origin);

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
		precache_model ("progs/pedsuit.mdl");
		precache_model ("progs/ped1_d.spr");
		self.think = spawn_pedestrian1;
		self.nextthink = time + 0.2;
	}

	if (self.spawnflags & 1) // Jumping flag dude
	{
		precache_model ("progs/ped2.spr");
		self.think = spawn_pedestrian2;
		self.nextthink = time + 0.2;
	}

	if (self.spawnflags & 2) // Jiving guy
	{
		precache_model ("progs/ped3.spr");
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