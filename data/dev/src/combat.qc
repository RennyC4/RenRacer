//+--------+
//|Combat  |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Weapons and combat functions are done here								   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void(string name, float size, vector org) ThrowScenery;

// ---
// Obituary
// ---

void(entity targ, entity attacker, string attackerclassname) PrintDeathMessage =
{
	if (attacker == world) // This shouldn't happen, but lets add it anyways
	{
		bprint(targ.netname, " was killed by the karma gods\n");
		return;
	}
	if (attacker == targ || attackerclassname == "trigger") // suicide
	{
		bprint(targ.netname, " commited vehicular suicide\n");
		return;
	}

	if (attackerclassname == "bullet") // machine gun
	{
		bprint(attacker.netname, " gunned down ");
		bprint(targ.netname, "\n");
	}
	if (attackerclassname == "rocket") // fire rocket
	{
		bprint(targ.netname, " swallowed ");
		bprint(attacker.netname, "'s fire rocket\n");
	}
	if (attackerclassname == "rocket2") // homing rocket
	{
		bprint(attacker.netname, "'s homing rocket really loves ");
		bprint(targ.netname, "\n");
	}
	if (attackerclassname == "rocket3") // power rocket
	{
		bprint(attacker.netname, " showed ");
		bprint(targ.netname, " true power\n");
	}
	if (attackerclassname == "napalm" || attackerclassname == "napalmfire")
	{
		bprint(attacker.netname, " made ");
		bprint(targ.netname, " feel all warm and cozy\n");
	}
	if (attackerclassname == "landmine")
	{
		bprint(attacker.netname, "'s landmine tripped ");
		bprint(targ.netname, " into the afterlife\n");
	}
	if (attackerclassname == "rico")
	{
		bprint(attacker.netname, "'s richochet bomb blew ");
		bprint(targ.netname, " into twisted metal\n");
	}
	if (attackerclassname == "remotebomb")
	{
		bprint(attacker.netname, "'s remote bomb vaporized ");
		bprint(targ.netname, " into dust\n");
	}	
	if (attackerclassname == "freeze")
	{
		bprint(attacker.netname, " gave ");
		bprint(targ.netname, " the cold shoulder\n");
	}	
	if (attackerclassname == "ramming")
	{
		bprint(attacker.netname, " rammed ");
		bprint(targ.netname, "\n");
	}
	if (attackerclassname == "flame")
	{
		bprint(attacker.netname, " nicely toasted ");
		bprint(targ.netname, "\n");
	}
	if (attackerclassname == "ghostrocket")
	{
		bprint(targ.netname, " was ghosted by ");
		bprint(attacker.netname, "'s spectral missile\n");
	}
	if (attackerclassname == "boomerang")
	{
		bprint(targ.netname, " caught ");
		bprint(attacker.netname, "'s boomerang\n");
	}
	if (attackerclassname == "skyscraper")
	{
		bprint(targ.netname, " was pancaked by ");
		bprint(attacker.netname, "\n");
	}
	if (attackerclassname == "redrage")
	{
		bprint(targ.netname, " felt ");
		bprint(attacker.netname, "'s crimson fury\n");
	}
	if (attackerclassname == "lawbreaker")
	{
		bprint(attacker.netname, " showed ");
		bprint(targ.netname, " the long tazer of the law\n");
	}
	if (attackerclassname == "rocket4") // razorback
	{
		bprint(attacker.netname, " missiles pummeled ");
		bprint(targ.netname, " into paste\n");
	}
	if (attackerclassname == "hotdog") // mince meat
	{
		bprint(targ.netname, " blew up on ");
		bprint(attacker.netname, "'s famous weiner\n");
	}
	if (attackerclassname == "bullet2") // king turret machine gun
	{
		bprint(attacker.netname, "'s turret took care of ");
		bprint(targ.netname, "\n");
	}
};

// ---
// Damage / Death / Effects
// ---

void(vector position) CreateExplosion =
{
	if (intermission_running) // don't cause explosions at camera origin
		return;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, position_x);
	WriteCoord (MSG_BROADCAST, position_y);
	WriteCoord (MSG_BROADCAST, position_z);
	sound (self, CHAN_BODY, "combat/xplode.wav", 1, ATTN_NORM);
};

void() Create2DExplosion_think =
{
	if (self.animation_finished < time)
	{
		if (self.frame < 14)
			self.frame = self.frame + 1;
		else
		{
			self.solid = SOLID_NOT;
			remove(self);
			return;
		}
		self.animation_finished = time + 0.1;
	}
	frameskip(0.01);
};

void(vector position, float size) Create2DExplosion =
{
	entity xplode = spawn();
	xplode.owner = self.owner;
	xplode.classname = "xplode1";
	xplode.scale = size;
	xplode.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	xplode.alpha = 0.75;
	xplode.movetype = MOVETYPE_NONE;
	xplode.solid = SOLID_SLIDEBOX;
	xplode.dimension_hit = xplode.dimension_solid = 0;
	xplode.colormod = '1.5 1 1';
	setorigin (xplode, position);
	setmodel (xplode, "progs/xplode1.spr");
	setsize (xplode, '0 0 0', '0 0 0');

	xplode.think = Create2DExplosion_think;
	xplode.nextthink = time;

	// Give off RT Light
	xplode.pflags = PFLAGS_FULLDYNAMIC;
	xplode.light_lev = 75;
	xplode.color = [3, 1.25, 1];

	//spawn_color_glow(3, 1.25, 1, 75, xplode); // dynamic light
};

void() Create2DFreezeExplosion_think =
{
	if (self.animation_finished < time)
	{
		if (self.frame < 7)
			self.frame = self.frame + 1;
		else
		{
			self.solid = SOLID_NOT;
			remove(self);
			return;
		}
		self.animation_finished = time + 0.1;
	}
	self.scale = self.scale + 0.01;
	self.alpha = self.alpha - 0.005;
	frameskip(0.01);
};

void(vector position, float size) Create2DFreezeExplosion =
{
	entity xplode = spawn();
	xplode.owner = self.owner;
	xplode.classname = "xplode2";
	xplode.scale = size;
	xplode.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	xplode.alpha = 0.75;
	xplode.movetype = MOVETYPE_NOCLIP;
	xplode.solid = SOLID_SLIDEBOX;
	xplode.velocity_z = 75;
	xplode.dimension_hit = xplode.dimension_solid = 0;
	xplode.colormod = '1 1 3';
	setorigin (xplode, position);
	setmodel (xplode, "progs/frzsmk2.spr");
	setsize (xplode, '0 0 0', '0 0 0');

	xplode.think = Create2DFreezeExplosion_think;
	xplode.nextthink = time;

	// Give off RT Light
	xplode.pflags = PFLAGS_FULLDYNAMIC;
	xplode.light_lev = 75;
	xplode.color = [1, 1, 3];

	//spawn_color_glow(1, 1, 3, 75, xplode); // dynamic light
};

void(entity targ, entity attacker) Death =
{
	targ.forcejump_strength = 700;
	targ.forcejump = TRUE;
	CreateExplosion(targ.origin + v_up * 32);
};

void(entity targ, entity attacker, float damage, string attackerclassname) DoDamage =
{
	if (!ragewar)
		return;
	if (targ.health < 1)
		return;
	if (targ.invulnerable_finished > time)
		return;
	if (targ == world)
		return;

	if (damage > 0)
	{
		if (targ.shield_finished < time)
			targ.health = targ.health - damage;
		else
			targ.health = targ.health - ceil(damage / 2);
		if (targ.classname == "player")
			targ.colormod_x = 2;

		// Send stats to CSQC
		if (attacker != targ && (attacker.classname == "player" && targ.classname == "player"))
		{
			attacker.enemy_displayname = targ.netname;
			attacker.enemy_displayhealth = targ.health;
			attacker.enemy_displaymaxhealth = targ.max_health;

			targ.enemy_displayname = attacker.netname;
			targ.enemy_displayhealth = attacker.health;
			targ.enemy_displaymaxhealth = attacker.max_health;
		}
	}

	if (targ.health <= 0)
	{
		if (attacker.classname == "trigger_hurt")
			targ.frags = targ.frags - 1; // trigger death

		if (targ.classname == "player")
		{
			if (attacker != targ)
				attacker.frags = attacker.frags + 1; // reward
			else
				attacker.frags = attacker.frags - 1; // suicide punish
			Death(targ, attacker);
			PrintDeathMessage(targ, attacker, attackerclassname);
		}
		targ.deadflag = TRUE;

		entity oself = self;
		self = targ;
		if (self.th_die)
			self.th_die();
		self = oself;
	}
};

void(entity attacker, float radius, float damage, float setfire, string attackerclassname, float diminish) DoRadiusDamage =
{
	if (!ragewar)
		return;
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= radius && targ.invulnerable_finished < time)
		{
			float dmg = damage;
			if (diminish)
			{
				float distance_length = vlen(targ.origin - self.origin);
				float distance_factor = 1 - (distance_length / radius);
				dmg = ceil(damage * distance_factor);
			}
			
			DoDamage(targ, attacker, dmg, self.classname);

			if (self.classname == "remotebomb")
			{
				targ.forcejump_strength = (1000 * distance_factor);
				targ.forcejump = TRUE;
			}

			if (setfire && targ.frozen_finished < time)
			{
				targ.onfire_finished = time + 5;
				targ.igniter = attacker;
			}
		}
	}
};

// Used for aquiring targets (missiles and other projectiles)
void() GetTarget =
{
	float bestd = 9999999;
	entity bestv = world;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (targ == self || targ.health < 1 || targ.invulnerable_finished > time)
			continue; // skip

		vector heading = targ.origin - self.origin;
		float d = heading * heading;

		if (d < bestd)
		{
			bestd = d;
			bestv = targ;
		}

		if (bestv)
		{
			if (visible(targ) && infront3(targ, 0.75) && !self.enemy && targ.health > 0 && targ != self.owner && !targ.observer)
				self.enemy = targ;
		}
	}
};

// ---
// Special weapon regeneration
// ---

void() SpecialRegenerate =
{
	if (self.special_regen_finished > time)
		return;

	if (self.vehicle == VEH_HOTROD)
	{
		if (self.ammo_special < 5) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 60; // regen time
		}
	}
	if (self.vehicle == VEH_WRAITH)
	{
		if (self.ammo_special < 4) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 35; // regen time
		}
	}
	if (self.vehicle == VEH_ROADBASTARD)
	{
		if (self.ammo_special < 5) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 35; // regen time
		}
	}
	if (self.vehicle == VEH_SKYSCRAPER)
	{
		if (self.ammo_special < 5) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 60; // regen time
		}
	}
	if (self.vehicle == VEH_REDRAGE)
	{
		if (self.ammo_special < 6) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 10; // regen time
		}
	}
	if (self.vehicle == VEH_LAWBREAKER)
	{
		if (self.ammo_special < 3) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 55; // regen time
		}
	}
	if (self.vehicle == VEH_RAZORBACK)
	{
		if (self.ammo_special < 5) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 35; // regen time
		}
	}
	if (self.vehicle == VEH_MINCEMEAT)
	{
		if (self.ammo_special < 5) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 18; // regen time
		}
	}
	if (self.vehicle == VEH_STREETKING)
	{
		if (self.ammo_special < 3) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 35; // regen time
		}
	}
	if (self.vehicle == VEH_SANDROAMER)
	{
		if (self.ammo_special < 1) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 1; // regen time
		}
	}
	if (self.vehicle == VEH_THOROGOOD)
	{
		if (self.ammo_special < 3) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 70; // regen time
		}
	}
	if (self.vehicle == VEH_NIGHTSHADE)
	{
		if (self.ammo_special < 1) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			stuffcmd (self, "play combat/special.wav\n"); // FIXME: Ugly
			self.special_regen_finished = time + 1; // regen time
		}
	}
};

// ---
// Machine Gun
// ---

