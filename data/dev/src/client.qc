//+------+
//|Client|
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Handle's "clients" (eg, Players) connecting, disconnecting, etc.           |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() CheckImpulses;
void() ClientKill = {};

void(optional float csqcactive) ClientConnect =
{
	ClientInRankings(); // FrikBot
	bprint (self.netname, " joined the race!\n");
};

void() ClientDisconnect =
{
	ClientDisconnected(); // FrikBot
};

void() EngineSounds =
{
	if (time < self.engine_sound_time)
		return;

	if (self.realspeed < 10)
	{
		sound (self, CHAN_BODY, "engine/aa01.wav", 0.25, ATTN_NORM);
		self.engine_sound_time = time + 0.3;
	}
	else if (self.realspeed > 10 && self.realspeed < 15)
		sound (self, CHAN_BODY, "engine/aa02.wav", 0.28, ATTN_NORM);
	else if (self.realspeed > 14 && self.realspeed < 20)
		sound (self, CHAN_BODY, "engine/aa03.wav", 0.30, ATTN_NORM);
	else if (self.realspeed > 19 && self.realspeed < 25)
		sound (self, CHAN_BODY, "engine/aa04.wav", 0.32, ATTN_NORM);
	else if (self.realspeed > 24 && self.realspeed < 30)
		sound (self, CHAN_BODY, "engine/aa05.wav", 0.34, ATTN_NORM);
	else if (self.realspeed > 29 && self.realspeed < 35)
		sound (self, CHAN_BODY, "engine/aa06.wav", 0.36, ATTN_NORM);
	else if (self.realspeed > 34 && self.realspeed < 40)
		sound (self, CHAN_BODY, "engine/aa07.wav", 0.38, ATTN_NORM);
	else if (self.realspeed > 45)
		sound (self, CHAN_BODY, "engine/aa08.wav", 0.40, ATTN_NORM);

	if (!(self.engine_sound_time > time))
		self.engine_sound_time = time + 0.15;
};

.float welcomemsg_finished;
void() PlayerPreThink = 
{
	if (BotPreFrame()) // FrikBot
		return;

	// Force player in car, give greetings message
	if (!self.driving)
	{
		Car_CheckAttach();
		if (self.welcomemsg_finished < time)
		{
			centerprint (self, "Welcome to RenRacer\n\n===================\n\n\nPress [FIRE] to start the race");
			self.welcomemsg_finished = time + 1.5;
		}
		if (framecount > 75 && self.button0 && !race_start)
		{
			//centerprint (self, ""); // clear centerprint
			race_start = TRUE;

			// Spawn car
			local entity car = hotrod();
			makevectors(self.angles);
			car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
			Car_InitVehicle(car);
			
			local float i;
			local float g = cvar("sv_playerslots");
	
			for (i = 0; i < g-1; i = i+1)
			BotConnect(0, 0, 0);
			
			// Start countdown
			countdown_finished = time + 1;
		}
	}
	else
	{
		EngineSounds();

		// Race start countdown
		// TODO: Figure out why centerprint(self, "foo"); doesn't work?
		if (countdown_finished < time && countdown_count > -1)
		{
			local string f = ftos(countdown_count);
			if (countdown_count != 0)
			{
				bprint (f, "\n");
				localsound("cntdwn.wav");
			}
			else
			{
				localsound("gogo.wav");
				self.bot_dontbackup_finished = time + 3; // TODO: Remove me for tracebox
			}
			countdown_count = countdown_count - 1;
			countdown_finished = time + 1;
		}

		if (self.start_laptime) // turned on by start/finish goal
		{
			if (self.laptime_tic_second < time)
			{
				self.laptime = self.laptime + 1; // count seconds
				self.laptime_tic_second = time + 1;

				self.overall_time = self.overall_time + 1;
			}
			if (self.laptime_tic_fastsecond < time)
			{
				self.laptime = self.laptime + 0.01; // count half seconds
				self.laptime_tic_fastsecond = time + 0.01;

				self.overall_time = self.overall_time + 0.01;
			}
		}
	}
};

void() PlayerPostThink =
{
	if (BotPostFrame()) // FrikBot
		return;

	TryUpdateVehicle();
	CheckImpulses();
	
	// Enforce console variables
	if (cvar("chase_active") > 0)
		cvar_set("chase_active", "0");
};

//----
// Select a proper spawn spot
//----

entity() SelectSpawnSpot =
{
	local	entity spot = lastspawn;
	local	entity thing;
	local	float  pcount;
			
	while (1)
	{
		spot = find(spot, classname, "info_player_deathmatch");
		if (spot != world)
		{
			if (spot == lastspawn)
				return lastspawn;

			pcount = 0;

			thing = findradius(spot.origin, 32);
			while(thing)
			{
				if (thing.classname == "player")
					pcount = pcount + 1;
				thing = thing.chain;
			}
			if (pcount == 0)
			{
				lastspawn = spot;
				return spot;
			}
		}
	}

	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("Cannot find spawn point in map");
	
	return spot;
};


//----
// Spawning the Player
//----
void() PutClientInServer =
{
	local entity spawn_spot = SelectSpawnSpot();

	self.classname = "player";
	self.health = self.max_health = 100;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.flags = FL_CLIENT;
	self.origin = spawn_spot.origin;
	
	//func_vehicle
	setmodel (self, "progs/null.spr");
	modelindex_null = self.modelindex;
	stuffcmd(self, "chase_active 1\n");
	stuffcmd(self, "crosshair 0\n");
	//func_vehicle
	
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.view_ofs = '0 0 42'; // Best height for no CSQC chasecam
	self.velocity = '0 0 0';
	self.modelindex = 0;

	self.angles = spawn_spot.angles;
	self.fixangle = TRUE;

	self.hitme = "TRUE"; // Allow searchradius to look for me
	self.checkpoint = 0;
	
	// Frikbots Insta-spawn as the player does
	if (!self.ishuman)
	{
		local entity car = hotrod();
		makevectors(self.angles);
		car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
		Car_InitVehicle(car);
	}
};