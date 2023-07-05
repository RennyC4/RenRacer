//+----+
//|Main|
//+----+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Contains some 'base' subroutines. As a general rule nothing in this file   |
//| does much, except to setup basic variables and entities.                   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() load_waypoints;
void(vector org, float which, optional float speed) create_waypoint;

void() main = {};

// CSQC value requests
void() CSEv_GrabCSQCValues =
{
	clientstat(STAT_TURBOFUEL, EV_FLOAT, turbo_fuel);
	clientstat(STAT_SPEED, EV_FLOAT, realspeed);
	clientstat(STAT_DRIFT, EV_FLOAT, drift);
	clientstat(STAT_DRIVING, EV_FLOAT, driving);
	globalstat(STAT_RACESTATUS, EV_FLOAT, "race_status");
	clientstat(STAT_TIME, EV_FLOAT, laptime);
	clientstat(STAT_TURBO, EV_FLOAT, turbo);
	clientstat(STAT_SPEEDBOOST, EV_FLOAT, speedboost_finished);
	clientstat(STAT_HEALTH, EV_FLOAT, health);
	clientstat(STAT_MAXHEALTH, EV_FLOAT, max_health);
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

	PART_DIRT = particleeffectnum("dirt");
	PART_TURBO = particleeffectnum("turbo");
	PART_SPEEDBOOST = particleeffectnum("speedboost");
	PART_BUBBLE = particleeffectnum("bubble");
	PART_ROCKET1 = particleeffectnum("rocket1");
	PART_ROCKET2 = particleeffectnum("rocket2");
	PART_ROCKET3 = particleeffectnum("rocket3");

	precache_model("progs/null.spr");
	precache_model("progs/s_debug.spr");
	precache_model("progs/bullet.mdl");
	precache_model("progs/rocket.mdl");

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

	precache_sound ("engine/engine.wav");
	precache_sound ("engine/start.wav");
	precache_sound ("land.wav");
	precache_sound ("camera.wav");
	precache_sound ("turbo.wav");
	precache_sound ("cntdwn.wav");
	precache_sound ("gogo.wav");
	precache_sound ("youwin.wav");
	precache_sound ("finallap.wav");
	precache_sound ("fastlap.wav");
	precache_sound ("1.wav");
	precache_sound ("2.wav");
	precache_sound ("3.wav");
	precache_sound ("slide.wav");
	precache_sound ("warning.wav");
	precache_sound ("handbreak.wav");
	precache_sound ("skidding.wav");
	precache_sound ("teleport1.wav");
	precache_sound ("teleport2.wav");
	precache_sound ("hit1.wav");
	precache_sound ("hit2.wav");
	precache_sound ("hit3.wav");
	precache_sound ("hit4.wav");
	precache_sound ("spdboost.wav");

	precache_sound ("combat/mgun.wav");
	precache_sound ("combat/rocket.wav");
	precache_sound ("combat/xplode.wav");

	world_lights();
	BotInit();  // FrikBot
	load_waypoints(); // Load waypoints
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