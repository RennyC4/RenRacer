//+--------+
//|Combat  |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Weapons and combat functions are done here								   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

// ---
// Damage / Death / Effects
// ---

void(vector position) CreateExplosion =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, position_x);
	WriteCoord (MSG_BROADCAST, position_y);
	WriteCoord (MSG_BROADCAST, position_z);
	sound (self, CHAN_BODY, "combat/xplode.wav", 1, ATTN_NORM);
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

void(entity targ, entity attacker, float damage) DoDamage =
{
	if (targ.health < 1)
		return;
	if (targ.invulnerable_finished > time)
		return;

	targ.health = targ.health - damage;
	targ.colormod_x = 2;

	if (targ.health <= 0)
	{
		attacker.frags = attacker.frags + 1; // reward
		Death(targ, attacker);
		return;
	}
};

// Used for aquiring targets (missiles and other projectiles)
void() GetTarget =
{
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (visible(targ) && infront3(targ, 0.75) && !self.enemy && targ.health > 0 && targ != self.owner)
			self.enemy = targ;
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
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
		remove(self);
		return;
	}
	if (other.owner.driving.classname != "player")
		return;
	if (self.owner == other.owner.driving)
		return;

	DoDamage(other.owner.driving, self.owner, 2); // other.owner.driving is the player

	remove(self);
};

.float mgun;
void() Fire_MachineGun =
{
	local entity bullet = spawn ();

	makevectors (self.realang);

	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.owner = self;
	bullet.solid = SOLID_TRIGGER;
	bullet.classname = "bullet";
	bullet.netname = "projectile";
	bullet.effects = EF_FULLBRIGHT;
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

	if (!self.mgun)
	{
		setorigin (bullet, self.origin + v_up * 8 + v_forward * 14 + v_right * 24);
		self.mgun = TRUE;
	}
	else
	{
		setorigin (bullet, self.origin + v_up * 8 + v_forward * 14 - v_right * 24);
		self.mgun = FALSE;
	}

	sound (self, CHAN_WEAPON, "combat/mgun.wav", 1, ATTN_NORM);

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
		float homing = 0;
		if (self.classname == "rocket")
			homing = 10;
		if (self.classname == "rocket2")
			homing = 25;
		if (self.classname == "rocket3")
			homing = 0;

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
		remove(self);
		return;
	}
	if (other.owner.driving.classname != "player")
		return;
	if (self.owner == other.owner.driving)
		return;

	// Car jumps on hit
	local entity targ = other.owner.driving;
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
			Phys_Force(targ.driving, targ.driving.physobj_mass, '0 0 1' * 250 * 1.0, trace_endpos, wheels[i].lmat_up);
	}

	if (self.classname == "rocket")
		DoDamage(other.owner.driving, self.owner, 15); // fire
	if (self.classname == "rocket2")
		DoDamage(other.owner.driving, self.owner, 9); // homing
	if (self.classname == "rocket3")
		DoDamage(other.owner.driving, self.owner, 30); // power

	CreateExplosion(self.origin);
	remove(self);
};

void(float type) Fire_Rocket =
{
	local entity rocket = spawn ();

	makevectors (self.realang);

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

void() NapalmTouch_Think =
{
	if (self.scale < 8)
		self.scale = self.scale + 0.1;
	if (self.alpha > 0.01)
		self.alpha = self.alpha - 0.01;
	else
	{
		remove(self);
		return;
	}
	frameskip(0.01);
};

void() Napalm_Touch =
{
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	CreateExplosion(self.origin);
	self.think = NapalmTouch_Think;
	self.nextthink = time;
};

void() Napalm_Think =
{
	if (!self.enemy)
		GetTarget();

	pointparticles(PART_NAPALM, self.origin, '0 0 0', 1);

	if (self.enemy && self.velocity_z <= 0) // Home in on enemy
	{
		float homing = 20;

		local vector vele, vels, ph;
		vele = normalize(self.enemy.origin - self.origin);
		vels = normalize(self.velocity);
		ph = vele + (vels * 4);
		ph = ph * (1/33); // increase seceond number for less homing capability

		self.velocity = normalize(vels + ph);
		self.velocity = self.velocity * 350;
	}

	frameskip(0.01);
};

void() Fire_Napalm =
{
	local entity napalm = spawn ();
	napalm.owner = self;
	napalm.solid = SOLID_SLIDEBOX;
	napalm.movetype = MOVETYPE_TOSS;
	napalm.classname = "napalm";
		
	makevectors (self.realang);

	napalm.velocity = v_forward * 350;
	napalm.velocity = aim(self, 350);
	napalm.velocity = napalm.velocity * 350;
	napalm.velocity_z = 700;
	napalm.effects = EF_FULLBRIGHT | EF_DIMLIGHT | EF_ADDITIVE;
	napalm.alpha = 0.9;
	napalm.avelocity = '-500 200 0';

	napalm.velocity_x = napalm.velocity_x + self.driving.velocity_x;
	napalm.velocity_y = napalm.velocity_y + self.driving.velocity_y;

	napalm.angles = vectoangles(napalm.velocity);
	
	setmodel (napalm, "progs/napalm.mdl");
	setsize (napalm, '0 0 0', '0 0 0');		
	setorigin (napalm, self.origin + v_up * 32);
	
	napalm.scale = 2;
	napalm.touch = Napalm_Touch;
	napalm.think = Napalm_Think;
	napalm.nextthink = time;
};

// Change weapons
void() ChangeWeapon =
{
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

// Main function to determine what gun the car fires
void(float type) CarAttack =
{
	if (!deathmatch)
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
				Fire_Rocket(0);
				self.spcl_finished = time + 1;
			}
			if (self.weapon == WEP_HROCKET)
			{
				Fire_Rocket(1);
				self.spcl_finished = time + 1;
			}
			if (self.weapon == WEP_PROCKET)
			{
				Fire_Rocket(2);
				self.spcl_finished = time + 1;
			}
			if (self.weapon == WEP_NAPALM)
			{
				Fire_Napalm();
				self.spcl_finished = time + 3;
			}
		}
	}
};