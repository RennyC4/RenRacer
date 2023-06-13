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

float stagger_think;
.float bot_backup_finished;
.float bot_search_finished;
.entity old_goalentity;
.float bot_search_count;
void() headlights_on;

/*
=============
infront (of car)

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ) infront =
{
	makevectors (self.realang);
	local vector vec = normalize (targ.origin - self.origin);
	local float dot = vec * v_forward;

	if (dot > 0.7)
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
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

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
	local float h;
	local vector view;

	if (self.goalentity)
	{
		view = realorigin(self.goalentity);
		view = view - (self.origin + self.view_ofs);
		view = vectoangles(view);
		view_x = view_x * -1;
		self.b_angle = view;
	}
	else
		self.b_angle_x = 0;

	self.keys = self.keys & 63;
	self.v_angle = self.b_angle;
	while (self.v_angle_x < -180)
		self.v_angle_x = self.v_angle_x + 360;
	while (self.v_angle_x > 180)
		self.v_angle_x = self.v_angle_x - 360;
};

.float findcheckpoint_fail;
void() FindGoalPoint =
{
	for (entity y = world;(y = find(y, classname, "bot_waypoint_goal"));)
	{
		if (self.goalentity)
			self.old_goalentity = self.goalentity; // Stash it

		self.goalentity = y;
		self.findcheckpoint_fail = 0;
	}
};

void() FindCheckPoint =
{
	for (entity y = world;(y = find(y, classname, "marker"));)
	{
		if (y.checkpoint == self.checkpoint + 1)
		{
			if (self.goalentity)
				self.old_goalentity = self.goalentity; // Stash it

			self.goalentity = y;
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
			if (self.goalentity)
				self.old_goalentity = self.goalentity; // Stash it

			self.goalentity = y;
			self.waypoint_speed = y.waypoint_speed; // Set waypoint speed on bot if marker has one
			self.findcheckpoint_fail = 0;
		}
	}
};

void() FindWayPoint =
{
	for (entity y = world;(y = find(y, classname, "bot_waypoint"));)
	{
		if (visible(y) && self.waypoint < y.waypoint)
		{
			if (self.goalentity)
				self.old_goalentity = self.goalentity; // Stash it

			y.colormod = '1 1 5';
			self.goalentity = y;
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

void() BotAI =
{
	// stagger the bots AI out so they all don't think at the same time, causing game 'spikes'
	if (self.b_skill < 2)
	{
		if (self.ai_time > time)
			return;

		self.ai_time = time + 0.05;
		if (bot_count > 0)
		{
			if ((time - stagger_think) < (0.1 / bot_count))
				self.ai_time = self.ai_time + 0.1 / (2 * bot_count);
		}
		else
			return;
	}

	// Turn on headlights once
	// TODO: Have the AI detect when in a dark map / area
	if (!self.headlights && world.model == "maps/map4.hmp")
	{
		self.headlights = TRUE;
		headlights_on();
	}

	if (!self.goal_touched)
	{
		if (!self.goalentity)
		{
			FindGoalPoint();
			bprint ("FindGoalPoint_STARTRACE\n");
		}
	}
	else
	{
		if (!self.goalentity)
		{
			FindCheckPoint();
			self.findcheckpoint_fail = self.findcheckpoint_fail + 1;
			if (self.findcheckpoint_fail > 1) // Reached the end of checkpoints
			{
				FindGoalPoint();
				//if (!visible(self.goalentity))
				//	FindWayPoint(); // Can't see goal, find next waypoint for now
			}
		}
		else
		{
			if (self.checkpoint == self.goalentity.checkpoint) // Find next checkpoint
				self.goalentity = world;
		}
	}

	if (self.goalentity)
	{
		local float r = vlen(self.origin - self.goalentity.origin) * 0.1; // Find distance to goalentity target

		// Debug distance to goalentity
		//local string f = ftos(self.realspeed);
		//local string n = ftos(r);
		//bprint ("Speed: ", f, " Dist: ", n, "\n");

		//
		// Get out of being toppled / rolling
		//
		if (self.realang_z > -330 && self.realang_z < -30)
		{
			if (self.realang_z < -180)
				self.keys = KEY_MOVELEFT;
			else
				self.keys = KEY_MOVERIGHT;
			return;
		}

		//
		// Back up for a second, hit a wall/obstacle
		//
		if (self.goal_touched && (self.keys == KEY_MOVEFORWARD || (self.button0 && self.turbo_fuel > 0)) && self.realspeed <= 3)
			self.bot_backup_finished = time + 0.6 + random()*1.1;

		//
		// Normal driving routine
		//
		if (self.bot_backup_finished < time)
		{
			if (self.bot_search_finished < time)
			{
				if (self.findcheckpoint_fail > 1) // Reached the end of valid checkpoints
				{
					FindGoalPoint(); // Go for goal
					if (!visible(self.goalentity)) // Goal can't be seen
						FindWayPoint(); // Find the next waypoint
				}
				if (self.goalentity.classname == "marker" && !visible(self.goalentity))
					FindWayPoint(); // Find waypoints along the way
				if (self.goalentity.classname == "bot_waypoint")
					FindCheckPointDriving(); // Always find visible checkpoints

				//if (!(self.origin_z < self.goalentity.origin_z + 20 && self.origin_z > self.goalentity.origin_z - 20))
				//	bprint ("WHAT THE F\n");
	
				self.bot_search_finished = time + 0.1;
				if (self.bot_search_count < time)
				{
					self.bot_search_count = time + 3; // count till targ switch (TODO: Implement a way)
					bprint ("bot search count done\n");
				}
			}

			if (self.goalentity.classname == "bot_waypoint_goal")
				local float goforgoal = TRUE;
			else
				goforgoal = FALSE;

			if (r >= 100) // Far from goal
			{
				if (goforgoal)
				{
					if (r > 100)
						if (infront(self.goalentity))
							if (self.turbo_fuel >= 50)
								self.button0 = TRUE;
					else
					{
						if (self.realspeed > 30)
						{
							self.keys = KEY_MOVEBACK;
							bprint ("Coming in too hot!\n");
						}
						self.button0 = FALSE;
					}
				}
				else
				{
					if (infront(self.goalentity) && visible(self.goalentity) && self.turbo_fuel > 0)
					{
						self.button0 = TRUE;
						bprint ("Let's go!\n");
					}
					else
						self.button0 = FALSE;
				}
				self.keys = KEY_MOVEFORWARD;
			}
			else // Close to goal
			{
				if (self.realspeed > 50)
				{
					if (!goforgoal)
					{
						self.keys = KEY_MOVEBACK; // Slow down, coming in too fast!
						bprint ("Moving in too hot!\n");
					}
					else
						self.keys = KEY_MOVEFORWARD;
				}
				else
				{
					if (!self.goal_touched)
					{
						self.button0 = TRUE;
						self.keys = KEY_MOVEFORWARD;
					}
					else
					{
						if (self.realspeed < 40)
							self.keys = KEY_MOVEFORWARD;
						self.button0 = FALSE;
					}
				}
	
				// Adhere to waypoint set speeds when close to waypoint/marker
				if (self.waypoint_speed > 0)
				{
					if (self.realspeed > self.waypoint_speed)
						self.keys = KEY_MOVEBACK;
					else
						self.keys = KEY_MOVEFORWARD;
				}
			}

			// Fight inclines
			if (self.goalentity.origin_z > self.origin_z && self.angles_x >= 5 && infront(self.goalentity))
			{
				self.keys = KEY_MOVEFORWARD;
				if (self.turbo_fuel >= 25)
					self.button0 = TRUE;
				//bprint ("Fighting an incline\n");
			}
		}
		else // backing up
		{
			self.button0 = FALSE;
			self.keys = KEY_MOVEBACK;
		}

		bot_angle_set();

		// Debugging prints
		/*
		bprint (self.goalentity.classname, "\n");
		local string d1 = ftos (self.goalentity.origin_x);
		local string d2 = ftos (self.goalentity.origin_y);
		local string d3 = ftos (self.goalentity.origin_z);
		bprint (d1, "\n");
		bprint (d2, "\n");
		bprint (d3, "\n");
		*/
	}
};





