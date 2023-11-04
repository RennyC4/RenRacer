.entity frontright, frontleft, backright, backleft;
entity() hotrod;

void PushAndDamageThink(){
// RennyC: Disable this
/*
	entity e = self.p_damage_next;
	while(e){
		T_Damage (e, self, self, e.p_damage_val);
		e.p_damage_val = 0;
		entity temp = e.p_damage_next;
		e.p_damage_next = world;
		e = temp;
	}
	self.p_damage_next = world;

	self.nextthink = time + 0.2;
*/
}

// FIXME: need to take attacker mass into account
void PushAndDamageTarget(entity instigator, entity targ){
/*
	vector vel = instigator.velocity;
	if (!p_damage_thinker){
		p_damage_thinker = spawn();
		p_damage_thinker.think = PushAndDamageThink;
		p_damage_thinker.nextthink = time + 0.2;
	}

	if (targ.flags & FL_MONSTER || targ.flags & FL_CLIENT){
		float len = vlen(vel);
		if (len > 100) {
			targ.flags -= (other.flags & FL_ONGROUND);
			targ.velocity += vel * 0.035;
			targ.velocity += [0, 0, len * 0.02];

			float contains = FALSE;
			entity e = p_damage_thinker.p_damage_next;
			while(e){
				if(e == targ){
					contains = TRUE;
					break;
				}
				e = e.p_damage_next;
			}

			if (!contains){
				targ.p_damage_next = p_damage_thinker.p_damage_next;
				p_damage_thinker.p_damage_next = targ;
			}
			targ.p_damage_val += len * 0.01;
		}
	}
*/
}

// RennyC: From build a delivery by shpuld
float sfx_skidding;
void(entity e, float strength) play_skidding =
{
	if (time < sfx_skidding)
		return;

	//sound(e, CHAN_AUTO, "skidding.wav", 0.025 + min(0.5, strength * 0.8), 0, 95 + strength * 60);
	sound(e, CHAN_AUTO, "skidding.wav", 0.025 + min(0.5, strength * 0.8), 0, 95 + strength * 7);
	sfx_skidding = time + random(0, 2);
}
//

void Car_TirePlace(entity tire){
	entity tireparticle = tire.enemy;
	entity plyrent_tireowner = self.owner.driving; // RennyC

	tire.angles = vectoangles(tireparticle.lmat_forward, tireparticle.lmat_up);
	
	// Animate tire spin
	if (plyrent_tireowner.realspeed > 2)
	{
		if (tire.animation_finished < time)
		{
			if (!plyrent_tireowner.backward)
			{
				if (tire.frame > 0)
					tire.frame -= 1;
				else
					tire.frame = 11;
			}
			else
			{
				if (tire.frame < 11)
					tire.frame += 1;
				else
					tire.frame = 0;
			}
			// Animate speed
			if (plyrent_tireowner.realspeed < 12)
				tire.animation_finished = time + 0.1;
			else if (plyrent_tireowner.realspeed < 24)
				tire.animation_finished = time + 0.03;
			else if (plyrent_tireowner.realspeed < 36)
				tire.animation_finished = time + 0.02;
			else
				tire.animation_finished = time + 0.001;

		}
	}

	/*
	// Spin Tires - RennyC: Disabled due to choppy/ghosty/weird angle stuff
	tire.angles_z = 0; // Fix wacky tires on slopes (TODO: Needs to match Z of car chassis)
	makevectors(tire.angles);
	vector forward = normalize(v_forward);
	float pitch = -dotproduct(tire.angles, forward) * 360.0;
	if (plyrent_tireowner.realspeed >= 4)
		tire.angles_x += pitch * 0.1;
	*/

	traceline(tireparticle.origin, tireparticle.origin - tireparticle.lmat_up * tire.frags, TRUE, tire);
	tire.oldorigin = tire.origin;
	if (trace_fraction == 1 || trace_plane_normal_z > 0.7){
		float tracelen = fabs(tireparticle.physobj_spring_length + tire.relative_size);
		tire.frags = min(tire.frags + frametime*30, tracelen*trace_fraction);
		tire.punchangle = trace_endpos + tireparticle.lmat_up * tire.relative_size;
		setorigin(tire, tire.punchangle);
		tire.punchangle -= tireparticle.origin;
	}
	else {
		setorigin(tire, tireparticle.origin + tire.punchangle);
	}
	// RennyC: From build a delivery by shpuld
	if (trace_fraction < 0.8)
	{
		if (fabs(tireparticle.velocity * tireparticle.lmat_left) > 80)
		{
			/* Unsupported on Terrain Maps :(
			local float surfnum = getsurfacenearpoint(world, trace_endpos);
			local string s = getsurfacetexture(world, surfnum);
			local float r = strstrofs(s, "dirt", 0);
			*/
			//if (!r)
			pointparticles(PART_DIRT, trace_endpos, normalize(tireparticle.velocity + '0 0 100'), 1);
			play_skidding(tireparticle, (fabs(tireparticle.velocity * tireparticle.lmat_left) - 40) / 500);
			
			//local string v = ftos(r);
			//bprint (v, "\n");
		}
	}
	//
}