void() MachineGunBullet_Touch =
{
	// Projectile conflict fix with boomerang return arc hitbox change
	if (other.owner == self.owner && other.classname != "turret")
		return;

	if (!other.takedamage) // Hit wall
	{
		float tt = ceil(random() * 3);
		if (tt == 1)
			sound(self, CHAN_BODY, "combat/ric1.wav", 1, ATTN_NORM);
		else if (tt == 2)
			sound(self, CHAN_BODY, "combat/ric2.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_BODY, "combat/ric3.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
		pointparticles(PART_MGUNSMOKE, self.origin, '0 0 0', 1);
		remove(self);
		return;
	}
	if (other.owner.driving == self.owner) // Hit self
	{
		remove(self);
		return;
	}

	tt = ceil(random() * 3);
	if (tt == 1)
		sound(self, CHAN_BODY, "combat/mgunh1.wav", 1, ATTN_NORM);
	else if (tt == 2)
		sound(self, CHAN_BODY, "combat/mgunh2.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_BODY, "combat/mgunh3.wav", 1, ATTN_NORM);

	if (other.owner.driving) // other.owner.driving is the player
		DoDamage(other.owner.driving, self.owner, 2, self.classname);
	if (other.health > 0)
		DoDamage(other, self.owner, 2, self.classname);

	pointparticles(PART_MGUNSMOKE, self.origin, '0 0 0', 1);

	remove(self);
};

// Turn bullets collision back on; fixes conflict with players bounding box
// this fixes reversing while firing
void() MachineGunBullet_Think
{
	self.dimension_hit = 255;
	self.think = SUB_Remove;
	self.nextthink = time + 1.5;

};

.float mgun;
void() Fire_MachineGun =
{
	entity bullet = spawn();

	// machine gun slight tilt
	vector v = self.realang;
	if (self.vehicle != VEH_THOROGOOD)
	{
		if (self.mgun)
			v_y = v_y - 1;
		else
			v_y = v_y + 1;
	}
	makevectors(v);

	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.owner = self;
	bullet.solid = SOLID_TRIGGER;
	bullet.classname = "bullet";
	bullet.netname = "projectile";
	bullet.effects = EF_FULLBRIGHT | EF_MUZZLEFLASH;
	bullet.touch = MachineGunBullet_Touch;

	bullet.dimension_hit = 0; // Turn off initial collision

	bullet.velocity = aim(self, 1000);
	bullet.velocity = bullet.velocity * 1000;

	makevectors (self.realang);

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		bullet.velocity_x = bullet.velocity_x + self.driving.velocity_x;
		bullet.velocity_y = bullet.velocity_y + self.driving.velocity_y;
	}

	bullet.angles = vectoangles(bullet.velocity);

	setmodel (bullet, "progs/bullet.mdl");
	setsize (bullet, '0 0 0', '0 0 0');

	// Muzzleflash - flat
	entity mflash1 = spawn();
	mflash1.movetype = MOVETYPE_NONE;
	mflash1.owner = self;
	mflash1.solid = SOLID_NOT;
	mflash1.classname = "mflash";
	mflash1.effects = EF_FULLBRIGHT;
	mflash1.drawonlytoclient = self; // do not network muzzle flashes
	mflash1.scale = 0.25;
	mflash1.angles_y = self.realang_y + 90;
	mflash1.angles_x = 90;
	setmodel (mflash1, "progs/mflash.spr");
	setsize (mflash1, '0 0 0', '0 0 0');

	// Muzzleflash - side
	entity mflash2 = spawn();
	mflash2.movetype = MOVETYPE_NONE;
	mflash2.owner = self;
	mflash2.solid = SOLID_NOT;
	mflash2.classname = "mflash";
	mflash2.effects = EF_FULLBRIGHT;
	mflash2.drawonlytoclient = self; // do not network muzzle flashes
	mflash2.scale = 0.25;

	if (self.mgun)
	{
		mflash2.angles_y = self.realang_y - 90;
		setmodel (mflash2, "progs/mflash2.spr");
	}
	else
	{
		mflash2.angles_y = self.realang_y + 90;
		setmodel (mflash2, "progs/mflash.spr");
	}

	setsize (mflash2, '0 0 0', '0 0 0');

	// Machine Gun positions
	// X = Forward/Back, Y = Side, Z = Height
	vector newloc, newloc2;
	if (self.vehicle == VEH_HOTROD)
	{
		newloc = '35 22.5 10.5'; // mgun 1 (right)
		newloc2 = '35 22.5 10.5'; // mgun 2 (left)
	}
	else if (self.vehicle == VEH_WRAITH)
	{
		newloc = '36.5 24 -1.5';
		newloc2 = '36.5 24 -1.5';
	}
	else if (self.vehicle == VEH_ROADBASTARD)
	{
		newloc = '37 24 -0.5';
		newloc2 = '37 24 -0.5';
	}
	else if (self.vehicle == VEH_SKYSCRAPER)
	{
		newloc = '38 28 12';
		newloc2 = '38 28 12';
	}
	else if (self.vehicle == VEH_REDRAGE)
	{
		newloc = '40 28 -3.5';
		newloc2 = '40 28 -3.5';
	}
	else if (self.vehicle == VEH_LAWBREAKER)
	{
		newloc = '49.5 27.5 1.5';
		newloc2 = '49.5 27.5 1.5';
	}
	else if (self.vehicle == VEH_RAZORBACK)
	{
		newloc = '57.5 29 5';
		newloc2 = '57.5 29 5';
	}
	else if (self.vehicle == VEH_MINCEMEAT)
	{
		newloc = '67 29 10';
		newloc2 = '67 29 10';
	}
	else if (self.vehicle == VEH_STREETKING)
	{
		newloc = '30.5 26 -1.5';
		newloc2 = '30.5 26 -1.5';
	}
	else if (self.vehicle == VEH_SANDROAMER)
	{
		newloc = '52 16 1';
		newloc2 = '52 16 1';
	}
	else if (self.vehicle == VEH_THOROGOOD)
	{
		newloc = '38 6 4.5';
		newloc2 = '38 16 4.5';
	}
	else if (self.vehicle == VEH_NIGHTSHADE)
	{
		newloc = '102 23 13';
		newloc2 = '102 23 13';
	}
	//

	if (!self.mgun)
	{
		if (!self.backward)
		{
			setorigin (mflash1, self.origin + v_up * newloc_z + v_forward * (newloc_x + self.realspeed) + v_right * newloc_y); // flat
			setorigin (mflash2, self.origin + v_up * newloc_z + v_forward * (newloc_x + self.realspeed) + v_right * newloc_y); // side
			setorigin (bullet, self.origin + v_up * newloc_z + v_forward * (newloc_x + self.realspeed) + v_right * newloc_y);
		}
		else
		{
			setorigin (mflash1, self.origin + v_up * newloc_z + v_forward * (newloc_x - self.realspeed) + v_right * newloc_y); // flat
			setorigin (mflash2, self.origin + v_up * newloc_z + v_forward * (newloc_x - self.realspeed) + v_right * newloc_y); // side
			setorigin (bullet, self.origin + v_up * newloc_z + v_forward * (newloc_x - self.realspeed) + v_right * newloc_y);
		}
		self.mgun = TRUE;
	}
	else
	{
		if (!self.backward)
		{
			setorigin (mflash1, self.origin + v_up * newloc2_z + v_forward * (newloc2_x + self.realspeed) - v_right * newloc2_y); // flat
			setorigin (mflash2, self.origin + v_up * newloc2_z + v_forward * (newloc2_x + self.realspeed) - v_right * newloc2_y); // side
			setorigin (bullet, self.origin + v_up * newloc2_z + v_forward * (newloc2_x + self.realspeed) - v_right * newloc2_y);
		}
		else
		{
			setorigin (mflash1, self.origin + v_up * newloc2_z + v_forward * (newloc2_x - self.realspeed) - v_right * newloc2_y); // flat
			setorigin (mflash2, self.origin + v_up * newloc2_z + v_forward * (newloc2_x - self.realspeed) - v_right * newloc2_y); // side
			setorigin (bullet, self.origin + v_up * newloc2_z + v_forward * (newloc2_x - self.realspeed) - v_right * newloc2_y);
		}
		self.mgun = FALSE;
	}

	sound (self, CHAN_AUTO, "combat/mgun.wav", 1, ATTN_NORM);

	mflash1.think = SUB_Remove;
	mflash1.nextthink = time + 0.1;
	mflash2.think = SUB_Remove;
	mflash2.nextthink = time + 0.1;
	bullet.think = MachineGunBullet_Think; // Reactivate collision
	bullet.nextthink = time + 0.05;
};

// ---
// Special: Rockets (Fire / Homing / Power)
// ---

void() Rocket_Think =
{
	if (self.removeme_finished < time)
	{
		CreateExplosion(self.origin);
		Create2DExplosion(self.origin, 2);
		remove(self);
		return;
	}

	if (!self.enemy)
		if (self.classname != "rocket3")
			GetTarget();

	if (self.classname == "rocket" || self.classname == "rocket4")
		pointparticles(PART_ROCKET1, self.origin, '0 0 0', 1);
	if (self.classname == "rocket2")
		pointparticles(PART_ROCKET2, self.origin, '0 0 0', 1);
	if (self.classname == "rocket3")
		pointparticles(PART_ROCKET3, self.origin, '0 0 0', 1);

	if (self.enemy) // Home in on enemy
	{
		vector vele, vels, ph;
		vele = normalize(self.enemy.origin - self.origin);
		vels = normalize(self.velocity);
		ph = vele + (vels * 4);

		if (self.classname == "rocket" || self.classname == "rocket4") // fire + razorback rockets
			ph = ph * (1/33); // increase seceond number for less homing capability
		if (self.classname == "rocket2")
			ph = ph * (1/15);

		self.velocity = normalize(vels + ph);
		if (self.classname == "rocket")
			self.velocity = self.velocity * 1500;
		if (self.classname == "rocket2")
			self.velocity = self.velocity * 1000;
		if (self.classname == "rocket4")
			self.velocity = self.velocity * 1250;

		self.angles = vectoangles(self.velocity);
	}

	frameskip(0.01);
};

void() Rocket_Touch =
{
	float dmg; // damage values
	if (self.classname == "rocket")
		dmg = 7;
	if (self.classname == "rocket2")
		dmg = 10;
	if (self.classname == "rocket3")
		dmg = 15;
	if (self.classname == "rocket4")
		dmg = 6;

	makevectors_mdl(self.angles);
	if (!other.takedamage) // Hit wall
	{
		CreateExplosion(self.origin - v_forward * 32);
		Create2DExplosion(self.origin - v_forward * 32, 2);
		remove(self);
		return;
	}
	if (self.owner == other.owner.driving) // Hit self
		return;

	if (self.classname == "rocket")
	{
		if (other.owner.driving) // other.owner.driving is the player
		{
			DoDamage(other.owner.driving, self.owner, dmg, self.classname); // fire
			other.owner.driving.forcejump_strength = 250;
			other.owner.driving.forcejump = TRUE;
		}
		else
			DoDamage(other, self.owner, dmg, self.classname);
	}
	if (self.classname == "rocket2")
	{
		if (other.owner.driving) // other.owner.driving is the player
		{
			DoDamage(other.owner.driving, self.owner, dmg, self.classname); // homing
			other.owner.driving.forcejump_strength = 350;
			other.owner.driving.forcejump = TRUE;
		}
		else
			DoDamage(other, self.owner, dmg, self.classname);
	}
	if (self.classname == "rocket3")
	{
		if (other.owner.driving) // other.owner.driving is the player
		{
			DoDamage(other.owner.driving, self.owner, dmg, self.classname); // power
			other.owner.driving.forcejump_strength = 450;
			other.owner.driving.forcejump = TRUE;
		}
		else
			DoDamage(other, self.owner, dmg, self.classname);
	}
	if (self.classname == "rocket4")
	{
		if (other.owner.driving) // other.owner.driving is the player
		{
			if (self.hitobject_finished > time)
				DoDamage(other.owner.driving, self.owner, dmg, self.classname); // razorbacks rockets
			else
				DoDamage(other.owner.driving, self.owner, floor(dmg/2), self.classname); // distance razorbacks rockets
			other.owner.driving.forcejump_strength = 250;
			other.owner.driving.forcejump = TRUE;
		}
		else
			DoDamage(other, self.owner, floor(dmg/2), self.classname);
	}

	// requires special case due to owner stuff
	if (other.classname == "turret")
		DoDamage(other, self.owner, dmg, self.classname); // damage turrets

	CreateExplosion(self.origin);
	Create2DExplosion(self.origin, 2);
	remove(self);
};

void(float type, float rear, float rzrbck_pos) Fire_Rocket =
{
	entity rocket = spawn();
	float spawn_dist = 48;
	if (self.vehicle == VEH_NIGHTSHADE)
		spawn_dist = 64;

	makevectors (self.realang);
	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	rocket.movetype = MOVETYPE_FLYMISSILE;
	rocket.owner = self;
	rocket.solid = SOLID_TRIGGER;

	if (!type) // fire
		rocket.classname = "rocket";
	else if (type == 1) // homing
	{
		rocket.classname = "rocket2";
		rocket.colormod = '10 1 10';
	}
	else if (type == 2) // power
	{
		rocket.classname = "rocket3";
		rocket.colormod = '1 1 10';
	}
	else // razorback rockets
	{
		rocket.classname = "rocket4";
		rocket.colormod = '1 1 1';
	}

	rocket.netname = "projectile";
	rocket.effects = EF_FULLBRIGHT | EF_DIMLIGHT;
	rocket.touch = Rocket_Touch;

	if (!type)
	{
		rocket.velocity = aim(self, 1500);
		rocket.velocity = rocket.velocity * 1500; // fire
	}
	else
	{
		if (type == 1)
		{
			rocket.velocity = aim(self, 1000);
			rocket.velocity = rocket.velocity * 1000; // homing
		}
		else if (type == 2)
		{
			rocket.velocity = aim(self, 2000);
			rocket.velocity = rocket.velocity * 2000; // power
		}
		else // razorback
		{
			rocket.velocity = aim(self, 1250);
			rocket.velocity = rocket.velocity * 1250; // razorback
		}
	}
	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		rocket.velocity_x = rocket.velocity_x + self.driving.velocity_x;
		rocket.velocity_y = rocket.velocity_y + self.driving.velocity_y;
	}
	rocket.angles = vectoangles(rocket.velocity);

	setmodel (rocket, "progs/rocket.mdl");
	setsize (rocket, '0 0 0', '0 0 0');

	if (type != 3)
		setorigin (rocket, self.origin + v_up * 8 + v_forward * (spawn_dist + self.realspeed));
	else // razorback missile positions
	{
		if (!rzrbck_pos)
			setorigin (rocket, self.origin + v_up * 32 + v_forward * (spawn_dist + self.realspeed));
		else if (rzrbck_pos == 1)
			setorigin (rocket, self.origin + v_up * 16 + v_forward * (spawn_dist + self.realspeed) + v_right * 32);
		else
			setorigin (rocket, self.origin + v_up * 16 + v_forward * (spawn_dist + self.realspeed) - v_right * 32);
	}

	sound (self, CHAN_WEAPON, "combat/rocket.wav", 1, ATTN_NORM);

	rocket.removeme_finished = time + 3;
	rocket.hitobject_finished = time + 2; // How long until razorbacks rockets do less damage
	rocket.think = Rocket_Think;
	rocket.nextthink = time;
};

