//+------+
//|Client|
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Handle's "clients" (eg, Players) connecting, disconnecting, etc.           |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() CheckImpulses;
void(float type) CarAttack;
void(vector position) CreateExplosion;
void() ClientKill = {};

void() ClientConnect =
{
	ClientInRankings(); // FrikBot
	bprint (self.netname, " joined the race!\n");
};

void() ClientDisconnect =
{
	bprint (self.netname, " has retired!\n");
	ClientDisconnected(); // FrikBot
	remove_car(self.driving);
	remove(self);
};

// This is ugly
void() Setup_level_effects =
{
	if (framecount > 10)
		return;

	if (world.model == "maps/map1.bsp" || world.model == "maps/map5.bsp")
	{
		stuffcmd (self, "r_sun_colour 0.2 0.2 0.2\n");
		stuffcmd (self, "r_sun_dir -1 0.5 0.8\n");
		if (world.model == "maps/map5.bsp")
			stuffcmd (self, "r_waterstyle 1\n"); // Needed otherwise breakage
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
		if (world.model == "maps/map6.hmp") // Temproary FIXME/TODO: Remove this
		{
			self.effects = EF_BRIGHTFIELD;
		}
	}
};

//
// RennyC: Work in progress to fake push other cars/players out of the way
//
void() PushPlayers =
{
	if (self.collide_finished > time)
		return;

	for (entity b = world;(b = find(b, classname, "player"));)
	{
		if (vlen(b.origin - self.origin ) < 100 && b != self && b.driving && self.realspeed > 9 && self.health > 0 && b.health > 0)
		{
			entity wheels[] =
			{
				b.driving.frontleft,
				b.driving.frontright,
				b.driving.backleft,
				b.driving.backright
			};

			// TODO: Find a better way to 'bump' players - Start

			for (float i = 0; i < wheels.length; i++)
			{
				traceline(wheels[i].origin, wheels[i].origin - wheels[i].lmat_up * 24, MOVE_NOMONSTERS, wheels[i]);
				if (trace_fraction < 1)
					Phys_Force(self.driving, self.driving.physobj_mass, '0 0 1' * 240 * 1.0, trace_endpos, wheels[i].lmat_up);
			}
			vector worldorg = self.driving.origin;

			local vector ran = '0 0 0';
			ran_y = random()*360;
			makevectors(ran);
			if (random() < 0.5)
				Phys_Force(self.driving, self.driving.physobj_mass * 0.35, (v_right * 10000 * -1) * frametime, worldorg - v_right * 16, -v_right);
			else
				Phys_Force(self.driving, self.driving.physobj_mass * 0.35, v_right * 10000 * frametime, worldorg + v_right * 16, +v_right);
			
			// TODO: Find a better way to 'bump' players - End
			
			b.collide_finished = time + 1;
			self.collide_finished = time + 1;

			if (random() < 0.25)
				sound (self, CHAN_AUTO, "hit1.wav", 1, ATTN_NORM);
			else if (random() < 0.5)
				sound (self, CHAN_AUTO, "hit2.wav", 1, ATTN_NORM);
			else if (random() < 0.75)
				sound (self, CHAN_AUTO, "hit3.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_AUTO, "hit4.wav", 1, ATTN_NORM);
		}
	}
};

void() spawn_car_countdown;
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
		Car_CheckAttach(); // Shove the player in the car
		if (framecount > 75 && (self.button0 || self.button3 || self.button4) && race_status == RACE_NOTSTARTED)
		{
			spawn_car_countdown(); // Start countdown
			race_status = RACE_COUNTDOWN;
			sound (self, CHAN_AUTO, "engine/start.wav", 1, ATTN_NORM);
		}
	}
	else
	{
		if (race_status == RACE_STARTED)
			PushPlayers();

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
				self.turbo_fuel_finished = time + 0.1;
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

void() snailtrail_think =
{
	if (!self.owner)
	{
		remove(self);
		return;
	}

	local float len = vlen(self.origin - self.owner.origin);
	if (len > 800) // Update trail origin
	{
		self.angles = self.owner.angles;
		setorigin(self, self.owner.origin);
	}

	frameskip(0.1);
};

void() RespawnPlayer =
{
	self.health = self.max_health;
	self.colormod = '0 0 0';
	self.deathcount = 0;
	car_teleport(self.spawn_loc,FALSE);
	self.invulnerable_finished = time + 3; // disallow damage / firing
};

void() PlayerPostThink =
{
	if (BotPostFrame()) // FrikBot
		return;

	if (!deathmatch) // racing
	{
		if (self.ishuman && race_status == RACE_STARTED && self.driving) // Player snail trail waypoint
		{
			if (!self.trail)
			{
				local entity trail1 = spawn();
				trail1.owner = self;
				self.trail = trail1;
				trail1.classname = "trail1";
				setorigin (trail1, self.origin);
				if (cvar("developer") == 2)
				{
					setmodel (trail1, "progs/s_debug.spr");
					trail1.colormod = '1 10 10';
				}
				else
					setmodel (trail1, "progs/null.spr");

				setsize (trail1, '0 0 0', '0 0 0');

				trail1.think = snailtrail_think;
				trail1.nextthink = time + 0.1;
			}
			else
			{
				makevectors(self.v_angle);
				local float len = vlen(self.origin - self.trail.origin);

				if (infront2(self.trail, 0.3) || len < 250) // Removed visible();
					self.trail.cnt = FALSE; // Frikbots can't teleport if the snail trail is being looked at
				else
					self.trail.cnt = TRUE;
				//bprint ("Self.Trail.Cnt = ", ftos(self.trail.cnt), "\n");
			}
		}
	}
	else // deathmatch
	{
		if (self.health > 0)
		{
			// Smooth restore colormod
			if (self.colormod_x > 1)
				self.colormod_x = self.colormod_x - 6 * frametime;
			else
				self.colormod_x = 0;

			if (self.colormod_y > 1)
				self.colormod_y = self.colormod_y - 6 * frametime;
			else
				self.colormod_y = 0;

			if (self.colormod_z > 1)
				self.colormod_z = self.colormod_z - 6 * frametime;
			else
				self.colormod_z = 0;
		}
		else // death animation / thinking
		{
			self.colormod = '0.1 0.1 0.1'; // car is cooked/black on death
			if (self.deathcount == 3 || self.deathcount == 6 || self.deathcount == 9 || self.deathcount == 12)
				CreateExplosion(self.origin);
			if (self.deathcount_finished < time)
			{
				if (self.deathcount < 30)
				{
					self.deathcount = self.deathcount + 1;
					self.deathcount_finished = time + 0.1;
				}
				else
					RespawnPlayer();
			}
		}
	}

	if (self.alpha < 1) // Smooth restore player transparency
		self.alpha = self.alpha + 0.4 * frametime;
	
	//
	// Get liquid level - RennyC
	//
	local float contents = 0;
	local vector point = self.origin;

	point_z = point_z + self.mins_z + 1; // get the minimum water depth (waterlevel 1)
	contents = pointcontents(point);
	if (contents >= CONTENT_LAVA && contents <= CONTENT_WATER)
		self.waterlevel = 1;
	else
		self.waterlevel = 0;

	if (self.waterlevel > 0 && self.health > 0 || self.invulnerable_finished > time)
		self.effects |= EF_BRIGHTFIELD;
	else
		self.effects &= ~(EF_BRIGHTFIELD);

	if (self.driving && deathmatch && self.health > 0 && self.invulnerable_finished < time && race_status == RACE_STARTED)
	{
		if (self.button3)
			CarAttack(0);
		if (self.button4)
			CarAttack(1);
	}

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
	self.checkpoint_lastpos = self.origin + v_up * 64;
	self.spawn_loc = self.origin + v_up * 64; // Stash it
	self.spawn_loc_angles = self.angles; // Stash it
	self.alpha = 1;

	if (cvar("developer") != 1)
	{
		if (!deathmatch)
			centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________\n\n\nPress [^b^1FIRE^7^b] to start the race");
		else
			centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\n\nPress [^b^1FIRE^7^b] to unleash carnage");
	}
};