void() Car_ChassiThink =
{
	entity car = self.realowner;

	entity tbleft = car.backleft.enemy;
	entity tbright = car.backright.enemy;
	entity tfleft = car.frontleft.enemy;
	entity tfright = car.frontright.enemy;

	entity hitmodel = self.realowner.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.hitcontentsmaski = CONTENTBIT_BODY|CONTENTBIT_SOLID|CONTENTBIT_PLAYERCLIP|CONTENTBIT_SKY; // RennyC
		hitmodel.dimension_hit = player_dimension_hit;
		hitmodel.dimension_solid = player_dimension_solid;

		hitmodel.solid = SOLID_TRIGGER;
		setorigin(hitmodel, hitmodel.origin);
		hitmodel = hitmodel.physobj_next;
	}

	Car_TirePlace(tbleft);
	Car_TirePlace(tbright);
	Car_TirePlace(tfleft);
	Car_TirePlace(tfright);

	hitmodel = self.realowner.physobj_hitmodel;
	while (hitmodel)
	{
		hitmodel.hitcontentsmaski = CONTENTBIT_BODY|CONTENTBIT_SOLID|CONTENTBIT_PLAYERCLIP|CONTENTBIT_SKY; // RennyC
		hitmodel.dimension_hit = player_dimension_hit;
		hitmodel.dimension_solid = player_dimension_solid;
		hitmodel.solid = SOLID_BSP;
		setorigin(hitmodel, hitmodel.origin);
		hitmodel = hitmodel.physobj_next;
	}

	// Setup translucent + colormod effects on visible car parts
	local entity e = car.physobj_staticlist;
    while (e)
    {
		float plyralpha = car.driving.alpha;
		vector plyrcmod = car.driving.colormod;
		e.hitcontentsmaski = CONTENTBIT_BODY|CONTENTBIT_SOLID|CONTENTBIT_PLAYERCLIP|CONTENTBIT_SKY; // RennyC
		e.dimension_hit = player_dimension_hit; // RennyC
		e.dimension_solid = player_dimension_solid; // RennyC
		e.pvsflags = PVSF_IGNOREPVS; // FIXME: Fix certain instances of cars disappearing inside geometry (needs testing)
		if (plyralpha < 1)
		{
			e.effects |= EF_ADDITIVE;
			e.alpha = car.driving.alpha;
		}
		else
		{
			e.effects &= ~EF_ADDITIVE;
			e.alpha = 1;
		}
		if (e.colormod != plyrcmod)
			e.colormod = plyrcmod;

        e = e.physobj_next;
    }
    //

	self.nextthink = time;

	// RennyC - Send real (car) speed / angles to player
	float r = vlen(car.velocity) * 0.1;
	vector v = car.angles;
	entity realowner = car.driving;
	if (realowner.classname == "player")
	{
		realowner.realang = v;
		realowner.realspeed = r;

		// Car body damage logic (deformation / colormod / skin) changes
		if (realowner.health > (realowner.max_health * 0.75))
		{
			self.frame = 0;
			realowner.max_colormod = 1;
		}
		if (realowner.health < (realowner.max_health * 0.75) && realowner.health > (realowner.max_health * 0.5))
		{
			self.frame = 1;
			realowner.max_colormod = 0.75;
		}
		if (realowner.health < (realowner.max_health * 0.5) && realowner.health > (realowner.max_health * 0.25))
		{
			self.frame = 2;
			realowner.max_colormod = 0.5;
		}
		if (realowner.health < (realowner.max_health * 0.25))
		{
			self.frame = 3;
			realowner.max_colormod = 0.25;
		}
	}
};

vector() Car_SpringyOrigin;

entity FindStaticOfName(string name, entity obj){
	entity e = obj.physobj_staticlist;
	while(e){
		if (e.netname == name)
			return e;
		e = e.physobj_next;
	}
	return world;
}

