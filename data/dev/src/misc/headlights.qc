.entity flash;
.entity flash2;

void() headlight_update =
{
	local vector middle;

	self.pflags = PFLAGS_FULLDYNAMIC;
	self.light_lev = 1600;
	self.color = [1, 1, 1];

	makevectors (self.owner.realang);
	traceline (self.owner.origin + v_up * 64  + v_forward * (40 + self.owner.realspeed), (self.owner.origin+(v_forward * 1024)) , FALSE , self);
	middle = (self.owner.origin + v_up * 128 + v_forward * (40 + self.owner.realspeed) + trace_endpos) / 2;

	if (self.classname == "flash")
       	setorigin (self, trace_endpos + (v_forward * -5));
	else if (self.classname == "flash2")
		setorigin (self, middle);

	frameskip(0.01);
};

void() headlights_on =
{
	local entity myflash, myflash2;
	local vector middle = self.owner.origin + v_forward * 50;

	self.headlights = TRUE;

	makevectors (self.realang);

	//
	// Spawn flashlight entity at end of traceline
	//

	myflash = spawn ();
	myflash.hitcontentsmaski = 0;
	myflash.movetype = MOVETYPE_NOCLIP;
	myflash.solid = SOLID_NOT;
	setmodel (myflash, "*null");
	setsize (myflash, '0 0 0', '0 0 0');

	myflash.owner = self; // link entities
	self.flash = myflash; // link entities

	myflash.classname = "flash";
	myflash.effects = EF_DIMLIGHT;

	myflash.think = headlight_update;
	myflash.nextthink = time;

	//
	// Spawn flashlight entity at middle of traceline
	//

	myflash2 = spawn ();
	myflash2.hitcontentsmaski = 0;
	myflash2.movetype = MOVETYPE_NOCLIP;
	myflash2.solid = SOLID_NOT;
	setmodel (myflash2, "*null");
	setsize (myflash2, '0 0 0', '0 0 0');

	myflash2.owner = self; // link entities
	self.flash2 = myflash2; // link entities

	myflash2.classname = "flash2";
	myflash2.effects = EF_DIMLIGHT;

	setorigin (myflash2, middle);

	myflash2.think = headlight_update;
	myflash2.nextthink = time;
};

void() headlights_off =
{
	self.effects = 0;
	self.headlights = FALSE;
	// Turn end light off
	if (self.flash)
	{
		self.flash.think = SUB_Remove;
		self.flash.nextthink = time;
		self.flash = world;
	}
	// Turn middle light off
	if (self.flash2)
	{
		self.flash2.think = SUB_Remove;
		self.flash2.nextthink = time;
		self.flash2 = world;
	}
}; 

void() headlights_toggle =
{
	if (!self.driving)
		return;

	if (!self.headlights)
	{
		sprint(self, "Headlights: ON\n");
		headlights_on();
	}
	else
	{
		sprint(self, "Headlights: OFF\n");
		headlights_off();
	}
}; 