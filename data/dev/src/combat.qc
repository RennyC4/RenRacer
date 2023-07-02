//+--------+
//|Combat  |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Weapons and combat functions are done here								   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

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

	other.owner.driving.colormod_x = 2; // color target red

	// Damage target, add red colormod
	// other.owner.driving is the player

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

// TODO: Machine gun needs it's own attack finished and so does specials..
// can fire machine guns while using your special
void(float type) CarAttack =
{
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