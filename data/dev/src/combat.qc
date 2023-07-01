//+--------+
//|Combat  |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Weapons and combat functions are done here								   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() MachineGunBullet_Touch =
{
	if (other.solid == SOLID_BSP && !other.owner)
	{
		bprint ("Bullet hit wall\n");
		remove(self);
		return;
	}
	if (other.owner.driving.classname != "player")
		return;
	if (self.owner == other.owner.driving)
		return;

	bprint ("Damage target\n");
	// Damage target, add red colormod
	//other.owner.driving is the player

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
	bullet.angles = vectoangles(bullet.velocity);

	setmodel (bullet, "progs/bullet.mdl");
	setsize (bullet, '0 0 0', '0 0 0');

	if (!self.mgun)
	{
		setorigin (bullet, self.origin + v_forward * 14 + v_right * 24);
		self.mgun = TRUE;
	}
	else
	{
		setorigin (bullet, self.origin + v_forward * 14 - v_right * 24);
		self.mgun = FALSE;
	}

	sound (self, CHAN_WEAPON, "combat/mgun.wav", 1, ATTN_NORM);

	bullet.think = SUB_Remove;
	bullet.nextthink = time + 1;
};