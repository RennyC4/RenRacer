//+------+
//|Client|
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Handle's "clients" (eg, Players) connecting, disconnecting, etc.           |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() CheckImpulses;
void(float type, float rear) CarAttack;
void(vector position) CreateExplosion;
void(vector position, float scale) Create2DExplosion;
void(entity targ, entity attacker, float damage, string attackerclassname) DoDamage;
void() CommandSpecials;
void() SpecialRegenerate;

void() ClientKill = {};

void() ClientConnect =
{
	if (intermission_running) // a client connecting during an intermission can cause problems
		GotoNextMap();
	if (!ragewar)
		bprint (self.netname, " joined the race!\n");
	else
		bprint (self.netname, " has come to hunt!\n");
};

void() ClientDisconnect =
{
	if (clienttype(self) == CLIENTTYPE_REAL && human_players > 0)
	{
		human_players = human_players - 1;
		for (entity targ = world;(targ = find(targ, classname, "player"));)
		{
			if (targ.player_id != 1)
				targ.player_id = targ.player_id - 1; // only player_id 1 can add/remove bots
			if (targ.player_id < 1) // this shouldn't happen, but let's be sure
				targ.player_id = 1;
		}
	}
	if (gameover)
		return;
	if (self.observer)
		bprint (self.netname, " stopped observing\n");
	else
	{
		if (!ragewar)
			bprint (self.netname, " has retired!\n");
		else
			bprint (self.netname, " has chickened out with ", ftos(self.frags), " frags!\n");
	}

	if (!self.observer)
	{
		if (self.fire)
			remove(self.fire);
		if (self.frozen)
			remove(self.frozen);
		if (self.driving)
			remove_car(self.driving);
	}
	// Clear fields on disconnect
	self.spawncar = FALSE;
	self.deadflag = FALSE;
	self.deathcount = 0;
	self.ammo_firerocket = self.ammo_homingrocket = self.ammo_powerrocket = self.ammo_napalm = self.ammo_rico = self.ammo_remote = self.ammo_freeze = 0;
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
	}
};

//
// RennyC: Fake push other cars/players out of the way, includes turbo ramming damage
//

void() PushPlayers =
{
	if (self.frozen_finished > time || self.invulnerable_finished > time)
		return;

	for (entity b = world;(b = find(b, classname, "player"));)
	{
		if (vlen(b.origin - self.origin) <= 100 && b != self && b.driving && b.health > 0 && b.invulnerable_finished < time)
		{
			if (self.realspeed >= 10 && self.realspeed > b.realspeed)
			{
				if (ragewar)
				{
					if (self.vehicle != VEH_SKYSCRAPER)
					{
						b.forcejump_strength = 240 + (self.realspeed * 2);
						b.forcejump = TRUE;
					}
					else if (self.turbo) // skyscraper jumps on turbo hit
					{
						self.forcejump_strength = 240 + (self.realspeed * 2);
						self.forcejump = TRUE;
					}
				}
				else
				{
					b.forcejump_strength = 240 + (self.realspeed * 2);
					b.forcejump = TRUE;
				}
				
				if (random() < 0.25)
					sound (self, CHAN_AUTO, "hit1.wav", 1, ATTN_NORM);
				else if (random() < 0.5)
					sound (self, CHAN_AUTO, "hit2.wav", 1, ATTN_NORM);
				else if (random() < 0.75)
					sound (self, CHAN_AUTO, "hit3.wav", 1, ATTN_NORM);
				else
					sound (self, CHAN_AUTO, "hit4.wav", 1, ATTN_NORM);
			}

			if (ragewar)
			{
				if (self.turbo)
				{
					// target damage
					float dmg = floor(self.realspeed / 32) + floor(self.max_health / 5);
					DoDamage(b, self, dmg, "ramming");

					// self damage
					dmg = floor(dmg / 4);
					if (self.vehicle != VEH_SKYSCRAPER)
						DoDamage(self, self, dmg, "ramming");

					if (self.vehicle == VEH_SKYSCRAPER && self.ammo_special > 0 && b.health > 0)
					{
						sound (self, CHAN_AUTO, "combat/skyscraper.wav", 1, ATTN_NORM);

						self.forcejump_strength = 240 + (self.realspeed * 2);
						self.forcejump = TRUE;
						dmg = 15; // extra 15 damage
						DoDamage(b, self, dmg, "skyscraper");
						self.ammo_special -= 1;
					}
				}
			}

			// Fire stuff on car touch
			if (self.onfire_finished > time)
			{
				b.onfire_finished = time + 2.5;
				b.igniter = self.igniter;
			}
			if (b.onfire_finished > time)
			{
				self.onfire_finished = time + 2.5;
				self.igniter = b.igniter;
			}

			// Stop player thats doing the ramming
			// FIXME: Let this work in race mode, but fix the AI backing up stuff
			if (ragewar)
			{
				entity part = self.driving.physobj_particlelist;
				while(part)
				{
					part.velocity = part.velocity / 1000;
					part = part.physobj_next;
				}
			}
			self.collide_finished = time + 1;
		}
	}
};

