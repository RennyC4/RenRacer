//+------+
//|Client|
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Handle's "clients" (eg, Players) connecting, disconnecting, etc.           |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

void() CheckImpulses;

void() ClientKill = {};
void(optional float csqcactive) ClientConnect = {};
void() ClientDisconnect ={};

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

void() PlayerPreThink = 
{
	// Player origin debugging
	/*
	local string s_x, s_y, s_z;
	
	s_x = ftos(self.origin_x);
	s_y = ftos(self.origin_y);
	s_z = ftos(self.origin_z);
	
	bprint (self.classname, "_X: ", s_x, "\n");
	bprint (self.classname, "_Y: ", s_y, "\n");
	bprint (self.classname, "_Z: ", s_z, "\n");
	*/
	
	// Player speed debugging
	// 'real speed' is sent from func_vehicles Car_ChassiThink(); function
	/*
	local string f;
	f = ftos(self.realspeed);
	bprint ("Speed: ", f, "\n");
	*/

	// Force player in car, give greetings message
	if (!self.driving)
	{
		Car_CheckAttach();
		centerprint (self, "Welcome to RenRacer\n");
	}
	else
	{
		EngineSounds();
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
	TryUpdateVehicle();
	CheckImpulses();
};

//----
// Spawning the Player
//----
void() PutClientInServer =
{
	local entity spawn_spot;
	spawn_spot = find (world, classname, "info_player_start");

	self.classname = "player";
	self.health = self.max_health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	self.origin = spawn_spot.origin;
	
	//func_vehicle
	setmodel (self, "progs/null.spr");
	modelindex_null = self.modelindex;
	stuffcmd(self, "chase_active 1\n");
	stuffcmd(self, "crosshair 0\n");
	//func_vehicle
	
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.view_ofs = '0 0 22';
	self.velocity = '0 0 0';
	self.modelindex = 0;

	self.angles = spawn_spot.angles;
	self.fixangle = TRUE;

	self.hitme = "TRUE"; // Allow searchradius to look for me
	self.checkpoint = 0;

	// Spawn car
	local entity car = hotrod();
	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};