// ---
// Special: Napalm
// ---

void() napalmfire_think =
{
	if (self.onfire_finished > time)
		DoRadiusDamage(self.owner, 150, 0, TRUE, self.classname, FALSE); // Set whoever's near me on fire
	else
	{
		if (self.movetype != MOVETYPE_TOSS) // Gravity brings the napalm fire back down
			self.movetype = MOVETYPE_TOSS;
		if (self.scale > 0)
			self.scale = self.scale - 0.1;
		else
		{
			remove(self);
			return;
		}
	}
	if (self.animation_finished < time)
	{
		if (self.frame < 9)
			self.frame = self.frame + 1;
		else
			self.frame = 0;
		self.animation_finished = time + 0.05;
	}
	if (self.sound_finished < time)
	{
		sound (self, CHAN_AUTO, "combat/fire.wav", 1, ATTN_NORM);
		self.sound_finished = time + 1;
	}
	frameskip(0.01);
};

void() CreateNapalmFire =
{
	vector fix = self.angles;
	fix_x = 0;
	fix_z = 0;
	makevectors_mdl(fix);

	entity nf = spawn();
	nf.owner = self.owner;
	nf.classname = "napalmfire";
	nf.scale = 6;
	nf.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	nf.alpha = 0.75;
	nf.movetype = MOVETYPE_NONE;
	nf.solid = SOLID_SLIDEBOX;
	nf.frame = random()*8;
	nf.dimension_hit = nf.dimension_solid = 0;
	setorigin (nf, self.origin + v_up * 64 - v_forward * 32);
	setmodel (nf, "progs/fire.spr");
	setsize (nf, '0 0 0', '0 0 0');
	nf.onfire_finished = time + 5;
	nf.think = napalmfire_think;
	nf.nextthink = time;

	// Give off RT Light
	nf.pflags = PFLAGS_FULLDYNAMIC;
	nf.light_lev = 150;
	nf.color = [3, 1.25, 1];
};

void() NapalmTouch_Think =
{
	if (self.scale < 12)
		self.scale = self.scale + 0.1;
	if (self.alpha > 0.01)
		self.alpha = self.alpha - 0.01;
	else
	{
		remove(self);
		return;
	}
	self.movetype = MOVETYPE_NOCLIP;
	if (!self.cnt2)
	{
		if (random() < 0.5)
			self.cnt2 = 1;
		else
			self.cnt2 = 2;
	}
	if (self.cnt2 == 1)
		self.avelocity = '0 1000 0';
	else
		self.avelocity = '0 -1000 0';
	
	self.velocity = '0 0 0';
	frameskip(0.01);
};

void() Napalm_Touch = // Does 10 damage on direct player hit + fire damage is 4-6 dmg / sec, flames stay for 5 seconds
{
	makevectors_mdl(self.angles);
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	CreateExplosion(self.origin - v_forward * 8);
	DoRadiusDamage(self.owner, 50, 10, TRUE, self.classname, FALSE);
	CreateNapalmFire();
	self.think = NapalmTouch_Think;
	self.nextthink = time;
};

void() Napalm_Think =
{
	if (!self.enemy)
		GetTarget();

	if (self.enemy && !self.cnt)
	{
		vector dir = normalize(self.enemy.origin - self.origin);
		self.velocity_x = dir_x * 550;
		self.velocity_y = dir_y * 550;
		
		self.angles = vectoangles(self.velocity);
		self.cnt = TRUE;
	}
	pointparticles(PART_NAPALM, self.origin, '0 0 0', 1);

	if (self.velocity_z < 0)
		self.gravity = 1.75;
	if (self.enemy && self.velocity_z <= 0) // Home in on enemy
	{
		vector vele, vels, ph;
		vele = normalize(self.enemy.origin - self.origin);
		vels = normalize(self.velocity);
		ph = vele + (vels * 4);
		ph = ph * (1/25); // increase seceond number for less homing capability

		self.velocity = normalize(vels + ph);
		self.velocity = self.velocity * 550;
	}

	frameskip(0.01);
};

void(float rear) Fire_Napalm =
{
	entity napalm = spawn();
	napalm.owner = self;
	napalm.solid = SOLID_SLIDEBOX;
	napalm.movetype = MOVETYPE_TOSS;
	napalm.classname = "napalm";
		
	makevectors (self.realang);

	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	napalm.velocity = v_forward * 350;
	napalm.velocity = aim(self, 350);
	napalm.velocity = napalm.velocity * 350;
	napalm.velocity_z = 700;
	napalm.effects = EF_FULLBRIGHT | EF_DIMLIGHT | EF_ADDITIVE;
	napalm.alpha = 0.9;
	napalm.avelocity = '-500 200 0';
	napalm.hitcontentsmaski = CONTENTBIT_SOLID|0x00000002i|CONTENTBIT_BODY|CONTENTBIT_PLAYERCLIP|CONTENTBIT_WATER|CONTENTBIT_SLIME|CONTENTBIT_LAVA;

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		napalm.velocity_x = napalm.velocity_x + self.driving.velocity_x / 1.75;
		napalm.velocity_y = napalm.velocity_y + self.driving.velocity_y / 1.75;
	}

	setmodel (napalm, "progs/napalm.mdl");
	setsize (napalm, '0 0 0', '0 0 0');
	setorigin (napalm, self.origin + v_up * 32);

	sound (self, CHAN_VOICE, "combat/napalm.wav", 1, ATTN_NORM); // CHAN_WEAPON is for specials, mgun spams

	napalm.scale = 3;
	napalm.touch = Napalm_Touch;
	napalm.think = Napalm_Think;
	napalm.nextthink = time;
};

//
// Ricochet Bomb
//

void() Rico_Think =
{
	makevectors_mdl(self.angles);
	if (self.cnt > 9 || self.removeme_finished < time) // Explode on 10th bounce, or removal time hit
	{
		CreateExplosion(self.origin + v_up * 48);
		Create2DExplosion(self.origin + v_up * 48, 4);
		remove(self);
		return;
	}

	makevectors_mdl(self.angles);

	// Wall bounce
	traceline(self.origin, (self.origin + self.velocity * frametime), FALSE, self);
	if (trace_fraction < 1)
	{
		setorigin(self, trace_endpos);
		vector normal = trace_plane_normal;
		vector reflection = self.velocity - 2 * dotproduct(self.velocity, normal) * normal;
		self.velocity = reflection;
		self.cnt = self.cnt + 1; // Add damage
		self.scale = self.scale + 0.1; // Grow
	}

	// Ground slide + Slope climb
    vector start = self.origin;
    vector end = self.origin + [0, 0, -999];
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{
		vector slopeNormal = trace_plane_normal;
		vector upwardDirection = [0, 0, 1];
		float slopeAngle = slopeNormal * upwardDirection;
		slopeAngle = acos(slopeAngle) * 180.0 / M_PI;
		if (slopeAngle == 0)
			setorigin (self, trace_endpos + v_up * 3);
		else
			setorigin (self, trace_endpos + v_up * (3 + (slopeAngle / 2)));
	}

	if (self.cnt > 0)
		float size = 50 + (self.scale * 25);
	else
		size = 50;

	// Damage
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		float do_hit = TRUE;
		if (targ == self.owner && self.cnt == 0)
			do_hit = FALSE;
		
		if (vlen(targ.origin - self.origin) <= size && do_hit)
		{
			float damage = self.cnt * 2;
			DoDamage(targ, self.owner, 7+damage, self.classname); // base damage 7, bounce x 2, total: 27
			if (self.cnt > 0)
			{
				entity part = targ.driving.physobj_particlelist;
				while(part)
				{
					part.velocity -= (self.origin + '0 0 1' - targ.origin) * 13;
					part = part.physobj_next;
				}
			}
			CreateExplosion(self.origin + v_up * 48);
			Create2DExplosion(self.origin + v_up * 48, 4);
			remove(self);
			return;
		}
	}

	frameskip(0.01);
};