void(entity car) Car_InitVehicle =
{
	local entity e;
	local float hasStabilizer;

	e = car.physobj_particlelist;
	while (e)
	{
		if (e.netname == "frontright")
			car.frontright = e;
		else if (e.netname == "frontleft")
			car.frontleft = e;
		else if (e.netname == "backright")
			car.backright = e;
		else if (e.netname == "backleft")
			car.backleft = e;
		e = e.physobj_next;
	}
	hasStabilizer = FALSE;
	if (car.frontright && car.frontleft){
		e = car.physobj_sticklist;
		while (e)
		{
			if (e.physobj_p1 == car.frontright || e.physobj_p2 == car.frontright){
				if (e.physobj_p1 == car.frontleft || e.physobj_p2 == car.frontleft){
					e.physobj_flags |= PHFLAGS_STABILIZERBAR;
					hasStabilizer = TRUE;
					break;
				}
			}
			e = e.physobj_next;
		}
		if (!hasStabilizer){ // we better make one then
			e = Phys_ObjectAddStick(car.frontright, car.frontleft, car);
			e.physobj_flags |= PHFLAGS_STABILIZERBAR;
		}
	}
	hasStabilizer = FALSE;
	if (car.backright && car.backleft){
		e = car.physobj_sticklist;
		while (e)
		{
			if (e.physobj_p1 == car.backright || e.physobj_p2 == car.backright){
				if (e.physobj_p1 == car.backleft || e.physobj_p2 == car.backleft){
					e.physobj_flags |= PHFLAGS_STABILIZERBAR;
					hasStabilizer = TRUE;
					break;
				}
			}
			e = e.physobj_next;
		}
		if (!hasStabilizer){ // we better make one then
			e = Phys_ObjectAddStick(car.backright, car.backleft, car);
			e.physobj_flags |= PHFLAGS_STABILIZERBAR;
		}
	}
	e = car.physobj_staticlist;
	while (e)
	{
		e.colormap = self.colormap; // RennyC: Assign colourmaps
		if (e.netname == "frontright")
		{
			car.frontright.enemy = e;
			e.enemy = car.frontright;
		}
		else if (e.netname == "frontleft")
		{
			car.frontleft.enemy = e;
			e.enemy = car.frontleft;
		}
		else if (e.netname == "backright")
		{
			car.backright.enemy = e;
			e.enemy = car.backright;
		}
		else if (e.netname == "backleft")
		{
			car.backleft.enemy = e;
			e.enemy = car.backleft;
		}
		else if (e.netname == "chassis")
		{
			e.think = Car_ChassiThink;
			e.nextthink = time;
		}
		e = e.physobj_next;
	}
};

float TryPlacePlayer(entity exit){
	setorigin(self, exit.origin);
	if (!droptofloor())
		return FALSE;
	setorigin(self, exit.origin);
	self.flags -= (self.flags & FL_ONGROUND);
	vector vel = (exit.origin - exit.oldorigin) / frametime;
	vel += normalize(exit.owner.origin - exit.origin) * vlen(vel) * 0.3;
	vel += [0, 0, vlen(vel) * 0.3];
	self.velocity = vel;
	return TRUE;
}

void(entity ply, entity car) Car_AttachToVehicle =
{
	if (ply.driving) // already sitting in car
	{
		ply.driving = world;
		ply.solid = SOLID_SLIDEBOX;
		ply.movetype = MOVETYPE_WALK;
		stuffcmd(ply, "chase_active 0\n");
		stuffcmd(ply, "crosshair 1\n");
		car.driving = world;
	}
	else {
		ply.driving = car;
		ply.solid = SOLID_NOT;
		ply.movetype = MOVETYPE_NOCLIP;
		//ply.flags |= FL_FLY;
		stuffcmd(ply, "chase_active 1\n");
		stuffcmd(ply, "crosshair 0\n");
		setorigin(ply, car.origin);
		car.driving = ply;
	}
};

void Car_CheckAttach(){
	if (self.driving){
		Car_AttachToVehicle(self, self.driving);
		return;
	}
	entity e = findradius(self.origin + self.view_ofs, 100);
	while(e){
		if (e.physobj_flags & PHFLAGS_VEHICLE){
			if (!e.driving){
				Car_AttachToVehicle(self, e);
				break;
			}
		}
		e = e.chain;
	}
}

void(entity attacker, float damage) Car_Pain = {
	if (!self.realowner.driving)
		return;
	T_Damage(self.realowner.driving, attacker, attacker, damage * 0.5); // driving provides protection
};

