//+--------+
//|Combat  |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Weapons and combat functions are done here								   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void(entity targ, entity attacker, string attackerclassname) PrintDeathMessage =
{
	if (attacker == world) // This shouldn't happen, but lets add it anyways
	{
		bprint(targ.netname, " was killed by the karma gods\n");
		return;
	}
	if (attacker == targ) // suicide
	{
		if (targ)
			targ.frags = targ.frags - 1;
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
		bprint(targ.netname, " true power!\n");
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
	local entity xplode = spawn();
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

void(entity targ, entity attacker) Death =
{
	// Car jumps big on death
	entity wheels[] = {
		targ.driving.frontleft,
		targ.driving.frontright,
		targ.driving.backleft,
		targ.driving.backright
	};
	for (float i = 0; i < wheels.length; i++)
	{
		traceline(wheels[i].origin, wheels[i].origin - wheels[i].lmat_up * 24, MOVE_NOMONSTERS, wheels[i]);
		if (trace_fraction < 1)
			Phys_Force(targ.driving, targ.driving.physobj_mass, '0 0 1' * 500 * 1.0, trace_endpos, wheels[i].lmat_up);
	}
	// Initial big explosion here
	CreateExplosion(targ.origin + v_up * 32);
};

void(entity targ, entity attacker, float damage, string attackerclassname) DoDamage =
{
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
		targ.colormod_x = 2;
	}

	if (targ.health <= 0)
	{
		if (attacker)
			attacker.frags = attacker.frags + 1; // reward
		Death(targ, attacker);
		PrintDeathMessage(targ, attacker, attackerclassname);
		targ.deadflag = TRUE;
	}
};

void(entity attacker, float radius, float damage, float setfire, string attackerclassname) DoRadiusDamage =
{
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (vlen(targ.origin - self.origin) <= radius)
		{
			DoDamage(targ, attacker, damage, self.classname);
			if (setfire)
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
// Machine Gun
// ---

// func_vehicle is solid_bsp with an owner
// so check for walls if there is none
void() MachineGunBullet_Touch =
{
	if (other.solid == SOLID_BSP && !other.owner) // Hit wall
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
	if (other.owner.driving.classname != "player")
		return;
	if (self.owner == other.owner.driving)
		return;

	tt = ceil(random() * 3);
	if (tt == 1)
		sound(self, CHAN_BODY, "combat/mgunh1.wav", 1, ATTN_NORM);
	else if (tt == 2)
		sound(self, CHAN_BODY, "combat/mgunh2.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_BODY, "combat/mgunh3.wav", 1, ATTN_NORM);

	DoDamage(other.owner.driving, self.owner, 2, self.classname); // other.owner.driving is the player
	pointparticles(PART_MGUNSMOKE, self.origin, '0 0 0', 1);

	remove(self);
};

.float mgun;
void() Fire_MachineGun =
{
	local entity bullet = spawn();

	makevectors (self.realang);

	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.owner = self;
	bullet.solid = SOLID_TRIGGER;
	bullet.classname = "bullet";
	bullet.netname = "projectile";
	bullet.effects = EF_FULLBRIGHT | EF_MUZZLEFLASH;
	bullet.touch = MachineGunBullet_Touch;

	bullet.velocity = aim(self, 1000);
	bullet.velocity = bullet.velocity * 1000;
	bullet.velocity_x = bullet.velocity_x + self.driving.velocity_x;
	bullet.velocity_y = bullet.velocity_y + self.driving.velocity_y;

	bullet.angles = vectoangles(bullet.velocity);

	// Test
	bullet.dimension_solid = 0;
	bullet.dimension_hit = 1;
	//

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
		setorigin (mflash1, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) + v_right * 24); // flat
		setorigin (mflash2, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) + v_right * 24); // side
		setorigin (bullet, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) + v_right * 24);
		self.mgun = TRUE;
	}
	else
	{
		setorigin (mflash1, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) - v_right * 24); // flat
		setorigin (mflash2, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) - v_right * 24); // side
		setorigin (bullet, self.origin + v_up * 8 + v_forward * (14 + self.realspeed) - v_right * 24);
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
	if (other.solid == SOLID_BSP && !other.owner) // Hit wall
	{
		CreateExplosion(self.origin);
		Create2DExplosion(self.origin, 2);
		remove(self);
		return;
	}
	if (other.owner.driving.classname != "player")
		return;
	if (self.owner == other.owner.driving)
		return;

	if (self.classname == "rocket")
	{
		DoDamage(other.owner.driving, self.owner, 7, self.classname); // fire

		other.owner.driving.forcejump_strength = 250;
		if (other.owner.driving.health > 7) // Possible fix for NaN on jump physics being called twice when target killed
			other.owner.driving.forcejump = TRUE;
	}
	if (self.classname == "rocket2")
	{
		DoDamage(other.owner.driving, self.owner, 10, self.classname); // homing

		other.owner.driving.forcejump_strength = 350;
		if (other.owner.driving.health > 10) // Possible fix for NaN on jump physics being called twice when target killed
			other.owner.driving.forcejump = TRUE;
	}
	if (self.classname == "rocket3")
	{
		DoDamage(other.owner.driving, self.owner, 15, self.classname); // power

		other.owner.driving.forcejump_strength = 450;
		if (other.owner.driving.health > 15) // Possible fix for NaN on jump physics being called twice when target killed
			other.owner.driving.forcejump = TRUE;
	}

	CreateExplosion(self.origin);
	Create2DExplosion(self.origin, 2);
	remove(self);
};