void(float rear) Fire_Ricochet =
{
	entity rico = spawn();
	float spawn_dist = 48;
	if (self.vehicle == VEH_NIGHTSHADE)
		spawn_dist = 64;

	makevectors (self.realang);
	
	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	rico.movetype = MOVETYPE_FLYMISSILE;
	rico.owner = self;
	rico.solid = SOLID_TRIGGER;
	rico.classname = "rico";
	rico.flags = FL_ITEM; // enlarge hitbox
	rico.netname = "projectile";
	rico.scale = 1;

	rico.velocity = aim(self, 750);
	rico.velocity = rico.velocity * 750;

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		rico.velocity_x = rico.velocity_x + self.driving.velocity_x;
		rico.velocity_y = rico.velocity_y + self.driving.velocity_y;
	}
	rico.angles = vectoangles(rico.velocity);

	setmodel (rico, "progs/ricochet.mdl");
	setsize (rico, '0 0 0', '0 0 0');
	setorigin (rico, self.origin + v_forward * (spawn_dist + self.realspeed));

	sound (self, CHAN_WEAPON, "combat/ricochet.wav", 1, ATTN_NORM);

	rico.removeme_finished = time + 30;
	rico.think = Rico_Think;
	rico.nextthink = time;
};

//
// Remote Bomb
//

void() Remote_Detonate =
{
	makevectors_mdl(self.angles);
	DoRadiusDamage(self.owner, 350, 25, FALSE, self.classname, TRUE);
	CreateExplosion(self.origin + v_up * 8);
	Create2DExplosion(self.origin + v_up * 100, 8);
	if (self.owner)
		self.owner.plyrremote = world;
	remove(self);
};

void() Remote_Think =
{
	if (!self.owner)
	{
		remove(self);
		return;
	}

	// touch function
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= 10 && targ != self.owner)
		{
			Remote_Detonate();
			return;
		}
	}

	frameskip(0.1);
};

void() RemoteSignal_Think =
{
	if (self.owner)
	{
		setorigin (self, self.owner.origin + v_up * 44);
		self.scale = 1 + sin(time*512)*0.25;
	}
	if (!self.realowner.plyrremote)
	{
		remove(self);
		return;
	}
	frameskip(0.1);
};

void() Fire_Remote =
{
	if (!self.plyrremote)
	{
		entity remote = spawn();
		remote.owner = self;
		remote.solid = SOLID_TRIGGER;
		remote.movetype = MOVETYPE_TOSS;
		remote.classname = "remotebomb";

		setmodel (remote, "progs/remote.spr");
		setsize (remote, '0 0 -16', '0 0 0');
		setorigin (remote, self.origin);

		sound (self, CHAN_AUTO, "combat/landmine.wav", 1, ATTN_NORM); // CHAN_WEAPON is for specials, mgun spams

		remote.think = Remote_Think;
		remote.nextthink = time;
		self.plyrremote = remote; // link
		
		entity signal = spawn();
		signal.owner = remote;
		signal.realowner = self;
		signal.solid = SOLID_NOT;
		signal.movetype = MOVETYPE_NOCLIP;
		signal.classname = "signal";
		signal.dimension_hit = signal.dimension_solid = 0;
		signal.scale = 1;
		signal.alpha = 0.75;
		signal.effects = EF_FULLBRIGHT | EF_ADDITIVE;

		setmodel (signal, "progs/remote2.spr"); // just an effect
		setsize (signal, '0 0 -16', '0 0 0');
		setorigin (signal, self.origin + v_up * 44);

		signal.think = RemoteSignal_Think;
		signal.nextthink = time;
	}
	else // Remote already in play
	{
		self.plyrremote.think = Remote_Detonate;
		self.plyrremote.nextthink = time;
	}
};

//
// Freeze Blast
//

void() Freeze_Think =
{
	if (self.removeme_finished < time)
	{
		Create2DFreezeExplosion(self.origin, 3);
		remove(self);
		return;
	}

	if (!self.enemy)
		GetTarget();

	pointparticles(PART_FREEZEBLAST, self.origin, '0 0 0', 1);

	if (self.enemy) // Home in on enemy
	{
		vector vele, vels, ph;
		vele = normalize(self.enemy.origin - self.origin);
		vels = normalize(self.velocity);
		ph = vele + (vels * 4);
		ph = ph * (1/7);

		self.velocity = normalize(vels + ph);
		self.velocity = self.velocity * 700;
		self.angles = vectoangles(self.velocity);
	}

	// Animate
	if (self.animation_finished < time)
	{
		if (self.frame < 7)
			self.frame = self.frame + 1;
		else
			self.frame = 0;
		self.animation_finished = time + 0.05;
	}
	self.scale = 2 + sin(time*16)*0.25;
	self.alpha = 0.75 + sin(time*16)*0.25;

	frameskip(0.01);
};

void() Freeze_Touch =
{
	makevectors_mdl(self.angles);
	if (other.solid == SOLID_BSP && !other.owner || other.owner.driving.invulnerable_finished > time) // Hit wall / invunerable player
	{
		Create2DFreezeExplosion(self.origin - v_forward * 32, 3);
		remove(self);
		return;
	}
	if (self.owner == other.owner.driving)
		return;

	if (other.takedamage)
		DoDamage(other, self.owner, 7, self.classname);

	if (other.owner.driving)
	{
		if (other.owner.driving.onfire_finished > time) // remove fire
			other.owner.driving.onfire_finished = time;
		if (other.owner.driving.shield_finished < time) // shield blocks freeze
			other.owner.driving.frozen_finished = time + 4;
		if (other.owner.driving.health > 0) // dont interfere with death colormod stuff
			other.owner.driving.colormod = '1 1 6';
		DoDamage(other.owner.driving, self.owner, 7, self.classname);
	}

	Create2DFreezeExplosion(self.origin, 3);
	remove(self);
};

void(float rear) Fire_Freeze =
{
	entity freeze = spawn();
	float spawn_dist = 48;
	if (self.vehicle == VEH_NIGHTSHADE)
		spawn_dist = 64;

	makevectors (self.realang);
	
	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	freeze.movetype = MOVETYPE_FLYMISSILE;
	freeze.owner = self;
	freeze.solid = SOLID_TRIGGER;

	freeze.classname = "freeze";
	freeze.colormod = '1 1 3';
	freeze.netname = "projectile";
	freeze.effects = EF_ADDITIVE;
	freeze.flags = FL_ITEM; // bigger hitbox
	freeze.alpha = 0.75;
	freeze.scale = 2;
	freeze.touch = Freeze_Touch;

	freeze.velocity = aim(self, 700);
	freeze.velocity = freeze.velocity * 700;

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		freeze.velocity_x = freeze.velocity_x + self.driving.velocity_x;
		freeze.velocity_y = freeze.velocity_y + self.driving.velocity_y;
	}
	freeze.angles = vectoangles(freeze.velocity);

	setmodel (freeze, "progs/frzsmk.spr");
	setsize (freeze, '0 0 0', '0 0 0');
	setorigin (freeze, self.origin + v_up * 8 + v_forward * (spawn_dist + self.realspeed));

	sound (self, CHAN_WEAPON, "combat/freeze.wav", 1, ATTN_NORM);

	freeze.removeme_finished = time + 2;
	freeze.think = Freeze_Think;
	freeze.nextthink = time;

	// Give off RT Light
	freeze.pflags = PFLAGS_FULLDYNAMIC;
	freeze.light_lev = 150;
	freeze.color = [1, 1, 3];

	//spawn_color_glow(1, 1, 3, 150, freeze); // dynamic light
};

//
// Landmine
//

void() Landmine_Think =
{
	if (self.cnt >= 30 || !self.owner)
	{
		remove(self);
		return;
	}
	if (self.animation_finished < time)
	{
		self.cnt = self.cnt + 1; // remove timer
		self.animation_finished = time + 1;
	}

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= 50 && targ != self.owner && self.hitobject_finished < time)
		{
			CreateExplosion(self.origin);
			Create2DExplosion(self.origin + v_up * 24, 3);
			DoDamage(targ, self.owner, 15, self.classname);

			targ.forcejump_strength = 450;
			targ.forcejump = TRUE;
			remove(self);
			return;
		}
	}
	frameskip(0.1);
};

void() Fire_Landmine =
{
	entity landmine = spawn();
	landmine.owner = self;
	landmine.solid = SOLID_TRIGGER;
	landmine.movetype = MOVETYPE_TOSS;
	landmine.classname = "landmine";
	landmine.scale = .5;

	setmodel (landmine, "progs/landmine.spr");
	setsize (landmine, '0 0 -16', '0 0 0');
	setorigin (landmine, self.origin);

	sound (self, CHAN_AUTO, "combat/landmine.wav", 1, ATTN_NORM); // CHAN_WEAPON is for specials, mgun spams

	landmine.hitobject_finished = time + 0.5; // How long till it's active
	landmine.think = Landmine_Think;
	landmine.nextthink = time;
};

//
// Shield
//

void() Shield_Think =
{
	if (self.owner.shield_finished < time)
	{
		remove(self);
		return;
	}
	if (self.sound_finished < time)
	{
		sound (self, CHAN_BODY, "combat/shield.wav", 1, ATTN_NORM);
		self.sound_finished = time + 0.5;
	}
	self.scale = 10 + sin(time*8)*0.5;
	setorigin (self, self.owner.origin);
	frameskip(0.01);
};

void() Fire_Shield =
{
	entity shield = spawn();
	shield.owner = self;
	shield.solid = SOLID_NOT;
	shield.dimension_hit = shield.dimension_solid = 0;
	shield.movetype = MOVETYPE_NOCLIP;
	shield.classname = "shield";
	shield.alpha = 0.5;
	shield.scale = 10;
	shield.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	shield.colormod = '1 3 1';

	// Give off RT Light
	shield.pflags = PFLAGS_FULLDYNAMIC;
	shield.light_lev = 125;
	shield.color = [1, 3, 1];

	setmodel (shield, "progs/shield.mdl");
	setsize (shield, '0 0 0', '0 0 0');
	setorigin (shield, self.origin);

	shield.nextthink = time;
	shield.think = Shield_Think;
};

//
// Special Weapon - HotRod (Flame Thrower)
//

void() SpecialWeapon_HotRod_Touch =
{
	if (other.owner.driving.classname != "player")
		return;
	if (self.owner == other.owner.driving)
		return;

	if (self.frame < 7 && self.hitobject_finished < time)
	{
		DoDamage(other.owner.driving, self.owner, 1, self.classname);
		if (other.owner.driving.frozen_finished < time)
		{
			other.owner.driving.onfire_finished = time + 5;
			other.owner.driving.igniter = self.owner;
		}
		self.hitobject_finished = time + 0.12; // how fast to damage
	}
};

