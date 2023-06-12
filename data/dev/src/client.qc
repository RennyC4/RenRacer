//+------+
//|Client|
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Handle's "clients" (eg, Players) connecting, disconnecting, etc.           |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() CheckImpulses;
void() ClientKill = {};

void() ClientConnect =
{
	ClientInRankings(); // FrikBot
	bprint (self.netname, " joined the race!\n");
};

void() ClientDisconnect =
{
	ClientDisconnected(); // FrikBot
};

// This is ugly
void() Setup_level_effects =
{
	if (framecount > 10)
		return;

	if (world.model == "maps/map1.bsp")
	{
		stuffcmd (self, "r_sun_colour 0.2 0.2 0.2\n");
		stuffcmd (self, "r_sun_dir -1 0.5 0.8\n");
		stuffcmd (self, "r_waterstyle 3\n");
	}
	else
	{
		stuffcmd (self, "r_sun_colour 0 0 0\n");
		stuffcmd (self, "r_waterstyle 1\n");
		
		if (world.model == "maps/map4.hmp") // Low gravity & RT Lights
		{
			stuffcmd (self, "sv_gravity 600\n");
			stuffcmd (self, "r_shadow_realtime_world 1\n");
		}
		else
			stuffcmd (self, "sv_gravity 1200\n");
	}
};

void() spawn_countdown;
.float turbo_fuel_finished;
void() PlayerPreThink = 
{
	if (BotPreFrame()) // FrikBot
		return;

	if (cvar("developer") == 1) // Coord/Angle reporting, helps insert entities in hmp maps
	{
		local string x,y,z,ang_y,ang_x;
		x = ftos(self.origin_x);
		y = ftos(self.origin_y);
		z = ftos(self.origin_z);
		ang_y = ftos(self.angles_y);
		ang_x = ftos(self.angles_x);

		sprint (self, "X: ", x, "\n");
		sprint (self, "Y: ", y, "\n");
		sprint (self, "Z: ", z, "\n");
		sprint (self, "Angle_Y: ", ang_y, "\n");
		sprint (self, "Angle_X: ", ang_x, "\n");

		return;
	}

	if (framecount == 10)
		Setup_level_effects();

	// Force player in car, give greetings message
	if (!self.driving)
	{
		Car_CheckAttach();
		if (framecount > 75 && self.button0 && race_status == RACE_NOTSTARTED)
		{
			race_status = RACE_COUNTDOWN;
			spawn_countdown(); // Start countdown

			// Spawn car
			sound (self, CHAN_AUTO, "engine/start.wav", 1, ATTN_NORM);

			local entity car = hotrod();
			makevectors(self.angles);
			car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
			Car_InitVehicle(car);

			// Add bots
			local float i;
			local float g = cvar("sv_playerslots");
			for (i = 0; i < g-1; i = i+1)
				BotConnect(0, 0, 0);
		}
	}
	else
	{
		if (self.clearcprint_finished < time)
		{
			if (!self.clearcprint)
			{
				centerprint(self, string_null); // used to clear /P centerprints
				self.clearcprint = TRUE;
			}
		}
		else
			self.clearcprint = FALSE;

		// Slow turbo fuel recharge
		if (self.turbo_fuel < 100)
		{
			if (self.turbo_fuel_finished < time && !self.button2)
			{
				self.turbo_fuel = self.turbo_fuel + 1;
				if (self.ishuman)
					self.turbo_fuel_finished = time + 0.1;
				else
					self.turbo_fuel_finished = time + 0.05; // AI Cheats TODO: Teach them to drift?
			}
		}
		else
			self.turbo_fuel = 100;

		if (self.start_laptime) // turned on by start/finish goal
		{
			if (self.laptime_tic < time)
			{
				self.laptime = self.laptime + 0.01; // count half seconds
				self.laptime_tic = time + 0.01;

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
};

//----
// Select a proper spawn spot
//----

void() racer_spawnpoint = {};
entity() SelectSpawnSpot =
{
	local	entity spot = lastspawn;
	local	entity thing;
	local	float  pcount;
			
	while (1)
	{
		spot = find(spot, classname, "racer_spawnpoint");
		if (spot)
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
			if (!pcount)
			{
				lastspawn = spot;
				return spot;
			}
		}
		else
		{
			spot = find(spot, classname, "info_player_start");
			return spot;
		}
	}
	if (!spot)
		error ("Cannot find entity racer_spawnpoint / info_player_start in map");
	
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

	if (cvar("developer") != 1)
	{
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
	}
	else
		self.movetype = MOVETYPE_NOCLIP;

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

	self.flags = FL_FINDABLE_NONSOLID; // Needed for findradius to find me
	self.angles = spawn_spot.angles;
	self.fixangle = TRUE;
	self.checkpoint = 0;
	self.clearcprint = TRUE;
	self.cardrift_stabilizer = -1;
	self.turbo_fuel = 100;
	if (!cvar("developer"))
		centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________\n\n\nPress [^b^1FIRE^7^b] to start the race");
	
	// Frikbots Insta-spawn as the player does
	if (!self.ishuman)
	{
		local entity car = hotrod();
		makevectors(self.angles);
		car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
		Car_InitVehicle(car);
	}
};