void(float turn, float backwards) Car_Turn =
{
	local float f;
	local entity tright, tleft;

	if (!self.driving)
		return;
	entity car = self.driving;
	tleft = car.frontleft;
	tright = car.frontright;
	if (ragewar) // ragewar stat
		f = self.handling;
	else
		f = 135;

	if (backwards)
	{
		turn *= -1;
		if (turn > 100)
			turn -= 180;
		if (turn < -100)
			turn += 180;
	}

	float want_yaw = bound(-30, turn, 30);
	if (want_yaw < 0)
		car.ideal_yaw = max(want_yaw, car.ideal_yaw - f*frametime);
	else if (want_yaw > 0)
		car.ideal_yaw = min(want_yaw, car.ideal_yaw + f*frametime);
	else{
		if (car.ideal_yaw > 0)
			car.ideal_yaw = max(0, car.ideal_yaw - f*2*frametime);
		else
			car.ideal_yaw = min(0, car.ideal_yaw + f*2*frametime);
	}

	// left tire
	makevectors(tleft.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 0 1', car.ideal_yaw);
	tleft.relative_forward = matrix_forward;
	tleft.relative_left = matrix_left;
	tleft.relative_up = matrix_up;
	// right tire
	makevectors(tright.base_pose);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	Matrix_RotateByAxisAngle('0 0 1', car.ideal_yaw);
	tright.relative_forward = matrix_forward;
	tright.relative_left = matrix_left;
	tright.relative_up = matrix_up;
};

void(float speed, float maxspeed) Car_Accelerate =
{
	local entity tright, tleft;

	if (!self.driving || self.drift) // RennyC
		return;
	if (self.slow_finished > time) // slow status
	{
		speed = speed / 6;
		maxspeed = maxspeed / 2;
	}
	tleft = self.driving.backleft;
	tright = self.driving.backright;
	float allowAccelerateRight = tright.velocity * tright.lmat_forward < maxspeed;
	float allowAccelerateLeft = tleft.velocity * tleft.lmat_forward < maxspeed;
	if (allowAccelerateRight && tright.flags & FL_ONGROUND){
		tright.velocity = tright.velocity + tright.lmat_forward *speed*frametime;
	}
	if (allowAccelerateLeft && tleft.flags & FL_ONGROUND){
		tleft.velocity = tleft.velocity + tleft.lmat_forward *speed*frametime;
	}
};

void(float speed, float maxspeed) Car_Decelerate =
{
	entity tright, tleft;
	maxspeed = maxspeed * -1; // reverse

	if (self.slow_finished > time) // slow status
	{
		speed = speed / 2;
		maxspeed = maxspeed / 2;
	}

	if (!self.driving || self.drift) // RennyC
		return;
	tleft = self.driving.backleft;
	tright = self.driving.backright;

	float allowDeccelerateRight = tright.velocity * tright.lmat_forward > maxspeed;
	float allowDeccelerateLeft = tleft.velocity * tleft.lmat_forward > maxspeed;

	if (allowDeccelerateRight && tright.flags & FL_ONGROUND){
		tright.velocity = tright.velocity - tright.lmat_forward *speed*frametime;
	}
	if (allowDeccelerateLeft && tleft.flags & FL_ONGROUND){
		tleft.velocity = tleft.velocity - tleft.lmat_forward *speed*frametime;
	}
};

// schpuld: don't use for actual braking, it's hack
void() Car_Brake =
{
	entity tright, tleft;

	if (!self.driving)
		return;
	
	tleft = self.driving.backleft;
	tright = self.driving.backright;
	if (tright.flags & FL_ONGROUND){
		tright.physobj_flags = tright.physobj_flags - (tright.physobj_flags & PHFLAGS_RESTING);
		tright.velocity *= 0.8;
	}
	if (tleft.flags & FL_ONGROUND){
		tleft.physobj_flags = tleft.physobj_flags - (tleft.physobj_flags & PHFLAGS_RESTING);
		tleft.velocity *= 0.8;
	}
};

void(float speed, float maxspeed) Car_Roll =
{
	local entity f_right, f_left;
	local entity b_right, b_left;

	if (!self.driving)
		return;

	f_left = self.driving.frontleft;
	f_right = self.driving.frontright;
	b_left = self.driving.backleft;
	b_right = self.driving.backright;

	if (f_right.flags & FL_ONGROUND && f_left.flags & FL_ONGROUND && b_right.flags & FL_ONGROUND && b_left.flags & FL_ONGROUND) // all tires touching ground, no rolling allowed
		return;

	float fright_lzvel = f_right.velocity * f_right.lmat_up;
	float fleft_lzvel = f_left.velocity * f_left.lmat_up;
	float bright_lzvel = b_right.velocity * b_right.lmat_up;
	float bleft_lzvel = b_left.velocity * b_left.lmat_up;

	float rel_bzvel = fabs(bright_lzvel - bleft_lzvel);
	float rel_fzvel = fabs(fright_lzvel - fleft_lzvel);

	float allowRollFront = (rel_fzvel) < maxspeed;
	float allowRollBack = (rel_bzvel) < maxspeed;
	if (allowRollFront && allowRollBack){
		f_right.velocity = f_right.velocity + f_right.lmat_up *speed*frametime;
		b_right.velocity = b_right.velocity + b_right.lmat_up *speed*frametime;
		f_left.velocity = f_left.velocity - f_left.lmat_up *speed*frametime;	
		b_left.velocity = b_left.velocity - b_left.lmat_up *speed*frametime;	
	}
}

// SinisterSpud addition
void(float speed, float maxspeed) Car_Pitch =
{
    local entity f_right, f_left;
    local entity b_right, b_left;

    if (!self.driving)
        return;

    f_left = self.driving.frontleft;
    f_right = self.driving.frontright;
    b_left = self.driving.backleft;
    b_right = self.driving.backright;

    if (f_right.flags & FL_ONGROUND && f_left.flags & FL_ONGROUND && b_right.flags & FL_ONGROUND && b_left.flags & FL_ONGROUND) // all tires touching ground, no rolling allowed
        return;

    float fright_lzvel = f_right.velocity * f_right.lmat_up;
    float fleft_lzvel = f_left.velocity * f_left.lmat_up;
    float bright_lzvel = b_right.velocity * b_right.lmat_up;
    float bleft_lzvel = b_left.velocity * b_left.lmat_up;

    float rel_bzvel = fabs(bright_lzvel - bleft_lzvel);
    float rel_fzvel = fabs(fright_lzvel - fleft_lzvel);

    float allowRollFront = (rel_fzvel) < maxspeed;
    float allowRollBack = (rel_bzvel) < maxspeed;
    if (allowRollFront && allowRollBack){
        f_right.velocity = f_right.velocity - f_right.lmat_up *speed*frametime;
        b_right.velocity = b_right.velocity + b_right.lmat_up *speed*frametime;
        f_left.velocity = f_left.velocity - f_left.lmat_up *speed*frametime;    
        b_left.velocity = b_left.velocity + b_left.lmat_up *speed*frametime;    
    }
}

//
// RennyC: Taken from Build-A-Delivery by shpuld
//
void(float strength) car_boost =
{
	makevectors([-self.driving.angles.x, self.driving.angles.y, self.driving.angles.z]);
	vector worldorg = self.driving.origin;
	Phys_Force(self.driving, self.driving.physobj_mass * 0.35, v_forward * strength * frametime, worldorg - v_forward * 16, -v_forward);
}

.float driftsfx_finished; // RennyC
.float driftspeed_timer; // RennyC: Hold initial speed
void() car_drift =
{
	local entity f_right, f_left;
	local entity b_right, b_left;

	f_left = self.driving.frontleft;
	f_right = self.driving.frontright;
	b_left = self.driving.backleft;
	b_right = self.driving.backright;

	if (!(f_right.flags & FL_ONGROUND && f_left.flags & FL_ONGROUND && b_right.flags & FL_ONGROUND && b_left.flags & FL_ONGROUND)) // all tires have to touch ground
		return;

	// Remove tire friction on drifts
	f_left.physobj_friction_ground_y = 0.2;
	f_right.physobj_friction_ground_y = 0.2;
	b_left.physobj_friction_ground_y = 0.1;
	b_right.physobj_friction_ground_y = 0.1;

	local float strength = 2500;

	makevectors([-self.driving.angles.x, self.driving.angles.y, self.driving.angles.z]);
	vector worldorg = self.driving.origin;

	if (self.driftsfx_finished < time)
	{
		sound (self, CHAN_AUTO, "slide.wav", 1, ATTN_NORM);
		self.driftsfx_finished = time + 0.6;
	}

	makevectors(self.v_angle);
	float car_angs = self.driving.angles_y;
	if (car_angs > 180)
		car_angs -= 360;
	/*

	if (car_angs > self.v_angle_y)
		Phys_Force(self.driving, self.driving.physobj_mass * 0.35, (v_right * strength * -1) * frametime, worldorg - v_right * 16, -v_right);
	else
		Phys_Force(self.driving, self.driving.physobj_mass * 0.35, v_right * strength * frametime, worldorg + v_right * 16, +v_right);
	*/
};

// RennyC - helps to keep the car balanced if it's tipping in a cheaty manner
void() CarStabilizeCheat =
{
	if (self.vehicle == VEH_THOROGOOD) // Motorcycle needs special condition, feel free to tweak this
	{
		if (self.realang_z > 10 && self.realang_z < 350)
		{
			if (self.realang_z > 180)
				Car_Roll(-5000, 5000);
			else
				Car_Roll(5000, 5000);
		}
	}
	else
	{
		if (self.realang_z > 30 && self.realang_z < 330)
		{
			if (self.realang_z > 180)
				Car_Roll(-4000, 120);
			else
				Car_Roll(4000, 120);
		}
	}

	//FIXME: Red Rage CAN act funky with pitch correction
	//Red Rage in general gets funky. doesn't like any of my physics tinkering. -spud
	//commenting out (for now?) since pitch stabilization is done with air firction. -spud
/*
    if (self.realang_x < -30 && self.realang_x > -330 && self.vehicle != VEH_REDRAGE)
    {
        if (self.realang_x < -180)
            Car_Pitch(-1000, 1000);
        else
            Car_Pitch(1000, 1000);
    }
*/
};
//RennyC

.float turbosfx; // RennyC
.float turbo_warning; // RennyC
.float handbreak_sfx; // RennyC
void TryUpdateVehicle(){
	if (!check_camera_state){
		check_camera_state = TRUE;
	}
	if (!self.driving)
		return;

	// RennyC	
	local entity f_right, f_left;
	local entity b_right, b_left;

	f_left = self.driving.frontleft;
	f_right = self.driving.frontright;
	b_left = self.driving.backleft;
	b_right = self.driving.backright;
	//
	self.driving.physobj_flags -= (self.driving.physobj_flags & PHFLAGS_RESTING);
	setorigin(self, Car_SpringyOrigin());

	if (race_status == RACE_STARTED && self.health > 0) // RennyC: Allow player to control the car
	{
		makevectors(self.v_angle);

		float forw = v_forward * self.velocity;
		if (forw > 100){
			self.keyflags = self.keyflags | KEY_UP; // RennyC
			if (self.frozen_finished < time)
			{
				if (!ragewar)
					Car_Accelerate(3000, 950);
				else
					Car_Accelerate(self.speed, self.max_speed);
			}
		}
		else if (forw < -100){
			self.keyflags = self.keyflags | KEY_DOWN; // RennyC
			if (self.frozen_finished < time)
			{
				if (!ragewar)
					Car_Decelerate(2500, 800);
				else
					Car_Decelerate(self.speed, self.max_speed / 2);
			}
		}
		else
		{
			if (self.keyflags & KEY_UP)
				self.keyflags = self.keyflags - KEY_UP;
			if (self.keyflags & KEY_DOWN)
				self.keyflags = self.keyflags - KEY_DOWN;
		}
		if (self.frozen_finished > time) // frozen status
		{
			f_right.physobj_stiction = 99999;
			f_left.physobj_stiction = 99999;
			b_right.physobj_stiction = 99999;
			b_left.physobj_stiction = 99999;
		}

		// RennyC: Speed Booster
		if (self.speed > 0 && self.speedboost_finished > time)
		{
			self.car_stabilizer = -2; // Harder to tip while speed boosting
			car_boost(self.speed);
			if (!self.waterlevel)
				pointparticles(PART_SPEEDBOOST, self.origin - v_up * 16 - v_forward * 32, '0 0 0', 1);
			else
				pointparticles(PART_BUBBLE, self.origin - v_up * 16 - v_forward * 32, '0 0 0', 1);
		}

		float roll = v_right * self.velocity;
		if (roll > 100){
			self.keyflags = self.keyflags | KEY_RIGHT; // RennyC
			//Car_Roll(-4000, 350);
		}
		else if (roll < -100){
			self.keyflags = self.keyflags | KEY_LEFT; // RennyC
			//Car_Roll(4000, 350);
		}
		else
		{
			if (self.keyflags & KEY_RIGHT)
				self.keyflags = self.keyflags - KEY_RIGHT;
			if (self.keyflags & KEY_LEFT)
				self.keyflags = self.keyflags - KEY_LEFT;
		}

		// RennyC
		// Taken from Build-A-Delivery by shpuld
		if (!self.drift)
		{
			if (self.button0)
			{
				self.turbo_held = TRUE;
				if (self.turbo_fuel >= 15 && self.turbo_held)
					self.turbo = TRUE;
			}
			else
			{
				self.turbo_held = FALSE;
				self.turbo = FALSE;
			}
			//self.turbo = self.button0;
		}
		if (self.turbo)
		{
			if (self.turbo_fuel > 0)
			{
				if (self.turbo_fuel <= 15 && !self.turbo_warning)
				{
					stuffcmd (self, "play warning.wav\n"); // FIXME: Ugly
					self.turbo_warning = TRUE;
				}
				if (self.turbo_fuel > 15)
					self.turbo_warning = FALSE;

				if (!self.turbosfx)
				{
					stuffcmd(self, "play turbo.wav\n");
					//sound (self, CHAN_WEAPON, "turbo.wav", 1, ATTN_NORM);
					self.turbosfx = TRUE;
				}
				Car_Accelerate(3000, 950);
				if (self.frozen_finished < time)
					car_boost(2000);
				makevectors(self.realang);

				if (!self.waterlevel)
				{
					if (self.vehicle == VEH_THOROGOOD)
						pointparticles(PART_TURBO, self.origin - v_right * 16 - v_up * 16 - v_forward * 32, '0 0 0', 1);
					else
						pointparticles(PART_TURBO, self.origin - v_up * 16 - v_forward * 32, '0 0 0', 1);
				}
				else
					pointparticles(PART_BUBBLE, self.origin - v_up * 16 - v_forward * 32, '0 0 0', 1);

				if (self.onfire_finished > time) // Remove being on fire faster!
					self.onfire_finished = self.onfire_finished - 0.1;
				if (self.frozen_finished > time) // Remove being frozen faster!
					self.frozen_finished = self.frozen_finished - 0.03;

				if (self.turbo_fuel > 0)
					self.turbo_fuel = self.turbo_fuel - 1;
				else
					self.turbo_fuel = 0; // prevent underflow
			}
			else
				self.turbo = self.turbo_held = FALSE;
		}
		else
		{
			if (self.turbo_fuel > 0) // stop sound spam
				self.turbosfx = FALSE;
		}

		if (!self.turbo)
			self.drift = self.button2;
		if (self.drift)
		{
			if (!self.handbreak_sfx)
			{
				stuffcmd (self, "play handbreak.wav\n"); // FIXME: Ugly
				self.handbreak_sfx = TRUE;
			}
			if (self.airborne_cnt <= 10 && self.realspeed >= 20)
			{
				if (!self.driftspeed_timer)
					self.driftspeed_timer = 10;
				self.car_stabilizer = -2; // Harder to tip while drifting (lowers chassis)
				car_drift();
				if (self.turbo_fuel < 100)
					self.turbo_fuel = self.turbo_fuel + 1; // Drift adds turbo fuel
				else
					self.turbo_fuel = 100;
			}
		}
		else
		{
			self.handbreak_sfx = FALSE;
			if (self.driftspeed_timer != 0)
			{
				if (self.driftspeed_timer > 0)
					self.driftspeed_timer = self.driftspeed_timer - 1; // Remove it faster when button release
				else
					self.driftspeed_timer = 0;
			}
			else
			{
				if (self.car_stabilizer < -1)
					self.car_stabilizer = self.car_stabilizer + 0.05; // Lower # = more stability after letting go of drift
				else
					self.car_stabilizer = -1; // Restore normal stablizer

				if (f_left.physobj_friction_ground_y < f_left.wheelsidefriction)
					f_left.physobj_friction_ground_y = f_left.physobj_friction_ground_y + 1;
				else
					f_left.physobj_friction_ground_y = f_left.wheelsidefriction;

				if (f_right.physobj_friction_ground_y < f_right.wheelsidefriction)
					f_right.physobj_friction_ground_y = f_right.physobj_friction_ground_y + 1;
				else
					f_right.physobj_friction_ground_y = f_right.wheelsidefriction;
					
				if (b_left.physobj_friction_ground_y < b_left.wheelsidefriction)
					b_left.physobj_friction_ground_y = b_left.physobj_friction_ground_y + 1;
				else
					b_left.physobj_friction_ground_y = b_left.wheelsidefriction;

				if (b_right.physobj_friction_ground_y < b_right.wheelsidefriction)
					b_right.physobj_friction_ground_y = b_right.physobj_friction_ground_y + 1;
				else
					b_right.physobj_friction_ground_y = b_right.wheelsidefriction;
			}
		}
		//local string debug = ftos(self.driftspeed_timer);
		//bprint ("Drift Speed: ", debug, "\n");
		//RennyC

		float car_angs = self.driving.angles_y;
		if (car_angs > 180)
			car_angs -= 360;
		float move = car_angs - self.v_angle_y;
		if (car_angs > self.v_angle_y)
		{
			if (move > 180)
				move = move - 360;
		}
		else
		{
			if (move < -180)
				move = move + 360;
		}

		car_angs = self.driving.angles_x;
		if (car_angs > 180)
			car_angs -= 360;
		float pitch = car_angs - self.v_angle_x;
		if (car_angs > self.v_angle_x)
		{
			if (pitch > 180)
				pitch = pitch - 360;
		}
		else
		{
			if (pitch < -180)
				pitch = pitch + 360;
		}
		// RennyC: Game started & unfrozen , unlock tires
		if (self.frozen_finished < time)
		{
			if (f_right.physobj_stiction != 10)
				f_right.physobj_stiction = 10;
			if (f_left.physobj_stiction != 10)
				f_left.physobj_stiction = 10;
			if (b_right.physobj_stiction != 10)
				b_right.physobj_stiction = 10;
			if (b_left.physobj_stiction != 10)
				b_left.physobj_stiction = 10;
		}
	}
	else // RennyC: Race not started, lock tires
	{
		if (!ragewar)
		{
			f_right.physobj_stiction = 99999;
			f_left.physobj_stiction = 99999;
			b_right.physobj_stiction = 99999;
			b_left.physobj_stiction = 99999;
		}
		else if (race_status < RACE_STARTED || self.frozen_finished > time) // Lock DM players tires before count-down & frozen status
		{
			f_right.physobj_stiction = 99999;
			f_left.physobj_stiction = 99999;
			b_right.physobj_stiction = 99999;
			b_left.physobj_stiction = 99999;
		}
	}
	// RennyC

	// RennyC: Check if the car is airborne by checking all tire onground flags
	if (!(self.driving.frontright.flags & FL_ONGROUND && self.driving.frontleft.flags & FL_ONGROUND
	&& self.driving.backright.flags & FL_ONGROUND && self.driving.backleft.flags & FL_ONGROUND)) // all tires are off the ground
		self.airborne_cnt = self.airborne_cnt + 1;
	else
	{
		if (self.airborne_cnt > 29) // landed
			sound (self, CHAN_AUTO, "land.wav", 1, ATTN_NORM);
		self.airborne_cnt = 0;
	}
	// RennyC
	if (self.realspeed <= 10 && !self.keyflags) // RennyC: schpulds stuff applied to RenRacer
		Car_Brake();

	CarStabilizeCheat(); // RennyC: Car auto corrects to prevent flipping

	makevectors(self.driving.angles);
	float backwards = (self.driving.velocity * v_forward) < 0;
	if (backwards)
		self.backward = TRUE;
	else
		self.backward = FALSE;

	Car_Turn(move, backwards);
	
	self.velocity = '0 0 0';
	self.frame = 0;
};

vector() Car_SpringyOrigin =
{
	entity car = self.driving;
	entity tbleft = car.backleft.enemy;
	entity tbright = car.backright.enemy;
	entity tfleft = car.frontleft.enemy;
	entity tfright = car.frontright.enemy;

	vector org = tbleft.origin + tbright.origin + tfleft.origin + tfright.origin;
	org = (org / 4) + car.lmat_up * 16;
#if defined(SMOOTH)
	vector oldorg = tbleft.oldorigin + tbright.oldorigin + tfleft.oldorigin + tfright.oldorigin;
	oldorg = (oldorg / 4) + car.lmat_up * 16;
	vector pos = lerpVector(oldorg, org, 1-(car.frags - time)*10);
#else
	vector pos = org;
#endif
	return pos;
};


void(entity wheel, entity car) AddWheelStatic =
{
	local entity stat;

	stat = spawn();
	stat.classname = "phys_static";
	stat.netname = wheel.netname;
	setorigin(stat, wheel.origin);
	stat.model = wheel.model;
	wheel.model = 0;
	wheel.classname = "phys_particle";
	stat.base_pose = wheel.base_pose;
	stat.relative_org = wheel.relative_org;
	stat.relative_forward = wheel.relative_forward;
	stat.relative_left = wheel.relative_forward;
	stat.relative_up = wheel.relative_forward;

	stat.physobj_next = car.physobj_staticlist;
	car.physobj_staticlist = stat;
}

void() StartFuncVehicle =
{
	entity e;

	makevectors(self.angles);
	matrix_forward = v_forward;
	matrix_left = -v_right;
	matrix_up = v_up;
	if (self.phys_particle_target) {
		e = find(world, targetname, self.phys_particle_target);
		while(e) {
			e.physobj_next = self.physobj_particlelist;
			self.physobj_particlelist = e;
			e.owner = self;
			e.relative_org = Matrix_MultiplyPoint(e.origin - self.origin);
			e.base_pose = e.angles - self.angles;
			makevectors(e.base_pose);
			e.relative_forward = v_forward;
			e.relative_left = -v_right;
			e.relative_up = v_up;
			if (e.classname == "func_vehicle_wheel" || e.classname == "phys_wheel")
				AddWheelStatic(e, self);
			e = find(e, targetname, self.phys_particle_target);
		}
	}
	if (self.phys_hitmodel_target) {
		e = find(world, targetname, self.phys_hitmodel_target);
		while(e) {
			e.physobj_next = self.physobj_hitmodel;
			self.physobj_hitmodel = e;
			e.owner = self;
			e.relative_org = Matrix_MultiplyPoint(e.origin - self.origin);
			e.base_pose = e.angles - self.angles;
			makevectors(e.base_pose);
			e.relative_forward = v_forward;
			e.relative_left = -v_right;
			e.relative_up = v_up;
			e = find(e, targetname, self.phys_hitmodel_target);
		}
	}
	if (self.phys_static_target){
		e = find(world, targetname, self.phys_static_target);
		while(e) {
			e.physobj_next = self.physobj_staticlist;
			self.physobj_staticlist = e;
			e.owner = self;
			e.relative_org = Matrix_MultiplyPoint(e.origin - self.origin);
			e.base_pose = e.angles - self.angles;
			makevectors(e.base_pose);
			e.relative_forward = v_forward;
			e.relative_left = -v_right;
			e.relative_up = v_up;
			e = find(e, targetname, self.phys_static_target);
		}
	}

	self.physobj_flags |= PHFLAGS_VEHICLE;
	Phys_MakeIntoPhysicsObject(self, self.origin, matrix_forward, matrix_left, matrix_up, '0 0 1', 0);
	self.physobj_impactevent = PushAndDamageTarget;
	Car_InitVehicle(self);
}