void() SpecialWeapon_HotRod_Think =
{
	// Animation speed
	if (self.think_finished < time)
	{
		if (self.animation_finished > time)
		{
			if (self.frame < 7)
				self.frame = self.frame + 1;
			else
				self.frame = 0;
		}
		else // remove animation
		{
			self.movetype = MOVETYPE_NOCLIP;
			self.velocity_z = 125;
			self.frame = 8 + self.cnt;

			if (self.cnt < 6)
				self.cnt = self.cnt + 1;
			else
			{
				remove(self);
				return;
			}
		}
		self.think_finished = time + 0.05;
		pointparticles(PART_FLAME, self.origin, '0 0 0', 1);
	}

	// Update origin
	makevectors(self.owner.realang);
	
	if (self.backward)
	{
		vector v = self.owner.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	vector start = self.owner.origin + v_forward * 50;
	vector end = start + (v_forward * self.cnt2);
	traceline (start, end, TRUE, self);

	// Effects
	float scl;
	if (self.cnt < 60)
		scl = 1;
	if (self.cnt2 == 60)
		scl = 1.2;
	if (self.cnt2 == 90)
		scl = 1.4;
	if (self.cnt2 == 120)
		scl = 1.6;
	if (self.cnt2 == 150)
		scl = 1.8;
	if (self.cnt2 == 180)
	{
		scl = 2;
		self.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_DIMLIGHT; // Add dimlight effect at flame throwers end
	}

	if (self.animation_finished > time)
	{
		self.scale = scl + random()*0.5 + sin(time*16)*0.15;
		self.alpha = 0.9 + sin(time*4)*0.25;

		// RennyC: Uncomment this for HotRod's flame thrower to be stopped by walls/objects, be sure to adjust damage timer
		//if (trace_fraction < 1)
		//	setorigin(self, trace_endpos);
		//else
			setorigin(self, end);			
	}
	
	float contents = pointcontents(self.origin);
	if (contents >= CONTENT_LAVA && contents <= CONTENT_WATER)
		self.animation_finished = time; // remove myself, I hit water

	frameskip(0.01);
};

void(float rear) SpecialWeapon_HotRod =
{
	makevectors(self.realang);

	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	vector start = self.origin + v_forward * 50;

	float i;
	for (i = 0; i < 6; i = i+1) // 6 flames
	{
		float distance = distance + 30;

		vector end = start + (v_forward * distance);
		traceline (start, end, TRUE, self);

		entity flame = spawn();
		flame.owner = self;
		flame.angles = self.owner.angles;
		flame.solid = SOLID_TRIGGER;
		flame.movetype = MOVETYPE_NOCLIP;
		flame.classname = "flame";
		flame.alpha = 0.9;
		flame.scale = 1+random()*1;
		flame.animation_finished = time + 3; // how long flames last
		flame.cnt = 0;
		flame.cnt2 = distance;
		flame.frame = random()*7;
		flame.effects = EF_ADDITIVE | EF_FULLBRIGHT;
		setmodel (flame, "progs/flame.spr");
		setsize (flame, '0 0 0', '0 0 0');
		setorigin (flame, trace_endpos);

		if (rear)
			flame.backward = TRUE;

		flame.touch = SpecialWeapon_HotRod_Touch;
		flame.think = SpecialWeapon_HotRod_Think;
		flame.nextthink = time;
	}
	sound (self, CHAN_AUTO, "combat/flamethr.wav", 1, ATTN_NORM);
};

//
// Special Weapon - Wraith (Spectral Missile)
//

void() SpecialWeapon_Wraith_GetTarget =
{
	float bestd = 9999999;
	entity bestv = world;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (targ == self || targ.health < 1 || targ.invulnerable_finished > time)
			continue; // skip

		vector heading = targ.origin - self.origin;
		float d = heading * heading;

		if (d < bestd)
		{
			bestd = d;
			bestv = targ;
		}

		if (bestv)
		{
			if (infront3(targ, 0.75) && !self.enemy && targ.health > 0 && targ != self.owner && !targ.observer)
				self.enemy = targ;
		}
	}
};

void() SpecialWeapon_Wraith_Think =
{
    if (self.removeme_finished < time)
    {
        CreateExplosion(self.origin);
        Create2DExplosion(self.origin, 2);
        remove(self);
        return;
    }

    if (self.cnt >= 20) // zig-zag
    {
		makevectors_mdl(self.angles);

		vector newyaw = self.angles;
		vector newheight = self.angles;
		vector thespeed = v_forward * 1000;

		newyaw_y = ceil(45 + random()*315);
        if (random() < 0.5)
			newyaw_y = newyaw_y * -1;

		newheight_x = ceil(90 + random()*90);
        if (random() < 0.5)
			newheight_x = newheight_x * -1;

		newheight = v_up * newheight_x;

		self.velocity = thespeed + newyaw + newheight;
		self.angles = vectoangles(self.velocity);

        self.think_finished = time + 0.121;
        self.cnt = 0;
    }
    if (!self.enemy)
        SpecialWeapon_Wraith_GetTarget();

    pointparticles(PART_GROCKET, self.origin, '0 0 0', 1);

    if (self.enemy) // Home in on enemy
    {
        if (self.think_finished < time)
        {
            vector dir = normalize(self.enemy.origin - self.origin);
            self.velocity = dir * 1000;
            self.angles = vectoangles(self.velocity);
        }
    }
    self.cnt = self.cnt + 1;
    frameskip(0.01);
};

void() SpecialWeapon_Wraith_Touch =
{
	if (self.owner == other.owner.driving) // Hit self
		return;

	if (other.owner.driving) // other.owner.driving is other players
	{
		DoDamage(other.owner.driving, self.owner, 12, self.classname);
		other.owner.driving.forcejump_strength = 250;
		other.owner.driving.forcejump = TRUE;
	}
	else if (other)
		DoDamage(other, self.owner, 12, self.classname);

	CreateExplosion(self.origin);
	Create2DExplosion(self.origin, 2);
	remove(self);
};

void(float rear) SpecialWeapon_Wraith =
{
	makevectors (self.realang);

	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	entity rocket = spawn();
	rocket.movetype = MOVETYPE_NOCLIP;
	rocket.owner = self;
	rocket.solid = SOLID_TRIGGER;
	rocket.classname = "ghostrocket";
	rocket.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	rocket.alpha = 0.5;
	rocket.cnt = 0; // zig-zag counter
	rocket.skin = 1; // white/ghosty skin
	rocket.touch = SpecialWeapon_Wraith_Touch;
	rocket.pflags = PFLAGS_FULLDYNAMIC | PFLAGS_CORONA;
	rocket.color = [1, 1, 1];
	rocket.light_lev = 250;

	rocket.velocity = aim(self, 1000);
	rocket.velocity = rocket.velocity * 1000;

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		rocket.velocity_x = rocket.velocity_x + self.driving.velocity_x;
		rocket.velocity_y = rocket.velocity_y + self.driving.velocity_y;
	}
	rocket.angles = vectoangles(rocket.velocity);

	setmodel (rocket, "progs/rocket.mdl");
	setsize (rocket, '0 0 0', '0 0 0');

	setorigin (rocket, self.origin + v_up * 8 + v_forward * (48 + self.realspeed));

	rocket.removeme_finished = time + 4;
	rocket.think = SpecialWeapon_Wraith_Think;
	rocket.nextthink = time;

	sound (self, CHAN_WEAPON, "combat/rocket.wav", 1, ATTN_NORM);
	sound(self, CHAN_BODY, "combat/ghstrckt.wav", 1, ATTN_NORM);
};

//
// Special Weapon - Road Bastard (Boomerang)
//

void() SpecialWeapon_RoadBastard_Think =
{
	if (self.animation_finished < time)
	{
		if (self.frame < 7)
			self.frame += 1;
		else
		{
			self.frame = 0;
			sound(self, CHAN_BODY, "combat/boomerang2.wav", 1, ATTN_NORM);
		}
		self.animation_finished = time + 0.025;
	}
	if (self.owner && self.cnt >= 90) // Come back to owner
	{
		setsize (self, '-16 -16 -1', '16 16 1'); // larger hitbox on return
		pointparticles(PART_ROCKET1, self.origin, '0 0 0', 1); // Particle effect
		vector vele, vels, ph;
		vele = normalize(self.owner.origin - self.origin);
		vels = normalize(self.velocity);
		ph = vele + (vels * 4);
		ph = ph * (1/1);

		self.velocity = normalize(vels + ph);
		self.velocity = self.velocity * 800;

		self.angles = vectoangles(self.velocity);
		frameskip(0.01);
		return;
	}
	if (self.think_finished < time)
	{
		pointparticles(PART_ROCKET1, self.origin, '0 0 0', 1); // Particle effect
		self.cnt2 = TRUE; // Do the increased damage
		self.colormod = '.25 .25 .25';
		self.angles_y += 2;
		self.cnt += 1;
		makevectors_mdl(self.angles);
		self.velocity = v_forward * 800;
	}

	frameskip(0.01);
};

void() SpecialWeapon_RoadBastard_Touch =
{
	if (other.owner == self.owner) // Projectile conflict fix
		return;

	if (self.owner == other.owner.driving) // Owner stuff
	{
		if (self.cnt >= 90)
		{
			other.owner.driving.ammo_special += 1; // give wasted shot back
			remove(self);
		}
		return;
	}

	if (other.owner.driving) // other.owner.driving is other players
	{
		if (self.cnt2) // Return trip damage
		{
			DoDamage(other.owner.driving, self.owner, 40, self.classname);
			other.owner.driving.forcejump_strength = 500;
			other.owner.driving.forcejump = TRUE;
			Create2DExplosion(self.origin, 4);
		}
		else
		{
			DoDamage(other.owner.driving, self.owner, 10, self.classname);
			other.owner.driving.forcejump_strength = 200;
			other.owner.driving.forcejump = TRUE;
			Create2DExplosion(self.origin, 2);
		}
	}
	else if (other)
	{
		DoDamage(other, self.owner, 10, self.classname);
		Create2DExplosion(self.origin, 2);
	}

	CreateExplosion(self.origin);
	remove(self);
};

void(float rear) SpecialWeapon_RoadBastard =
{
	// Fire outwards
	vector aimdir = self.realang;
	aimdir_y -= 10;
	makevectors(aimdir);

	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 170;
		makevectors(v);
	}

	entity boomerang = spawn();
	boomerang.movetype = MOVETYPE_NOCLIP;
	boomerang.owner = self;
	boomerang.solid = SOLID_TRIGGER;
	boomerang.flags = FL_ITEM; // bigger hitbox
	boomerang.classname = "boomerang";
	boomerang.effects = EF_FULLBRIGHT | EF_NODEPTHTEST;
	boomerang.cnt = 0;
	boomerang.touch = SpecialWeapon_RoadBastard_Touch;

	boomerang.velocity = aim(self, 800);
	boomerang.velocity = boomerang.velocity * 800;

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		boomerang.velocity_x = boomerang.velocity_x + self.driving.velocity_x;
		boomerang.velocity_y = boomerang.velocity_y + self.driving.velocity_y;
	}
	boomerang.angles = vectoangles(boomerang.velocity);

	setmodel (boomerang, "progs/boomerang.mdl");
	setsize (boomerang, '0 0 0', '0 0 0');

	setorigin (boomerang, self.origin + v_up * 8 + v_forward * (48 + self.realspeed));

	boomerang.think_finished = time + 1; // start the arc back
	boomerang.think = SpecialWeapon_RoadBastard_Think;
	boomerang.nextthink = time;

	sound (self, CHAN_WEAPON, "combat/boomerang.wav", 1, ATTN_NORM);
};

//
// Special Weapon - Red Rage (Crimson Beam)
//

void() SpecialWeapon_RedRage_touch =
{
	makevectors_mdl(self.angles);
	if (!other.takedamage) // Hit wall
	{
		remove(self);
		return;
	}
	if (self.owner == other.owner.driving) // Hit self
		return;

	if (other.owner.driving) // other.owner.driving is the player
	{
		Create2DExplosion(self.origin, 1);
		DoDamage(other.owner.driving, self.owner, 13, self.classname);
		other.owner.driving.forcejump_strength = 100;
		other.owner.driving.forcejump = TRUE;
	}
	else if (other)
		DoDamage(other, self.owner, 11, self.classname);

	remove(self);
};

void() SpecialWeapon_RedRage_Think =
{
	if (!self.enemy)
		GetTarget();
	if (self.enemy)
	{
		vector dir = normalize(self.enemy.origin - self.origin);
		self.velocity = dir * 1500;
		self.angles = vectoangles(self.velocity);
	}
};

void(float rear) SpecialWeapon_RedRage =
{
	makevectors(self.realang);

	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	entity beam = spawn();
	beam.movetype = MOVETYPE_FLYMISSILE;
	beam.owner = self;
	beam.solid = SOLID_TRIGGER;
	beam.classname = "redrage";
	beam.effects = EF_FULLBRIGHT | EF_ADDITIVE;
	beam.flags = FL_ITEM; // bigger hitbox
	beam.alpha = 0.9;
	beam.colormod = '1 .1 .1'; // colored red
	beam.scale = 2; // bigger
	beam.touch = SpecialWeapon_RedRage_touch;

	beam.pflags = PFLAGS_FULLDYNAMIC | PFLAGS_CORONA;
	beam.color = [2, 1, 1];
	beam.light_lev = 100;

	beam.velocity = aim(self, 1500);
	beam.velocity = beam.velocity * 1500;

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		beam.velocity_x = beam.velocity_x + self.driving.velocity_x;
		beam.velocity_y = beam.velocity_y + self.driving.velocity_y;
	}
	beam.angles = vectoangles(beam.velocity);

	beam.think = SpecialWeapon_RedRage_Think;
	beam.nextthink = time;

	setmodel (beam, "progs/bullet.mdl");
	setsize (beam, '0 0 0', '0 0 0');

	setorigin (beam, self.origin + v_up * 8 + v_forward * (48 + self.realspeed));
	sound (self, CHAN_WEAPON, "combat/redrage.wav", 1, ATTN_NORM);
};

