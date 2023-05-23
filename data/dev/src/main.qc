//+----+
//|Main|
//+----+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Contains some 'base' subroutines. As a general rule nothing in this file   |
//| does much, except to setup basic variables and entities.                   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() main = {};

void() CSEv_GrabCSQCValues =
{
	clientstat(STAT_ORIGINX, EV_FLOAT, player_x);
	clientstat(STAT_ORIGINY, EV_FLOAT, player_y);
	clientstat(STAT_ORIGINZ, EV_FLOAT, player_z);
};

void() world_lights =
{
	lightstyle(0, "m");
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	lightstyle(4, "mamamamamama");
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	lightstyle(6, "nmonqnmomnmomomno");
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	lightstyle(9, "aaaaaaaazzzzzzzz");	
	lightstyle(10, "mmamammmmammamamaaamammma");
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	lightstyle(63, "a");
};

void() worldspawn = 
{
	countdown_count = 3;
	lastspawn = world;

	precache_model("progs/null.spr");

	//
	// func_vehicle - start
	//

	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	// hotrod
	precache_model("progs/HotRod_body.mdl");
	precache_model("progs/HotRod_roof.mdl");
	precache_model("progs/HotRod_player_driver.mdl");
	precache_model("progs/HotRod_wheel_front_L.mdl");
	precache_model("progs/HotRod_wheel_rear_L.mdl");
	precache_model("progs/HotRod_wheel_front_R.mdl");
	precache_model("progs/HotRod_wheel_rear_R.mdl");
	precache_model("progs/HotRod_turret_base.mdl");
	precache_model("progs/HotRod_turret_swivel.mdl");
	precache_model("progs/HotRod_turret_body.mdl");
	precache_model("progs/HotRod_turret_barrel.mdl");

	//
	// func_vehicle - end
	//

	precache_sound ("engine/aa01.wav");
	precache_sound ("engine/aa02.wav");
	precache_sound ("engine/aa03.wav");
	precache_sound ("engine/aa04.wav");
	precache_sound ("engine/aa05.wav");
	precache_sound ("engine/aa06.wav");
	precache_sound ("engine/aa07.wav");
	precache_sound ("engine/aa08.wav");

	world_lights();
	BotInit();  // FrikBot
	CSEv_GrabCSQCValues(); //CSQC Setup
};

void() SetNewParms = {};
void() SetChangeParms = {};

void() StartFrame = 
{
	BotFrame(); // FrikBot
	framecount = framecount + 1;
};

// =======
// new hit detection method
// =======

float bound2 (float bmin, float bvalue, float bmax)
{
 	if (bvalue < bmin)
 		return bmin;
 	else if (bvalue > bmax)
 		return bmax;
	return bvalue;
};

entity(vector org, float rad) searchradius =
{
	local entity y, head, ent = world;
	local vector v;

	head = world;

	y = find(world, hitme, "TRUE");
	while(y)
	{
		v_x = bound2(y.absmin_x, org_x, y.absmax_x);
		v_y = bound2(y.absmin_y, org_y, y.absmax_y);
		v_z = bound2(y.absmin_z, org_z, y.absmax_z);

		if(vlen(v - org) < rad)
		{
			if (head)
				ent.chain = y;
			else
				head = y;
			ent = y;
		}
		y = find(y, hitme, "TRUE");
	}
	if (head)
		ent.chain = world;
	return head;
};

// =======
// Help keep low framerates in sync
// =======

float frameskip_delay; 
entity frameskip_ent;

void(float n) frameskip =
{
	if (frameskip_ent != self)
	{
		frameskip_delay = 0;
		frameskip_ent = self;
	}
	if (frametime > n + frameskip_delay)
	{
		frameskip_delay = frameskip_delay + n;
		self.think();
	}
	else
	{
		if (self.movetype != MOVETYPE_PUSH)
			self.nextthink = time + n;
		else // ltime used on movetype push
			self.nextthink = self.ltime + n;
	}
};