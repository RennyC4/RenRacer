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
	precache_model("progs/frzsmk.spr");
	precache_model("progs/frzsmk2.spr");
	precache_model("progs/frozen.mdl");

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
	precache_sound ("combat/jump.wav");
	precache_sound ("combat/landmine.wav");
	precache_sound ("combat/shield.wav");
	precache_sound ("combat/cloak.wav");
	precache_sound ("combat/ricochet.wav");
	precache_sound ("combat/freeze.wav");
	precache_sound ("combat/frozen.wav");

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

	// FIXME/TODO: FTE engine bug dimension_solid/hit is broken?
	// Remove the !deathmatch conditional when bug is fixed.
	if (!deathmatch)
	{
		player_dimension_hit = 0;
		player_dimension_solid = 0; 
	}
	else
	{
		player_dimension_hit = FLAG_1;
		player_dimension_solid = FLAG_2;
	}
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

//
// Radar by Reki
//

enum NETENTITY:float {
	NULL,
	RADARBLIP,
};

// SSQC
float SendEntity_RadarBlip(entity to, float sendflags) // in this, "to" is the client being sent the data and "self" is the entity being networked
{
	if (to == self.owner) // don't send the player their own blip
		return FALSE;

	WriteByte(MSG_ENTITY, NETENTITY::RADARBLIP);
	WriteByte(MSG_ENTITY, sendflags);

	if (sendflags & 0x01) // send coordinates (where the blip will show)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
	}

	if (sendflags & 0x02) // send color, you can replace this with colormod x y z or something
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.owner) - 1); // player index
	}

	return TRUE;
}

void Think_RadarBlip()
{
	if !(self.owner) // if we don't have an owner, we don't need to update since we won't be moving!
		return;
	if (self.owner.cloak_finished > time)
		return;

	setorigin(self, self.owner.origin);
	self.SendFlags |= 0x01; // tell the SendEntity to update our coordinates on the client

	self.think = Think_RadarBlip;
	frameskip(0.01);
}

entity Spawn_RadarBlip(entity player)
{
	entity blip = spawn();
	blip.SendEntity = SendEntity_RadarBlip; // use our SendEntity for networking
	blip.SendFlags = 0x03; // tell it to send both coordinates and color for initial state
	blip.pvsflags = PVSF_IGNOREPVS; // never cull via pvs for the network

	// start think loop
	blip.think = Think_RadarBlip;
	blip.nextthink = time + 0.1;

	// initial state
	blip.owner = player;
	blip.colormap = player.colormap;
	blip.origin = player.origin;

	return blip;
}