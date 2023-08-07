.entity frontright, frontleft, backright, backleft;
.entity gun;

float VEHICLE_NO_ROOF = 1;
float VEHICLE_PERMANENT_GUN = 2;

entity() hotrod;
entity() triton;

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

	// Spin Tires - RennyC
	tire.angles_z = 0; // Fix wacky tires on slopes (TODO: Needs to match Z of car chassis)
	makevectors(tire.angles);
	vector forward = normalize(v_forward);
	float pitch = -dotproduct(tire.angles, forward) * 360.0;
	if (plyrent_tireowner.realspeed >= 4)
		tire.angles_x += pitch * 0.1;

	traceline(tireparticle.origin, tireparticle.origin + tireparticle.lmat_up * -tire.frags, TRUE, tire);
	float tracelen = fabs(tireparticle.physobj_spring_length);
#if defined(SMOOTH)
	float f = 0.1;
#else
	float f = frametime;
#endif
	tire.frags = min(tire.frags + f*30, tracelen*trace_fraction);
	tire.oldorigin = tire.origin;
	setorigin(tire, trace_endpos + tireparticle.lmat_up * tireparticle.relative_size);
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
		local float plyralpha = car.driving.alpha;
		local vector plyrcmod = car.driving.colormod;
		e.dimension_hit = player_dimension_hit;
		e.dimension_solid = player_dimension_solid;
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
	
#if defined(SMOOTH)
	car.frags = time + 0.1;
	self.angles = vectoangles2(self.lmat_forward, self.lmat_up);
	setorigin(self, self.view_ofs);
	self.nextthink = time + 0.1;
#else
	self.nextthink = time;
#endif

	// RennyC - Send real (car) speed / angles to player
	local float r = vlen(car.velocity) * 0.1;
	local vector v = car.angles;
	if (car.driving.classname == "player")
	{
		car.driving.realang = v;
		car.driving.realspeed = r;
	}
};

