//
// RennyC: Modified from AI Cafe, ragewar specific waypoint system
//

void() rw_waypoint_touch =
{
	if (other.owner.driving.classname != "player")
		return;
	if (other.owner.driving)
		entity toucher = other.owner.driving;
	if (clienttype(toucher) == CLIENTTYPE_REAL)
		return;

	if (toucher.Last_RW_Waypoint2)
		toucher.Last_RW_Waypoint3 = toucher.Last_RW_Waypoint2;
	if (toucher.Last_RW_Waypoint)
		toucher.Last_RW_Waypoint2 = toucher.Last_RW_Waypoint;

	//bprint (ftos(toucher.Last_RW_Waypoint3_y), "\n");

	toucher.Last_RW_Waypoint = self.origin;
};

void(vector org, float which, optional float cnt) rw_create_waypoint =
{
	entity wp = spawn();
	wp.classname = "bot_waypoint";
	wp.solid = SOLID_TRIGGER;
	wp.movetype = MOVETYPE_NONE;
	wp.flags = FL_ITEM; // bigger touch box
	wp.touch = waypoint_touch;
	wp.waypoint_speed = cnt;

	if (cvar("developer") == 2)
		setmodel (wp, "progs/s_debug.spr");
	else
		setmodel (wp, "*null");

	setorigin(wp, org);
	setsize (wp, '-128 -128 -128', '128 128 128'); // bigger touch box
};

// Ragewar mapper placed entity
void() rw_bot_waypoint =
{
	if (!ragewar)
	{
		remove(self);
		return;
	}
	self.classname = "rw_bot_waypoint";
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.flags = FL_ITEM; // bigger touch box
	self.dimension_solid = 0;
	self.touch = rw_waypoint_touch;
	setorigin (self, self.origin + v_up * 8);

//	if (cvar("developer") == 2)
		setmodel (self, "progs/s_debug.spr");
//	else
//		setmodel (self, "*null");

	setsize (self, '-64 -64 -64', '64 64 64'); // bigger touch box
};