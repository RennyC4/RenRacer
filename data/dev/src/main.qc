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

// correct pitch fix without breaking stuff, thanks spike
void(vector ang) makevectors_mdl =
{
	ang_x *= autocvar(r_meshpitch, -1);
	makevectors(ang);
};

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
	clientstat(STAT_AMMO_FIREROCKET, EV_FLOAT, ammo_firerocket);
	clientstat(STAT_AMMO_HOMINGROCKET, EV_FLOAT, ammo_homingrocket);
	clientstat(STAT_AMMO_POWERROCKET, EV_FLOAT, ammo_powerrocket);
	clientstat(STAT_AMMO_NAPALM, EV_FLOAT, ammo_napalm);
	globalstat(STAT_INTERMISSION, EV_FLOAT, "intermission_running");
	clientstat(STAT_WEAPON, EV_FLOAT, weapon);
	clientstat(STAT_ENERGY, EV_FLOAT, energy);
	clientstat(STAT_ENEMYNAME, EV_STRING, enemy_displayname);
	clientstat(STAT_ENEMYHEALTH, EV_FLOAT, enemy_displayhealth);
	clientstat(STAT_ENEMYMAXHEALTH, EV_FLOAT, enemy_displaymaxhealth);
	clientstat(STAT_AMMO_RICOCHET, EV_FLOAT, ammo_rico);
	clientstat(STAT_AMMO_REMOTE, EV_FLOAT, ammo_remote);
	clientstat(STAT_AMMO_FREEZE, EV_FLOAT, ammo_freeze);
	clientstat(STAT_PLAYERID, EV_FLOAT, player_id);
	clientstat(STAT_AMMO_SPECIAL, EV_FLOAT, ammo_special);
	globalstat(SERVER_RAGEWAR, EV_FLOAT, "ragewar");
	clientstat(STAT_VEHICLE, EV_FLOAT, vehicle);
	clientstat(STAT_BLIND, EV_FLOAT, blind_finished);
	clientstat(STAT_ORIGINX, EV_FLOAT, origin_x);
	clientstat(STAT_ORIGINY, EV_FLOAT, origin_y);
	clientstat(STAT_ORIGINZ, EV_FLOAT, origin_z);
	clientstat(STAT_FIRE, EV_FLOAT, onfire_finished);
	clientstat(STAT_FROZE, EV_FLOAT, frozen_finished);
	clientstat(STAT_OBSERVE, EV_FLOAT, observer);
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
	PART_NAPALM = particleeffectnum("napalm");
	PART_MGUNSMOKE = particleeffectnum("mgunsmoke");
	PART_FREEZEBLAST = particleeffectnum("freezeblast");
	PART_FLAME = particleeffectnum("flamethrower");
	PART_GROCKET = particleeffectnum("ghostrocket");
	PART_HOTDOGSPLAT = particleeffectnum("hotdogsplat");

	precache_model("progs/null.spr");
	precache_model("progs/s_debug.spr");
	precache_model("progs/bullet.mdl");
	precache_model("progs/rocket.mdl");
	precache_model("progs/napalm.mdl");
	precache_model("progs/mflash.spr");
	precache_model("progs/mflash2.spr");
	precache_model("progs/fire.spr");
	precache_model("progs/xplode1.spr");
	precache_model("progs/landmine.spr");
	precache_model("progs/shield.mdl");
	precache_model("progs/ricochet.mdl");
	precache_model("progs/remote.spr");
	precache_model("progs/remote2.spr");
	precache_model("progs/frzsmk.spr");
	precache_model("progs/frzsmk2.spr");
	precache_model("progs/frozen.mdl");
	precache_model("progs/flame.spr");
	precache_model("progs/boomerang.mdl");
	precache_model("progs/vfxring.mdl");
	precache_model("progs/mountedgun.mdl");
	precache_model("progs/turret_h.mdl");
	precache_model("progs/turret_b.mdl");
	precache_model("progs/demon.spr");
	precache_model("progs/blood.spr");

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
	precache_model("progs/HotRod_wheel_front_L.mdl");
	precache_model("progs/HotRod_wheel_rear_L.mdl");
	precache_model("progs/HotRod_wheel_front_R.mdl");
	precache_model("progs/HotRod_wheel_rear_R.mdl");

	// wraith
	precache_model("progs/Wraith_body.mdl");
	precache_model("progs/Wraith_wheel.mdl");

	// road bastard
	precache_model("progs/Roadbstrd_body.mdl");
	precache_model("progs/wheel2.mdl");

	// skyscraper
	precache_model("progs/Skyscraper_body.mdl");
	precache_model("progs/Skyscraper_wheel.mdl");

	// redrage
	precache_model("progs/Redrage_body.mdl");
	precache_model("progs/Redrage_wheel.mdl");

	// lawbreaker
	precache_model("progs/Lawbreaker_body.mdl");
	precache_model("progs/Lawbreaker_wheel.mdl");

	// razorback
	precache_model("progs/Razorback_body.mdl");
	precache_model("progs/Razorback_wheel.mdl");

	// mince meat
	precache_model("progs/Mincemeat_body.mdl");
	precache_model("progs/Mincemeat_wheel.mdl");
	precache_model("progs/Mincemeat_hotdog.mdl");
	precache_model("progs/hotdog_proj.mdl");

	// street king
	precache_model("progs/Streetking_body.mdl");

	// sand roamer
	precache_model("progs/SandRoamer_body.mdl");

	// thorogood
	precache_model("progs/Thorogood_Body.mdl");
	precache_model("progs/Thorogood_Driver.mdl");
	precache_model("progs/Thorogood_Wheel.mdl");
	precache_model("progs/Thorogood_Sidecar.mdl");

	//
	// func_vehicle - end
	//

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

	precache_sound ("misc/metlbrk.wav");

	precache_sound ("combat/mgun.wav");
	precache_sound ("combat/fire.wav");
	precache_sound ("combat/rocket.wav");
	precache_sound ("combat/xplode.wav");
	precache_sound ("combat/napalm.wav");
	precache_sound ("combat/item.wav");
	precache_sound ("combat/ric1.wav");
	precache_sound ("combat/ric2.wav");
	precache_sound ("combat/ric3.wav");
	precache_sound ("combat/mgunh1.wav");
	precache_sound ("combat/mgunh2.wav");
	precache_sound ("combat/mgunh3.wav");
	precache_sound ("combat/death1.wav");
	precache_sound ("combat/death2.wav");
	precache_sound ("combat/death3.wav");
	precache_sound ("combat/death4.wav");
	precache_sound ("combat/hitped.wav");
	precache_sound ("combat/jump.wav");
	precache_sound ("combat/landmine.wav");
	precache_sound ("combat/shield.wav");
	precache_sound ("combat/cloak.wav");
	precache_sound ("combat/ricochet.wav");
	precache_sound ("combat/freeze.wav");
	precache_sound ("combat/frozen.wav");
	precache_sound ("combat/rw1.wav");
	precache_sound ("combat/rw2.wav");
	precache_sound ("combat/rw3.wav");
	precache_sound ("combat/special.wav");
	precache_sound ("combat/killkill.wav");
	precache_sound ("combat/flamethr.wav");
	precache_sound ("combat/ghstrckt.wav");
	precache_sound ("combat/boomerang.wav");
	precache_sound ("combat/boomerang2.wav");
	precache_sound ("combat/skyscraper.wav");
	precache_sound ("combat/redrage.wav");
	precache_sound ("combat/lawbreaker.wav");
	precache_sound ("combat/lawbreaker2.wav");
	precache_sound ("combat/razorback.wav");
	precache_sound ("combat/mincemeat.wav");
	precache_sound ("combat/splat.wav");
	precache_sound ("combat/tur_deploy.wav");
	precache_sound ("combat/tur_spin.wav");
	precache_sound ("combat/tur_sight.wav");
	precache_sound ("combat/thorogood.wav");

	world_lights();
	load_waypoints(); // Load waypoints
	CSEv_GrabCSQCValues(); //CSQC Setup

	//
	// new console command & cvar stuff
	//
	registercommand("addbot", "Adds a bot to the game, will not spawn if server is full\n");
	registercommand("removebot", "Removes a bot\n");
	
	//ragewar cvar setup
	registercvar("ragewar", "0"); // ragewar on/off
	ragewar = cvar("ragewar");

	// physic cvar setup
	registercvar("sv_car_physics_steps", "4"); // func_vehicle physics steps, higher is more stable with perf hit
	if (substring(world.model, -3, 3) == "hmp") // thanks reki
		cvar_set("sv_car_physics_steps", "1"); // fixes physics steps destroying FPS on heightmap levels
	else
		cvar_set("sv_car_physics_steps", "4"); // set physics step back to default on .bsp maps

	// sv_player_slots cvar setup
	if (!ragewar) // only 4 racers max in race mode
		cvar_set("sv_playerslots", "4");
	else // 10 in ragewar max
		cvar_set("sv_playerslots", "10");
};

//
// Parms
//

void() SetNewParms = {};
void() SetChangeParms = {};
void() DecodeLevelParms ={};

void() StartFrame = 
{
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