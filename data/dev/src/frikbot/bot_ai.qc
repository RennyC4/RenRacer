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

/*
	if (self.enemy)
	{
		if (self.missile_speed == 0)
			self.missile_speed = 10000;
		if (self.enemy.solid == SOLID_BSP)
		{
			view = (((self.enemy.absmin + self.enemy.absmax) * 0.5) - self.origin);
		}
		else
		{
			local float levels;

			levels = 3;
			view = self.enemy.origin;
			while (levels)
			{
				h = vlen(view - self.origin) / self.missile_speed;
				if (self.enemy.flags & FL_ONGROUND)
					view = self.enemy.velocity * h + '0 0 -20';
				else
					view = (self.enemy.velocity - (sv_gravity * '0 0 1') * h) * h;
				view = self.enemy.origin + view; 
				traceline(self.enemy.origin, view, FALSE, self);
				view = trace_endpos;
				levels = levels - 1;
			}
			view = normalize(view - self.origin);
		}
		view = vectoangles(view);
		view_x = view_x * -1;
		self.b_angle = view;
	}
	*/
	//else if (self.target1)

	if (self.target1)
	{
		view = realorigin(self.target1);
		if (self.target1.flags & FL_ITEM)
				view = view + '0 0 48';
		view = view - (self.origin + self.view_ofs);
		view = vectoangles(view);
		view_x = view_x * -1;
		self.b_angle = view;
	}
	else
		self.b_angle_x = 0;

	// HACK HACK HACK HACK
	// The bot falls off ledges a lot because of "turning around"
	// so let the bot use instant turn around when not hunting a player
	if (self.b_skill == 3)
	{
		self.keys = self.keys & 63;
		self.v_angle = self.b_angle;
		while (self.v_angle_x < -180)
			self.v_angle_x = self.v_angle_x + 360;
		while (self.v_angle_x > 180)
			self.v_angle_x = self.v_angle_x - 360;

	}
	else if ((self.enemy == world || self.enemy.movetype == MOVETYPE_PUSH) && self.target1.classname != "player")
	{
		self.keys = self.keys & 63;
		self.v_angle = self.b_angle;
		while (self.v_angle_x < -180)
			self.v_angle_x = self.v_angle_x + 360;
		while (self.v_angle_x > 180)
			self.v_angle_x = self.v_angle_x - 360;
	}
	else if (self.b_skill < 2) // skill 2 handled in bot_phys
	{
		if (self.b_angle_x > 180)
			self.b_angle_x = self.b_angle_x - 360;
		self.keys = self.keys & 63;

		if (angcomp(self.b_angle_y, self.v_angle_y) > 10)
			self.keys = self.keys | KEY_LOOKLEFT;
		else if (angcomp(self.b_angle_y, self.v_angle_y) < -10)
			self.keys = self.keys | KEY_LOOKRIGHT;
		if (angcomp(self.b_angle_x, self.v_angle_x) < -10)
			self.keys = self.keys | KEY_LOOKUP;
		else if (angcomp(self.b_angle_x, self.v_angle_x) > 10)
			self.keys = self.keys | KEY_LOOKDOWN;
	}
};

// TODO: Count all checkpoints in the map and compare where the bot is at
// and when to race towards the goal

.float findcheckpoint_fail;
void() bot_waypoint_goal = {self.classname = "bot_waypoint_goal";};
void() FindGoalPoint =
{
	local entity y, head, ent = world;
	head = world;

	y = find(world, classname, "bot_waypoint_goal");
	while(y)
	{
		self.goalentity = self.target1 = y;
		self.findcheckpoint_fail = 0;
		y = find(y, classname, "bot_waypoint_goal");
	}
	if (head)
		ent.chain = world;
//	return head;
};

void() FindCheckPoint =
{
	local entity y, head, ent = world;
	head = world;

	y = find(world, classname, "marker");
	while(y)
	{
		if (y.checkpoint == self.checkpoint + 1)
		{
			self.goalentity = self.target1 = y;
			self.findcheckpoint_fail = 0;
		}
		y = find(y, classname, "marker");
	}
	if (head)
		ent.chain = world;
//	return head;
};


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotAI

This is the main ai loop. Though called every
frame, the ai_time limits it's actual updating

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float stagger_think;
.float bot_backup_finished;
.float bot_dontbackup_finished;
void() BotAI =
{
	// stagger the bot's AI out so they all don't think at the same time, causing game 'spikes'
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

	if (!self.goalentity)
	{
		//bprint ("FindCheckPoint\n");
		FindCheckPoint();
		self.findcheckpoint_fail = self.findcheckpoint_fail + 1;
		if (self.findcheckpoint_fail > 1)
			FindGoalPoint();
	}
	else
	{
		if (self.checkpoint == self.goalentity.checkpoint) // Find next checkpoint
			self.goalentity = world;
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
		
		if (self.carroll_angle > -330 && self.carroll_angle < -30)
		{
			//bprint ("Car roll, get out\n");
			if (self.carroll_angle < -180)
				self.keys = self.keys = KEY_MOVELEFT;
			else
				self.keys = self.keys = KEY_MOVERIGHT;
			return;
		}

		// Back up for a second, hit a wall or rolled over
		// TODO: Should tracebox?, and seperate the roll over code into it's own thing
		// FIXME: This is ran at the beginning of a race
		if (self.keys == KEY_MOVEFORWARD && self.realspeed <= 2 && self.bot_dontbackup_finished < time)
		{
			self.keys = KEY_MOVEBACK;
			self.bot_backup_finished = time + 0.65;
			//bprint ("Hit wall, backup!\n");
		}

		if (self.bot_backup_finished < time)
		{
			if (r >= 80) // Far from goalentity
				self.keys = KEY_MOVEFORWARD; // Full speed
			else // Driving stuff when near market / target
			{
				if (r < 5)
				{
					if (self.realspeed > 10)
						self.keys = KEY_MOVEBACK; // decelerate when near marker
					else
						self.keys = KEY_MOVEFORWARD;
				}
				if (r < 20)
				{
					if (self.realspeed > 15)
						self.keys = KEY_MOVEBACK; // decelerate when near marker
					else
						self.keys = KEY_MOVEFORWARD;
				}
				else if (r < 40)
				{
					if (self.realspeed > 35)
						self.keys = KEY_MOVEBACK; // decelerate when near marker
					else
						self.keys = KEY_MOVEFORWARD;
				}
				else if (r < 80)
				{
					if (random() < 0.5)
					{
						if (self.realspeed < 30)
							self.keys = KEY_MOVEFORWARD; // Car go forward
						else
							self.keys = 0;
					}
					else
						self.keys = 0;
				}
			}
		}
		bot_angle_set();

//		self.keys = KEY_MOVERIGHT;    // TODO: Detect when the car is toppled over

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