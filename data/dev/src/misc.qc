//+------+
//|Misc  |
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Misc code handled here, nowhere else to put it.                            |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

//
// Range - compare distance between two entities
//

float(entity targ) range =
{
	vector spot1 = self.origin;
	vector spot2 = targ.origin;

	float r = vlen(spot1 - spot2);
	if (r < 200)
		return RANGE_CLOSE;
	if (r < 500)
		return RANGE_NEAR;
	if (r < 1000)
		return RANGE_MID;
	return RANGE_FAR;
};

//
// Blood effects
//

void() ThrowBloodRemove =
{
	if (self.alpha > 0.1)
		self.alpha = self.alpha - 0.1;
	else
	{
		remove(self);
		return;
	}
	if (self.animation_finished < time)
	{
		if (self.frame < 3)
			self.frame += 1;
		self.animation_finished = time + 0.1;
	}
	frameskip(0.1);
};

void(vector org, vector dir, float size) ThrowBlood =
{
	entity thing = spawn();
	makevectors_mdl (thing.angles);

	thing.owner = self;
	thing.movetype = MOVETYPE_TOSS;
	thing.solid = SOLID_NOT;
	thing.scale = size;
	thing.velocity = dir;
	//thing.angles_y = random() * 360;
	//thing.velocity = v_forward * random()*200;
	thing.velocity_z = 300 + random()*300;
	thing.alpha = 1;

	thing.think = ThrowBloodRemove;
	thing.nextthink = time + 1;

	setmodel (thing, "progs/blood.spr");
	setsize (thing, '0 0 0', '0 0 0');     
	setorigin (thing, org);
};

//
// Intermission / Next map
//

void() info_intermission = {self.classname = "info_intermission";};

void() GotoNextMap =
{
	if (cvar("samelevel"))
		changelevel (mapname);
	else
		changelevel (nextmap);
};

void() execute_changelevel =
{
	intermission_running = TRUE;
	intermission_exittime = time + 5;

	entity pos = find(world, classname, "info_intermission");

	other = find (world, classname, "player");
	while (other)
	{
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;
		other.view_ofs = '0 0 0';
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}
	//WriteByte (MSG_ALL, SVC_INTERMISSION);
};

void() IntermissionThink = // called from PostThink
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2 && !self.button3 && !self.button4)
		return;
	
	GotoNextMap ();
};

void() NextLevel =
{
	entity o = find(world, classname, "trigger_changelevel");
	if (!o)
	{
		mapname = "dm1";
		o = spawn();
		o.map = mapname;
	}

	nextmap = o.map;
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
	gameover = TRUE;
};

entity highestScorer;
float highestFrags;
void() Timelimit_Printwinner =
{
    for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
        if (targ.frags > highestFrags)
		{
            highestScorer = targ;
            highestFrags = targ.frags;
        }
    }
    if (highestScorer)
		bprint (highestScorer.netname, " won the rage war with ", ftos(highestFrags), " frags!\n");
};

void() CheckGameRules =
{
	if (gameover)
		return;

	float timelimit = cvar("timelimit") * 60;
	float fraglimit = cvar("fraglimit");

	if (timelimit && time >= timelimit)
	{
		Timelimit_Printwinner();
		race_status = RACE_FINISHED;
		if (self.driving)
			Car_AttachToVehicle(self, self.driving); // Remove player from car
		NextLevel();
		return;
	}

	if (fraglimit && self.frags >= fraglimit)
	{
		race_status = RACE_FINISHED;
		bprint (self.netname, " won the rage war with ", ftos(self.frags), " frags!\n");
		if (self.driving)
			Car_AttachToVehicle(self, self.driving); // Remove player from car
		NextLevel();
		return;
	}
};

//
//
//

void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	self.angles = '0 0 0';
};

//================
//InitTrigger
//================
void() InitTrigger =
{
	// trigger angles are used for one-way touches.  An angle of 0 is assumed
	// to mean no restrictions, so use a yaw of 360 instead.

	SetMovedir ();	
	if (self.classname != "changelevel")
		self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};

//
// Spawns a dynamic light for colored light glowing, only use if needed
//

void() spawn_color_glow_think =
{
	// HACK: SOLID_NOT is the only method I've found to actually remove
	// the dynamic light entity properly, otherwise it starts to randomly
	// assign itself to other entities.

	if (self.owner.solid == SOLID_NOT)
	{
		dprint ("spawn_color_glow removed properly\n");
		self.pflags = 0;
		self.light_lev = 0;
		self.color = [0,0,0];
		remove(self);
		return;
	}
	makevectors_mdl(self.owner.angles);
	setorigin (self, self.owner.origin + v_up * 10); // move slightly above ground
	frameskip(0.01);
};

