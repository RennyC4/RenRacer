//+------+
//|Misc  |
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Misc code handled here, nowhere else to put it.                            |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

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

/*
================
InitTrigger
================
*/
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
* mdl: The model to display. Can be of type mdl, bsp, or spr.
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
	
    // Only animate if given a frame range
    if (!self.last_frame)
        return;

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
	// Detach player first
	Car_AttachToVehicle(car.driving, car);
	Phys_ObjectRemove(car);

	// these should be removed with Phys_ObjectRemove, very worrying..
	nukecar_with_classname("physics_object");
	nukecar_with_classname("particle");
	nukecar_with_classname("static");
	nukecar_with_classname("stick");
	nukecar_with_classname("hitmodel");
};

// HACK: Remove car, teleport player, recreate car and shove 'em back in
void(vector dest) car_teleport =
{
	if (self.teleport_finished > time)
		return;

	if (random() < 0.5)
		sound (self, CHAN_AUTO, "teleport1.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_AUTO, "teleport2.wav", 1, ATTN_NONE);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	remove_car(self.driving);
	setorigin(self, dest);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	local entity car = hotrod();
	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};
