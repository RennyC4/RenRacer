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
void(vector dest, float silent) car_teleport;

float stagger_think;

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
float(entity targ, float howmuch) infront3 =
{
	makevectors (self.angles);
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
	
	//if (trace_inopen && trace_inwater)
	//	return FALSE;			// sight line crossed contents

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
	stagger_think = time;

	//
	// Bot headlights
	//

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

	//
	// Bot searches for stuff
	//

	if (!self.goal_touched) // Bot searches for start/finish flag to start race
	{
		if (!self.goalentity)
		{
			GetGoalPoint(); // Get goal entities position, only needs to be done once
			self.goalentity = self.goalentity_goal;
			//bprint ("Beginning goal entity set\n");
		}
	}
	else
	{
		if (!self.goalentity)
			GetCheckPoint(); // Bot gets first goalentity waypoint after hitting beginning goal
		else
		{
			self.goalentity_time = self.goalentity_time + 1; // Bot counts how long its taking to reach goal
			//bprint (ftos(self.goalentity_time), "\n");

			if (self.checkpoint == self.goalentity.checkpoint) // Find next target
			{
				//if (self.findcheckpoint_fail > 1) // Reached the end of valid checkpoints
				if (self.checkpoint == total_checkpoints)
				{
					self.goalentity = self.goalentity_goal;
					self.goalentity_time = 0; // reset goalentity timer
					//bprint("Go for Goal!\n");
				}
				else
				{
					GetCheckPoint();
					if (self.goalentity != self.goalentity_checkpoint)
					{
						self.goalentity = self.goalentity_checkpoint;
						self.goalentity_time = 0; // reset goalentity timer
					}
					//bprint ("GetCheckPoint\n");
				}
				//self.findcheckpoint_fail = self.findcheckpoint_fail + 1;
			}
		}
	}

	//
	// Goalentity is set management: Compare distances - switch to closest
	//

	if (self.goalentity.classname != "bot_waypoint_goal")
	{
		if (self.checkpoint == total_checkpoints) // Start searching for goal point once all checkpoints are hit
		{
			local float findgp = FindGoalPoint();
			if (findgp)
			{
				self.goalentity = self.goalentity_goal;
				self.goalentity_time = 0; // reset goalentity timer
				//bprint ("Bot is going for goal point\n");
			}
		}
		if (self.goalentity_checkpoint || self.goalentity_waypoint)
		{
			local float check_dist_wp;
			if (!self.goalentity_waypoint)
				check_dist_wp = 9999999; // Waypoints don't always exist, checkpoints do
			else
				check_dist_wp = vlen(self.origin - self.goalentity_waypoint.origin);

			local float check_dist_cp = vlen(self.origin - self.goalentity_checkpoint.origin);

			if (check_dist_cp > check_dist_wp) // waypoint is closer than checkpoint/marker
			{
				if (self.goalentity != self.goalentity_waypoint)
				{
					if (self.goalentity)
						self.old_goalentity = self.goalentity; // Stash it

					if (self.goalentity_waypoint.waypoint == self.waypoint + 1)
					{
						self.goalentity = self.goalentity_waypoint;
						self.goalentity_time = 0; // reset goalentity timer
						//bprint ("Dist: Goal entity set to waypoint\n");
					}
					else
					{
						if (self.goalentity != self.goalentity_checkpoint)
						{
							self.goalentity = self.goalentity_checkpoint;
							self.goalentity_time = 0; // reset goalentity timer
							//bprint ("Dist: Had to switch to checkpoint\n");
						}
					}
				}
			}
			else // checkpoint/marker is closer than waypoint
			{
				if (self.goalentity != self.goalentity_checkpoint)
				{
					if (self.goalentity)
						self.old_goalentity = self.goalentity; // Stash it

					if (self.checkpoint < total_checkpoints) // Bot hasn't ran out of valid checkpoints yet...
					{
						if (self.goalentity != self.goalentity_checkpoint)
						{
							self.goalentity = self.goalentity_checkpoint;
							self.goalentity_time = 0; // reset goalentity timer
							//bprint ("Dist: Goal entity switch to CheckPoint\n");
						}
					}
				}
			}
		}
	}

	//
	// Normal driving routine
	//

	if (self.goalentity)
	{
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

		local float r = vlen(self.origin - self.goalentity.origin) * 0.1; // Find distance to goalentity target

		// Debug distance to goalentity
		// local string f = ftos(self.realspeed);
		// local string n = ftos(r);
		// bprint ("Speed: ", f, " Dist: ", n, "\n");

		//
		// Back up for randomly for a second, hit a wall/obstacle
		//

		if (self.goal_touched && (self.keys == KEY_MOVEFORWARD || (self.button0 && self.turbo_fuel > 0)) && self.realspeed <= 3)
			self.bot_backup_finished = time + 0.3 + random()*0.6;

		if (self.bot_backup_finished < time)
		{
			if (self.bot_search_finished < time) // Bot searches while driving
			{
				if (self.goalentity.classname == "marker")				
					FindWayPoint(); // Find waypoints along the way
				if (self.goalentity.classname == "bot_waypoint")
					FindCheckPointDriving(); // Always looks for visible checkpoints

				if (race_status == RACE_STARTED)
				{
					if (!visible(self.goalentity))
						self.bot_search_count = self.bot_search_count + 1; // count till targ switch
					else
						self.bot_search_count = 0;
				}

				// Bot is stuck / lost, or is taking too long to hit its goal
				if (self.bot_search_count >= 15 || self.goalentity_time >= 30)
				{
					for (entity targ = world;(targ = find(targ, classname, "player"));)
					{
						if (!visible(targ) && targ.trail.cnt && (targ.checkpoint > self.checkpoint || targ.waypoint > self.waypoint))
						{
							// Steal player stats & update goal entities
							if (targ.checkpoint > self.checkpoint)
							{
								self.checkpoint = targ.checkpoint;
								GetCheckPoint();
							}
							if (targ.waypoint > self.waypoint)
							{
								self.waypoint = targ.waypoint;
								FindWayPoint();
							}
							if (targ.lap > self.lap)
								self.lap = targ.lap;

							self.checkpoint_lastpos = targ.checkpoint_lastpos;
							self.angles_y = targ.trail.angles_y;
							self.fixangle = TRUE; // Is this needed?
							//
							self.goalentity_time = 0;
							self.bot_search_count = 0;
							self.collide_finished = time + 1; // Don't bump player on teleport
							makevectors(self.realang);
							car_teleport(targ.trail.origin, TRUE);
							self.bot_search_count = 0;

							if (cvar("developer") == 2)							
								bprint ("Teleported bot to player trail entity\n");
						}
					}
				}
				self.bot_search_finished = time + 0.1;
			}

			if (self.goalentity.classname == "bot_waypoint_goal")
				local float goforgoal = TRUE;
			else
				goforgoal = FALSE;

			if (r >= 100) // Far from goal
			{
				if (goforgoal)
				{
					if (infront(self.goalentity, 0.7) && visible(self.goalentity))
					{
						if (self.turbo_fuel >= 0)
							self.button0 = TRUE;
					}
					else
						self.button0 = FALSE;
				}
				else
				{
					if (infront(self.goalentity, 0.8) && visible(self.goalentity) && self.turbo_fuel > 0 && r >= 125)
						self.button0 = TRUE; // Bot normal turbo
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
						if (self.waypoint_speed != 999)
							self.keys = KEY_MOVEBACK; // Slow down, coming in too fast!
						//bprint ("Moving in too hot!\n");
					}
					else
						self.keys = KEY_MOVEFORWARD;
				}
				else
				{
					if (!self.goal_touched) // Go for goal point
					{
						self.button0 = TRUE;
						self.keys = KEY_MOVEFORWARD;
					}
					else
					{
						if (self.realspeed < 50)
							self.keys = KEY_MOVEFORWARD;
						else
						{
							if (self.waypoint_speed != 999)
								self.keys = KEY_MOVEBACK;
						}
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
					// 999 Speed waypoint tells bot to turbo, but only if facing goal entity & visible
					if (self.waypoint_speed == 999 && infront(self.goalentity, 0.992) && visible(self.goalentity))
					{
						if (self.turbo_fuel > 0)
						{
							self.button0 = TRUE;
							self.keys = KEY_MOVEFORWARD;
							//bprint ("Waypoint says to Turbo\n");
						}
						else
							self.button0 = FALSE;
					}
				}
			}

			// Fight inclines
			if (self.goalentity.origin_z > self.origin_z && self.angles_x >= 5 && infront(self.goalentity, 0.7))
			{
				self.keys = KEY_MOVEFORWARD;
				if (self.turbo_fuel >= 0)
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

		// AI cheats, can always turbo
		if (self.turbo_fuel < 100)
			self.turbo_fuel = 100;

		/*
		// Debugging prints
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
