//
// skyscraper - car 4
//

entity() skyscraper =
{
	self.vehicle = VEH_SKYSCRAPER;
	self.health = self.max_health = 150; // max health is also armor
	self.speed = 850; // also acceleration
	self.max_speed = 700;
	self.handling = 100; // poor handling
	self.pushfactor = 0.03;

	local entity obj, part;

	obj = spawn();
	obj.netname = "skyscraper";
	obj.physobj_mass = 1000; // RennyC: This is used for car collision stuff, doesn't affect RenRacer
	obj.physobj_impactevent = PushAndDamageTarget;
	setorigin(obj, self.origin);

	//
	// body / chassis
	//

	part = spawn();
	part.physobj_next = obj.physobj_staticlist;
	obj.physobj_staticlist = part;
	part.owner = obj;
	part.classname = "phys_static";
	part.netname = "chassis";
	part.model = "progs/Skyscraper_body.mdl";
	part.relative_org = '0 0 0';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	//

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
		part.relative_org = '0 28 0';
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
		part.relative_org = '0 -28 0';
		part.relative_forward = '1 0 0';
		part.relative_left = '0 1 0';
		part.relative_up = '0 0 1';
	}
	//

	//
	// wheels
	//

	// frontleft
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "frontleft";
	part.relative_org = '36 25 -40';
	part.physobj_spring_length = 15;
	part.physobj_spring_force = '1 4 0.01';
	part.relative_size = 20;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 2 5';
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
	part.model = "progs/Skyscraper_wheel.mdl";
	part.relative_org = '43.5 30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	//
	
	// frontright
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "frontright";
	part.relative_org = '36 -25 -40';
	part.physobj_spring_length = 15;
	part.physobj_spring_force = '1 4 0.01';
	part.relative_size = 20;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 2 5';
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
	part.model = "progs/Skyscraper_wheel.mdl";
	part.relative_org = '43.5 -30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	//

	// backleft
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "backleft";
	part.relative_org = '-44 25 -40';
	part.physobj_spring_length = 15;
	part.physobj_spring_force = '1 4 0.01';
	part.relative_size = 20;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 2 5';
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
	part.model = "progs/Skyscraper_wheel.mdl";
	part.relative_org = '-43.5 30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	//

	// backright
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "backright";
	part.relative_org = '-44 -25 -40';
	part.physobj_spring_length = 15;
	part.physobj_spring_force = '1 4 0.01';
	part.relative_size = 20;
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 18;
	part.part_mass = 1;
	part.physobj_stiction = 10;
	part.physobj_friction_ground = '0.225 2 5';
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
	part.model = "progs/Skyscraper_wheel.mdl";
	part.relative_org = '-43.5 -30 -24';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	//

	//
	// physics particles/sticks - all various points
	//

	// front/car hood
	part = spawn();
	part.physobj_next = obj.physobj_particlelist;
	obj.physobj_particlelist = part;
	part.owner = obj;
	part.classname = "phys_particle";
	part.netname = "point";
	part.relative_org = '57 0 -5';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.52;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_air = '0.25 0.25 0.1';
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
	part.relative_org = '-2.5 0 26';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.375;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_air = '0.25 0.25 0.1';
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
	part.relative_org = '-73.5 0 -8';
	part.relative_forward = '1 0 0';
	part.relative_left = '0 1 0';
	part.relative_up = '0 0 1';
	part.physobj_stepup = 1;
	part.part_mass = 0.575;
	part.physobj_stiction = 50;
	part.physobj_friction_ground = '8 8 8';
	part.physobj_friction_air = '0.25 0.25 0.1';
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