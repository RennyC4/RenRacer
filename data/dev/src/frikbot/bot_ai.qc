/***********************************************
*                                              *
*            FrikBot General AI                *
*     "The I'd rather be playing Quake AI"     *
*                                              *
***********************************************/

/*

This program is in the Public Domain. My crack legal
team would like to add:

RYAN "FRIKAC" SMITH IS PROVIDING THIS SOFTWARE "AS IS"
AND MAKES NO WARRANTY, EXPRESS OR IMPLIED, AS TO THE
ACCURACY, CAPABILITY, EFFICIENCY, MERCHANTABILITY, OR
FUNCTIONING OF THIS SOFTWARE AND/OR DOCUMENTATION. IN
NO EVENT WILL RYAN "FRIKAC" SMITH BE LIABLE FOR ANY
GENERAL, CONSEQUENTIAL, INDIRECT, INCIDENTAL,
EXEMPLARY, OR SPECIAL DAMAGES, EVEN IF RYAN "FRIKAC"
SMITH HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES, IRRESPECTIVE OF THE CAUSE OF SUCH DAMAGES. 

You accept this software on the condition that you
indemnify and hold harmless Ryan "FrikaC" Smith from
any and all liability or damages to third parties,
including attorney fees, court costs, and other
related costs and expenses, arising out of your use
of this software irrespective of the cause of said
liability. 

The export from the United States or the subsequent
reexport of this software is subject to compliance
with United States export control and munitions
control restrictions. You agree that in the event you
seek to export this software, you assume full
responsibility for obtaining all necessary export
licenses and approvals and for assuring compliance
with applicable reexport restrictions. 

Any reproduction of this software must contain
this notice in its entirety. 

*/

void() headlights_on;
void() headlights_off;
void(entity targ, vector dest, float silent, float stop) car_teleport;
float(float y1, float y2) angcomp;

.float bot_backup_finished;
.float bot_search_finished;
.float bot_search_count;

.entity old_goalentity;
.entity goalentity_waypoint;
.entity goalentity_checkpoint;
.entity goalentity_goal;

.float goalentity_time;

