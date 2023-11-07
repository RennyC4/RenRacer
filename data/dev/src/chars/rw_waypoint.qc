//
// RennyC: Modified from AI Cafe, ragewar specific waypoint system
//

.float rw_waypoint_finished;
void() rw_waypoint_touch =
{
	if (other.owner.driving.classname != "player")
		return;
	if (clienttype(other.owner.driving) == CLIENTTYPE_REAL)
		return;
	if (other.owner.driving.rw_waypoint_finished > time)
		return;
	if (other.owner.driving.Last_RW_Waypoint == self.origin)
		return;

	// Update list
	bprint ("Before 1: ", vtos(other.owner.driving.Last_RW_Waypoint), "\n");

	other.owner.driving.Last_RW_Waypoint3 = other.owner.driving.Last_RW_Waypoint2;
	other.owner.driving.Last_RW_Waypoint2 = other.owner.driving.Last_RW_Waypoint;
	other.owner.driving.Last_RW_Waypoint = self.origin;

	bprint ("1: ", vtos(other.owner.driving.Last_RW_Waypoint), "\n");
	bprint ("2: ", vtos(other.owner.driving.Last_RW_Waypoint2), "\n");
	bprint ("3: ", vtos(other.owner.driving.Last_RW_Waypoint3), "\n");

	other.owner.driving.rw_waypoint_finished = time + 1;
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