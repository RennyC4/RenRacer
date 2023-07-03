//+--------+
//|Combat  |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Weapons and combat functions are done here								   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void(vector position) CreateExplosion =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, position_x);
	WriteCoord (MSG_BROADCAST, position_y);
	WriteCoord (MSG_BROADCAST, position_z);
};

void(entity targ, entity attacker) Death =
{
	// Car jumps on death
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
		Death(targ, attacker);
		return;
	}
};

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
	//DoDamage(other.owner.driving, self.owner, 50); // test

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
	bullet.nextthink = time + 1;
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
			bprint ("Fire a special weapon here\n");
			self.spcl_finished = time + 1;
		}
	}
};