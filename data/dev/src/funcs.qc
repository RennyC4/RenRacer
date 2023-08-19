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

void(string name, float size, vector org) ThrowScenery =
{
	entity thing = spawn();
	makevectors_mdl (thing.angles);

	thing.movetype = MOVETYPE_BOUNCE;
	thing.solid = SOLID_NOT;
	thing.scale = size;
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
"spawnflags":
0 (default): nothing
1: explode into wooden chunks
2: explode into rock chunks
4: explode into metal chunks
8: explode into glass chunks
16: spawn explosion
32: die on touch

cnt: how many scenery objects to throw (default 3)
cnt2: scale of objects

frags: what item to spawn into
	1: fire rocket
	2: homing rocket
	3: power rocket
	4: napalm
	5: ricochet
	6: remote bomb
	7: freeze
	8+: health
*/

void() func_breakable_death =
{
	vector h = self.absmin + ((self.absmax - self.absmin) * 0.5);
	float i;

	if (self.spawnflags & 1)
	{
		for (i = 0; i < self.cnt; i = i+1)
	      ThrowScenery("progs/wood1.mdl", self.cnt2, h);
	}
	if (self.spawnflags & 2)
	{
		for (i = 0; i < self.cnt; i = i+1)
	      ThrowScenery("progs/rubble1.mdl", self.cnt2, h);
	}
	if (self.spawnflags & 4)
	{
		for (i = 0; i < self.cnt; i = i+1)
	      ThrowScenery("progs/metal1.mdl", self.cnt2, h);
	}
	if (self.spawnflags & 8)
	{
		for (i = 0; i < self.cnt; i = i+1)
	      ThrowScenery("progs/glasshrd.mdl", self.cnt2, h);
	}
	if (self.spawnflags & 16) // explosions
	{
		CreateExplosion(h);
		Create2DExplosion(h, self.cnt2);
		sound (self, CHAN_BODY, "combat/xplode.wav", 1, ATTN_NONE);
	}

	if (self.noise != "")
		sound (self, CHAN_AUTO, self.noise, 1, ATTN_NONE);
	if (self.noise1 != "")
		sound (self, CHAN_AUTO, self.noise1, 1, ATTN_NONE);
	if (self.noise2 != "")
		sound (self, CHAN_AUTO, self.noise2, 1, ATTN_NONE);

	// spawn items
	if (self.frags > 0)
	{
		entity item = spawn();
		setorigin (item, h);

		if (self.frags == 1)
			item.think = item_firerocket;
		else if (self.frags == 2)
			item.think = item_homingrocket;
		else if (self.frags == 3)
			item.think = item_powerrocket;
		else if (self.frags == 4)
			item.think = item_napalm;
		else if (self.frags == 5)
			item.think = item_ricochet;
		else if (self.frags == 6)
			item.think = item_remote;
		else if (self.frags == 7)
			item.think = item_freeze;
		else
			item.think = item_health;

		item.nextthink = time;
	}
	SUB_UseTargets();
	remove(self);
};

void() func_breakable_touch =
{
	if (!other.owner.driving)
		return;
	self.th_die();
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
	if (self.spawnflags & 8)
	{
		precache_model ("progs/glasshrd.mdl");
		self.noise = "misc/glassbrk.wav";
	}
	// 16 is reserved for explosions
	// 32 is touch

	if (self.noise)
		precache_sound(self.noise);
	if (self.noise1)
		precache_sound(self.noise1);
	if (self.noise2)
		precache_sound(self.noise2);

	if (!self.cnt)
		self.cnt = 3; // how many to scenery parts to throw (default: 3)
	if (!self.cnt2)
		self.cnt2 = 1; // scale, can't use .scale

	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;

	if (self.spawnflags & 32) // Dies on touch, no sense in blocking
	{
		self.solid = SOLID_TRIGGER;
		self.touch = func_breakable_touch;
	}

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
