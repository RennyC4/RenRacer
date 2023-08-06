/***********************************************
*                                              *
*              FrikBot Misc Code               *
*   "Because you can't name it anything else"  *
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

BotName

Sets bot's name

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

string(float r) BotName =
{
	self.b_num = r;
	if (r == 1)
		return "Vigil";
	else if (r == 2)
		return "xaGe";
	else if (r == 3)
		return "KyleMac";
	else if (r == 4)
		return "Spoike";
	else if (r == 5)
		return "FrikaC";
	else if (r == 6)
		return "Reki";
	else if (r == 7)
		return "ericw";
	else if (r == 8)
		return "kristus";
	else if (r == 9)
		return "Zwiffle";
	else if (r == 10)
		return "Tomaz";
	else if (r == 11)
		return "scar3crow";
	else if (r == 12)
		return "khreathor";
	else if (r == 13)
		return "Harbinger";
	else if (r == 14)
		return "Corporal";
	else if (r == 15)
		return "E-Werd";
	else if (r == 16)
		return "MauveBib";
	else
		return "CleanRacer";
};

string () PickARandomName =
{
	local float y, test;
	local string h;
	local entity t;
	y = TRUE;
	while(y)
	{
		test = ceil(random() * 16);
		h = BotName(test);
		t = find(world, netname, h);
		if (t == world)
			y = FALSE;
	}
	return h;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Simplified origin checking. 

God, I wish I had inline

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

vector(entity ent) realorigin =
{
// even more simplified...
	return (ent.absmin + ent.absmax) * 0.5;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

fisible

a version of visible that checks for corners
of the bounding boxes

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float (entity targ) fisible =
{
	local vector	spot1, org;
	local float thruwater, pc1, pc2;
	
	org = realorigin(targ);
	spot1 = self.origin + self.view_ofs;
	
	if (targ.solid == SOLID_BSP)
	{
		traceline (spot1, org, TRUE, self);
		if (trace_ent == targ)
			return TRUE;
		else if (trace_fraction == 1)
			return TRUE;
		return FALSE;
	}
	else
	{
		pc1 = pointcontents(org);
		pc2 = pointcontents(spot1);
		if (targ.classname == "player")
			thruwater = FALSE;
		else if (pc1 == CONTENT_LAVA)
			return FALSE;
		else	
			thruwater = TRUE;
	}
	
	if (pc1 < -1) // targ's origin is in water or other liquid
	{
		if (pc2 != pc1)
		{
			// look for their head
			traceline (spot1, org + targ.mins, TRUE, self);
			// cross the water check
			if (trace_inopen)
				if (trace_inwater)
					if (!thruwater)
						return FALSE;
			if (trace_ent == targ)
				return TRUE;
			else if (trace_fraction == 1)
				return TRUE;
			return FALSE;
		}
	}
	else
	{
		if (pc2 != pc1)
		{
			traceline (spot1, org + targ.maxs, TRUE, self);
			if (trace_inopen)
				if (trace_inwater)
					if (!thruwater)
						return FALSE;
			if (trace_ent == targ)
				return TRUE;
			else if (trace_fraction == 1)
				return TRUE;
			return FALSE;
		}
	}
	traceline (spot1, org, TRUE, self);
	if (trace_ent == targ)
		return TRUE;
	else if (trace_fraction == 1)
		return TRUE;
	traceline (spot1, org + targ.maxs, TRUE, self);
	if (trace_ent == targ)
		return TRUE;
	else if (trace_fraction == 1)
		return TRUE;
	traceline (spot1, org + targ.mins, TRUE, self);
	if (trace_ent == targ)
		return TRUE;
	else if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

sisible

Now this is getting ridiculous. Simple visible,
used when we need just a simple traceline nothing else

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float (entity targ) sisible =
{
	traceline (self.origin, targ.origin, TRUE, self);
	if (trace_ent == targ)
		return TRUE;
	else if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

angcomp

subtracts one angle from another

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float (float y1, float y2) angcomp = 
{
	y1 = frik_anglemod(y1);
	y2 = frik_anglemod(y2);

	local float answer;
	answer = y1 - y2;
	if (answer > 180)
		answer = answer - 360;
	else if (answer < -180)
		answer = answer + 360;
	return answer;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

fov

is the entity in the bot's field of view

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float (entity targ) fov =
{
	local vector yawn;
	local float g;
	yawn = realorigin(targ);
	yawn = (yawn + targ.view_ofs) - (self.origin + self.view_ofs);
	yawn = normalize(yawn);
	yawn = vectoangles(yawn);
	g = angcomp(self.v_angle_x, yawn_x);
	if (fabs(g) > 45)
		return FALSE;
	g = angcomp(self.v_angle_y, yawn_y);
	if (fabs(g) > 60)
		return FALSE;
 
	return TRUE;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

frik_anglemod

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float(float v) frik_anglemod =
{
	return v - floor(v/360) * 360;
};