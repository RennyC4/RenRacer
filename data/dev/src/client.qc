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
void(vector position, float size) Create2DFreezeExplosion;

void() ClientKill =
{
	if (ragewar)
		DoDamage(self, self, self.health, self.classname);
};

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
	self.weapon = WEP_SPECIAL;
	self.music = "";
	self.max_colormod = 1;
	self.ammo_firerocket = self.ammo_homingrocket = self.ammo_powerrocket = self.ammo_napalm = self.ammo_rico = self.ammo_remote = self.ammo_freeze = 0;
};

// This is ugly
void() Setup_level_effects =
{
	if (framecount > 10)
		return;

	if (world.model == "maps/map1.bsp" || world.model == "maps/map5.bsp" || world.model == "maps/dm3.bsp")
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
// RennyC: Fake push other cars/players out of the way, includes turbo/drifting ramming damage
//         Note: collision_finished is used to disable collisions from occuring for x time
//

void() PushPlayers =
{
	if (self.frozen_finished > time || self.invulnerable_finished > time || self.collide_finished > time || self.health < 1)
		return;

	for (entity b = world;(b = find(b, classname, "player"));)
	{
		if (vlen(b.origin - self.origin) <= 100 && b != self && b.invulnerable_finished < time && !b.observer && b.health > 0)
		{
			if (self.realspeed > b.realspeed)
			{
				if (ragewar && self.turbo)
				{
					if (self.vehicle != VEH_SKYSCRAPER)
					{
						b.forcejump_strength = ceil(200 + (self.realspeed * 1.75));
						b.forcejump = TRUE;
					}
					else if (self.drift) // only skyscraper jumps on turbo/drift hit
					{
						self.forcejump_strength = ceil(200 + (self.realspeed * 1.75));
						self.forcejump = TRUE;
					}
				}

				if (self.collide_finished < time)
				{
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

			// damage routine - ramming
			if (ragewar)
			{
				if (!self.backward && (self.turbo || self.drift))
				{
					// RennyC: Run SkyScraper's special before regular vehicle damage is done
					if (self.vehicle == VEH_SKYSCRAPER && self.ammo_special > 0 && b.health > 0)
					{
						sound (self, CHAN_AUTO, "combat/skyscraper.wav", 1, ATTN_NORM);
						DoDamage(b, self, 15, "skyscraper"); // extra 15 damage
						if (self.ammo_special > 0)
							self.ammo_special -= 1;
					}

					// calculate regular ramming damage
					float dmg = floor(self.realspeed / 32) + floor(self.max_health / 5);
					float dmg2 = ceil(dmg / 2); // RennyC: Ramming damage was reportedly too high
					DoDamage(b, self, dmg2, "ramming");

					// self damage
					dmg = floor(dmg / 4);
					if (self.vehicle != VEH_SKYSCRAPER) // skyscraper doesn't suffer from ramming damage
						DoDamage(self, self, dmg, "ramming");
				}
			}

			// Fire spreading on car touch
			if (self.onfire_finished > time && self.health > 0)
			{
				b.onfire_finished = time + 2.5;
				b.igniter = self.igniter;
			}
			if (b.onfire_finished > time && b.health > 0)
			{
				self.onfire_finished = time + 2.5;
				self.igniter = b.igniter;
			}

			// Stop player thats doing the ramming
			entity part = self.driving.physobj_particlelist;
			while (part)
			{
				float pf = self.pushfactor * 10;

				if (b.turbo)
				{
					vector push_cap = part.velocity -= (b.origin - self.origin) * (101 - vlen(b.origin - self.origin)) * (pf + 0.05);
					
					if (push_cap_x > 800)
						push_cap_x = 800;
					if (push_cap_y > 800)
						push_cap_y = 800;
					if (push_cap_z > 800)
						push_cap_z = 800;

					if (push_cap_x < -800)
						push_cap_x = -800;
					if (push_cap_y < -800)
						push_cap_y = -800;
					if (push_cap_z < -800)
						push_cap_z = -800;

					part.velocity = '0 0 0';
					part.velocity = push_cap;
				}
				else
				{
					push_cap = part.velocity -= (b.origin - self.origin) * (101 - vlen(b.origin - self.origin)) * (pf + 0.05);

					if (push_cap_x > 500)
						push_cap_x = 500;
					if (push_cap_y > 500)
						push_cap_y = 500;
					if (push_cap_z > 500)
						push_cap_z = 500;

					if (push_cap_x < -500)
						push_cap_x = -500;
					if (push_cap_y < -500)
						push_cap_y = -500;
					if (push_cap_z < -500)
						push_cap_z = -500;

					part.velocity = '0 0 0';
					part.velocity = push_cap;
				}
				// debugging
				/*
				string x = ftos(push_cap_x);
				string y = ftos(push_cap_y);
				string z = ftos(push_cap_z);				
				bprint ("X: ", x, "Y: ", y, "Z: ", z, "\n");
				*/

				part = part.physobj_next;
			}
			//self.collide_finished = time + 0.5;
		}
	}
};

// Instances that can force the car to jump (example: being hit by a rocket)
.float forcejump_finished;
void() ForceJump =
{
	if (self.forcejump_finished > time)
		return;

	entity part = self.driving.physobj_particlelist;
	while (part)
	{
		part.velocity_z += self.forcejump_strength;
		part = part.physobj_next;
	}
	self.forcejump_finished = time + 0.1;
};

void() spawn_car_countdown;
void() CarSelection_Update;
entity() SelectSpawnSpot;
.float turbo_fuel_finished;
.float energy_finished;
void() PlayerPreThink = 
{
	if (cvar("developer") == 1) // Coord/Angle reporting, helps insert entities in hmp maps
	{
		string x,y,z,ang_y,ang_x;
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
	{
		Setup_level_effects();
		CarSelection_Update(); // Show starting menu / greetings
	}

	// Force player in car, give greetings message
	if (!self.driving || (self.observer && ragewar))
	{
		if (ragewar)
		{
			if (race_status == RACE_NOTSTARTED || self.observer)
			{
				if (self.music != "sound/music/rwmenu.ogg" && framecount > 20)
				{
					self.music = "sound/music/rwmenu.ogg";
					stuffcmd (self, sprintf("music %s\n", self.music));
				}
			}
		}
		else if (!self.observer && !self.ready)
		{
			if (race_status == RACE_NOTSTARTED)
			{
				if (self.music != "sound/music/rmmenu.ogg" && framecount > 20)
				{
					self.music = "sound/music/rmmenu.ogg";
					stuffcmd (self, sprintf("music %s\n", self.music));
				}
			}
		}
		Car_CheckAttach(); // Shove the player in the car

		// framecount + CLIENTTYPE_BOT needs to be here, otherwise stuff breaks with bot spawning
		if (framecount > 75 && ((self.button0 || self.button3 || self.button4) || (clienttype(self) == CLIENTTYPE_BOT && race_status > RACE_NOTSTARTED)))
		{
			centerprint(self, ""); // clear any centerprints
			if (race_status == RACE_NOTSTARTED)
			{
				if (!self.ready)
				{
					self.ready = TRUE; // important!
					if (!ragewar && clienttype(self) == CLIENTTYPE_REAL)
					{
						human_players_ready += 1;
						bprint(self.netname, " is ready!\n");
					}
				}
				self.observer = FALSE; // important!

				if (!ragewar)
				{
					if (human_players_ready == human_players)
					{
						stuffcmd (self, "play misc/menu_s1.wav\n");
						spawn_car_countdown(); // Start countdown
						race_status = RACE_COUNTDOWN;
						sound (self, CHAN_AUTO, "engine/start.wav", 1, ATTN_NORM);
					}
				}
				else
				{
					stuffcmd (self, "play misc/menu_s2.wav\n");
					spawn_car_countdown(); // Start countdown
					race_status = RACE_COUNTDOWN;
					sound (self, CHAN_AUTO, "engine/start.wav", 1, ATTN_NORM);
				}
			}

			if (!self.spawncar)
			{
				if (self.music != "")
				{
					self.music = "";
					stuffcmd (self, "stopmusic\n");
				}

				if (clienttype(self) == CLIENTTYPE_BOT)
					Bot_SelectVehicle();
				self.ready = TRUE; // important!
				self.observer = FALSE; // important!

				// You can fly around while selecting your car in ragewar, so set the player position back
				if (ragewar)
				{
					entity spawn_spot = SelectSpawnSpot();
					self.angles = spawn_spot.angles;
					setorigin(self, spawn_spot.origin);
					self.fixangle = TRUE;
					self.invulnerable_finished = time + 5;
				}

				sound (self, CHAN_AUTO, "engine/start.wav", 1, ATTN_NORM);

				// Put cars in game
				if (self.vehicle == VEH_HOTROD)
					entity car = hotrod();
				if (self.vehicle == VEH_WRAITH)
					car = wraith();
				if (self.vehicle == VEH_ROADBASTARD)
					car = roadbastard();
				if (self.vehicle == VEH_SKYSCRAPER)
					car = skyscraper();
				if (self.vehicle == VEH_REDRAGE)
					car = redrage();
				if (self.vehicle == VEH_LAWBREAKER)
					car = lawbreaker();
				if (self.vehicle == VEH_RAZORBACK)
					car = razorback();
				if (self.vehicle == VEH_MINCEMEAT)
					car = mincemeat();
				if (self.vehicle == VEH_STREETKING)
					car = streetking();
				if (self.vehicle == VEH_SANDROAMER)
					car = sandroamer();
				if (self.vehicle == VEH_THOROGOOD)
					car = thorogood();
				if (self.vehicle == VEH_NIGHTSHADE)
					car = nightshade();
				if (self.vehicle == VEH_SERVANT)
					car = servant();
				if (self.vehicle == VEH_WARWIENER)
					car = warwiener();

				makevectors(self.angles);

				// Some vehicles need extra spawn height
				if (self.vehicle == VEH_SKYSCRAPER || self.vehicle == VEH_NIGHTSHADE)
					car = Phys_MakeIntoPhysicsObject(car, self.origin + v_up * 74, v_forward, -v_right, v_up, '0 0 1', 0);
				else
					car = Phys_MakeIntoPhysicsObject(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);

//				car.physobj_flags |= PHFLAGS_VEHICLE;
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

		if (self.start_laptime && race_status == RACE_STARTED) // turned on by start/finish goal
		{
			if (self.laptime_tic < time)
			{
				self.laptime += 0.01; // count half seconds
				self.laptime_tic = time + 0.01;

				self.overall_time += 0.01;
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

	float len = vlen(self.origin - self.owner.origin);
	if (len > 800) // Update trail origin
	{
		self.angles = self.owner.angles;
		setorigin(self, self.owner.origin);
	}
	frameskip(0.1);
};

void() RespawnPlayer =
{
	entity spawn_spot = SelectSpawnSpot();

	self.health = self.max_health;
	self.colormod = '0 0 0';
	self.deathcount = 0;
	self.igniter = world;
	self.onfire_finished = time;
	self.frozen_finished = time;
	self.slow_finished = time;
	self.blind_finished = time;
	self.energy = 100;
	self.enemy_displayname = "";
	self.enemy_displayhealth = 0;
	self.enemy_displaymaxhealth = 0;
	self.angles = spawn_spot.angles;
	self.fixangle = TRUE;	
	TeleportPhysObject(self.driving, spawn_spot.origin, spawn_spot.angles, FALSE);
	spawn_telesfx(self);
	spawn_televfx(self);
	self.invulnerable_finished = time + 5; // disallow damage / firing
	centerprint(self, ""); // clear screen
	self.clearcprint_finished = time + 0.1;
	sound (self, CHAN_AUTO, "engine/start.wav", 1, ATTN_NORM);
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

void() freeze_explode_vfx_think =
{
	if (self.think_finished < time)
	{
		if (self.scale > 0)
			self.scale -= 0.01;
		else
		{
			remove(self);
			return;
		}
	}
	frameskip(0.01);
};

void() freeze_explode_vfx =
{
	entity fxp = spawn ();
	fxp.angles_y = random() * 360;
	makevectors (fxp.angles);
	fxp.velocity = v_forward * (150 + random()*200);
	fxp.velocity_z = ceil(500 + random()*250);
	fxp.owner = self;
	fxp.avelocity = '1000 200 650';
	fxp.movetype = MOVETYPE_BOUNCE;
	fxp.solid = SOLID_NOT;
	fxp.alpha = 0.75;
	fxp.dimension_hit = fxp.dimension_solid = 0;
	fxp.effects = EF_ADDITIVE;
	fxp.scale = 0.5 + random()*1;
	fxp.classname = "icexplode";
	setmodel (fxp, "progs/frozen.mdl");
	setsize (fxp, '0 0 0', '0 0 0');
	makevectors (self.angles);
	setorigin (fxp, self.origin);
	fxp.think_finished = time + (3 + random()*3);

	fxp.think = freeze_explode_vfx_think;
	fxp.nextthink = time;
};

void() freeze_think =
{
	if (self.owner.shield_finished > time) // Shield break ice effect
	{
		float i = 3 + ceil(random()*4);
		for (float t = 0 ; t < i ; t++)
			freeze_explode_vfx();
		sound(self, CHAN_AUTO, "combat/freezebrk.wav", 1, ATTN_NORM);		
		self.owner.frozen = world;
		Create2DFreezeExplosion(self.origin + v_up * 24, 3);
		remove(self);
		return;		
	}
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

void() VFX_WaterSplash_Think =
{
	if (!self.cnt) // Run once
	{
		droptofloor();
		self.cnt = TRUE;
	}

	if (self.scale < 3)
		self.scale += 0.1;
	else
	{
		if (self.alpha > 0)
			self.alpha -= 0.01;
		else
		{
			remove(self);
			return;
		}
	}

	frameskip(0.01);
};

void() VFX_WaterSplash =
{
	entity splash = spawn();
	splash.owner = self;
	splash.classname = "watersplash";
	splash.effects = EF_ADDITIVE;
	splash.alpha = 0.8;
	splash.movetype = MOVETYPE_NONE;
	splash.solid = SOLID_NOT;
	splash.hitcontentsmaski = CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA;

	splash.think = VFX_WaterSplash_Think;
	splash.nextthink = time;

	setorigin (splash, self.origin + v_up * 64);
	setmodel (splash, "progs/watersplash.spr");
	setsize (splash, '0 0 0', '0 0 0');
};

void() PlayerPostThink =
{
	if (clienttype(self) == CLIENTTYPE_BOT)
		BotAI();

	if (intermission_running)
	{
		self.onfire_finished = time;
		self.blind_finished = time;
		self.frozen_finished = time;
		IntermissionThink ();
		return;
	}
	if (self.observer)
	{
		if (self.movetype != MOVETYPE_NOCLIP)
			self.movetype = MOVETYPE_NOCLIP;
		if (ragewar)
			CheckImpulses(); // Allow car selection in observer mode
		return;
	}

	if (race_status == RACE_STARTED && !intermission_running && self.health > 0 && self.driving)
	{
		if (!self.observer)
			PushPlayers();
		if (ragewar)
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
		if (clienttype(self) == CLIENTTYPE_REAL && race_status == RACE_STARTED && self.driving) // Player snail trail waypoint
		{
			if (!self.trail)
			{
				entity trail1 = spawn();
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
					setmodel (trail1, "*null");

				setsize (trail1, '0 0 0', '0 0 0');
				trail1.scale = 3;

				trail1.think = snailtrail_think;
				trail1.nextthink = time + 0.1;
			}
			else
			{
				makevectors(self.v_angle);
				float len = vlen(self.origin - self.trail.origin);

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
			if (self.colormod_x > self.max_colormod) // red
				self.colormod_x = self.colormod_x - 6 * frametime;
			else
				self.colormod_x = self.max_colormod;

			if (self.colormod_y > self.max_colormod) // green
				self.colormod_y = self.colormod_y - 6 * frametime;
			else
				self.colormod_y = self.max_colormod;

			if (self.frozen_finished < time)
			{
				if (self.colormod_z > self.max_colormod) // blue
					self.colormod_z = self.colormod_z - 6 * frametime;
				else
					self.colormod_z = self.max_colormod;
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
						if (self.vehicle == VEH_STREETKING) // Kill all of street kings turrets
						{
							for (entity targ = world;(targ = find(targ, classname, "turret"));)
							{
								if (targ.owner == self)
								{
									DoDamage(targ, targ, 999, ""); // Do it properly
									self.turrets = 0;
								}
							}
						}
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
					if (self.cloak_finished > time)
						self.cloak_finished = time;
					self.colormod = '0.01 0.01 0.01'; // car is cooked/black on death
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
	float contents;// = 0;
	vector point = self.origin;

	point_z = point_z + self.mins_z + 1; // get the minimum water depth (waterlevel 1)
	contents = pointcontents(point);
	if (contents >= CONTENT_LAVA && contents <= CONTENT_WATER)
	{
		if (self.onfire_finished > time && self.waterlevel > 0)
			self.onfire_finished = time; // water removes fire

		if (!self.waterlevel) // Splash VFX+SFX
		{
			VFX_WaterSplash();
			sound (self, CHAN_AUTO, "watersplash.wav", 1, ATTN_NORM);
		}
		self.waterlevel = 1;
	}
	else
		self.waterlevel = 0;

	// EF_BRIGHTFIELD effects handler
	if (self.driving)
	{
		if (ragewar)
		{
			if (self.invulnerable_finished > time)
			{
				self.effects |= EF_BRIGHTFIELD;
				if (self.onfire_finished > time)
					self.onfire_finished = time;
				if (self.frozen_finished > time)
					self.frozen_finished = time;
				if (self.blind_finished > time)
					self.blind_finished = time;
				if (self.slow_finished > time)
					self.slow_finished = time;
			}
			else
				self.effects &= ~(EF_BRIGHTFIELD);
		}
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

			// Give off RT Light
			fire1.pflags = PFLAGS_FULLDYNAMIC;
			fire1.light_lev = 100;
			fire1.color = [3, 1.25, 1];
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

			// Give off RT Light
			freeze1.pflags = PFLAGS_FULLDYNAMIC;
			freeze1.light_lev = 100;
			freeze1.color = [1, 1, 3];

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
	
	//
	// SPECIAL MOVE MOTIONS: Reset keys if timer is dropped
	//

	if (clienttype(self) == CLIENTTYPE_REAL)
		CommandSpecials();

	CheckImpulses();

	// Debug status effects
	/*
	if (self.driving)
	{
		self.blind_finished = time + 3;
		self.onfire_finished = time + 3;
		if (self.shield_finished < time)
			self.frozen_finished = time + 3;
		self.slow_finished = time + 3;
	}
	*/
};

//----
// Select a proper spawn spot
//----

void() racer_spawnpoint = {};
void() dm_spawnpoint = {};

entity() SelectSpawnSpot =
{
	entity spot = lastspawn;

	if (!ragewar) // racing
	{
		while (1)
		{
			spot = find(spot, classname, "racer_spawnpoint");
			if (spot)
			{
				if (spot == lastspawn)
					return lastspawn;

				lastspawn = spot;
				return spot;
			}
			else // last shot attempt
			{
				spot = find(spot, classname, "info_player_start");
				return spot;
			}
			return spot;
		}
	}
	else
	{
		while (1)
		{
			spot = find(spot, classname, "dm_spawnpoint");
			if (spot)
			{
				if (spot == lastspawn)
					return lastspawn;

				lastspawn = spot;
				return spot;
			}
			else // last shot attempt
			{
				spot = find(spot, classname, "info_player_start");
				return spot;
			}
			return spot;
		}
		return spot;
	}

	/*
	if (!spot)
	{
		spot = find(spot, classname, "info_player_start"); // last try
		return spot;
		//error ("Cannot find spawnpoint on map");
	}
	*/

	bprint ("SelectSpawnSpot failed!\n");
	return world;
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
	self.angles = spawn_spot.angles;
	self.fixangle = TRUE;

	setmodel (self, "progs/null.spr");
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 42'; // Best height for no CSQC chasecam
	self.velocity = '0 0 0';

	self.flags = FL_FINDABLE_NONSOLID; // Needed for findradius to find me
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
	self.spawncar = FALSE;
	self.max_colormod = 1;

	if (clienttype(self) == CLIENTTYPE_REAL)
		human_players = human_players + 1;
	self.player_id = human_players;

	if (cvar("developer") != 1)
	{
		if (ragewar && race_status != RACE_NOTSTARTED)
		{
			// Start music on player mid-game join
			if (world.model == "maps/dm1.bsp")
				self.music = "sound/music/dm1.ogg";
			if (world.model == "maps/dm2.bsp")
				self.music = "sound/music/dm2.ogg";
			if (world.model == "maps/dm3.bsp")
				self.music = "sound/music/dm3.ogg";
			if (checkextension("DP_QC_SPRINTF"))
				stuffcmd (self, sprintf("music %s\n", self.music));
		}
	}

	// grab ragewar from server
	ragewar = cvar("ragewar");
	if (ragewar)
		self.observer = TRUE; // important now
	
	CarSelection_Update(); // Display menu on connect
};