//
// Below is removed FrikBot AI code that won't work in RenRacer but is used for reference
//

/*

	// am I dead? Fire randomly until I respawn
	// health < 1 is used because fractional healths show up as 0 on normal player
	// status bars, and the mod probably already compensated for that
	if (self.health < 1)
	{ 
		self.button0 = floor(random() * 2);
		self.button2 = 0;
		self.keys = 0;
		self.b_aiflags = 0;
		ClearMyRoute();
		self.target1 = self.target2 = self.target3 = self.target4 = self.enemy = world;
		self.last_way = world;
		return;
	}

	if (self.view_ofs == '0 0 0')
		bot_start_topic(7);

	stagger_think = time;

	// shut the bot's buttons off, various functions will turn them on by AI end

	self.button2 = 0;
	self.button0 = 0;

	// target1 is like goalentity in normal Quake monster AI.
	// it's the bot's most immediate target
	if (route_table == self)
	{
		if (busy_waypoints <= 0)
		{
			if (waypoint_mode < WM_EDITOR)
				bot_look_for_crap(TRUE);
		}
		self.b_aiflags = 0;
		self.keys = 0;
	}
	else if (self.target1)
	{
		frik_movetogoal();
		bot_path();
	}
	else
	{
		if (waypoint_mode < WM_EDITOR)
		{
			if (self.route_failed)
			{
				if (waypoint_mode == WM_DYNAMIC)
				{
					frik_bot_roam();
				}
				else
					self.keys = 0;
				self.route_failed = 0;
			}
			else if (!begin_route())
			{	
				bot_look_for_crap(FALSE);
				self.keys = 0;
			}
		}
		else
		{
			self.b_aiflags = AI_WAIT;
			self.keys = 0;
		}
	}

	// bot_angle_set points the bot at it's goal (self.enemy or target1)
	bot_angle_set();
	bot_chat(); // don't want chat to screw him up if he's rjing or something
*/
