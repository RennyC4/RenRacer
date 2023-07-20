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
		spawn_color_glow(1, 1, 1, 100, self);
	if (self.classname == "item_frckt")
		spawn_color_glow(1.67, 1.33, 0, 100, self);
	if (self.classname == "item_hrckt")
		spawn_color_glow(1.5, 1, 1.5, 100, self);
	if (self.classname == "item_prckt")
		spawn_color_glow(1, 1, 2, 100, self);
	if (self.classname == "item_napalm")
		spawn_color_glow(2, .75, .75, 100, self);
	if (self.classname == "item_ricochet")
		spawn_color_glow(1, 2, 1, 100, self);
	if (self.classname == "item_remote")
		spawn_color_glow(1, 2.36, 2.59, 100, self);
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
	entity toucher = other.owner.driving;

	if (toucher.health <= 0)
		return;

	toucher.health = toucher.health + 25;
	if (toucher.health > toucher.max_health)
		toucher.health = toucher.max_health;

	sprint(toucher, "Health recharged!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 60;
};

void() item_health =
{
	if (!deathmatch)
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
	self.effects = EF_FULLBRIGHT;
	self.touch = item_health_touch;

	setmodel (self, "progs/item_health.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');
	SetupItemDynamicLight(); // init dlights
};

//
// Fire Rocket Pickup
//

void() item_firerocket_touch =
{
	entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_firerocket = toucher.ammo_firerocket + 3;
	if (toucher.ammo_firerocket > 9)
		toucher.ammo_firerocket = 9;

	sprint(toucher, "Fire Rockets loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_firerocket =
{
	if (!deathmatch)
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
	entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_homingrocket = toucher.ammo_homingrocket + 2;
	if (toucher.ammo_homingrocket > 6)
		toucher.ammo_homingrocket = 6;

	sprint(toucher, "Homing Rockets loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_homingrocket =
{
	if (!deathmatch)
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
	entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_powerrocket = toucher.ammo_powerrocket + 2;
	if (toucher.ammo_powerrocket > 3)
		toucher.ammo_powerrocket = 3;

	sprint(toucher, "Power Rockets loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_powerrocket =
{
	if (!deathmatch)
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
	entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_napalm = toucher.ammo_napalm + 2;
	if (toucher.ammo_napalm > 5)
		toucher.ammo_napalm = 5;

	sprint(toucher, "Napalm fuel loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_napalm =
{
	if (!deathmatch)
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
	entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_rico = toucher.ammo_rico + 3;
	if (toucher.ammo_rico > 3)
		toucher.ammo_rico = 3;

	sprint(toucher, "Ricochet bombs loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_ricochet =
{
	if (!deathmatch)
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

	setmodel (self, "progs/item_rico.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');
	
	SetupItemDynamicLight(); // init dlights
};


//
// Remote Bomb Pickup
//

void() item_remote_touch =
{
	entity toucher = other.owner.driving;
	if (toucher.health <= 0)
		return;

	toucher.ammo_remote = toucher.ammo_remote + 1;
	if (toucher.ammo_remote > 2)
		toucher.ammo_remote = 2;

	sprint(toucher, "Remote bomb loaded!\n");
	sound(self, CHAN_AUTO, "combat/item.wav", 1, ATTN_NORM);

	// Remove item and setup for respawn
	self.solid = SOLID_NOT;
	setmodel (self, string_null);
	self.think = SUB_Respawn;
	self.nextthink = time + 20;
};

void() item_remote =
{
	if (!deathmatch)
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

	setmodel (self, "progs/item_remote.spr");
	self.mdl = self.model; // can be restored on respawn
	setsize (self, '0 0 0', '0 0 0');
	
	SetupItemDynamicLight(); // init dlights
};