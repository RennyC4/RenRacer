//+--------+
//|Pickups |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Item pickups and logic, etc												   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

.string mdl;

void() SetupItemDynamicLight =
{
	if (self.classname == "item_health")
		self.color = [1, 1, 1];
	if (self.classname == "item_frckt")
		self.color = [1.67, 1.33, 0];
	if (self.classname == "item_hrckt")
		self.color = [1.5, 1, 1.5];
	if (self.classname == "item_prckt")
		self.color = [1, 1, 2];
	if (self.classname == "item_napalm")
		self.color = [2, .75, .75];
	if (self.classname == "item_ricochet")
		self.color = [1, 2, 1];
	if (self.classname == "item_remote")
		self.color = [1, 2.36, 2.59];
	if (self.classname == "item_freeze")
		self.color = [.1, .1, 3];

	self.pflags = PFLAGS_FULLDYNAMIC;
	self.light_lev = 100;
};

void() SUB_Respawn =
{
	SetupItemDynamicLight(); // reinit dlights
	setmodel(self, self.mdl);
	self.solid = SOLID_TRIGGER;
	setorigin (self, self.origin);
};

//
// Health Pickup
//

void() item_health_touch =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;

	if (toucher.health <= 0)
		return;

	toucher.health = toucher.health + 25;
	if (toucher.health > toucher.max_health)
		toucher.health = toucher.max_health;

	sprint(toucher, "Health recharged!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.light_lev = 0;
	self.pflags = 0;
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 60;
};

void() item_health =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/item_health.spr");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "item_health";
	self.flags = FL_ITEM;
	self.netname = "item";
	self.effects = EF_FULLBRIGHT | EF_ADDITIVE;
	self.touch = item_health_touch;
	self.scale = 1.5;
	self.alpha = 0.9;
	self.dimension_solid = 0;

	setmodel (self, "progs/item_health.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	setorigin(self, self.origin);

	SetupItemDynamicLight(); // init dlights
};

//
// Fire Rocket Pickup
//

void() item_firerocket_touch =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_firerocket = toucher.ammo_firerocket + 3;
	if (toucher.ammo_firerocket > 9)
		toucher.ammo_firerocket = 9;

	sprint(toucher, "Fire Rockets loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.light_lev = 0;
	self.pflags = 0;
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_firerocket =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/item_frckt.spr");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "item_frckt";
	self.flags = FL_ITEM;
	self.netname = "item";
	self.effects = EF_FULLBRIGHT;
	self.touch = item_firerocket_touch;
	self.scale = 1.5;
	self.dimension_solid = 0;

	setmodel (self, "progs/item_frckt.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');
	SetupItemDynamicLight(); // init dlights
};

//
// Homing Rocket Pickup
//

void() item_homingrocket_touch =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_homingrocket = toucher.ammo_homingrocket + 2;
	if (toucher.ammo_homingrocket > 6)
		toucher.ammo_homingrocket = 6;

	sprint(toucher, "Homing Rockets loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.light_lev = 0;
	self.pflags = 0;
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_homingrocket =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/item_hrckt.spr");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "item_hrckt";
	self.flags = FL_ITEM;
	self.netname = "item";
	self.effects = EF_FULLBRIGHT;
	self.touch = item_homingrocket_touch;
	self.scale = 1.5;
	self.dimension_solid = 0;

	setmodel (self, "progs/item_hrckt.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');
	SetupItemDynamicLight(); // init dlights
};

//
// Power Rocket Pickup
//

void() item_powerrocket_touch =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_powerrocket = toucher.ammo_powerrocket + 2;
	if (toucher.ammo_powerrocket > 3)
		toucher.ammo_powerrocket = 3;

	sprint(toucher, "Power Rockets loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.light_lev = 0;
	self.pflags = 0;
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_powerrocket =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/item_prckt.spr");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "item_prckt";
	self.flags = FL_ITEM;
	self.netname = "item";
	self.effects = EF_FULLBRIGHT;
	self.touch = item_powerrocket_touch;
	self.scale = 1.5;
	self.dimension_solid = 0;

	setmodel (self, "progs/item_prckt.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');
	SetupItemDynamicLight(); // init dlights
};

//
// Napalm Fuel Pickup
//

void() item_napalm_touch =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_napalm = toucher.ammo_napalm + 2;
	if (toucher.ammo_napalm > 5)
		toucher.ammo_napalm = 5;

	sprint(toucher, "Napalm fuel loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.light_lev = 0;
	self.pflags = 0;
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_napalm =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/item_napalm.spr");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "item_napalm";
	self.flags = FL_ITEM;
	self.netname = "item";
	self.effects = EF_FULLBRIGHT;
	self.touch = item_napalm_touch;
	self.scale = 1.5;
	self.dimension_solid = 0;

	setmodel (self, "progs/item_napalm.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');
	SetupItemDynamicLight(); // init dlights
};

//
// Ricochet Bomb Pickup
//

void() item_ricochet_touch =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_rico = toucher.ammo_rico + 3;
	if (toucher.ammo_rico > 3)
		toucher.ammo_rico = 3;

	sprint(toucher, "Ricochet bombs loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.light_lev = 0;
	self.pflags = 0;
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_ricochet =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/item_rico.spr");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "item_ricochet";
	self.flags = FL_ITEM;
	self.netname = "item";
	self.effects = EF_FULLBRIGHT;
	self.touch = item_ricochet_touch;
	self.scale = 1.5;
	self.dimension_solid = 0;

	setmodel (self, "progs/item_rico.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');

	setorigin(self, self.origin);
	
	SetupItemDynamicLight(); // init dlights
};

//
// Remote Bomb Pickup
//

void() item_remote_touch =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_remote = toucher.ammo_remote + 1;
	if (toucher.ammo_remote > 2)
		toucher.ammo_remote = 2;

	sprint(toucher, "Remote bomb loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.light_lev = 0;
	self.pflags = 0;
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_remote =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/item_remote.spr");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "item_remote";
	self.flags = FL_ITEM;
	self.netname = "item";
	self.effects = EF_FULLBRIGHT;
	self.touch = item_remote_touch;
	self.scale = 1.5;
	self.dimension_solid = 0;

	setmodel (self, "progs/item_remote.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');

	setorigin(self, self.origin);
	
	SetupItemDynamicLight(); // init dlights
};

//
// Freeze Blast Pickup
//

void() item_freeze_touch =
{
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_freeze = toucher.ammo_freeze + 3;
	if (toucher.ammo_freeze > 5)
		toucher.ammo_freeze = 5;

	sprint(toucher, "Freeze blast loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.light_lev = 0;
	self.pflags = 0;
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_freeze =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	precache_model ("progs/item_freeze.spr");

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.classname = "item_freeze";
	self.flags = FL_ITEM;
	self.netname = "item";
	self.effects = EF_FULLBRIGHT;
	self.touch = item_freeze_touch;
	self.colormod = '1 1 3';
	self.scale = 1.5;
	self.dimension_solid = 0;

	setmodel (self, "progs/item_freeze.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');

	SetupItemDynamicLight(); // init dlights
};