#if defined(SMOOTH)
void() DriverThink =
{
	self.angles = vectoangles2(self.lmat_forward, self.lmat_up);
	setorigin(self, self.view_ofs);

	self.nextthink = time + 0.1;
};
#endif

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
	if (car.frontright && car.frontleft){
		e = car.physobj_sticklist;
		while (e)
		{
			if (e.physobj_p1 == car.frontright || e.physobj_p2 == car.frontright){
				if (e.physobj_p1 == car.frontleft || e.physobj_p2 == car.frontleft){
					e.physobj_flags |= PHFLAGS_STABILIZERBAR;
					break;
				}
			}
			e = e.physobj_next;
		}
	}
	if (car.backright && car.backleft){
		e = car.physobj_sticklist;
		while (e)
		{
			if (e.physobj_p1 == car.backright || e.physobj_p2 == car.backright){
				if (e.physobj_p1 == car.backleft || e.physobj_p2 == car.backleft){
					e.physobj_flags |= PHFLAGS_STABILIZERBAR;
					break;
				}
			}
			e = e.physobj_next;
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
		else if (e.netname == "roof")
		{
			if (car.spawnflags & VEHICLE_NO_ROOF){ // hide
				e.modelindex = 0;
			}
		}
#if defined(SMOOTH)
		else if (e.netname == "driver")
		{
			e.think = DriverThink;
			e.nextthink = time;
		}
#endif
		else if (e.netname == "turretbase")
		{
			car.gun = e;
			car.gun.gun = FindStaticOfName("turretswivel", car);
			car.gun.gun.gun = FindStaticOfName("turretbody", car);
			car.gun.gun.gun.gun = FindStaticOfName("turretbarrel", car);
			if (!(car.spawnflags & VEHICLE_PERMANENT_GUN)){ // hide
				car.gun.modelindex = 0;
				car.gun.gun.modelindex = 0;
				car.gun.gun.gun.modelindex = 0;
				car.gun.gun.gun.gun.modelindex = 0;
			}
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

float modelindex_null;

void(entity ply, entity car) Car_AttachToVehicle =
{
	entity oself;
	if (ply.driving){ // already sitting in car
		ply.driving = world;
		ply.solid = SOLID_SLIDEBOX;
		ply.movetype = MOVETYPE_WALK;
		ply.modelindex = modelindex_player;
		stuffcmd(ply, "chase_active 0\n");
		stuffcmd(ply, "crosshair 1\n");
		oself = self;
		self = ply;
		if (!TryPlacePlayer(FindStaticOfName("rightdoor", car)))
			if (!TryPlacePlayer(FindStaticOfName("leftdoor", car)))
				if (!TryPlacePlayer(FindStaticOfName("topexit", car)))
					if (!TryPlacePlayer(FindStaticOfName("botexit", car)))
						if (!TryPlacePlayer(FindStaticOfName("backexit", car)))
							TryPlacePlayer(FindStaticOfName("frontexit", car));
		self = oself;
		car.driving = world;
	}
	else {
		//ply.view_ofs = '0 0 16';
		ply.driving = car;
		ply.solid = SOLID_NOT;
		ply.movetype = MOVETYPE_NOCLIP;
		//ply.flags |= FL_FLY;
		ply.modelindex = modelindex_null;
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
		if (e.classname == "physics_object"){
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
	tright.physobj_flags = tright.physobj_flags - (tright.physobj_flags & PHFLAGS_RESTING);
	tleft.physobj_flags = tleft.physobj_flags - (tleft.physobj_flags & PHFLAGS_RESTING);
	f = 125;

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
	tleft = self.driving.backleft;
	tright = self.driving.backright;
	float allowAccelerateRight = tright.velocity * tright.lmat_forward < maxspeed;
	float allowAccelerateLeft = tleft.velocity * tleft.lmat_forward < maxspeed;
	if (allowAccelerateRight && tright.flags & FL_ONGROUND){
		tright.physobj_flags = tright.physobj_flags - (tright.physobj_flags & PHFLAGS_RESTING);
		tright.velocity = tright.velocity + tright.lmat_forward *speed*frametime;
	}
	if (allowAccelerateLeft && tleft.flags & FL_ONGROUND){
		tleft.physobj_flags = tleft.physobj_flags - (tleft.physobj_flags & PHFLAGS_RESTING);
		tleft.velocity = tleft.velocity + tleft.lmat_forward *speed*frametime;
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

		f_right.physobj_flags = f_right.physobj_flags - (f_right.physobj_flags & PHFLAGS_RESTING);
		f_left.physobj_flags = f_left.physobj_flags - (f_left.physobj_flags & PHFLAGS_RESTING);
		b_right.physobj_flags = b_right.physobj_flags - (b_right.physobj_flags & PHFLAGS_RESTING);
		b_left.physobj_flags = b_left.physobj_flags - (b_left.physobj_flags & PHFLAGS_RESTING);

		f_right.velocity = f_right.velocity + f_right.lmat_up *speed*frametime;
		b_right.velocity = b_right.velocity + b_right.lmat_up *speed*frametime;
		f_left.velocity = f_left.velocity - f_left.lmat_up *speed*frametime;	
		b_left.velocity = b_left.velocity - b_left.lmat_up *speed*frametime;	
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
	f_left.physobj_friction_ground_y = 0;
	f_right.physobj_friction_ground_y = 0;
	b_left.physobj_friction_ground_y = 0;
	b_right.physobj_friction_ground_y = 0;

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

	if (car_angs > self.v_angle_y)
		Phys_Force(self.driving, self.driving.physobj_mass * 0.35, (v_right * strength * -1) * frametime, worldorg - v_right * 16, -v_right);
	else
		Phys_Force(self.driving, self.driving.physobj_mass * 0.35, v_right * strength * frametime, worldorg + v_right * 16, +v_right);
};

// RennyC - helps to keep the car balanced if it's tipping in a cheaty manner
void() CarStabilizeCheat =
{
	if (self.realang_z > 30 && self.realang_z < 330)
	{
		if (self.realang_z > 180)
			Car_Roll(-4000, 500);
		else
			Car_Roll(4000, 500);
	}
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

	setorigin(self, Car_SpringyOrigin());
	if (race_status == RACE_STARTED && self.health > 0 && self.frozen_finished < time) // RennyC: Allow player to control the car
	{
		makevectors(self.v_angle);

		float forw = v_forward * self.velocity;
		if (forw > 100){
			self.keyflags = self.keyflags | KEY_UP; // RennyC
			Car_Accelerate(3000, 950);
		}
		else if (forw < -100){
			self.keyflags = self.keyflags | KEY_DOWN; // RennyC
			Car_Accelerate(-2500, 800);
		}
		else
		{
			if (self.keyflags & KEY_UP)
				self.keyflags = self.keyflags - KEY_UP;
			if (self.keyflags & KEY_DOWN)
				self.keyflags = self.keyflags - KEY_DOWN;
		}

		// RennyC: Speed Booster
		if (self.speed > 0 && self.speedboost_finished > time)
		{
			self.car_stabilizer = -6; // Harder to tip while speed boosting
			car_boost(self.speed);
			if (!self.waterlevel)
				pointparticles(PART_SPEEDBOOST, self.origin - v_up * 16 - v_forward * 32, '0 0 0', 1);
			else
				pointparticles(PART_BUBBLE, self.origin - v_up * 16 - v_forward * 32, '0 0 0', 1);
		}

		float roll = v_right * self.velocity;
		if (roll > 100){
			self.keyflags = self.keyflags | KEY_RIGHT; // RennyC
			Car_Roll(-4000, 350);
		}
		else if (roll < -100){
			self.keyflags = self.keyflags | KEY_LEFT; // RennyC
			Car_Roll(4000, 350);
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
			self.turbo = self.button0;
		if (self.turbo)
		{
			if (self.turbo_fuel > 0)
			{
				if (self.turbo_fuel <= 10 && !self.turbo_warning)
				{
					stuffcmd (self, "play warning.wav\n"); // FIXME: Ugly
					self.turbo_warning = TRUE;
				}
				if (self.turbo_fuel > 10)
					self.turbo_warning = FALSE;

				if (!self.turbosfx)
				{
					sound (self, CHAN_WEAPON, "turbo.wav", 1, ATTN_NORM);
					self.turbosfx = TRUE;
				}
				Car_Accelerate(3000, 950);
				car_boost(2000);
				makevectors(self.realang);

				if (!self.waterlevel)
					pointparticles(PART_TURBO, self.origin - v_up * 16 - v_forward * 32, '0 0 0', 1);
				else
					pointparticles(PART_BUBBLE, self.origin - v_up * 16 - v_forward * 32, '0 0 0', 1);

				if (self.onfire_finished > time) // Remove being on fire faster!
					self.onfire_finished = self.onfire_finished - 0.1;				
				if (self.turbo_fuel > 0)
					self.turbo_fuel = self.turbo_fuel - 1;
				else
					self.turbo_fuel = 0; // prevent overflow
			}
		}
		else
		{
			if (self.turbo_fuel > 0) // Stop sound spam
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
				self.car_stabilizer = -6; // Harder to tip while drifting (lowers chassis)
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

				if (f_left.physobj_friction_ground_y < 4.4)
					f_left.physobj_friction_ground_y = f_left.physobj_friction_ground_y + 1;
				else
					f_left.physobj_friction_ground_y = 4.4;

				if (f_right.physobj_friction_ground_y < 4.4)
					f_right.physobj_friction_ground_y = f_right.physobj_friction_ground_y + 1;
				else
					f_right.physobj_friction_ground_y = 4.4;
					
				if (b_left.physobj_friction_ground_y < 4.4)
					b_left.physobj_friction_ground_y = b_left.physobj_friction_ground_y + 1;
				else
					b_left.physobj_friction_ground_y = 4.4;

				if (b_right.physobj_friction_ground_y < 4.4)
					b_right.physobj_friction_ground_y = b_right.physobj_friction_ground_y + 1;
				else
					b_right.physobj_friction_ground_y = 4.4;
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
		// RennyC: Race started, unlock tires
		if (f_right.physobj_stiction != 10)
			f_right.physobj_stiction = 10;
		if (f_left.physobj_stiction != 10)
			f_left.physobj_stiction = 10;
		if (b_right.physobj_stiction != 10)
			b_right.physobj_stiction = 10;
		if (b_left.physobj_stiction != 10)
			b_left.physobj_stiction = 10;
	}
	else // RennyC: Race not started, lock tires
	{
		if (!deathmatch)
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
	self.modelindex = modelindex_null;
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

/*
void() automake_triton =
{
	entity car = triton();
	
	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin + '0 0 16', v_forward, v_right * -1, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
	Car_AttachToVehicle(self, car);
};
*/

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

	Phys_MakeIntoPhysicsObject(self, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	self.physobj_impactevent = PushAndDamageTarget;
	Car_InitVehicle(self);
}

// keeping the titular name for the memes, but this is a point entity
/*QUAKED func_vehicle (1 0 0) (-8 -8 -8) (8 8 8)
This is the entity which brings all the disjointed particles, statics and hitmodels together for a fully simulated vehicle

"targetname" must be defined, used by the physics object to find the particle
"model" must be defined, loads a .bsp model to use for pushing objects around
"phys_particle_target" must be defined, the targetname of all the particles and/or wheels in this object
"phys_static_target" the targetname of all the statics in this object
"phys_hitmodel_target" the targetname of all the hitmodels in this object
*/
void() func_vehicle =
{
	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
	precache_model("progs/null.spr");

	self.think = StartFuncVehicle;
	self.nextthink = 0.2;
};
/*QUAKED phys_hitmodel (1 0 0) (-8 -8 -8) (8 8 8)
Hitmodels are brushes that move together with the physics-object and push entities around (for example monsters).

"targetname" must be defined, used by the physics object to find the particle
"model" must be defined, loads a .bsp model to use for pushing objects around
"angle" base-pose for the physics object
*/
void() phys_hitmodel =
{
	self.physobj_flags = self.physobj_flags | PHFLAGS_BSPMODEL; // this is always a bmodel	
	setorigin (self, self.origin);
	if (!self.model)
		error("hitmodel with no model");
	precache_model(self.model);
	setmodel (self, self.model);
}
/*QUAKED func_vehicle_hitmodel (1 0 0) ?
Brush version of phys_hitmodel.

Hitmodels are brushes that move together with the physics-object and push entities around (for example monsters).

"targetname" must be defined, used by the physics object to find the particle
*/
void() func_vehicle_hitmodel =
{
	phys_hitmodel();
}
/*QUAKED phys_particle (1 0 0) (-8 -8 -8) (8 8 8)
Particles are what define the simulation-shape of a physics-object. These collide with the world and other entities.

"targetname" must be defined, used by the physics object to find the particle
"angle" base-pose angle for this particle in the physics object
"physobj_spring_length" length of spring for this particle, primarily meant for wheels (see phys_wheel instead)
"physobj_spring_force" x and y are spring forces based on distance to surface, z is unused, primarily meant for wheels (see phys_wheel instead)
"relative_size" extra-height for particles as an offset from the floor, good default 1
"physobj_stepup" quake-style step-up in stairs. relative_size already gives some step-up inherently, but if relative_size is 0 the quake default would be 18
"part_mass" mass multiplier of this particle, affects center of mass of entire object, mass of 0 makes particle stick in mid-air, good default 1
"physobj_stiction" half-assed attempt at making physics objects not slide infinitely on slopes, good default 10
"physobj_friction_ground" directional ground friction, good default '8 8 8'
"physobj_friction_water" directional water friction, good default '2 2 2'
"physobj_friction_air" directional air friction
"physobj_bounce" 1 means no bounce, 2 means perfect reflection-bounce, good default 1.025
"physobj_buoyancy" gravity multiplier when under-water, good default -0.75
*/
void() phys_particle =
{
	setorigin (self, self.origin);
	if (self.model){
		precache_model(self.model);
		setmodel (self, self.model);
	}
}
/*QUAKED phys_static (1 0 0) (-8 -8 -8) (8 8 8)
Statics are objects which follow the physics-object around but don't affect the physics themselves. Useful for models visually representing the physics-object, and for entrances/exits in a vehicle.

"targetname" must be defined, used by the physics-object to find the static
"model" the model to be loaded for visualization
"netname" in vehicle-contexts useful names are chassis, roof, driver, but also rightdoor, leftdoor, topexit, botexit, backexit, frontexit
"angle" base-pose angle for this static in the physics-object
*/
void() phys_static =
{
	setorigin (self, self.origin);
	if (self.model){
		precache_model(self.model);
		setmodel (self, self.model);
	}
}
/*QUAKED func_vehicle_static (1 0 0) ?
Brush version of phys_static.

Statics are objects which follow the physics-object around but don't affect the physics themselves. Useful for models visually representing the physics-object, and for entrances/exits in a vehicle.

"targetname" must be defined, used by the physics-object to find the static
"netname" in vehicle-contexts useful names are chassis, roof, driver, but also rightdoor, leftdoor, topexit, botexit, backexit, frontexit
*/
void() func_vehicle_static =
{
	self.physobj_flags = self.physobj_flags | PHFLAGS_BSPMODEL;
	phys_static();
}

/*QUAKED phys_wheel (1 0 0) (-8 -8 -8) (8 8 8)
Wheels are useful for vehicles! They're a combo of a particle and a static. Make four of these, with correct netnames and targetnames.

"targetname" must be defined, used by the physics object to find the wheel
"netname" useful names are frontleft, frontright, backleft, backright
"model" the model to be loaded for visualization
"angle" base-pose angle for this wheel in the physics object
"physobj_spring_length" length of spring for this wheel, good default 12
"physobj_spring_force" x and y are spring forces based on distance to surface, z is unused, good default '2 4 0'
"relative_size" radius of wheel, good default 14
"physobj_stepup" quake-style step-up in stairs. relative_size already gives some step-up inherently, but if relative_size is 0 the quake default would be 18
"part_mass" mass multiplier of this wheel, affects center of mass of entire object, mass of 0 makes wheel stick in mid-air, good default 1
"physobj_stiction" half-assed attempt at making physics objects not slide infinitely on slopes, good default 10
"physobj_friction_ground" directional ground friction, higher value on y than x is what allows steering of vehicles. z is used for damping the spring! good default '0.225 3.3 5'
"physobj_friction_water" directional water friction, good default '2 2 2'
"physobj_friction_air" directional air friction
"physobj_bounce" 1 means no bounce, 2 means perfect reflection-bounce, good default 1.025
"physobj_buoyancy" gravity multiplier when under-water, good default -0.75
*/
void() phys_wheel =
{
	setorigin (self, self.origin);
	if (self.model){
		precache_model(self.model);
	}
}
/*QUAKED func_vehicle_wheel (1 0 0) ?
Brush version of phys_wheel.

Wheels are useful for vehicles! They're a combo of a particle and a static. Make four of these, with correct netnames and targetnames.

"targetname" must be defined, used by the physics object to find the wheel
"netname" useful names are frontleft, frontright, backleft, backright
"physobj_spring_length" length of spring for this wheel, good default 12
"physobj_spring_force" x and y are spring forces based on distance to surface, z is unused, good default '2 4 0'
"relative_size" radius of wheel, good default 14
"physobj_stepup" quake-style step-up in stairs. relative_size already gives some step-up inherently, but if relative_size is 0 the quake default would be 18
"part_mass" mass multiplier of this wheel, affects center of mass of entire object, mass of 0 makes wheel stick in mid-air, good default 1
"physobj_stiction" half-assed attempt at making physics objects not slide infinitely on slopes, good default 10
"physobj_friction_ground" directional ground friction, higher value on y than x is what allows steering of vehicles. z is used for damping the spring! good default '0.225 3.3 5'
"physobj_friction_water" directional water friction, good default '2 2 2'
"physobj_friction_air" directional air friction
"physobj_bounce" 1 means no bounce, 2 means perfect reflection-bounce, good default 1.025
"physobj_buoyancy" gravity multiplier when under-water, good default -0.75
*/
void() func_vehicle_wheel =
{
	self.physobj_flags = self.physobj_flags | PHFLAGS_BSPMODEL;
	phys_wheel();
}

// legacy, hopefully can remove in next release
void() func_vehicle_builtins =
{
	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
	precache_model("progs/null.spr");

	entity car;
	if (self.netname == "triton"){
		precache_model("progs/test/whl.mdl");
		precache_model("progs/test/triton.mdl");
		car = triton();
	}
	else if (self.netname == "hotrod"){
		precache_model("progs/HotRod_body.mdl");
		precache_model("progs/HotRod_roof.mdl");
		precache_model("progs/HotRod_player_driver.mdl");
		precache_model("progs/HotRod_wheel_front_L.mdl");
		precache_model("progs/HotRod_wheel_rear_L.mdl");
		precache_model("progs/HotRod_wheel_front_R.mdl");
		precache_model("progs/HotRod_wheel_rear_R.mdl");
		precache_model("progs/HotRod_turret_base.mdl");
		precache_model("progs/HotRod_turret_swivel.mdl");
		precache_model("progs/HotRod_turret_body.mdl");
		precache_model("progs/HotRod_turret_barrel.mdl");
		car = hotrod();
	}
	//car.netname = self.netname;
	
	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};
// legacy, hopefully can remove in next release
void() func_vehicle_triton =
{
	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
	precache_model("progs/null.spr");

	precache_model("progs/test/whl.mdl");
	precache_model("progs/test/triton.mdl");
	entity car = triton();

	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};
/*QUAKED vehicle_hotrod (1 0 0) (-8 -8 -8) (8 8 8) VEHICLE_NO_ROOF VEHICLE_PERMANENT_GUN
The built-in Mad Max styled hotrod. 

SPAWNFLAGS
"vehicle_no_roof" convertible style
"vehicle_permanent_gun" turret always active
*/
void() vehicle_hotrod =
{
	precache_model("maps/cube16.bsp");
	precache_model("maps/cube32.bsp");
	precache_model("maps/round16.bsp");
	precache_model("maps/round32.bsp");

	if (cvar("developer") != 0){
		precache_model("progs/debug/org.mdl");
		precache_model("progs/debug/orgbig.mdl");
	}
	precache_model("progs/null.spr");

	precache_model("progs/HotRod_body.mdl");
	precache_model("progs/HotRod_roof.mdl");
	precache_model("progs/HotRod_player_driver.mdl");
	precache_model("progs/HotRod_wheel_front_L.mdl");
	precache_model("progs/HotRod_wheel_rear_L.mdl");
	precache_model("progs/HotRod_wheel_front_R.mdl");
	precache_model("progs/HotRod_wheel_rear_R.mdl");
	precache_model("progs/HotRod_turret_base.mdl");
	precache_model("progs/HotRod_turret_swivel.mdl");
	precache_model("progs/HotRod_turret_body.mdl");
	precache_model("progs/HotRod_turret_barrel.mdl");
	entity car = hotrod();
	car.spawnflags = self.spawnflags;
	
	makevectors(self.angles);
	car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
	Car_InitVehicle(car);
};
// legacy, hopefully can remove in next release
void() func_vehicle_hotrod =
{
	vehicle_hotrod();
};