//
// Special Weapon - Law Breaker (Tazer Shock)
//

.float tazer_finished;
void() SpecialWeapon_Lawbreaker_VFXThink =
{
	self.avelocity = '800 800 800';
	if (self.alpha > 0.1)
		self.alpha = self.alpha - 0.005;
	if (self.scale > 12)
	{
		remove(self);
		return;
	}
	else
		self.scale = self.scale + 0.1;

	setorigin(self, self.enemy.origin);
	frameskip(0.01);
};

void() SpecialWeapon_Lawbreaker_VFX =
{
	entity fx = spawn();
	setmodel(fx, "progs/vfxring.mdl");
	fx.movetype = MOVETYPE_NOCLIP;
	fx.alpha = 1;
	fx.effects = EF_FULLBRIGHT;
	fx.solid = SOLID_NOT;
	fx.enemy = self.enemy;
	setorigin(fx, self.enemy.origin);
	fx.think = SpecialWeapon_Lawbreaker_VFXThink;
	fx.nextthink = time;
	sound (fx, CHAN_AUTO, "combat/lawbreaker2.wav", 1, ATTN_NORM);
};

void() SpecialWeapon_Lawbreaker_Think =
{
	if (self.removeme_finished < time)
	{
		if (self.enemy.health > 0) // run second damage function before removal
		{
			SpecialWeapon_Lawbreaker_VFX();
			DoDamage(self.enemy, self.owner, 10, self.classname);
		}

		remove(self);
		return;
	}

	makevectors_mdl(self.angles);
	vector start = self.origin;

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= (self.radius + 100) && targ != self.owner && !self.enemy && targ.health > 0 && targ.invulnerable_finished < time && targ.tazer_finished < time)
		{
			self.enemy = targ;
			targ.tazer_finished = time + 3;
			self.removeme_finished = time + 1.25; // add time on target found
		}
	}

	if (!self.enemy)
	{
		self.angles_y += 5; // spin, keep above vector end stuff
		vector end = start + (v_forward * self.radius);
	}
	else // found one
	{
		if (!self.cnt) // run first damage function once
		{
			SpecialWeapon_Lawbreaker_VFX();
			self.enemy.forcejump_strength = 600;
			self.enemy.forcejump = TRUE;
			DoDamage(self.enemy, self.owner, 10, self.classname);
			self.cnt = TRUE;
		}
		end = self.enemy.origin; // update beam end position
	}

	traceline (start, end, TRUE, self);

	if (!self.frags) // Only show one search tazer
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
		WriteEntity (MSG_BROADCAST, self);
		WriteCoord (MSG_BROADCAST, start_x);
		WriteCoord (MSG_BROADCAST, start_y);
		WriteCoord (MSG_BROADCAST, start_z);
		if (self.enemy) // got an enemy
		{
			WriteCoord (MSG_BROADCAST, end_x);
			WriteCoord (MSG_BROADCAST, end_y);
			WriteCoord (MSG_BROADCAST, end_z);
		}
		else // hit walls
		{
			WriteCoord (MSG_BROADCAST, trace_endpos_x);
			WriteCoord (MSG_BROADCAST, trace_endpos_y);
			WriteCoord (MSG_BROADCAST, trace_endpos_z);
		}
	}
	else // only show other search tazers after targets locked
	{
		if (self.enemy)
		{
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
			WriteEntity (MSG_BROADCAST, self);
			WriteCoord (MSG_BROADCAST, start_x);
			WriteCoord (MSG_BROADCAST, start_y);
			WriteCoord (MSG_BROADCAST, start_z);
			WriteCoord (MSG_BROADCAST, end_x);
			WriteCoord (MSG_BROADCAST, end_y);
			WriteCoord (MSG_BROADCAST, end_z);
		}
	}
	makevectors_mdl(self.owner.realang);
	setorigin (self, self.owner.origin + v_up * 24 - v_forward * 10);
	
	if (self.animation_finished < time)
	{
		if (!self.cnt2)
			self.cnt2 = TRUE;
		else
			self.cnt2 = FALSE;
		self.animation_finished = time + 0.1;
	}
	
	if (!self.cnt2)
		self.color = [1, 0, 0];
	else
		self.color = [0, 0, 1];
	self.pflags = PFLAGS_FULLDYNAMIC | PFLAGS_CORONA;
	self.light_lev = 250;

	frameskip(0.01);
};

void() SpecialWeapon_Lawbreaker =
{
	makevectors(self.realang);

	float i;
	for (i = 0; i < 3; i = i+1) // 3 tazers
	{
		entity lit = spawn();
		lit.movetype = MOVETYPE_NOCLIP;
		lit.owner = self;
		lit.solid = SOLID_NOT;
		lit.classname = "lawbreaker";
		lit.enemy = world;
		lit.angles_y = random()*360;
		lit.radius = 300; // range of attack
		lit.removeme_finished = time + 2;
		lit.frags = i;
		setmodel (lit, string_null);
		setsize (lit, '0 0 0', '0 0 0');
		setorigin (lit, self.origin + v_up * 24 - v_forward * 10);
		lit.think = SpecialWeapon_Lawbreaker_Think;
		lit.nextthink = time;
	}
	sound (self, CHAN_WEAPON, "combat/lawbreaker.wav", 0.75, ATTN_NORM);
	stuffcmd (self, "play combat/lawbreaker.wav\n"); // ew
};


//
// Special Weapon - Splatter Dog (Mince Meat)
//

void() SpecialWeapon_MinceMeat_Think =
{
	if (self.removeme_finished < time)
	{
		Create2DExplosion(self.origin, 3);
		remove(self);
		return;
	}

	pointparticles(PART_ROCKET1, self.origin, '0 0 0', 1);

	if (!self.enemy)
		GetTarget();

	if (self.enemy) // Home in on enemy
	{
		vector vele, vels, ph;
		vele = normalize(self.enemy.origin - self.origin);
		vels = normalize(self.velocity);
		ph = vele + (vels * 4);
		ph = ph * (1/7);

		self.velocity = normalize(vels + ph);
		self.velocity = self.velocity * 800;
		self.angles = vectoangles(self.velocity);
	}

	makevectors_mdl(self.angles);
	self.velocity_z = sin(time*12)*200;
	self.angles_x = sin(time*12)*30;

	frameskip(0.01);
};

void() SpecialWeapon_MinceMeat_Touch =
{
	makevectors_mdl(self.angles);
	if (other.solid == SOLID_BSP && !other.owner || other.owner.driving.invulnerable_finished > time) // Hit wall / invunerable player
	{
		sound (self, CHAN_AUTO, "combat/splat.wav", 1, ATTN_NORM);
		pointparticles(PART_HOTDOGSPLAT, self.origin, '0 0 0', 1);
		Create2DExplosion(self.origin - v_forward * 32, 3);
		remove(self);
		return;
	}
	if (other.owner.driving.classname != "player")
		return;
	if (self.owner == other.owner.driving)
		return;

	other.owner.driving.blind_finished = time + 3; // Blind players for 3 seconds
	DoDamage(other.owner.driving, self.owner, 15, self.classname);
	sound (other.owner.driving, CHAN_AUTO, "combat/splat.wav", 1, ATTN_NORM);
	pointparticles(PART_HOTDOGSPLAT, self.origin, '0 0 0', 1);
	Create2DExplosion(self.origin, 3);
	remove(self);
};

void(float rear) SpecialWeapon_MinceMeat =
{
	entity hotdog = spawn();

	makevectors (self.realang);
	
	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	hotdog.movetype = MOVETYPE_FLYMISSILE;
	hotdog.owner = self;
	hotdog.solid = SOLID_TRIGGER;

	hotdog.classname = "hotdog";
	hotdog.colormod = '1 1 3';
	hotdog.netname = "projectile";
	hotdog.flags = FL_ITEM; // bigger hitbox
	hotdog.touch = SpecialWeapon_MinceMeat_Touch;
	hotdog.effects = EF_FULLBRIGHT;
	hotdog.scale = 2;

	hotdog.velocity = aim(self, 800);
	hotdog.velocity = hotdog.velocity * 800;

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		hotdog.velocity_x = hotdog.velocity_x + self.driving.velocity_x;
		hotdog.velocity_y = hotdog.velocity_y + self.driving.velocity_y;
	}
	hotdog.angles = vectoangles(hotdog.velocity);

	setmodel (hotdog, "progs/hotdog_proj.mdl");
	setsize (hotdog, '0 0 0', '0 0 0');
	setorigin (hotdog, self.origin + v_up * 8 + v_forward * (40 + self.realspeed));

	sound (self, CHAN_VOICE, "combat/mincemeat.wav", 1, ATTN_NORM);
	sound (self, CHAN_WEAPON, "combat/rocket.wav", 1, ATTN_NORM);

	hotdog.removeme_finished = time + 3;
	hotdog.think = SpecialWeapon_MinceMeat_Think;
	hotdog.nextthink = time;

	// Give off RT Light
	hotdog.pflags = PFLAGS_FULLDYNAMIC;
	hotdog.light_lev = 150;
	hotdog.color = [2.5, 2, 1];
};

//
// Special Weapon - King Turret (Street King)
//

void() SpecialWeapon_StreetKing_TurretHead_Fire =
{
	entity bullet = spawn();

	makevectors_mdl(self.angles);

	bullet.owner = self.owner;
	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.solid = SOLID_TRIGGER;
	bullet.classname = "bullet2";
	bullet.netname = "projectile";
	bullet.effects = EF_FULLBRIGHT | EF_MUZZLEFLASH;
	bullet.touch = MachineGunBullet_Touch;

	bullet.dimension_hit = 0; // Turn off initial collision

	bullet.velocity = aim(self, 2000);
	bullet.velocity = bullet.velocity * 2000;
	bullet.angles = vectoangles(bullet.velocity);

	setmodel (bullet, "progs/bullet.mdl");
	setsize (bullet, '0 0 0', '0 0 0');

	setorigin (bullet, self.origin + v_forward * 12 + v_up * 6);
	sound (self, CHAN_AUTO, "combat/mgun.wav", 1, ATTN_NORM);

	bullet.think = MachineGunBullet_Think; // Reactivate collision
	bullet.nextthink = time + 0.05;

	self.mgun -= 1; // deplete ammo
};

void() SpecialWeapon_StreetKing_Turret_Die =
{
	if (self.classname == "turret")
		self.owner.turrets -= 1;

	for (float i = 0; i < 4; i = i+1)
		ThrowScenery("progs/metal1.mdl", 1, self.origin);
	sound (self, CHAN_AUTO, "misc/metlbrk.wav", 1, ATTN_NORM);
	self.health = 0;
	Create2DExplosion(self.origin, 2.5);
	remove(self);
};

