
/*
======================================
FrikBot X (Version 0.10.2)
======================================

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

======================================
These installation instructions only apply to Normal Quake (as does this
entire file). For QuakeWorld, please refer to bot_qw.qc

--------------------------------------
To install on a new mod, do all this:
--------------------------------------
Place all included bot*.qc files in the subdirectory "frikbot"
in your source folder, then...

* Add the following lines to progs.src right after the defs.qc line
frikbot/bot.qc
frikbot/bot_way.qc
frikbot/bot_fight.qc 
frikbot/bot_ai.qc
frikbot/bot_misc.qc
frikbot/bot_phys.qc
frikbot/bot_move.qc
frikbot/bot_ed.qc

--------------------------------------
* Comment out the following functions in defs.qc
sound, stuffcmd, sprint, aim, centerprint, setspawnparms
WriteByte, WriteChar, WriteShort, WriteLong, WriteCoord
WriteAngle, WriteString, WriteEntity
--------------------------------------
* Add this to worldspawn() in world.qc, right at the very top, before InitBodyQue();
BotInit();  // FrikBot
--------------------------------------
* add this line to StartFrame() in world.qc, at the very top
BotFrame(); // FrikBot
--------------------------------------
* Add these two lines to PlayerPreThink in client.qc at the very top
if (BotPreFrame()) // FrikBot
	return;
--------------------------------------
* Add this line to PlayerPostThink in client.qc at the very top
if (BotPostFrame()) // FrikBot
	return;
--------------------------------------
* Add the following line to the very top of Client Connect in client.qc
ClientInRankings(); // FrikBot
--------------------------------------
* Add these lines to the very top of ClientDisconnect in client.qc
ClientDisconnected(); // FrikBot
--------------------------------------

To install the waypoints:

add

waypoints/map_dm1.qc
waypoints/map_dm2.qc
waypoints/map_dm3.qc
waypoints/map_dm4.qc
waypoints/map_dm5.qc
waypoints/map_dm6.qc

To progs.src, immediately after defs.qc

To remove these waypoints:

Delete the code in bot_map_load, located below.
*/

