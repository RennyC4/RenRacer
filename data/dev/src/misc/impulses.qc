/*
+--------+
|Impulses|
+--------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Handle and execute "Impulse" commands - as entered from console.           |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

void(vector dest) car_teleport =
{
	// This is a WIP
	sprint(self, "car_teleport(); called\n");
	
	// Update vehicle particle origins
	local entity part = self.driving.physobj_particlelist;
	while(part)
	{
		setorigin(part, dest);
		//part.velocity = '0 0 0';
		part.oldorigin = dest;
		part = part.physobj_next;
	}
	// Update vehicle hitmodel origins
	local entity hitmodel = self.driving.physobj_hitmodel;
	while (hitmodel)
	{
		setorigin(hitmodel, dest);
		//hitmodel.velocity = '0 0 0';
		hitmodel.oldorigin = dest;
		hitmodel = hitmodel.physobj_next;
	}
	force_retouch = 2;
};

void() CheckImpulses =
{
	if (self.impulse == 1)
		headlights_toggle();
	if (self.impulse == 2)
		car_teleport('0 0 160');
	if (self.impulse == 3)
	{
		create_waypoint(self.origin, total_waypoints, 0);
		bprint("Waypoint #: ", ftos(total_waypoints), "\n");
	}
	if (self.impulse == 4)
	{
		local entity way = find(world, classname, "bot_waypoint");
		while (way)
		{
			bprint("create_waypoint (");
			bprint(vtos(way.origin));
			bprint(", ");
			bprint(ftos(way.waypoint));
			bprint(", ");
			bprint(ftos(way.speed));
			bprint(");\n");
			way = find(way, classname, "bot_waypoint");
		}
	}
	self.impulse = 0;
};