void(float type, float rear) Fire_Rocket =
{
	local entity rocket = spawn ();

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
	rocket.velocity_x = rocket.velocity_x + self.driving.velocity_x;
	rocket.velocity_y = rocket.velocity_y + self.driving.velocity_y;
	rocket.angles = vectoangles(rocket.velocity);

	// Test
	rocket.dimension_solid = 0;
	rocket.dimension_hit = 1;
	//

	setmodel (rocket, "progs/rocket.mdl");
	setsize (rocket, '0 0 0', '0 0 0');
	setorigin (rocket, self.origin + v_up * 8 + v_forward * (40 + self.realspeed));

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
		DoRadiusDamage(self.owner, 150, 0, TRUE, self.classname); // Set whoever near me on fire
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
	setorigin (nf, self.origin + v_up * 64);
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
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	CreateExplosion(self.origin);
	DoRadiusDamage(self.owner, 50, 10, TRUE, self.classname);
	CreateNapalmFire();
	self.think = NapalmTouch_Think;
	self.nextthink = time;
};

void() Napalm_Think =
{
	if (!self.cnt) // run once on projectile launch
	{
		if (!self.enemy)
			GetTarget();
		self.cnt = TRUE;
	}

	pointparticles(PART_NAPALM, self.origin, '0 0 0', 1);

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
	local entity napalm = spawn ();
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

	napalm.velocity_x = napalm.velocity_x + self.driving.velocity_x / 1.75;
	napalm.velocity_y = napalm.velocity_y + self.driving.velocity_y / 1.75;

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
// Landmine
//

void() Landmine_Touch =
{
	if (other.owner.driving == self.owner) // Players can't trip their own mines
		return;
	if (self.hitobject_finished > time)
		return;

	CreateExplosion(self.origin);
	Create2DExplosion(self.origin + v_up * 24, 3);
	DoDamage(other.owner.driving, self.owner, 15, self.classname);

	other.owner.driving.forcejump_strength = 450;
	if (other.owner.driving.health > 15) // Possible fix for NaN on jump physics being called twice when target killed
		other.owner.driving.forcejump = TRUE;

	remove(self);
};

void() Landmine_Think =
{
	if (!self.owner)
	{
		remove(self);
		return;
	}
	droptofloor();
	setorigin(self, self.origin + v_up * 16);

	self.think = SUB_Remove;
	self.nextthink = time + 30;
};

void() Fire_Landmine =
{
	local entity landmine = spawn ();
	landmine.owner = self;
	landmine.solid = SOLID_TRIGGER;
	landmine.movetype = MOVETYPE_NONE;
	landmine.classname = "landmine";

	setmodel (landmine, "progs/landmine.spr");
	setsize (landmine, '0 0 0', '0 0 0');
	setorigin (landmine, self.origin);

	sound (self, CHAN_AUTO, "combat/landmine.wav", 1, ATTN_NORM); // CHAN_WEAPON is for specials, mgun spams

	landmine.hitobject_finished = time + 0.5; // How long till it's active
	landmine.touch = Landmine_Touch;
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
	self.scale = 10 + sin(time*512)*0.5;
	setorigin (self, self.owner.origin);
	frameskip(0.01);
};

void() Fire_Shield =
{
	local entity shield = spawn ();
	shield.owner = self;
	shield.solid = SOLID_SLIDEBOX;
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
	if (self.cmdspecial_rear_step == 2 && self.moveprog2 == 1 && self.energy >= 30) // Hit last step, user hit down
	{
		self.energy = self.energy - 30;
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
		self.weapon = WEP_ROCKET;
		sprint (self, "Fire Rockets selected\n");
	}
	if (self.impulse == 2)
	{
		self.weapon = WEP_HROCKET;
		sprint (self, "Homing Rockets selected\n");
	}
	if (self.impulse == 3)
	{
		self.weapon = WEP_PROCKET;
		sprint (self, "Power Rockets selected\n");
	}
	if (self.impulse == 4)
	{
		self.weapon = WEP_NAPALM;
		sprint (self, "Napalm selected\n");
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
		sprint (self, "Homing Rockets selected\n");
		return;
	}
	if (self.weapon == WEP_HROCKET)
	{
		self.weapon = WEP_PROCKET;
		sprint (self, "Power Rockets selected\n");
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
		self.weapon = WEP_ROCKET;
		sprint (self, "Fire Rockets selected\n");
		return;
	}
};

void() CycleWeaponBackward =
{
	if (!deathmatch)
		return;
	if (race_status != RACE_STARTED)
		return;

	if (self.weapon == WEP_ROCKET)
	{
		self.weapon = WEP_NAPALM;
		sprint (self, "Napalm selected\n");
		return;
	}
	if (self.weapon == WEP_NAPALM)
	{
		self.weapon = WEP_PROCKET;
		sprint (self, "Power Rockets selected\n");
		return;
	}
	if (self.weapon == WEP_PROCKET)
	{
		self.weapon = WEP_HROCKET;
		sprint (self, "Homing Rockets selected\n");
		return;
	}
	if (self.weapon == WEP_HROCKET)
	{
		self.weapon = WEP_ROCKET;
		sprint (self, "Fire Rockets selected\n");
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
					sprint(self, "Fire Rocket bay empty!\n");
					// TODO: Insert empty chamber sound
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
					sprint(self, "Homing Rocket bay empty!\n");
					// TODO: Insert empty chamber sound
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
					sprint(self, "Power Rocket bay empty!\n");
					// TODO: Insert empty chamber sound
				self.spcl_finished = time + 1;
			}
			if (self.weapon == WEP_NAPALM)
			{
				if (self.waterlevel > 0)
				{
					self.spcl_finished = time + 0.5;
					sprint(self, "Can't fire Napalm in water!\n");
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
					sprint(self, "Napalm fuel empty!\n");
					// TODO: Insert empty chamber sound
				self.spcl_finished = time + 2;
			}
		}
	}
};