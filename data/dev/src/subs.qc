//+------+
//|Subs  |
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| SUB Functions are stored here                                              |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

entity activator;
void() SUB_Null = {};
void() SUB_UseTargets;

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

void(string targ) FireTarget =
{	
	local entity t, stemp, otemp, act;
	
	act = activator;
	t = world;
	do
	{
		t = find (t, targetname, targ);
		if (!t)
			return;

		if (t.classname == "trigger_push")
		{
			if (t.spawnflags & 2)
				t.cnt = FALSE; // turn inactive trigger into an active one
		}

		stemp = self;
		otemp = other;
		self = t;
		other = stemp;

		if (self.use != SUB_Null)
		{
			if (self.use)
				self.use();
		}
		
		self = stemp;
		other = otemp;
		activator = act;
	}
	while (1);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/

void() SUB_UseTargets =
{
	local entity t;

	//
	// check for a delay
	//
	if (self.delay)
	{
		// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}

	//
	// fire targets
	//
	if (self.target)
		FireTarget(self.target);

	//
	// kill the killtagets
	//
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find (t, targetname, self.killtarget);
			if (!t)
				return;
			remove (t);
		} while (1);
	}
};