void() bot_map_load =
{
	// place your qc loaded waypoints here
	/*
	if (mapname == "dm1")
		map_dm1();
	else if (mapname == "dm2")
		map_dm2();
	else if (mapname == "dm3")
		map_dm3();
	else if (mapname == "dm4")
		map_dm4();
	else if (mapname == "dm5")
		map_dm5();
	else if (mapname == "dm6")
		map_dm6();
	*/
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Variables and shtuff

bot.qc has become pretty much a header file
for all variable in the bot...

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

// ----- entity fields ---
.float	wallhug, keys, oldkeys, ishuman;
.float	b_frags, b_clientno, b_shirt, b_pants; 
.float	priority, ai_time, b_sound, missile_speed;
.float	portal_time, b_skill, switch_wallhug;
.float	b_aiflags, b_num, b_chattime;
.float	b_menu, b_menu_time, b_menu_value;
.float route_failed, dyn_flags, dyn_time;
.float dyn_plat;
.entity	temp_way, last_way, phys_obj;
//.entity	target1, target2, target3, target4;
.entity	_next, _last;
.entity	current_way;
.vector	b_angle, b_dest, mouse_emu, obs_dir;
.vector	movevect, b_dir;
.vector dyn_dest;

// --------defines-----
float SVC_UPDATENAME	= 13;
float SVC_UPDATEFRAGS	= 14;
float SVC_UPDATECOLORS	= 17;

// used for the physics & movement AI
float KEY_MOVEUP 	= 1;
float KEY_MOVEDOWN 	= 2;
float KEY_MOVELEFT 	= 4;
float KEY_MOVERIGHT 	= 8;
float KEY_MOVEFORWARD	= 16;
float KEY_MOVEBACK	= 32;
float KEY_LOOKUP		= 64;
float KEY_LOOKDOWN	= 128;
float KEY_LOOKLEFT	= 256;
float KEY_LOOKRIGHT	= 512;

float AI_PRECISION	= 32; // read ahead + point

// these are flags for bots/players (dynamic/editor flags)
float AI_OBSTRUCTED	= 1;
float AI_HOLD_SELECT	= 2;
float AI_ROUTE_FAILED	= 2;
float AI_WAIT		= 4;
float AI_DANGER		= 8;

// addition masks
float AI_POINT_TYPES 	= 29152;
float AI_READAHEAD_TYPES	= 36528;
float AI_IGNORE_TYPES	= 4864;

float WM_UNINIT		= 0;
float WM_DYNAMIC		= 1;
float WM_LOADING		= 2;
float WM_LOADED		= 3;
float WM_EDITOR		= 4;
float WM_EDITOR_DYNAMIC	= 5;
float WM_EDITOR_DYNLINK	= 6;

float OPT_SAVEBOTS	= 1;
float OPT_NOCHAT	= 2;

// -------globals-----
float 	active_clients;
float	max_clients, real_frametime;
float	bot_count;
float	sv_friction, sv_gravity;
float	sv_accelerate, sv_maxspeed, sv_stopspeed;
entity	b_temp1, b_temp2;
entity 	player_head, phys_head;
float	saved_skills1, saved_skills2, current_bots;

// -------ProtoTypes------
// external
void() ClientConnect;
void() ClientDisconnect;
void() SetNewParms;

// rankings
float(float clientno)		ClientBitFlag;
float()				ClientNextAvailable;
void(float whichteam, float whatbot, float whatskill) BotConnect;
void(entity bot)			BotDisconnect;
void(float clientno)		BotInvalidClientNo;
void(entity who)			UpdateClient;

// physics & movement
void()				SV_Physics_Client;
void()				SV_ClientThink;
void() 				CL_KeyMove;

// ai & misc
string()				PickARandomName;
float(entity targ)		fov;
float(float y1, float y2)	angcomp;
float(entity targ1, entity targ2)		wisible;
float(entity targ)		sisible;
float(entity targ)		fisible;
vector(entity ent)		realorigin;
void()				KickABot;
void()				BotImpulses;
string(float r)			BotName;
float(float v)			frik_anglemod;

// ----------Commands---------
void(entity e, float chan, string samp, float vol, float atten) frik_sound = #8;
void(entity client, string s)	frik_stuffcmd = #21;
void(entity client, string s)	frik_sprint = #24;
vector(entity e, float sped)	frik_aim = #44;	
void(entity client, string s)	frik_centerprint = #73;
void(entity e)			frik_setspawnparms = #78;
void(float to, float f)		frik_WriteByte = #52;
void(float to, float f)		frik_WriteChar = #53;
void(float to, float f)		frik_WriteShort = #54;
void(float to, float f)		frik_WriteLong = #55;
void(float to, float f)		frik_WriteCoord = #56;
void(float to, float f)		frik_WriteAngle = #57;
void(float to, string s)	frik_WriteString	= #58;
void(float to, entity s)	frik_WriteEntity	= #59;
void(entity client, string s1, string s2, string s3, string s4, string s5, string s6, string s7) frik_big_centerprint = #73;

//----------------------------------------------------------------------------

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Function redclarations. These allow function 
designed to work for clients (sprint, so forth)
to mainly not complain when working with a bot

Although these shouldn't be needed anymore,
as the bots truly are clients now, if you don't
stop the SZ_ buffer from filling up by disabling
direct messages to the bots, it crashes quake :-(

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

/*
void(entity	client, string s) stuffcmd =
{
	if (client.ishuman == 1)
		frik_stuffcmd(client, s);
	b_temp1 = player_head;

	while(b_temp1)
	{
		if (b_temp1.classname == "botcam")
		{
			if ((b_temp1.enemy == client) && b_temp1.ishuman)
				frik_stuffcmd(b_temp1, s);
		}
		b_temp1 = b_temp1._next;
	}
};
*/

void(entity	e) setspawnparms =
{
	if (e.ishuman == 1)
		frik_setspawnparms(e);
	else
	{
		b_temp1 = player_head;
		while(b_temp1)
		{
			if (b_temp1.ishuman)
			{
				frik_setspawnparms(b_temp1);
				return;
			}
			b_temp1 = b_temp1._next;
		}
		SetNewParms();
	}
};

vector(entity e, float sped) aim =
{
	e.missile_speed = sped;
	return frik_aim(e, sped);
};

/*
void(entity e, float chan, string samp, float vol, float atten, optional float speedpct, optional float flags, optional float timeofs) sound = 
{
	frik_sound(e, chan, samp, vol, atten);
	if (e.classname == "player")
		e.b_sound = time + 1;
	else if (other.classname == "player")
		other.b_sound = time + 1;

};
*/

void(float to, float f) WriteByte =
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	frik_WriteByte(to, f);
};
void(float to, float f) WriteChar =		
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	frik_WriteChar(to, f);
};
void(float to, float f) WriteShort =	
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	frik_WriteShort(to, f);
};
void(float to, float f) WriteLong = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	frik_WriteLong(to, f);
};
void(float to, float f) WriteCoord = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	frik_WriteCoord(to, f);
};
void(float to, float f) WriteAngle = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	frik_WriteAngle(to, f);
};
void(float to, string s) WriteString = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	frik_WriteString(to, s);
};
void(float to, entity s) WriteEntity = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	frik_WriteEntity(to, s);
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Stuff mentioned up top
it just links the bot into the mod

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void() ClientFixRankings =
{
	local float cno;

	if (self.switch_wallhug > time)
		return;
	self.switch_wallhug = 0;

	b_temp2 = nextent(world);
	cno = 0;

	while (cno < max_clients)
	{
		if ((!b_temp2.ishuman) && (active_clients & ClientBitFlag(cno)))
			UpdateClient(b_temp2);
		cno = cno + 1;
		b_temp2 = nextent(b_temp2);
	}
};
		
