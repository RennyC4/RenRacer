//+------+
//|Funcs |
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Contains all func_ entites used in RenRacer                                |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() ThrowSceneryRemove =
{
	if (self.alpha > 0.1)
		self.alpha = self.alpha - 0.1;
	else
	{
		remove(self);
		return;
	}
	frameskip(0.1);
};

void(string name, vector org) ThrowScenery =
{
	entity thing = spawn();
	makevectors_mdl (thing.angles);

	thing.movetype = MOVETYPE_BOUNCE;
	thing.solid = SOLID_NOT;
	thing.angles_y = random() * 360;
	thing.velocity = v_forward * random()*200;
	thing.velocity_z = random()*300;
	thing.alpha = 1;

	if (random() < 0.25)
		thing.avelocity = '1000 3000 2000';
	else if (random() < 0.50)
		thing.avelocity = '100 500 350';
	else if (random() < 0.75)
		thing.avelocity = '0 700 500';
	else
		thing.avelocity = '500 100 1000';

	thing.think = ThrowSceneryRemove;
	thing.nextthink = time + 0.2;

	setmodel (thing, name);
	setsize (thing, '0 0 0', '0 0 0');     
	setorigin (thing, org);
};

//
// func_breakable
//

/*
Breakable brush
"health":
"cnt":
0 (default) explode into wooden chunks
1 explode into rock chunks
2 explode into metal chunks
*/

void() func_breakable_death =
{
	local vector h = self.absmin + ((self.absmax - self.absmin) * 0.5);
	if (self.spawnflags & 1)
	{
	      ThrowScenery("progs/wood1.mdl", h);
	      ThrowScenery("progs/wood2.mdl", h);
	      ThrowScenery("progs/wood3.mdl", h);
	      ThrowScenery("progs/wood1.mdl", h);
	      ThrowScenery("progs/wood2.mdl", h);
	      ThrowScenery("progs/wood3.mdl", h);
	}
	if (self.spawnflags & 2)
	{
	      ThrowScenery("progs/rubble1.mdl", h);
	      ThrowScenery("progs/rubble2.mdl", h);
	      ThrowScenery("progs/rubble3.mdl", h);
	      ThrowScenery("progs/rubble1.mdl", h);
	      ThrowScenery("progs/rubble2.mdl", h);
	      ThrowScenery("progs/rubble3.mdl", h);
	}
	if (self.spawnflags & 4)
	{
	      ThrowScenery("progs/metal1.mdl", h);
	      ThrowScenery("progs/metal2.mdl", h);
	      ThrowScenery("progs/metal3.mdl", h);
	      ThrowScenery("progs/metal1.mdl", h);
	      ThrowScenery("progs/metal2.mdl", h);
	      ThrowScenery("progs/metal3.mdl", h);
	}

	if (self.noise != "")
		sound (self, CHAN_AUTO, self.noise, 1, ATTN_NORM);
	if (self.noise1 != "")
		sound (self, CHAN_AUTO, self.noise1, 1, ATTN_NORM);
	if (self.noise2 != "")
		sound (self, CHAN_AUTO, self.noise2, 1, ATTN_NORM);
	remove(self);
};

void() func_breakable =
{
	if (!self.health)
		self.health = 1;
	if (self.spawnflags & 1)
	{
		precache_model ("progs/wood1.mdl");
		precache_model ("progs/wood2.mdl");
		precache_model ("progs/wood3.mdl");
		self.noise = "misc/woodbrk.wav";
	}
	if (self.spawnflags & 2)
	{
		precache_model ("progs/rubble1.mdl");
		precache_model ("progs/rubble2.mdl");
		precache_model ("progs/rubble3.mdl");
		self.noise1 = "misc/rockbrk.wav";
	}
	if (self.spawnflags & 4)
	{
		precache_model ("progs/metal1.mdl");
		precache_model ("progs/metal2.mdl");
		precache_model ("progs/metal3.mdl");
		self.noise2 = "misc/metlbrk.wav";
	}

	if (self.noise)
		precache_sound(self.noise);
	if (self.noise1)
		precache_sound(self.noise1);
	if (self.noise2)
		precache_sound(self.noise2);

	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.dimension_hit = 255;
	self.dimension_solid = 255;
	self.classname = "func_breakable";
	self.th_die = func_breakable_death;
	setmodel (self, self.model);
};

//
// func_illusionary
//

/*
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic (self);
};