// Instances that can force the car to jump (example: being hit by a rocket)
void() ForceJump =
{
	entity wheels[] = {
		self.driving.frontleft,
		self.driving.frontright,
		self.driving.backleft,
		self.driving.backright
	};
	for (float i = 0; i < wheels.length; i++)
	{	
		traceline(wheels[i].origin, wheels[i].origin - wheels[i].lmat_up * 32, MOVE_NOMONSTERS, wheels[i]);
		if (trace_fraction < 1)
			Phys_Force(self.driving, self.driving.physobj_mass, '0 0 1' * self.forcejump_strength, trace_endpos, wheels[i].lmat_up);
	}
};

void() spawn_car_countdown;
entity() SelectSpawnSpot;
.float turbo_fuel_finished;
.float energy_finished;
void() PlayerPreThink = 
{
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

	CheckGameRules(); // misc.qc

	if (framecount == 10)
		Setup_level_effects();

	// Force player in car, give greetings message
	if (!self.driving || (self.observer && ragewar))
	{
		if (ragewar)
		{
			if (race_status == RACE_NOTSTARTED || self.observer)
			{
				// Print welcome message
				if (self.vehicle == VEH_HOTROD)
					centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1HotRod^7\nSpecial Weapon: ^5Flame Thrower^7\n\nSpecial: [**** ]\nSpeed: [**   ]\nHandling: [**   ]\nArmor: [***  ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
				if (self.vehicle == VEH_WRAITH)
					centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Wraith^7\nSpecial Weapon: ^5Spectral Missile^7\n\nSpecial: [***  ]\nSpeed: [**** ]\nHandling: [**** ]\nArmor: [*    ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
				if (self.vehicle == VEH_ROADBASTARD)
					centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Road Bastard^7\nSpecial Weapon: ^5Boomerang^7\n\nSpecial: [***  ]\nSpeed: [***  ]\nHandling: [***  ]\nArmor: [***  ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
				if (self.vehicle == VEH_SKYSCRAPER)
					centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Sky Scraper^7\nSpecial Weapon: ^5Big Crush^7\n\nSpecial: [*****]\nSpeed: [*    ]\nHandling: [*    ]\nArmor: [*****]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
				if (self.vehicle == VEH_REDRAGE)
					centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Red Rage^7\nSpecial Weapon: ^5Crimson Beam^7\n\nSpecial: [**   ]\nSpeed: [*****]\nHandling: [*****]\nArmor: [*     ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
				if (self.vehicle == VEH_LAWBREAKER)
					centerprint (self, "/P^3Welcome to RenRacer: Rage War^7\n__________________________________\n\nVehicle: ^1Law Breaker^7\nSpecial Weapon: ^5Tazer Shock^7\n\nSpecial: [***  ]\nSpeed: [**** ]\nHandling: [***  ]\nArmor: [**    ]\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to unleash carnage");
			}
		}
		else if (!self.observer)
		{
			if (race_status == RACE_NOTSTARTED)
			{
				if (self.vehicle == VEH_HOTROD)
					centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1HotRod^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
				if (self.vehicle == VEH_WRAITH)
					centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Wraith^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
				if (self.vehicle == VEH_ROADBASTARD)
					centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Road Bastard^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
				if (self.vehicle == VEH_SKYSCRAPER)
					centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Sky Scraper^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
				if (self.vehicle == VEH_REDRAGE)
					centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Red Rage^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
				if (self.vehicle == VEH_LAWBREAKER)
					centerprint (self, "/P^3Welcome to RenRacer^7\n__________________________________\n\nVehicle: ^1Law Breaker^7\n\nPress [^b^4CYCLE WEAPON^7^b] to swap cars\nPress [^b^1FIRE^7^b] to start the race");
			}
		}
		Car_CheckAttach(); // Shove the player in the car
		if (framecount > 75 && (self.button0 || self.button3 || self.button4))
		{
			centerprint(self, ""); // clear any centerprints
			if (race_status == RACE_NOTSTARTED)
			{
				spawn_car_countdown(); // Start countdown
				race_status = RACE_COUNTDOWN;
				sound (self, CHAN_AUTO, "engine/start.wav", 1, ATTN_NORM);
			}
			if (ragewar && self.observer) // Allow player to join in mid-game
			{
				self.observer = FALSE; // important!
				entity spawn_spot = SelectSpawnSpot();
				self.origin = spawn_spot.origin;

				// Put car in game
				if (self.vehicle == VEH_HOTROD)
					entity car = hotrod();
				if (self.vehicle == VEH_WRAITH)
					car = wraith();

				makevectors(self.angles);
				car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
				Car_InitVehicle(car);
				self.spawncar = TRUE;
				Spawn_RadarBlip(self);

			}
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

		// Turbo fuel recharge
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

		// Energy recharge
		if (self.energy < 100)
		{
			if (self.energy_finished < time)
			{
				self.energy = self.energy + 1;
				self.energy_finished = time + 0.2;
			}
		}
		else
			self.energy = 100;

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
	self.igniter = world;
	self.onfire_finished = time;
	self.frozen_finished = time;
	self.energy = 100;
	self.enemy_displayname = "";
	self.enemy_displayhealth = 0;
	self.enemy_displaymaxhealth = 0;
	car_teleport(self, self.spawn_loc, FALSE, TRUE);
	self.invulnerable_finished = time + 5; // disallow damage / firing
	centerprint(self, "");
	self.clearcprint_finished = time + 0.1;
};

void() fire_think =
{
	if (self.animation_finished < time)
	{
		if (self.frame < 9)
			self.frame = self.frame + 1;
		else
			self.frame = 0;
		self.animation_finished = time + 0.05;
	}
	if (self.sound_finished < time)
	{
		sound (self, CHAN_AUTO, "combat/fire.wav", 0.5, ATTN_NORM);
		self.sound_finished = time + 1;
	}
	setorigin(self, self.owner.origin + v_up * 52);
	frameskip(0.01);
};

void() freeze_think =
{
	if (self.cnt)
	{
		if (self.alpha > 0)
			self.alpha = self.alpha - (0.2 * frametime);
		else
		{
			self.owner.frozen = world;
			remove(self);
			return;
		}
		setorigin(self, self.owner.origin);
		frameskip(0.01);
		return;
	}
	if (self.owner.invulnerable_finished > time || self.owner.frozen_finished < time)
		self.cnt = TRUE;

	self.alpha = 0.75 + sin(time*8)*0.25;
	self.colormod_x = 1 + sin(time*8)*0.25; // glow pallet
	self.colormod_y = 1 + sin(time*8)*0.25; // glow pallet
	self.colormod_z = 3 + sin(time*8)*0.25; // glow pallet
	setorigin(self, self.owner.origin);
	frameskip(0.01);
};

void() PlayerPostThink =
{
	if (clienttype(self) == CLIENTTYPE_BOT)
		BotAI();

	if (intermission_running)
	{
		self.onfire_finished = time;
		centerprint(self, "");
		IntermissionThink ();
		return;
	}
	if (self.observer)
	{
		if (self.movetype != MOVETYPE_NOCLIP)
			self.movetype = MOVETYPE_NOCLIP;
		return;
	}

	if (race_status == RACE_STARTED && !intermission_running && self.health > 0 && self.driving)
	{
		if (self.collide_finished < time)
			PushPlayers();
		SpecialRegenerate();
	}
	if (self.forcejump)
	{
		ForceJump();
		self.forcejump_strength = 0;
		self.forcejump = FALSE;
	}

	if (!ragewar) // racing
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
	else // ragewar
	{
		if (self.health > 0)
		{
			// Smooth restore colormod
			if (self.colormod_x > 1) // red
				self.colormod_x = self.colormod_x - 6 * frametime;
			else
				self.colormod_x = 0;

			if (self.colormod_y > 1) // green
				self.colormod_y = self.colormod_y - 6 * frametime;
			else
				self.colormod_y = 0;

			if (self.frozen_finished < time)
			{
				if (self.colormod_z > 1) // blue
					self.colormod_z = self.colormod_z - 6 * frametime;
				else
					self.colormod_z = 0;
			}
		}
		else // death animation / thinking
		{
			if (self.deadflag)
			{
				if (self.deathcount_finished < time)
				{
					if (!self.deathcount)
					{
						float tt = ceil(random() * 3);
						if (tt == 1)
							sound(self, CHAN_AUTO, "combat/death1.wav", 1, ATTN_NORM);
						else if (tt == 2)
							sound(self, CHAN_AUTO, "combat/death2.wav", 1, ATTN_NORM);
						else if (tt == 3)
							sound(self, CHAN_AUTO, "combat/death3.wav", 1, ATTN_NORM);
						else
							sound(self, CHAN_AUTO, "combat/death4.wav", 1, ATTN_NORM);

						Create2DExplosion(self.origin + v_up * 64, 10);
						self.onfire_finished = time + 9999; // cars on fire
					}
					self.colormod = '0.05 0.05 0.05'; // car is cooked/black on death
					if (self.deathcount == 3 || self.deathcount == 6 || self.deathcount == 9 || self.deathcount == 12)
						CreateExplosion(self.origin);
					if (self.deathcount < 30)
						self.deathcount = self.deathcount + 1;
					else
					{
						centerprint(self, "/P^1^b!!! YOU'RE DEAD !!!^7^b\n\n\nPress [^1^bFire^b^7] to Respawn\n");
						if (self.button3 || self.button4)
							RespawnPlayer();
					}
					self.deathcount_finished = time + 0.1;
				}
			}
		}
	}

	if (self.cloak_finished < time)
	{
		if (self.alpha < 1) // Smooth restore player transparency
			self.alpha = self.alpha + 0.4 * frametime;
	}
	else // cloak logic
	{
		if (self.alpha > 0.3)
			self.alpha = self.alpha - 0.75 * frametime;
		else
			self.alpha = 0.3; // cloak transparency
	}

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

	// EF_BRIGHTFIELD effects handler
	if (!ragewar)
	{
		if (self.waterlevel > 0)
			self.effects |= EF_BRIGHTFIELD;
		else
			self.effects &= ~(EF_BRIGHTFIELD);
	}
	else
	{
		if (self.invulnerable_finished > time)
		{
			if (self.onfire_finished > time)
				self.onfire_finished = time; // water removes napalm/fire
			self.effects |= EF_BRIGHTFIELD;
		}
		else
			self.effects &= ~(EF_BRIGHTFIELD);

		if (self.onfire_finished > time && self.waterlevel > 0)
			self.onfire_finished = time; // water removes napalm/fire
	}

	if (self.driving && ragewar && self.health > 0 && self.invulnerable_finished < time && race_status == RACE_STARTED)
	{
		if (self.button3)
			CarAttack(0, FALSE);
		if (self.button4)
			CarAttack(1, FALSE);
	}

	// on fire
	if (self.onfire_finished > time)
	{
		if (self.health > 0)
		{
			centerprint (self, "You're on fire!\n");
			if (self.onfire_tic < time)
			{
				float firedmg = ceil(random()*3 + 3);
				DoDamage(self, self.igniter, firedmg, "napalmfire");
				self.onfire_tic = time + 1;
			}
		}
		if (!self.fire)
		{
			entity fire1 = spawn();
			fire1.owner = self;
			self.fire = fire1;
			fire1.classname = "fire1";
			fire1.scale = 3;
			fire1.effects = EF_ADDITIVE | EF_FULLBRIGHT;
			fire1.alpha = 0.5;
			fire1.colormod = '2 2 2'; // brighter
			fire1.movetype = MOVETYPE_NOCLIP;
			fire1.solid = SOLID_SLIDEBOX; // spawn_color_glow hack
			fire1.dimension_hit = fire1.dimension_solid = 0;
			fire1.frame = random()*8;
			setorigin (fire1, self.origin + v_up * 52);
			setmodel (fire1, "progs/fire.spr");
			setsize (fire1, '0 0 0', '0 0 0');
			fire1.think = fire_think;
			fire1.nextthink = time;
			spawn_color_glow(3, 1.25, 1, 100, fire1); // dynamic light
		}
	}
	else
	{
		if (self.fire)
		{
			remove(self.fire);
			self.fire = world;
		}
	}

	// in ice
	if (self.frozen_finished > time)
	{
		if (!self.frozen)
		{
			entity freeze1 = spawn();
			freeze1.owner = self;
			self.frozen = freeze1;
			freeze1.classname = "freeze1";
			freeze1.scale = 3;
			freeze1.effects = EF_ADDITIVE | EF_FULLBRIGHT;
			freeze1.alpha = 0.5;
			freeze1.colormod = '1 1 1';
			freeze1.movetype = MOVETYPE_NOCLIP;
			freeze1.solid = SOLID_SLIDEBOX; // spawn_color_glow hack
			freeze1.dimension_hit = freeze1.dimension_solid = 0;
			freeze1.angles_x = random()*360;
			freeze1.angles_y = random()*360;
			freeze1.angles_z = random()*360;
			setorigin (freeze1, self.origin);
			setmodel (freeze1, "progs/frozen.mdl");
			setsize (freeze1, '0 0 0', '0 0 0');
			freeze1.think = freeze_think;
			freeze1.nextthink = time;
			spawn_color_glow(1, 1, 3, 100, freeze1); // dynamic light
			sound (freeze1, CHAN_AUTO, "combat/frozen.wav", 1, ATTN_NORM);
		}
	}

	TryUpdateVehicle();

	//
	// SPECIAL MOVE MOTIONS: Record keys if pressed, set timer till key is cleared
	//

	if (self.keyflags & KEY_UP)
	{
		if (self.FL_MP1PRESSED == FALSE)
		{
			self.moveprog1 = self.moveprog1 + 1; // increase counter
			self.moveprog1_finished = time + 0.2; // time till cleared
		}
		self.FL_MP1PRESSED = TRUE;
	}
	else if (!(self.keyflags & KEY_UP))
		self.FL_MP1PRESSED = FALSE;

	if (self.keyflags & KEY_DOWN)
	{
		if (self.FL_MP2PRESSED == FALSE)
		{
			self.moveprog2 = self.moveprog2 + 1; // increase counter
			self.moveprog2_finished = time + 0.2; // time till cleared
		}
		self.FL_MP2PRESSED = TRUE;
	}
	else if (!(self.keyflags & KEY_DOWN))
		self.FL_MP2PRESSED = FALSE;

	if (self.keyflags & KEY_LEFT)
	{
		if (self.FL_MP3PRESSED == FALSE)
		{
			self.moveprog3 = self.moveprog3 + 1; // increase counter
			self.moveprog3_finished = time + 0.2; // time till cleared
		}
		self.FL_MP3PRESSED = TRUE;
	}
	else if (!(self.keyflags & KEY_LEFT))
		self.FL_MP3PRESSED = FALSE;

	if (self.keyflags & KEY_RIGHT)
	{
		if (self.FL_MP4PRESSED == FALSE)
		{
			self.moveprog4 = self.moveprog4 + 1; // increase counter
			self.moveprog4_finished = time + 0.2; // time till cleared
		}
		self.FL_MP4PRESSED = TRUE;
	}
	else if (!(self.keyflags & KEY_RIGHT))
		self.FL_MP4PRESSED = FALSE;

	if (self.moveprog1_finished < time)
		self.moveprog1 = 0;
	if (self.moveprog2_finished < time)
		self.moveprog2 = 0;
	if (self.moveprog3_finished < time)
		self.moveprog3 = 0;
	if (self.moveprog4_finished < time)
		self.moveprog4 = 0;

	// Debugging
	/*
	string s = ftos(self.moveprog1);
	bprint ("MP Up: ", s);
	s = ftos(self.moveprog2);
	bprint (" MP Down: ", s);
	s = ftos(self.moveprog3);
	bprint (" MP Left: ", s);
	s = ftos(self.moveprog4);
	bprint (" MP Right: ", s, "\n");
	*/
	
	CommandSpecials();

	//
	// SPECIAL MOVE MOTIONS: Reset keys if timer is dropped
	//

	CheckImpulses();
};

//----
// Select a proper spawn spot
//----

void() racer_spawnpoint = {};
void() dm_spawnpoint = {};
entity() SelectSpawnSpot =
{
	local	entity spot = lastspawn;
	local	entity thing;
	local	float  pcount;

	if (!ragewar)
	{
		while (1)
		{
			spot = find(spot, classname, "racer_spawnpoint");
			if (spot)
			{
				if (spot == lastspawn)
					return lastspawn;
				pcount = 0;
				thing = findradius(spot.origin, 64);
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
	}
	else
	{
		spot = lastspawn;
		while (1)
		{
			spot = find(spot, classname, "dm_spawnpoint");
			if (spot != world)
			{
				if (spot == lastspawn)
					return lastspawn;
				pcount = 0;
				thing = findradius(spot.origin, 64);
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
	}

	if (!spot)
		error ("Cannot find spawnpoint on map");

	return spot;
};

//----
// Spawning the Player
//----

void() PutClientInServer =
{
	entity spawn_spot = SelectSpawnSpot();

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
	self.car_stabilizer = -1;
	self.turbo_fuel = 100;
	self.checkpoint_lastpos = self.origin + v_up * 64;
	self.spawn_loc = self.origin + v_up * 64; // Stash it
	self.spawn_loc_angles = self.angles; // Stash it
	self.alpha = 1;
	self.energy = 100;

	self.weapon = WEP_SPECIAL;
	//self.ammo_special = 1;

	if (clienttype(self) == CLIENTTYPE_REAL)
		human_players = human_players + 1;
	else // Bots just randomly select whatever vehicle
	{
		float tt = ceil(random() * 6);
		if (tt == 1)
			self.vehicle = VEH_HOTROD;
		else if (tt == 2)
			self.vehicle = VEH_WRAITH;
		else if (tt == 3)
			self.vehicle = VEH_ROADBASTARD;
		else if (tt == 4)
			self.vehicle = VEH_SKYSCRAPER;
		else if (tt == 5)
			self.vehicle = VEH_REDRAGE;
		else
			self.vehicle = VEH_LAWBREAKER;
	}
	self.player_id = human_players;

	if (cvar("developer") != 1)
	{
		if (race_status != RACE_NOTSTARTED)
		{
			if (!ragewar) // race is on, shove new player as observer
			{
				if (clienttype(self) == CLIENTTYPE_REAL)
					self.observer = TRUE;
			}
			else
			{
				if (!self.spawncar) // Joined mid-ragewar game, TODO: Add vehicle selection stuff for players
				{
					// Bots just randomly select whatever vehicle
					if (clienttype(self) == CLIENTTYPE_BOT)
					{
						if (random() < 0.5)
							entity car = hotrod();
						else
							car = wraith();
						makevectors(self.angles);
						car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
						Car_InitVehicle(car);
						self.spawncar = TRUE;
						Spawn_RadarBlip(self);
					}
					else // Present player with the menu
						self.observer = TRUE;
					
					// Start music on player mid-game join
					if (world.model == "maps/dm1.bsp")
						self.music = "sound/music/dm1.ogg";
					if (checkextension("DP_QC_SPRINTF"))
						stuffcmd (self, sprintf("music %s\n", self.music));
				}
			}
		}
	}

	// grab ragewar from server
	ragewar = cvar("ragewar");
};