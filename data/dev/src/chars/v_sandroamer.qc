//
// sandroamer - car 10
//

entity() sandroamer =
{
	self.vehicle = VEH_SANDROAMER;
	self.health = self.max_health = 100; // max health is also armor
	self.speed = 1750; // also acceleration
	self.max_speed = 955;
	self.handling = 45; // low handling
	self.pushfactor = 0.12;

	local entity obj, part;

	obj = spawn();
	obj.netname = "sandroamer";
	obj.physobj_mass = 1000; // RennyC: This is used for car collision stuff, doesn't affect RenRacer
	obj.physobj_impactevent = PushAndDamageTarget;
	setorigin(obj, self.origin);

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "chassis";
	part.model = "progs/SandRoamer_body.mdl";
	part.relative_org = '0 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	//Guns for ragewar
	if (ragewar)
	{
		part = spawn();
		part.physobj_next = obj.physobj_staticlist;
		obj.physobj_staticlist = part;
		part.owner = obj;
		part.classname = "phys_static";
		part.netname = "GunLeft";
		part.model = "progs/mountedgun.mdl";
		part.relative_org = '22 15 7';
		part.relative_forward = '1 0 0';
		part.relative_left = '0 -1 0';
		part.relative_up = '0 0 1';

		part = spawn();
		part.physobj_next = obj.physobj_staticlist;
		obj.physobj_staticlist = part;
		part.owner = obj;
		part.classname = "phys_static";
		part.netname = "GunRight";
		part.model = "progs/mountedgun.mdl";
		part.relative_org = '22 -15 7';
		part.relative_forward = '1 0 0';
		part.relative_left = '0 1 0';
		part.relative_up = '0 0 1';
	}
	//

	// frontleft
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "frontleft";
	part.relative_org = '40 25 -15.0';
	part.physobj_spring_length = 10;
	part.physobj_spring_force = '1 4 0.02'; // RennyC: Old default was '2 4 0'
	part.relative_size = 11;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 3.3 5';
	if(clienttype(self) == CLIENTTYPE_BOT) part.physobj_friction_ground = '0.225 4.4 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;
	part.wheelsidefriction = part.physobj_friction_ground_y;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "frontleft";
	part.model = "progs/Razorback_wheel.mdl";
	part.relative_org = '43.5 30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	
	// frontright
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "frontright";
	part.relative_org = '40 -25 -15.0';
	part.physobj_spring_length = 10;
	part.physobj_spring_force = '1 4 0.02'; // RennyC: Old default was '2 4 0'
	part.relative_size = 11;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 3.3 5';
	if(clienttype(self) == CLIENTTYPE_BOT) part.physobj_friction_ground = '0.225 4.4 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;
	part.wheelsidefriction = part.physobj_friction_ground_y;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "frontright";
	part.model = "progs/Razorback_wheel.mdl";
	part.relative_org = '43.5 -30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// backleft
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "backleft";
	part.relative_org = '-31 27 -18';
	part.physobj_spring_length = 10;
	part.physobj_spring_force = '1 4 0.02'; // RennyC: Old default was '2 4 0'
	part.relative_size = 14;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 3 5';
	if(clienttype(self) == CLIENTTYPE_BOT) part.physobj_friction_ground = '0.225 4.4 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;
	part.wheelsidefriction = part.physobj_friction_ground_y;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "backleft";
	part.model = "progs/Razorback_wheel.mdl";
	part.scale = 1.3;
	part.relative_org = '-43.5 30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// backright
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "backright";
	part.relative_org = '-31 -27 -18';
	part.physobj_spring_length = 10;
	part.physobj_spring_force = '1 4 0.02'; // RennyC: Old default was '2 4 0'
	part.relative_size = 14;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 3 5';
	if(clienttype(self) == CLIENTTYPE_BOT) part.physobj_friction_ground = '0.225 4.4 8';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;
	part.wheelsidefriction = part.physobj_friction_ground_y;

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "backright";
	part.model = "progs/Razorback_wheel.mdl";
	part.scale = 1.3;
	part.relative_org = '-43.5 -30 -14';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';

	// all various points
	// front/car hood
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	part.relative_org = '62 0 2.5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.5;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
//	part.physobj_friction_air = '0 0 0';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	// roof
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	part.relative_org = '0 0 15';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.875;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
//	part.physobj_friction_air = '0 0 0';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	// rear particle (trunk)
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	part.relative_org = '-48 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.5;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
//	part.physobj_friction_air = '0 0 0';
	part.physobj_friction_water = '2 2 2';
	part.physobj_bounce = 1.025;
	part.physobj_buoyancy = -0.75;

	//
	// hitmodels - used for car/projectile collisions
	//

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round32.bsp";
	part.relative_org = '48 0 -3';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round32.bsp";
	part.relative_org = '28.4 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round32.bsp";
	part.relative_org = '8.8 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round32.bsp";
	part.relative_org = '-10.8 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round32.bsp";
	part.relative_org = '-30.4 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round32.bsp";
	part.relative_org = '-50 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;
	// roof hitmodels
	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '-2 6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '-2 -6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '-14 6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '-14 -6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '-30 6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '-30 -6 16';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	//wheel hitmodels
	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '-49.84 -25 -14';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '-49.84 25 -14';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '47.5 -21 -13.5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	part = spawn();
	part.physobj_next = obj.physobj_hitmodel;
	obj.physobj_hitmodel = part;
	part.owner = obj;
	part.classname = "phys_hitmodel";
	part.model = "maps/round16.bsp";
	part.relative_org = '47.5 21 -13.5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.th_pain = Car_Pain;

	return obj;
}