void() SpecialWeapon_StreetKing_TurretHead_Think =
{
	makevectors_mdl(self.angles);

	// King Turret when deployed can be driven through, then goes solid
	if (!self.cnt)
	{
		self.movetype = MOVETYPE_STEP;
		float j = walkmove(0,0);
		if (!j)
			self.dimension_solid = 0;
		else
		{
			self.cnt = TRUE;
			self.dimension_solid = 255;
			self.movetype = MOVETYPE_NONE; // Don't allow car pushing
		}
		setorigin(self, self.pos1); // setup proper turret head position again
	}

	if (!self.enemy)
	{
		for (entity head = world;(head = find(head, classname, "player"));)
		{
			if (vlen(head.origin - self.origin) <= 800 && head.health > 0 && head != self.owner && infront3(head, 0.5) && head.invulnerable_finished < time && fisible(head))
			{
				sound (self, CHAN_BODY, "combat/tur_sight.wav", 1, ATTN_NORM);
				self.enemy = head;
			}
		}
		if (self.sound_finished < time)
		{
			sound (self, CHAN_BODY, "combat/tur_spin.wav", 1, ATTN_NORM);
			self.sound_finished = time + 1;
		}
		self.angles_y = self.angles_y + 15;
		self.angles_x = 0;
		self.frame = 0;
	}
	else
	{
		if (self.enemy.deadflag || !fisible(self.enemy))
			self.enemy = world;

		vector view = vectoangles(self.enemy.origin - self.origin);
		self.angles_y = view_y;
		self.angles_x = view_x;
			
		if (self.hitobject_finished < time)
		{
			if (!self.frame)
				self.frame = 1;
			if (self.frame < 4)
				self.frame += 1;
			else
				self.frame = 1;

			if (self.mgun > 0)
				SpecialWeapon_StreetKing_TurretHead_Fire();
			else
			{
				self.th_die();
				return;
			}

			self.effects = EF_MUZZLEFLASH;
			self.hitobject_finished = time + 0.1;
		}
	}
	frameskip(0.05);
};

void() SpecialWeapon_StreetKing_TurretBase_Think =
{
	if (self.owner.health < 1)
		self.th_die();
	frameskip(0.1);
};