/*
=============
infront (of car)

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ, float howmuch) infront =
{
	makevectors (self.realang);
	local vector vec = normalize (targ.origin - self.origin);
	local float dot = vec * v_forward;

	if (dot > howmuch)
		return TRUE;
	return FALSE;
};

/*
=============
infront2 (view angle)

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ, float howmuch) infront2 =
{
	makevectors (self.v_angle);
	local vector vec = normalize (targ.origin - self.origin);
	local float dot = vec * v_forward;

	if (dot > howmuch)
		return TRUE;
	return FALSE;
};

/*
=============
infront3 (angles)

returns 1 if the entity is in front (in sight) of self
=============
*/
void(vector ang) makevectors_mdl;
float(entity targ, float howmuch) infront3 =
{
	makevectors_mdl (self.angles);
	//makevectors (self.angles);
	local vector vec = normalize (targ.origin - self.origin);
	local float dot = vec * v_forward;

	if (dot > howmuch)
		return TRUE;
	return FALSE;
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
	traceline (spot1, spot2, TRUE, self);	// see through other monsters

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

bot_angle_set

Steer towards target

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void() bot_angle_set =
{
	makevectors_mdl(self.v_angle);

	if (self.goalentity)
	{
		vector view = vectoangles(self.goalentity.origin - self.origin);
		self.angles_y = view_y;
		// Cap X angle: Bots check their X angle for incline vs goalentity crap
		// at the same time don't allow straight up/down X, this will slow/stop their drive forward velocity
		if (self.angles_x > 10)
			self.angles_x = 10;
		if (self.angles_x < -10)
			self.angles_x = -10;
		//
		self.angles_z = 0;

		self.v_angle = view;
	}
};

.float findcheckpoint_fail;
void() GetGoalPoint =
{
	for (entity y = world;(y = find(y, classname, "bot_waypoint_goal"));)
	{
		self.goalentity_goal = y;
		self.findcheckpoint_fail = 0;
	}
};

float() FindGoalPoint =
{
	for (entity y = world;(y = find(y, classname, "bot_waypoint_goal"));)
	{
		if (visible(y))
		{
			self.goalentity_goal = y;
			self.findcheckpoint_fail = 0;
			return TRUE;
		}
	}
	return FALSE;
};

void() GetCheckPoint =
{
	for (entity y = world;(y = find(y, classname, "marker"));)
	{
		if (y.checkpoint == self.checkpoint + 1)
		{
			self.goalentity_checkpoint = y;
			self.goalentity_checkpoint.checkpoint = y.checkpoint;
			self.bot_search_count = 0;
			self.waypoint_speed = y.waypoint_speed; // Set waypoint speed on bot if marker has one
			self.findcheckpoint_fail = 0;
		}
	}
};

void() FindCheckPointDriving =
{
	for (entity y = world;(y = find(y, classname, "marker"));)
	{
		if (y.checkpoint == self.checkpoint + 1 && visible(y))
		{
			self.goalentity_checkpoint = y;
			self.goalentity_checkpoint.checkpoint = y.checkpoint;
			self.bot_search_count = 0;
			self.waypoint_speed = y.waypoint_speed; // Set waypoint speed on bot if marker has one
			self.findcheckpoint_fail = 0;
		}
	}
};

void() FindWayPoint =
{
	for (entity y = world;(y = find(y, classname, "bot_waypoint"));)
	{
		if (y.waypoint == self.waypoint + 1 && visible(y))
		{
			y.colormod = '1 1 5'; // For cvar developer 2
			self.goalentity_waypoint = y;
			self.goalentity_waypoint.waypoint = y.waypoint;
			self.bot_search_count = 0;
			self.waypoint_speed = y.waypoint_speed; // Set waypoint speed on bot
		}
	}
};

float() FindAnyVisibleWayPoint =
{
	for (entity y = world;(y = find(y, classname, "bot_waypoint"));)
	{
		if (visible(y) && y.waypoint != total_waypoints) // Don't grab the last waypoint, usually these are placed close to the start/finish flag and can confuse the bot
		{
			y.colormod = '1 1 5'; // For cvar developer 2
			self.goalentity_waypoint = y;
			self.goalentity_waypoint.waypoint = y.waypoint;
			self.bot_search_count = 0;
			self.waypoint_speed = y.waypoint_speed; // Set waypoint speed on bot
			return TRUE;
		}
	}
	return FALSE;
};

void() GetWayPoint =
{
	for (entity y = world;(y = find(y, classname, "bot_waypoint"));)
	{
		if (y.waypoint == self.waypoint + 1)
		{
			y.colormod = '1 1 5'; // For cvar developer 2
			self.goalentity_waypoint = y;
			self.goalentity_waypoint.waypoint = y.waypoint;
			self.bot_search_count = 0;
			self.waypoint_speed = y.waypoint_speed; // Set waypoint speed on bot
		}
	}
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotAI

This is the main ai loop. Though called every
frame, the ai_time limits it's actual updating

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

entity() BotGetClosestPlayer;
entity() Bot_FindClosestItem;
void() bot_ai_race;
void() bot_ai_fight;
.float bot_hitwall;

float stagger_think;
.float ai_time;

void() BotAI =
{
	if (cvar("developer") == 2)
		return;

	// Traceline: Bot hit/close to wall
	// RennyC: Needs improvement for being accurate
	makevectors(self.realang);
	float test1, test2, test3;
	float distance = 8;
	vector start = self.origin + v_forward * 50;

	// Center trace
	vector end = start + (v_forward * distance);
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)	test1 = TRUE; // hit
	else					test2 = FALSE;

	// Right trace
	end = start + (v_forward * distance) + v_right * 16;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)	test2 = TRUE; // hit
	else					test1 = FALSE;

	// Left trace
	end = start + (v_forward * distance) - v_right * 16;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)	test3 = TRUE; // hit
	else					test3 = FALSE;
		
	if (test1 || test2 || test3)
		self.bot_hitwall = TRUE;
	else
	{
		if (!self.bot_hitwall)
			self.bot_hitwall = FALSE;
	}

	// stagger the bot's AI out so they all don't think at the same time, causing game spikes
	if (self.ai_time > time)
		return;

	//self.ai_time = time + 0.025;
	if (bot_count > 0)
	{
		if ((time - stagger_think) < (0.1 / bot_count))
			self.ai_time = self.ai_time + 0.1 / (2 * bot_count);
	}
	stagger_think = time;

	if (!deathmatch)
	{
		local vector x = getlight(self.origin);
		if (world.model == "maps/map4.hmp")
		{
			if (!self.headlights)
				headlights_on();
		}
		else
		{
			if (x_x <= 3 || x_y <= 3 || x_z <= 3)
			{
				if (!self.headlights) 
					headlights_on();
			}
			else if (self.headlights)
				headlights_off();
		}
		bot_ai_race();
	}
	else
	{
		// bots can start/end matches on empty dedicated servers
		if (framecount >= 100 && !human_players && deathmatch && race_status != RACE_STARTED)
		{
			if (!self.button0) // don't spam console
			{
				bprint ("AI started match\n");
				self.button0 = 1;
			}
		}
		
		// am I dead? Fire randomly until I respawn
		// health < 1 is used because fractional healths show up as 0 on normal player
		// status bars, and the mod probably already compensated for that - FrikaC
		if (self.health < 1 && !intermission_running && race_status == RACE_STARTED && deathmatch) // bot respawn
		{
			self.button3 = floor(random() * 2);
			self.button0 = 0;
			self.button2 = 0;
			self.button4 = 0;
			self.keys = 0;
			return;
		}
		bot_ai_fight();
	}
};