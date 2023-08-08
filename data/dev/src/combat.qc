//+--------+
//|Combat  |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Weapons and combat functions are done here								   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

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
	if (attacker == targ) // suicide
	{
		bprint(targ.netname, " stupidly commited vehicular suicide\n");
		return;
	}

	if (attackerclassname == "bullet") // machine gun
	{
		bprint(attacker.netname, " coldly gunned down ");
		bprint(targ.netname, "\n");
	}
	if (attackerclassname == "rocket") // fire rocket
	{
		bprint(targ.netname, " swallowed ");
		bprint(attacker.netname, "'s rocket\n");
	}
	if (attackerclassname == "rocket2") // homing rocket
	{
		bprint(attacker.netname, "'s rocket really loves ");
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
		bprint(targ.netname, " raw\n");
	}
	if (attackerclassname == "flame")
	{
		bprint(attacker.netname, " nicely toasted ");
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
	spawn_color_glow(3, 1.25, 1, 75, xplode); // dynamic light
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
	spawn_color_glow(1, 1, 3, 75, xplode); // dynamic light
};

void(entity targ, entity attacker) Death =
{
	targ.forcejump_strength = 750;
	targ.forcejump = TRUE;
	CreateExplosion(targ.origin + v_up * 32);
};

void(entity targ, entity attacker, float damage, string attackerclassname) DoDamage =
{
	if (!deathmatch)
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
	if (!deathmatch)
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
			self.special_regen_finished = time + 80; // regen time
		}
	}
	if (self.vehicle == VEH_ZUMA)
	{
		if (self.ammo_special < 4) // max held
		{
			self.ammo_special = self.ammo_special + 1;
			self.special_regen_finished = time + 35; // regen time
		}
	}
};

// ---
// Machine Gun
// ---

void() MachineGunBullet_Touch =
{
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
	if (self.owner == other.owner.driving) // Hit self
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
	else if (other)
		DoDamage(other, self.owner, 2, self.classname);

	pointparticles(PART_MGUNSMOKE, self.origin, '0 0 0', 1);

	remove(self);
};

.float mgun;
void() Fire_MachineGun =
{
	local entity bullet = spawn();

	// machine gun slight tilt
	vector v = self.realang;
	if (self.mgun)
		v_y = v_y - 1;
	else
		v_y = v_y + 1;
	makevectors(v);

	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.owner = self;
	bullet.solid = SOLID_TRIGGER;
	bullet.classname = "bullet";
	bullet.netname = "projectile";
	bullet.effects = EF_FULLBRIGHT | EF_MUZZLEFLASH;
	bullet.touch = MachineGunBullet_Touch;

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
	local entity mflash1 = spawn();
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
	local entity mflash2 = spawn();
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

	if (!self.mgun)
	{
		if (!self.backward)
		{
			setorigin (mflash1, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) + v_right * 27); // flat
			setorigin (mflash2, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) + v_right * 27); // side
			setorigin (bullet, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) + v_right * 27);
		}
		else
		{
			setorigin (mflash1, self.origin + v_up * 8 + v_forward * (14 - self.realspeed) + v_right * 27); // flat
			setorigin (mflash2, self.origin + v_up * 8 + v_forward * (14 - self.realspeed) + v_right * 27); // side
			setorigin (bullet, self.origin + v_up * 8 + v_forward * (14 - self.realspeed) + v_right * 27);
		}
		self.mgun = TRUE;
	}
	else
	{
		if (!self.backward)
		{
			setorigin (mflash1, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) - v_right * 27); // flat
			setorigin (mflash2, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) - v_right * 27); // side
			setorigin (bullet, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) - v_right * 27);
		}
		else
		{
			setorigin (mflash1, self.origin + v_up * 8 + v_forward * (14 - self.realspeed) - v_right * 27); // flat
			setorigin (mflash2, self.origin + v_up * 8 + v_forward * (14 - self.realspeed) - v_right * 27); // side
			setorigin (bullet, self.origin + v_up * 8 + v_forward * (14 - self.realspeed) - v_right * 27);
		}
		self.mgun = FALSE;
	}

	sound (self, CHAN_AUTO, "combat/mgun.wav", 1, ATTN_NORM);

	mflash1.think = SUB_Remove;
	mflash1.nextthink = time + 0.1;
	mflash2.think = SUB_Remove;
	mflash2.nextthink = time + 0.1;
	bullet.think = SUB_Remove;
	bullet.nextthink = time + 1.5;
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

	if (self.classname == "rocket")
		pointparticles(PART_ROCKET1, self.origin, '0 0 0', 1);
	if (self.classname == "rocket2")
		pointparticles(PART_ROCKET2, self.origin, '0 0 0', 1);
	if (self.classname == "rocket3")
		pointparticles(PART_ROCKET3, self.origin, '0 0 0', 1);

	if (self.enemy) // Home in on enemy
	{
		local vector vele, vels, ph;
		vele = normalize(self.enemy.origin - self.origin);
		vels = normalize(self.velocity);
		ph = vele + (vels * 4);

		if (self.classname == "rocket")
			ph = ph * (1/33); // increase seceond number for less homing capability
		if (self.classname == "rocket2")
			ph = ph * (1/15);

		self.velocity = normalize(vels + ph);
		if (self.classname == "rocket")
			self.velocity = self.velocity * 1500;
		if (self.classname == "rocket2")
			self.velocity = self.velocity * 1000;

		self.angles = vectoangles(self.velocity);
	}

	frameskip(0.01);
};