void() SpecialWeapon_StreetKing =
{
	self.turrets += 1;

	entity base, head;
	makevectors_mdl (self.angles);

	head = spawn ();
	head.owner = self;
	head.movetype = MOVETYPE_NONE;
	head.solid = SOLID_SLIDEBOX;
	head.takedamage = DAMAGE_YES;

	head.classname = "turret";
	head.think = SpecialWeapon_StreetKing_TurretHead_Think;
	head.nextthink = time;
	head.health = 40;
	head.mgun = 80; // how many shots before exploding
	head.th_die = SpecialWeapon_StreetKing_Turret_Die;
	setmodel (head, "progs/turret_h.mdl");
	setsize (head, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin (head, self.origin + v_up * 10);
	head.pos1 = head.origin;

	base = spawn ();
	base.owner = head;
	base.movetype = MOVETYPE_NONE;
	base.solid = SOLID_NOT;
	base.takedamage = DAMAGE_NO;
	makevectors (self.angles);
	base.classname = "turret_base";
	base.think = SpecialWeapon_StreetKing_TurretBase_Think;
	base.nextthink = time + 0.1;
	base.th_die = SpecialWeapon_StreetKing_Turret_Die;
	setmodel (base, "progs/turret_b.mdl");
	setsize (base, '0 0 0', '0 0 0');
	setorigin (base, self.origin);

	head.sound_finished = time + 1;
	sound (head, CHAN_BODY, "combat/tur_deploy.wav", 1, ATTN_NORM);
};


//
// Special Weapon - Thorogood (Hell Spawn)
//

void() SpecialWeapon_Thorogood_touch =
{
	makevectors_mdl(self.angles);
	if (!other.takedamage) // Hit wall
	{
		remove(self);
		return;
	}
	if (self.owner == other.owner.driving) // Hit self
		return;

	if (other.owner.driving) // other.owner.driving is the player
	{
		Create2DExplosion(self.origin, 4);
		DoDamage(other.owner.driving, self.owner, 40, self.classname);
		other.owner.driving.forcejump_strength = 400;
		other.owner.driving.forcejump = TRUE;
	}
	else if (other)
		DoDamage(other, self.owner, 40, self.classname);

	remove(self);
};

void() SpecialWeapon_Thorogood_Think =
{
	if (self.frame < 3)
		self.frame += 1;
	else
		self.frame = 0;
	frameskip(0.1);
};

void(float rear) SpecialWeapon_Thorogood =
{
	makevectors(self.realang);

	if (rear)
	{
		vector v = self.realang;
		v_y = v_y + 180;
		makevectors(v);
	}

	entity hellspawn = spawn();
	hellspawn.movetype = MOVETYPE_FLYMISSILE;
	hellspawn.owner = self;
	hellspawn.solid = SOLID_TRIGGER;
	hellspawn.classname = "hellspawn";
	hellspawn.effects = EF_FULLBRIGHT;
	hellspawn.flags = FL_ITEM; // bigger hitbox
	hellspawn.touch = SpecialWeapon_Thorogood_touch;

	hellspawn.velocity = aim(self, 2000);
	hellspawn.velocity = hellspawn.velocity * 2000;

	// Players forward velocity is added to projectiles
	if (!self.backward)
	{
		hellspawn.velocity_x = hellspawn.velocity_x + self.driving.velocity_x;
		hellspawn.velocity_y = hellspawn.velocity_y + self.driving.velocity_y;
	}
	hellspawn.angles = vectoangles(hellspawn.velocity);

	hellspawn.think = SpecialWeapon_Thorogood_Think;
	hellspawn.nextthink = time;

	setmodel (hellspawn, "progs/demon.spr");
	setsize (hellspawn, '0 0 0', '0 0 0');

	setorigin (hellspawn, self.origin + v_up * 8 + v_forward * (48 + self.realspeed));
	sound (self, CHAN_WEAPON, "combat/thorogood.wav", 1, ATTN_NORM);
};

//
// Command Specials
//

.float cmdspecial_rear_step;
.float cmdspecial_rear_step_finished;
.float cmdspecial_landmine_step;
.float cmdspecial_landmine_step_finished;
.float cmdspecial_freezeburst_step;
.float cmdspecial_freezeburst_step_finished;
.float cmdspecial_napalm_step;
.float cmdspecial_napalm_step_finished;

void() CommandSpecials =
{
	if (!ragewar)
		return;
	if (race_status != RACE_STARTED)
		return;
	if (self.commandspcl_finished > time)
		return;
	if (self.invulnerable_finished > time)
		return;

	//
	// Cloak: Up, Up, Left
	//
	if (self.moveprog1 > 1 && self.moveprog3 > 0 && self.energy >= 50)
	{
		self.energy = self.energy - 50;
		self.cloak_finished = time + 5;
		sound (self, CHAN_BODY, "combat/cloak.wav", 1, ATTN_NORM);
		sprint (self, "^2Command: ");
		sprint (self, "^7Cloak\n");
		self.commandspcl_finished = time + 5;
		return;
	}

	//
	//
	// Shield: Up, Up, Right
	//
	if (self.moveprog1 > 1 && self.moveprog4 > 0 && self.energy >= 50)
	{
		self.energy = self.energy - 50;
		self.shield_finished = time + 3;
		Fire_Shield();
		sprint (self, "^2Command: ");
		sprint (self, "^7Shield\n");
		self.commandspcl_finished = time + 3;
		return;
	}
	//

	//
	// Jump: Down, Down, Up
	//
	if (self.moveprog1 > 0 && self.moveprog2 > 1 && self.energy >= 10)
	{
		self.energy = self.energy - 10;
		self.forcejump_strength = 800;
		ForceJump();
		sound (self, CHAN_BODY, "combat/jump.wav", 1, ATTN_NORM);
		sprint (self, "^2Command: ");
		sprint (self, "^7Jump\n");
		self.commandspcl_finished = time + 1;
		return;
	}
	//

	//
	// Rear Attack: Left, Right, Down
	//
	if (self.moveprog3 == 1) // User pressed left
	{
		self.cmdspecial_rear_step = 1;
		self.cmdspecial_rear_step_finished = time + 0.2;
	}
	if (self.cmdspecial_rear_step == 1 && self.moveprog4 == 1) // User pressed right
	{
		self.cmdspecial_rear_step = 2;
		self.cmdspecial_rear_step_finished = time + 0.2;
	}
	if (self.cmdspecial_rear_step == 2 && self.moveprog2 == 1) // Hit last step, user hit down
	{
		sprint (self, "^2Command: ");
		sprint (self, "^7Rear Attack\n");
		CarAttack(1, TRUE);
		self.cmdspecial_rear_step = 0;
		self.commandspcl_finished = time + 1;
		return;
	}
	if (self.cmdspecial_rear_step > 0)
	{
		if (self.cmdspecial_rear_step_finished < time)
			self.cmdspecial_rear_step = 0;
	}
	//

	//
	// Landmine: Right, Left, Down
	//
	if (self.moveprog4 == 1) // User pressed Right
	{
		self.cmdspecial_landmine_step = 1;
		self.cmdspecial_landmine_step_finished = time + 0.2;
	}
	if (self.cmdspecial_landmine_step == 1 && self.moveprog3 == 1) // User pressed left
	{
		self.cmdspecial_landmine_step = 2;
		self.cmdspecial_landmine_step_finished = time + 0.2;
	}
	if (self.cmdspecial_landmine_step == 2 && self.moveprog2 == 1 && self.energy >= 33) // Hit last step, user hit down
	{
		self.energy = self.energy - 33;
		sprint (self, "^2Command: ");
		sprint (self, "^7Landmine\n");
		Fire_Landmine();
		self.cmdspecial_landmine_step = 0;
		self.commandspcl_finished = time + 1;
		return;
	}
	if (self.cmdspecial_landmine_step > 0)
	{
		if (self.cmdspecial_landmine_step_finished < time)
			self.cmdspecial_landmine_step = 0;
	}
	//
	
	//
	// Freeze Burst: Left, Right, Up
	//
	if (self.moveprog3 == 1) // User pressed left
	{
		self.cmdspecial_freezeburst_step = 1;
		self.cmdspecial_freezeburst_step_finished = time + 0.2;
	}
	if (self.cmdspecial_freezeburst_step == 1 && self.moveprog4 == 1) // User pressed right
	{
		self.cmdspecial_freezeburst_step = 2;
		self.cmdspecial_freezeburst_step_finished = time + 0.2;
	}
	if (self.cmdspecial_freezeburst_step == 2 && self.moveprog1 == 1 && self.energy >= 80) // Hit last step, user hit up
	{
		self.energy = self.energy - 80;
		sprint (self, "^2Command: ");
		sprint (self, "^7Freeze Blast\n");
		Fire_Freeze(FALSE);
		self.cmdspecial_freezeburst_step = 0;
		self.commandspcl_finished = time + 1;
		return;
	}
	if (self.cmdspecial_freezeburst_step > 0)
	{
		if (self.cmdspecial_freezeburst_step_finished < time)
			self.cmdspecial_freezeburst_step = 0;
	}
	//

	//
	// Napalm: Right, Left, Up
	//
	if (self.moveprog4 == 1) // User pressed right
	{
		self.cmdspecial_napalm_step = 1;
		self.cmdspecial_napalm_step_finished = time + 0.2;
	}
	if (self.cmdspecial_napalm_step == 1 && self.moveprog3 == 1) // User pressed left
	{
		self.cmdspecial_napalm_step = 2;
		self.cmdspecial_napalm_step_finished = time + 0.2;
	}
	if (self.cmdspecial_napalm_step == 2 && self.moveprog1 == 1 && self.energy >= 40) // Hit last step, user hit up
	{
		if (self.waterlevel > 0)
		{
			self.commandspcl_finished = time + 1;
			sprint(self, "Can't fire napalm in water!\n");
			return;
		}
		self.energy = self.energy - 40;
		sprint (self, "^2Command: ");
		sprint (self, "^7Napalm\n");
		Fire_Napalm(FALSE);
		self.cmdspecial_napalm_step = 0;
		self.commandspcl_finished = time + 1;
		return;
	}
	if (self.cmdspecial_napalm_step > 0)
	{
		if (self.cmdspecial_napalm_step_finished < time)
			self.cmdspecial_napalm_step = 0;
	}
	//
};

//
// Change weapon functions
//

void() ChangeWeapon =
{
	if (!ragewar)
		return;
	if (race_status != RACE_STARTED)
		return;

	if (self.impulse == 1)
	{
		self.weapon = WEP_SPECIAL;
		sprint (self, "Special weapon selected\n");
	}
	if (self.impulse == 2)
	{
		self.weapon = WEP_ROCKET;
		sprint (self, "Fire rocket selected\n");
	}
	if (self.impulse == 3)
	{
		self.weapon = WEP_HROCKET;
		sprint (self, "Homing rocket selected\n");
	}
	if (self.impulse == 4)
	{
		self.weapon = WEP_PROCKET;
		sprint (self, "Power rocket selected\n");
	}
	if (self.impulse == 5)
	{
		self.weapon = WEP_NAPALM;
		sprint (self, "Napalm selected\n");
	}
	if (self.impulse == 6)
	{
		self.weapon = WEP_RICOCHET;
		sprint (self, "Ricochet bomb selected\n");
	}
	if (self.impulse == 7)
	{
		self.weapon = WEP_REMOTE;
		sprint (self, "Remote bomb selected\n");
	}
	if (self.impulse == 8)
	{
		self.weapon = WEP_FREEZE;
		sprint (self, "Freeze blast selected\n");
	}
};

void() CycleWeaponForward =
{
	if (!ragewar)
		return;
	if (race_status != RACE_STARTED)
		return;

	if (self.weapon == WEP_ROCKET)
	{
		self.weapon = WEP_HROCKET;
		sprint (self, "Homing rocket selected\n");
		return;
	}
	if (self.weapon == WEP_HROCKET)
	{
		self.weapon = WEP_PROCKET;
		sprint (self, "Power rocket selected\n");
		return;
	}
	if (self.weapon == WEP_PROCKET)
	{
		self.weapon = WEP_NAPALM;
		sprint (self, "Napalm selected\n");
		return;
	}
	if (self.weapon == WEP_NAPALM)
	{
		self.weapon = WEP_RICOCHET;
		sprint (self, "Ricochet bomb selected\n");
		return;
	}
	if (self.weapon == WEP_RICOCHET)
	{
		self.weapon = WEP_REMOTE;
		sprint (self, "Remote bomb selected\n");
		return;
	}
	if (self.weapon == WEP_REMOTE)
	{
		self.weapon = WEP_FREEZE;
		sprint (self, "Freeze blast selected\n");
		return;
	}
	if (self.weapon == WEP_FREEZE)
	{
		self.weapon = WEP_SPECIAL;
		sprint (self, "Special weapon selected\n");
		return;
	}
	if (self.weapon == WEP_SPECIAL)
	{
		self.weapon = WEP_ROCKET;
		sprint (self, "Fire rocket selected\n");
		return;
	}
};

void() CycleWeaponBackward =
{
	if (!ragewar)
		return;
	if (race_status != RACE_STARTED)
		return;

	if (self.weapon == WEP_SPECIAL)
	{
		self.weapon = WEP_FREEZE;
		sprint (self, "Freeze blast selected\n");
		return;
	}
	if (self.weapon == WEP_FREEZE)
	{
		self.weapon = WEP_REMOTE;
		sprint (self, "Remote bomb selected\n");
		return;
	}
	if (self.weapon == WEP_REMOTE)
	{
		self.weapon = WEP_RICOCHET;
		sprint (self, "Ricochet bomb selected\n");
		return;
	}
	if (self.weapon == WEP_RICOCHET)
	{
		self.weapon = WEP_NAPALM;
		sprint (self, "Napalm selected\n");
		return;
	}	
	if (self.weapon == WEP_NAPALM)
	{
		self.weapon = WEP_PROCKET;
		sprint (self, "Power rocket selected\n");
		return;
	}
	if (self.weapon == WEP_PROCKET)
	{
		self.weapon = WEP_HROCKET;
		sprint (self, "Homing rocket selected\n");
		return;
	}
	if (self.weapon == WEP_HROCKET)
	{
		self.weapon = WEP_ROCKET;
		sprint (self, "Fire rocket selected\n");
		return;
	}
	if (self.weapon == WEP_ROCKET)
	{
		self.weapon = WEP_SPECIAL;
		sprint (self, "Special weapon selected\n");
		return;
	}
};

//
// Main function to determine what gun the car fires
//

void(float type, float rear) CarAttack =
{
	if (!ragewar)
		return;
	if (race_status != RACE_STARTED)
		return;
	if (self.frozen_finished > time)
		return;

	if (!type) // regular machine gun
	{
		if (self.mgun_finished < time)
		{
			Fire_MachineGun();
			self.mgun_finished = time + 0.125;
		}
	}
	else // all other weapons
	{
		if (self.spcl_finished < time)
		{
			if (self.weapon == WEP_SPECIAL)
			{
				if (self.ammo_special > 0)
				{
					if (self.vehicle == VEH_HOTROD) // Hotrod special
					{
						if (self.waterlevel > 0)
						{
							self.spcl_finished = time + 0.5;
							sprint(self, "Can't use flame thrower in water!\n");
							return;
						}
						else
						{
							if (!rear)
								SpecialWeapon_HotRod(FALSE);
							else
								SpecialWeapon_HotRod(TRUE);
							self.spcl_finished = time + 5; // fires slower
						}
					}
					if (self.vehicle == VEH_WRAITH) // Wraith special
					{
						if (!rear)
							SpecialWeapon_Wraith(FALSE);
						else
							SpecialWeapon_Wraith(TRUE);
					}
					if (self.vehicle == VEH_ROADBASTARD) // Road Bastard special
					{
						if (!rear)
							SpecialWeapon_RoadBastard(FALSE);
						else
							SpecialWeapon_RoadBastard(TRUE);
					}
					if (self.vehicle == VEH_REDRAGE) // Red Rage special
					{
						if (!rear)
							SpecialWeapon_RedRage(FALSE);
						else
							SpecialWeapon_RedRage(TRUE);
						self.spcl_finished = time + 0.5; // fires faster
					}
					if (self.vehicle == VEH_LAWBREAKER) // Law Breaker special
					{
						SpecialWeapon_Lawbreaker();
						self.spcl_finished = time + 3; // fires slower
					}
					if (self.vehicle == VEH_RAZORBACK) // Razorback special
					{
						float i;
						for (i = 0; i < 3; i = i+1)
						{
							if (!rear)
								Fire_Rocket(3, FALSE, i);
							else
								Fire_Rocket(3, TRUE, i);
						}
						sound (self, CHAN_AUTO, "combat/razorback.wav", 1, ATTN_NORM);
					}
					if (self.vehicle == VEH_MINCEMEAT) // Mince Meat special
					{
						if (!rear)
							SpecialWeapon_MinceMeat(FALSE);
						else
							SpecialWeapon_MinceMeat(TRUE);
					}
					if (self.vehicle == VEH_STREETKING) // Street King special
					{
						entity f_right, f_left, b_right, b_left;

						f_left = self.driving.frontleft;
						f_right = self.driving.frontright;
						b_left = self.driving.backleft;
						b_right = self.driving.backright;
	
						// all tires touching ground
						if (f_right.flags & FL_ONGROUND && f_left.flags & FL_ONGROUND && b_right.flags & FL_ONGROUND && b_left.flags & FL_ONGROUND)
						{
							if (self.turrets < 3)
								SpecialWeapon_StreetKing();
							else
							{
								sprint (self, "Only 3 turrets can be deployed\n");
								self.spcl_finished = time + 1;
								return;
							}
						}
						else
						{
							sprint(self, "King Turret can only be deployed on the ground\n");
							self.spcl_finished = time + 1;
							return;
						}
					}
					if (self.vehicle == VEH_THOROGOOD) // Thorogood special
					{
						if (!rear)
							SpecialWeapon_Thorogood(FALSE);
						else
							SpecialWeapon_Thorogood(TRUE);
					}

					// Keep at bottom
					if (self.vehicle != VEH_SKYSCRAPER) // Special exception
						self.ammo_special = self.ammo_special - 1;
				}
				else
				{
					sprint(self, "Special weapon bay empty!\n");
					stuffcmd (self, "play combat/empty.wav\n");
				}
				if (self.spcl_finished < time)
					self.spcl_finished = time + 1;
			}
			
			if (self.weapon == WEP_ROCKET)
			{
				if (self.ammo_firerocket > 0)
				{
					if (!rear)
						Fire_Rocket(0, FALSE, 0);
					else
						Fire_Rocket(0, TRUE, 0);
					self.ammo_firerocket = self.ammo_firerocket - 1;
				}
				else
				{
					sprint(self, "Fire rocket bay empty!\n");
					stuffcmd (self, "play combat/empty.wav\n");
				}
				self.spcl_finished = time + 1;
			}
			if (self.weapon == WEP_HROCKET)
			{
				if (self.ammo_homingrocket > 0)
				{
					if (!rear)
						Fire_Rocket(1, FALSE, 0);
					else
						Fire_Rocket(1, TRUE, 0);
					self.ammo_homingrocket = self.ammo_homingrocket - 1;
				}
				else
				{
					sprint(self, "Homing rocket bay empty!\n");
					stuffcmd (self, "play combat/empty.wav\n");
				}
				self.spcl_finished = time + 1;
			}
			if (self.weapon == WEP_PROCKET)
			{
				if (self.ammo_powerrocket > 0)
				{
					if (!rear)
						Fire_Rocket(2, FALSE, 0);
					else
						Fire_Rocket(2, TRUE, 0);
					self.ammo_powerrocket = self.ammo_powerrocket - 1;
				}
				else
				{
					sprint(self, "Power rocket bay empty!\n");
					stuffcmd (self, "play combat/empty.wav\n");
				}
				self.spcl_finished = time + 1;
			}
			if (self.weapon == WEP_NAPALM)
			{
				if (self.waterlevel > 0)
				{
					self.spcl_finished = time + 0.5;
					sprint(self, "Can't fire napalm in water!\n");
					return;
				}
				if (self.ammo_napalm > 0)
				{
					if (!rear)
						Fire_Napalm(FALSE);
					else
						Fire_Napalm(TRUE);
					self.ammo_napalm = self.ammo_napalm - 1;
				}
				else
				{
					sprint(self, "Napalm fuel empty!\n");
					stuffcmd (self, "play combat/empty.wav\n");
				}
				self.spcl_finished = time + 2;
			}
			if (self.weapon == WEP_RICOCHET)
			{
				if (self.ammo_rico > 0)
				{
					if (!rear)
						Fire_Ricochet(FALSE);
					else
						Fire_Ricochet(TRUE);
					self.ammo_rico = self.ammo_rico - 1;
				}
				else
				{
					sprint(self, "Ricochet bombs empty!\n");
					stuffcmd (self, "play combat/empty.wav\n");
				}
				self.spcl_finished = time + 2;
			}
			if (self.weapon == WEP_REMOTE)
			{
				if (!self.plyrremote)
				{
					if (self.ammo_remote > 0)
					{
						Fire_Remote();
						self.ammo_remote = self.ammo_remote - 1;
					}
					else
					{
						sprint(self, "Remote bombs empty!\n");
						stuffcmd (self, "play combat/empty.wav\n");
					}
				}
				else // Remote bomb in play
					Fire_Remote();
				self.spcl_finished = time + 0.75;
			}
			if (self.weapon == WEP_FREEZE)
			{
				if (self.ammo_freeze > 0)
				{
					if (!rear)
						Fire_Freeze(FALSE);
					else
						Fire_Freeze(TRUE);
					self.ammo_freeze = self.ammo_freeze - 1;
				}
				else
				{
					sprint(self, "Freeze blast bay empty!\n");
					stuffcmd (self, "play combat/empty.wav\n");
				}
				self.spcl_finished = time + 1.5;
			}
		}
	}
};