void() ClientInRankings =
{
	local float cno;

   	cno = self.colormap - 1;
	BotInvalidClientNo (cno);
	
	if (player_head)
		player_head._last = self;

	self._next = player_head;
	self._last = world;
	player_head = self;

	if (!self.phys_obj)
	{
		b_temp2 = phys_head;
		while (b_temp2 != world && b_temp2.owner != self)
			b_temp2 = b_temp2._next;
		self.phys_obj = b_temp2;
	}

	if (self.ishuman == 2)
	{
		self.ishuman = FALSE;
		return;
	}
	active_clients = active_clients | ClientBitFlag(cno);
	
	self.b_clientno = cno;
	self.ishuman = TRUE;
	self.switch_wallhug = time + 1;
};

void() ClientDisconnected =
{
	if (player_head == self)
		player_head = self._next;
	if (self._next)
		self._next._last = self._last;
	if (self._last)
		self._last._next = self._next;

	active_clients = active_clients - active_clients & ClientBitFlag(self.b_clientno);
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotPreFrame & BotPostFrame, used to make the
bot easier to install

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
float() BotPreFrame =
{
	if (self.b_clientno == -1)
		return TRUE;
	if (self.ishuman)
	{
		if (self.switch_wallhug)
			ClientFixRankings();
	}
	return FALSE;
};

float () BotPostFrame =
{
	if (self.b_clientno == -1)
		return TRUE;
	return FALSE;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotInit

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void() BotInit =
{
	local entity ent, fisent;
	local float numents;
	
	// spawn entities for the physics
	ent = nextent(world);
	max_clients = 0;

	while(ent != world)
	{
		max_clients = max_clients + 1;
		ent = nextent(ent);
	}
	if (max_clients > 16)
		max_clients = 16;

	ent = nextent(world);
	fisent = world;
	while (numents < max_clients)
	{
		phys_head = spawn();
		if (fisent)
			fisent._next = phys_head;
		phys_head._last = fisent;
		fisent = phys_head;
		ent.phys_obj = phys_head;
		phys_head.classname = "phys_obj";
		phys_head.owner = ent;
		numents = numents + 1;
		ent = nextent(ent);
	}
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Rankings 'utilities'. Written by Alan Kivlin,
this code just fools clients by sending precisely
the same network messages as when a real player
signs on to the server.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void(entity who) UpdateClient =
{
	WriteByte (MSG_ALL, SVC_UPDATENAME);
	WriteByte (MSG_ALL, who.b_clientno);
	WriteString (MSG_ALL, who.netname);
	WriteByte (MSG_ALL, SVC_UPDATECOLORS);
	WriteByte (MSG_ALL, who.b_clientno);
	WriteByte (MSG_ALL, who.b_shirt * 16 + who.b_pants);
	WriteByte (MSG_ALL, SVC_UPDATEFRAGS);
	WriteByte (MSG_ALL, who.b_clientno);
	WriteShort (MSG_ALL, who.frags);
};

float(float clientno) ClientBitFlag =
{
	// bigger, but faster
	if (clientno == 0)
		return 1;
	else if (clientno == 1)
		return 2;
	else if (clientno == 2)
		return 4;
	else if (clientno == 3)
		return 8;
	else if (clientno == 4)
		return 16;
	else if (clientno == 5)
		return 32;
	else if (clientno == 6)
		return 64;
	else if (clientno == 7)
		return 128;
	else if (clientno == 8)
		return 256;
	else if (clientno == 9)
		return 512;
	else if (clientno == 10)
		return 1024;
	else if (clientno == 11)
		return 2048;
	else if (clientno == 12)
		return 4096;
	else if (clientno == 13)
		return 8192;
	else if (clientno == 14)
		return 16384;
	else if (clientno == 15)
		return 32768;
	return 0;
};

float() ClientNextAvailable =
{
	local float clientno;

	clientno = max_clients;
	while(clientno > 0)
	{
		clientno = clientno - 1;

		if(!(active_clients & ClientBitFlag(clientno)))
			return clientno;
	}
	return -1;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Find Another Color

Team finding code

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float(float tcolor) FindAnotherColor =
{
	local float bestbet, scolor, pcount, bestp;
	bestbet = -1;
	bestp = 16;
	while(scolor < 14)
	{
		if (scolor != tcolor)
		{
			b_temp2 = player_head;
			pcount = 0;
			while(b_temp2 != world)
			{
				if (b_temp2.team == scolor + 1)
					pcount = pcount + 1;
				b_temp2 = b_temp2._next;
			}
			if ((pcount < bestp) && pcount)
			{
				bestbet = scolor;
				bestp = pcount;
			}
		}
		scolor = scolor + 1;
	}
	if (bestbet < 0)
	{
		bestbet = tcolor;
		while (bestbet == tcolor)
		{
			bestbet = floor(random() * 13);
		}
	}
	return bestbet;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotConnect and related functions.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
			
entity(float num) GetClientEntity =
{
	local entity upsy;
	upsy = world;
	num = num + 1;
	while (num > 0)
	{
		num = num - 1;
		upsy = nextent(upsy);
	} 
	return upsy;
};

void(float whichteam, float whatbot, float whatskill) BotConnect =
{
	local float f;
	local string h;
	local entity uself;

	f = ClientNextAvailable();
	uself = self;
	if(f == -1)
	{
		bprint("Unable to connect a bot, server is full.\n");
		return;
	}
	
	// chat thing

	bot_count = bot_count + 1;
	self = GetClientEntity(f);
	self.b_clientno = f;
	self.colormap = f + 1;
	if (whatbot)
		self.netname = BotName(whatbot);
	else
		self.netname = PickARandomName();

	// players can set skill all weird, so leave these checks in
	whatskill = rint(whatskill);
	if (whatskill > 3)
		whatskill = 3;
	else if (whatskill < 0)
		whatskill = 0;
	self.b_skill = whatskill;

	if (teamplay && !coop)
	{
		if (whichteam)
			self.b_pants = FindAnotherColor(uself.team - 1);
		else
			self.b_pants = uself.team - 1;
		self.b_shirt = self.b_pants;
	}

	self.team = self.b_pants + 1;
	UpdateClient(self);
	SetNewParms();
	self.ishuman = 2;
	ClientConnect();
	PutClientInServer();

	active_clients = active_clients | ClientBitFlag(f);

	// this is risky... could corrupt .way files if done wrong
	// If you're not the gambling type, comment this out

	f = ClientBitFlag(self.b_num - 1);
	current_bots = current_bots | f;

	if (self.b_num <= 8)
		saved_skills1 = (saved_skills1 & (65536 - (3 * f)) | (self.b_skill * f));
	else
	{
		f = ClientBitFlag(self.b_num - 9);
		saved_skills2 = (saved_skills2 & (65536 - (3 * f)) | (self.b_skill * f));
	}

	h = ftos(current_bots);
	cvar_set("scratch1", h);
	h = ftos(saved_skills1);
	cvar_set("scratch2", h);
	h = ftos(saved_skills2);
	cvar_set("scratch3", h);
	self = uself;
};

void(entity bot) BotDisconnect =
{
	local string h;
	local entity uself;
	uself = self;
	self = bot;

	bot_count = bot_count - 1;
	current_bots = current_bots - (current_bots & ClientBitFlag(self.b_num - 1));
	h = ftos(current_bots);
	cvar_set("scratch1", h);

	ClientDisconnect();

	if (self.b_clientno != -1)
	{
      	// the bot's client number is not in use by a real player so we
		// must remove it's entry in the rankings
		// Quake engine sets all fields to 0, can only do the most important here
		self.b_frags = self.frags = 0;
		self.netname = "";
		self.classname = "";
		self.health = 0;
		self.items = 0;
		self.armorvalue = 0;
		self.weaponmodel = "";
		self.b_pants = 0;
		self.b_shirt = 0;
		self.ammo_shells = self.ammo_nails = self.ammo_rockets = self.ammo_cells = 0;
		UpdateClient(self);
		active_clients = active_clients - (active_clients & ClientBitFlag(self.b_clientno));
	      self.b_clientno = -1;
   	}
	self = uself;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotInvalidClientNo
kicks a bot if a player connects and takes the bot's space

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void(float clientno) BotInvalidClientNo =
{
	local entity bot;

	bot = GetClientEntity(clientno);
	if(bot.b_clientno > 0)
	{
		if (active_clients & ClientBitFlag(self.b_clientno))
		{
			bot.b_clientno = -1;
			BotDisconnect(bot);
			active_clients = active_clients | ClientBitFlag(self.b_clientno);
			//BotConnect(0, bot.b_num, bot.b_skill); 
			return;
		}
	}
};

void() BotFrame =
{
	local float num;

	// for the sake of speed
	sv_maxspeed = cvar("sv_maxspeed");
	sv_gravity = cvar("sv_gravity");
	sv_friction = cvar("sv_friction");
	sv_accelerate = cvar("sv_accelerate");
	sv_stopspeed = cvar("sv_stopspeed");
	real_frametime = frametime; // in NQ this is alright
	
	self = nextent(world);
	num = 0;
	while (num < max_clients)
	{
		if (self.ishuman == FALSE)
		{
			if (active_clients & ClientBitFlag(num))
			{
				CL_KeyMove();
				SV_ClientThink();
				SV_Physics_Client();
			}
		}
		self = nextent(self);
		num = num + 1;
	}
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Bot Impulses. Allows the player to perform bot
related functions.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void() BotImpulses =
{
/*
	local float f;

	if (self.impulse == 100)
	{
		f = cvar("skill");
		BotConnect(0, 0, f);
	}
	else if (self.impulse == 101)
	{
		f = cvar("skill");
		BotConnect(1, 0, f);
	}
	else if (self.impulse == 102)
		KickABot();
	else
		return;

	self.impulse = 0;
*/
};