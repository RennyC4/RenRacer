//+--------+
//|Trigger |
//+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Contains all trigger_ entites used in RenRacer                             |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

//
// trigger_teleport
//

void() info_teleport_destination =
{
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("info_teleport_destination: no targetname\n");
};

// Spawnflag 1 ON = Silent
// Spawnflag 2 ON = Keep player velocity on teleport
void() trigger_teleport_touch =
{
	if (!other.owner.driving)
		return;
	if (other.owner.driving.teleport_finished > time)
		return;
	if (other.owner.driving.health <= 0)
		return;

	entity toucher = other.owner.driving;
	
	entity e = find(world, targetname, self.target);
	if (!e)
		objerror ("trigger_teleport: no destination set\n");

	if !(self.spawnflags & 2)
		float stop = TRUE;
	else
		stop = FALSE;

	if !(self.spawnflags & 1)
	{
		TeleportPhysObject(toucher.driving, e.origin, e.mangle, stop);
		spawn_telesfx(toucher);
		spawn_televfx(toucher);
	}
	else
		TeleportPhysObject(toucher.driving, e.origin, e.mangle, stop);

	toucher.angles = e.mangle;
	toucher.fixangle = TRUE;

	toucher.teleport_finished = time + 1;
};

// spawnflag 1 = silent teleporter
void() trigger_teleport
{
	if (!self.target)
		objerror ("trigger_teleport: no destination set\n");

	InitTrigger ();
	self.touch = trigger_teleport_touch;
};

//
// trigger hurt
//

void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

.float dmg;
void() trigger_hurt_touch =
{
	if (!other.owner.driving)
		return;
	if (other.owner.driving.health <= 0)
		return;

	entity toucher = other.owner.driving;

	self.solid = SOLID_NOT;
	DoDamage(toucher, self, self.dmg, "trigger");
	self.think = hurt_on;
	self.nextthink = time + 1;
};

void() trigger_hurt
{
	InitTrigger ();
	self.touch = trigger_hurt_touch;
}