void() Rocket_Touch =
{
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
			DoDamage(other.owner.driving, self.owner, 7, self.classname); // fire
			other.owner.driving.forcejump_strength = 250;
			other.owner.driving.forcejump = TRUE;
		}
		else if (other)
			DoDamage(other, self.owner, 7, self.classname);
	}
	if (self.classname == "rocket2")
	{
		if (other.owner.driving) // other.owner.driving is the player
		{
			DoDamage(other.owner.driving, self.owner, 10, self.classname); // homing
			other.owner.driving.forcejump_strength = 350;
			other.owner.driving.forcejump = TRUE;
		}
		else if (other)
			DoDamage(other, self.owner, 10, self.classname);
	}
	if (self.classname == "rocket3")
	{
		if (other.owner.driving) // other.owner.driving is the player
		{
			DoDamage(other.owner.driving, self.owner, 15, self.classname); // power
			other.owner.driving.forcejump_strength = 450;
			other.owner.driving.forcejump = TRUE;
		}
		else if (other)
			DoDamage(other, self.owner, 15, self.classname);
	}

	CreateExplosion(self.origin);
	Create2DExplosion(self.origin, 2);
	remove(self);
};

void(float type, float rear) Fire_Rocket =
{
	local entity rocket = spawn();

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
	else // power
	{
		rocket.classname = "rocket3";
		rocket.colormod = '1 1 10';
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
		else
		{
			rocket.velocity = aim(self, 2000);
			rocket.velocity = rocket.velocity * 2000; // power
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
	setorigin (rocket, self.origin + v_up * 8 + v_forward * (48 + self.realspeed));

	sound (self, CHAN_WEAPON, "combat/rocket.wav", 1, ATTN_NORM);

	rocket.removeme_finished = time + 3;
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

	local entity nf = spawn();
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
	spawn_color_glow(3, 1.25, 1, 150, nf); // dynamic light
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
	//if (!self.cnt) // run once on projectile launch
	//{
		if (!self.enemy)
			GetTarget();
		//self.cnt = TRUE;
	//}

	pointparticles(PART_NAPALM, self.origin, '0 0 0', 1);

	if (self.velocity_z <= 0)
		self.gravity = 1.75;
	if (self.enemy && self.velocity_z <= 0) // Home in on enemy
	{
		local vector vele, vels, ph;
		vele = normalize(self.enemy.origin - self.origin);
		vels = normalize(self.velocity);
		ph = vele + (vels * 4);
		ph = ph * (1/25); // increase seceond number for less homing capability

		self.velocity = normalize(vels + ph);
		self.velocity = self.velocity * 350;
	}

	frameskip(0.01);
};

void(float rear) Fire_Napalm =
{
	local entity napalm = spawn();
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
	napalm.hitcontentsmaski = CONTENTBIT_SOLID|0x00000002i|CONTENTBIT_BODY|CONTENTBIT_PLAYERCLIP|CONTENTBIT_WATER| CONTENTBIT_SLIME|CONTENTBIT_LAVA;

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
				targ.forcejump_strength = 750;
				targ.forcejump = TRUE;
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
	local entity rico = spawn();

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
	setorigin (rico, self.origin + v_forward * (48 + self.realspeed));

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
	frameskip(1);
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
		remote.dimension_hit = remote.dimension_solid = 0;

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
		local vector vele, vels, ph;
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
	if (other.owner.driving.classname != "player")
		return;
	if (self.owner == other.owner.driving)
		return;

	DoDamage(other.owner.driving, self.owner, 7, self.classname);

	if (other.owner.driving.onfire_finished > time) // remove fire
		other.owner.driving.onfire_finished = time;
	other.owner.driving.frozen_finished = time + 3;
	if (other.owner.driving.health > 0) // dont interfere with death colormod stuff
		other.owner.driving.colormod = '1 1 6';
	Create2DFreezeExplosion(self.origin, 3);
	remove(self);
};

void(float rear) Fire_Freeze =
{
	local entity freeze = spawn();

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
	setorigin (freeze, self.origin + v_up * 8 + v_forward * (40 + self.realspeed));

	sound (self, CHAN_WEAPON, "combat/freeze.wav", 1, ATTN_NORM);

	freeze.removeme_finished = time + 2;
	freeze.think = Freeze_Think;
	freeze.nextthink = time;
	spawn_color_glow(1, 1, 3, 150, freeze); // dynamic light
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
	local entity landmine = spawn();
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

	setmodel (shield, "progs/shield.mdl");
	setsize (shield, '0 0 0', '0 0 0');
	setorigin (shield, self.origin);

	shield.nextthink = time;
	shield.think = Shield_Think;
	spawn_color_glow(1, 3, 1, 125, shield); // dynamic light
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
		self.hitobject_finished = time + 0.5;
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
		if (trace_fraction < 1)
			setorigin(self, trace_endpos);
		else
			setorigin(self, end);			
	}

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
// Command Specials
//

.float cmdspecial_rear_step;
.float cmdspecial_rear_step_finished;
.float cmdspecial_landmine_step;
.float cmdspecial_landmine_step_finished;

void() CommandSpecials =
{
	if (!deathmatch)
		return;
	if (race_status != RACE_STARTED)
		return;
	if (self.commandspcl_finished > time)
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
		self.forcejump_strength = 1000;
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
	if (self.moveprog4 == 1) // User pressed left
	{
		self.cmdspecial_landmine_step = 1;
		self.cmdspecial_landmine_step_finished = time + 0.2;
	}
	if (self.cmdspecial_landmine_step == 1 && self.moveprog3 == 1) // User pressed right
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
};

//
// Change weapon functions
//

void() ChangeWeapon =
{
	if (!deathmatch)
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
	if (!deathmatch)
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
	if (!deathmatch)
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
	if (!deathmatch)
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
					if (self.vehicle == VEH_HOTROD)
					{
						if (!rear)
							SpecialWeapon_HotRod(FALSE);
						else
							SpecialWeapon_HotRod(TRUE);
					}
					if (self.vehicle == VEH_ZUMA)
					{
						bprint ("Fire Zuma Special Attack\n");
					}
					self.ammo_special = self.ammo_special - 1;
				}
				else
				{
					sprint(self, "Special weapon bay empty!\n");
					stuffcmd (self, "play combat/empty.wav\n");
				}
				self.spcl_finished = time + 1;
			}
			if (self.weapon == WEP_ROCKET)
			{
				if (self.ammo_firerocket > 0)
				{
					if (!rear)
						Fire_Rocket(0, FALSE);
					else
						Fire_Rocket(0, TRUE);
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
						Fire_Rocket(1, FALSE);
					else
						Fire_Rocket(1, TRUE);
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
						Fire_Rocket(2, FALSE);
					else
						Fire_Rocket(2, TRUE);					
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