void(float r, float g, float b, float light, entity spawner) spawn_color_glow =
{
	local entity glowy;
	
	glowy = spawn();

	glowy.movetype = MOVETYPE_NOCLIP;
	setorigin (glowy, spawner.origin + v_up*10);
	setmodel (glowy, "progs/null.spr");
	setsize (glowy, '0 0 0', '0 0 0');
	glowy.solid = SOLID_NOT;
	glowy.classname = "glowy";
	glowy.owner = spawner;
	
	// Give off RT Light
	glowy.pflags = PFLAGS_FULLDYNAMIC;
	glowy.light_lev = light;
	glowy.color = [r, g, b];
	
	glowy.think = spawn_color_glow_think;
	glowy.nextthink = time + 0.1;
};

/*
* misc_model.qc
*
* Author: Joshua Skelton joshua.skelton@gmail.com
*/

.float first_frame; // The starting frame of the animation
.float last_frame; // The ending frame of the animation

void() misc_model_think =
{
    self.nextthink = time + fabs(self.speed);
    self.frame = self.frame + sign(self.speed);
    self.frame = wrap(self.frame, self.first_frame, self.last_frame);
};

/*
* misc_model
*
* An entity for displaying models. A frame range can be given to animate the
* model.
*
* model: The model to display. Can be of type model, bsp, or spr.
* frame: The frame to display. Can be used to offset the animation.
* first_frame: The starting frame of the animation.
* last_frame: The last frame of the animation.
*/

void() misc_model =
{
    precache_model(self.model);
    setmodel(self, self.model);

    if (self.first_frame)
		self.frame = self.first_frame;

	if (self.spawnflags & 1)
		self.use = SUB_Remove;

    // Only animate if given a frame range, RennyC: MakeStatic 'em
    if (!self.last_frame && !self.spawnflags)
	{
		makestatic(self);
        return;
	}

	// Randomize start from between first/last frame
	if (self.spawnflags & 1)
	{
		self.frame = self.first_frame;
		local float diff;
		diff = self.last_frame - self.first_frame;

		self.frame = self.frame + ceil(random()*diff);
	}
	
    // Default animation speed to 10 fps
    if (!self.speed)
        self.speed = 10 / 60;

	self.nextthink = time + self.speed;
	self.think = misc_model_think;
};

void(string name) nukecar_with_classname =
{
	for(entity e = find(world, classname, name); e; e = find(e, classname, name))
	{
		if (e.realowner == self)
			remove(e);
	}
};

void(entity car) remove_car =
{
	// these should be removed with Phys_ObjectRemove, very worrying..
	nukecar_with_classname("physics_object");
	nukecar_with_classname("particle");
	nukecar_with_classname("static");
	nukecar_with_classname("stick");
	nukecar_with_classname("hitmodel");

	// Detach player first
	Car_AttachToVehicle(car.driving, car);
	Phys_ObjectRemove(car);
};

// Huge thanks to spike for the help with displacement
void(entity targ, vector dest, float silent, float stop) car_teleport =
{
	if (targ.teleport_finished > time)
		return;

	targ.collide_finished = time + 2; // Can't collide with other cars temporarily

	if (!silent)
	{
		if (random() < 0.5)
			sound (targ, CHAN_AUTO, "teleport1.wav", 1, ATTN_NORM);
		else
			sound (targ, CHAN_AUTO, "teleport2.wav", 1, ATTN_NORM);

		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_TELEPORT);
		WriteCoord (MSG_BROADCAST, targ.origin_x);
		WriteCoord (MSG_BROADCAST, targ.origin_y);
		WriteCoord (MSG_BROADCAST, targ.origin_z);
	}
	
	entity part = targ.driving.physobj_particlelist;
	vector displacement = dest - targ.origin;
    while(part)
    {
		local vector v2 = part.origin;
		v2 = v2 += displacement;
		setorigin(part, v2 + '0 0 32'); // add 32qu Z, helps keep cars out of the ground
		if (stop)
			part.velocity = part.velocity / 1000;
		part = part.physobj_next;
	}
	
	if (!silent)
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_TELEPORT);
		WriteCoord (MSG_BROADCAST, dest_x);
		WriteCoord (MSG_BROADCAST, dest_y);
		WriteCoord (MSG_BROADCAST, dest_z);
		targ.alpha = 0.1; // Teleport effect
	}
};

// directly set the car angles WIP
// this function sucks
void(entity targ, vector newang) car_setangle =
{
	bprint ("car_setangle called\n");

	// remove car
	remove_car(targ.driving);

	// set angle
	targ.angles = newang;
	targ.fixangle = TRUE;

	// Recreate car
	if (targ.vehicle == VEH_HOTROD)
		entity car = hotrod();
	if (targ.vehicle == VEH_WRAITH)
		car = wraith();
	if (targ.vehicle == VEH_ROADBASTARD)
		car = roadbastard();
	if (targ.vehicle == VEH_SKYSCRAPER)
		car = skyscraper();
	if (targ.vehicle == VEH_REDRAGE)
		car = redrage();
	if (targ.vehicle == VEH_LAWBREAKER)
		car = lawbreaker();
	if (targ.vehicle == VEH_RAZORBACK)
		car = razorback();

	makevectors(targ.angles);
	car = Phys_ObjectCreate(car, targ.origin + v_up * 64, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};