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

/*
=============
visible
returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float (entity targ) visible =
{
	local vector	spot1, spot2;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, TRUE, self);
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction)
		return TRUE;
	return FALSE;
};