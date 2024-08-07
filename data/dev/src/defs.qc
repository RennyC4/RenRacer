//+----+
//|Defs|
//+----+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| This contains necessary definitions from the original V1.06 defs.qc file.  |
//| This includes some basic constants, the built in function definitions, and |
//| some variable's used by the Quake Engine internally.                       |
//| Certain lines in this file are hardcoded into Quake engine, and -must- be  |
//| present and unchanged, in the order they are shown. Otherwise Quake will   |
//| refuse to run.                                                             |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

// These lines CANNOT be altered/moved
entity          self;
entity		other;
entity		world;
float		time;
float		frametime;
float		force_retouch;		// force all entities to touch triggers
string		mapname;
float		deathmatch;
float		coop;
float		teamplay;
float		serverflags;		// propagated from level to level, used to
float		total_secrets;
float		total_monsters;
float		found_secrets;		// number of secrets found
float		killed_monsters;	// number of monsters killed
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;
vector		v_forward, v_up, v_right;	// set by makevectors()
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;

entity          msg_entity;                      // destination of single entity writes
void()          main;                            // only for testing
void()		StartFrame;
void() 		PlayerPreThink;
void() 		PlayerPostThink;
void()		ClientKill;
//void()		ClientConnect;
void() 		PutClientInServer;		// call after setting the parm1... parms
void()		ClientDisconnect;
void()		SetNewParms;			// called when a client first connects to
void()		SetChangeParms;			// call to set parms for self so they can
void		end_sys_globals;		// flag for structure dumping

.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs
.float		ltime;			// local time for entity
.float		movetype;
.float		solid;
.vector		origin;			// ***
.vector		oldorigin;		// ***
.vector		velocity;
.vector		angles;
.vector		avelocity;
.vector		punchangle;		// temp angle adjust from damage or recoil
.string		classname;		// spawn function
.string		model;
.float		frame;
.float		skin;
.float		effects;
.vector		mins, maxs;		// bounding box extents reletive to origin
.vector		size;			// maxs - mins
.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;		// for doors or plats, called when can't push other
.float		nextthink;
.entity		groundentity;
.float		health;
.float		frags;
.float		weapon;			// one of the IT_SHOTGUN, etc flags
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float		items;			// bit flags
.float		takedamage;
.entity		chain;
.float		deadflag;
.vector		view_ofs;			// add to origin to get eye point
.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump
.float		impulse;		// weapon changes
.float		fixangle;
.vector		v_angle;		// view / targeting angle for players
.float		idealpitch;		// calculated pitch angle for lookup up slopes
.string		netname;
.entity 	enemy;
.float		flags;
.float		colormap;
.float		team;
.float		max_health;		// players maximum health is stored here
.float		teleport_time;	// don't back up
.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;
.float		waterlevel;		// 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float		watertype;		// a contents value
.float		ideal_yaw;
.float		yaw_speed;
.entity		aiment;
.entity 	goalentity;		// a movetarget or an enemy
.float		spawnflags;
.string		target;
.string		targetname;
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;
.entity		owner;		// who launched a missile
.vector		movedir;	// mostly for doors, but also used for waterjump
.string		message;		// trigger messages
.float		sounds;		// either a cd track number or sound number
.string         noise, noise1, noise2, noise3;  // contains names of wavs to play

void		end_sys_fields;			// flag for structure dumping
// End. Lines below this MAY be altered, to some extent

// Built In functions
void(vector ang) makevectors			= #1;	// sets v_forward, etc globals
void(entity e, vector o) setorigin		= #2;
void(entity e, string m) setmodel		= #3;	// set movetype and solid first
void(entity e, vector min, vector max) setsize	= #4;
void() break					= #6;
float() random					= #7;	// returns 0 - 1
//void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize			= #9;
void(string e) error				= #10;
void(string e) objerror				= #11;
float(vector v) vlen				= #12;
//float(vector v) vectoyaw			= #13;
entity() spawn					= #14;
void(entity e) remove				= #15;
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;	
entity() checkclient				= #17;		// returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound			= #19;
string(string s) precache_model			= #20;
//void(entity client, string s)stuffcmd		= #21;
//entity(vector org, float rad) findradius	= #22;
void(string s) dprint				= #25;
string(float f) ftos				= #26;
string(vector v) vtos				= #27;
void() coredump					= #28;		// prints all edicts
void() traceon					= #29;		// turns statment trace on
void() traceoff					= #30;
void(entity e) eprint				= #31;		// prints an entire edict
//float(float yaw, float dist) walkmove		= #32;		// returns TRUE or FALSE
float() droptofloor	= #34;		// TRUE if landed on floor
//void(float style, string value) lightstyle	= #35;
float(float v) rint				= #36;		// round to nearest int
float(float v) floor				= #37;		// largest integer <= v
float(float v) ceil				= #38;		// smallest integer >= v
float(entity e) checkbottom			= #40;		// true if self is on ground
float(vector v) pointcontents			= #41;		// returns a CONTENT_*
float(float f) fabs				= #43;
//vector(entity e, float speed) aim		= #44;		// returns the shooting vector
float(string s) cvar				= #45;		// return cvar.value
void(string s) localcmd				= #46;		// put string into local que
entity(entity e) nextent			= #47;		// for looping through all ents
void() ChangeYaw 				= #49;		// turn towards self.ideal_yaw
//vector(vector v) vectoangles			= #51;
//void(float to, float f) WriteByte		= #52;
//void(float to, float f) WriteChar		= #53;
//void(float to, float f) WriteShort		= #54;
//void(float to, float f) WriteLong		= #55;
//void(float to, float f) WriteCoord		= #56;
//void(float to, float f) WriteAngle		= #57;
//void(float to, string s) WriteString		= #58;
//void(float to, entity s) WriteEntity		= #59;
void(float step) movetogoal			= #67;
string(string s) precache_file			= #68;		// no effect except for -copy
void(entity e) makestatic			= #69;
//void(string s) changelevel			= #70;
void(string var, string val) cvar_set		= #72;		// sets cvar.value
//void(entity client, string s) centerprint 	= #73;		// sprint, but in middle
void(entity client, string s, string s) centerprint2 = #73;
void(entity client, string s, string s, string s) centerprint3 = #73;
void(entity client, string s, string s, string s, string s) centerprint4 = #73;
void(entity client, string s, string s, string s, string s, string s) centerprint5 = #73;
void(entity client, string s, string s, string s, string s, string s, string s) centerprint6 = #73;
void(entity client, string s, string s, string s, string s, string s, string s, string s) centerprint7 = #73;
void(vector pos, string samp, float vol, float atten) ambientsound = #74;
string(string s) precache_model2		= #75;	// registered version only
string(string s) precache_sound2		= #76;	// registered version only
string(string s) precache_file2			= #77;	// registered version only
//void(entity e) setspawnparms			= #78;	// set parm1... to the

//
// constants
//

float	FALSE					= 0;
float 	TRUE					= 1;

// edict.flags
float	FL_FLY					= 1;
float	FL_SWIM					= 2;
float	FL_CLIENT				= 8;	// set for all client edicts
float	FL_INWATER				= 16;	// for enter / leave water splash
float	FL_MONSTER				= 32;
float	FL_GODMODE				= 64;	// player cheat
float	FL_NOTARGET				= 128;	// player cheat
float	FL_ITEM					= 256;	// extra wide size for bonus items
float	FL_ONGROUND				= 512;	// standing on something
float	FL_PARTIALGROUND		= 1024;	// not all corners are valid
float	FL_WATERJUMP			= 2048;	// player jumping out of water
float	FL_JUMPRELEASED			= 4096;	// for jump debouncing

// edict.movetype values
float	MOVETYPE_NONE			= 0;	// never moves
float   MOVETYPE_ANGLENOCLIP    = 1;
float   MOVETYPE_ANGLECLIP              = 2;
float	MOVETYPE_WALK			= 3;	// players only
float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;	// gravity
float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE			= 10;
float	MOVETYPE_BOUNCEMISSILE	= 11;	// bounce with extra size

// edict.solid values
float	SOLID_NOT				= 0;	// no interaction with other objects
float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
float	SOLID_BBOX				= 2;	// touch on edge, block
float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
float	SOLID_BSP				= 4;	// bsp clip, touch on edge, block

// range values
float	RANGE_CLOSE 			= 0;
float	RANGE_NEAR				= 1;
float	RANGE_MID				= 2;
float	RANGE_FAR				= 4;

// deadflag values

float	DEAD_NO					= 0;
float	DEAD_DYING				= 1;
float	DEAD_DEAD				= 2;
float	DEAD_RESPAWNABLE		= 3;

// takedamage values

float	DAMAGE_NO				= 0;
float	DAMAGE_YES				= 1;
float	DAMAGE_AIM				= 2;

.void()		th_stand;
.void()		th_walk;
.void()		th_run;
.void(entity attacker, float damage)		th_pain;
.void()		th_die;
.void()         th_missile;
.void()         th_melee;

// point content values

float	CONTENT_EMPTY			= -1;
float	CONTENT_SOLID			= -2;
float	CONTENT_WATER			= -3;
float	CONTENT_SLIME			= -4;
float	CONTENT_LAVA			= -5;
float   CONTENT_SKY                     = -6;

float   STATE_RAISED            = 0;
float   STATE_LOWERED           = 1;
float	STATE_UP		= 2;
float	STATE_DOWN		= 3;

vector	VEC_ORIGIN = '0 0 0';
vector	VEC_HULL_MIN = '-16 -16 -24';
vector	VEC_HULL_MAX = '16 16 32';

vector	VEC_HULL2_MIN = '-32 -32 -24';
vector	VEC_HULL2_MAX = '32 32 64';

// protocol bytes
float	SVC_BAD			= 0;
float	SVC_NOP			= 1;
float	SVC_DISCONNECT		= 2;
float	SVC_UPDATESTAT		= 3;
float	SVC_VERSION		= 4;
float	SVC_SETVIEW		= 5;
float	SVC_SOUND		= 6;
float	SVC_TIME		= 7;
float	SVC_PRINT		= 8;
float	SVC_STUFFTEXT		= 9;
float	SVC_SETANGLE		= 10;
float	SVC_SERVERINFO		= 11;
float	SVC_LIGHTSTYLE		= 12;
float	SVC_UPDATENAME		= 13;
float	SVC_UPDATEFRAGS		= 14;
float	SVC_CLIENTDATA		= 15;
float	SVC_STOPSOUND		= 16;
float	SVC_UPDATECOLORS	= 17;
float	SVC_PARTICLE		= 18;
float	SVC_DAMAGE		= 19;
float	SVC_SPAWNSTATIC		= 20;
float	SVC_SPAWNBINARY		= 21;
float	SVC_SPAWNBASELINE	= 22;
float	SVC_TEMPENTITY		= 23;
float	SVC_SETPAUSE		= 24;
float	SVC_SIGNONNUM		= 25;
float	SVC_CENTERPRINT		= 26;
float	SVC_KILLEDMONSTER	= 27;
float	SVC_FOUNDSECRET		= 28;
float	SVC_SPAWNSTATICSOUND	= 29;	// 1998-08-08 Complete SVC list by Zhenga
float	SVC_INTERMISSION	= 30;
float	SVC_FINALE		= 31;
float	SVC_CDTRACK		= 32;
float	SVC_SELLSCREEN		= 33;
float	SVC_CUTSCENE		= 34;	// 1998-08-08 Complete SVC list by Zhenga

float	TE_SPIKE		= 0;
float	TE_SUPERSPIKE	= 1;
float	TE_GUNSHOT		= 2;
float	TE_EXPLOSION	= 3;
float	TE_TAREXPLOSION	= 4;
float	TE_LIGHTNING1	= 5;
float	TE_LIGHTNING2	= 6;
float	TE_WIZSPIKE		= 7;
float	TE_KNIGHTSPIKE	= 8;
float	TE_LIGHTNING3	= 9;
float	TE_LAVASPLASH	= 10;
float	TE_TELEPORT		= 11;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO		= 0;
float	CHAN_WEAPON		= 1;
float	CHAN_VOICE		= 2;
float	CHAN_ITEM		= 3;
float	CHAN_BODY		= 4;

float	ATTN_NONE		= 0;
float	ATTN_NORM		= 1;
float	ATTN_IDLE		= 2;
float	ATTN_STATIC		= 3;

// update types

float	UPDATE_GENERAL	= 0;
float	UPDATE_STATIC	= 1;
float	UPDATE_BINARY	= 2;
float	UPDATE_TEMP		= 3;

// entity effects

float	EF_BRIGHTFIELD	= 1;
float	EF_MUZZLEFLASH 	= 2;
float	EF_BRIGHTLIGHT 	= 4;
float	EF_DIMLIGHT 	= 8;


// messages
float	MSG_BROADCAST	= 0;		// unreliable to all
float	MSG_ONE			= 1;		// reliable to one (msg_entity)
float	MSG_ALL			= 2;		// reliable to all
float	MSG_INIT		= 3;		// write to the init string

float	AS_STRAIGHT		= 1;
float	AS_SLIDING		= 2;
float	AS_MELEE		= 3;
float	AS_MISSILE		= 4;

void() SUB_Null2 = {};

// Quake assumes these are defined.
//entity activator;
string string_null = "";    // null string, nothing should be held here

.string         wad, map;
.float worldtype, delay, wait, lip, light_lev, speed, style, skill;
.string killtarget;
.vector pos1, pos2, mangle;

void(vector o, vector d, float color, float count) particle = #48;// start a particle effect
//void(string s) bprint				= #23;
//void(entity client, string s) sprint		= #24;
void() SUB_Remove = {remove(self);};
// End

// func_vehicle
//float	modelindex_player;

// RenRacer
float framecount;
entity lastspawn;
float ragewar;

float race_status; // Other game modes also use this
float RACE_NOTSTARTED = 0;
float RACE_COUNTDOWN = 1;
float RACE_STARTED = 2;
float RACE_FINISHED = 4;

float countdown_finished;
float countdown_count;

.string music;
float gameover; // match is over (dm)
.float cnt; // misc counter
.float cnt2; // misc counter
.float lap;
.float checkpoint;
.float hitobject_finished;
.float animation_finished;
.float think_finished;
.float sound_finished;
.float headlights;
.float engine_sound_time;
.float realspeed; // send real speed from func_vehicle to client entity
.vector realang; // send real angles from func_vehicle to client entity
.float goal_touched; // client touched the beginning / end goal to start/end race
.float airborne_cnt; // car airborne counter
.float turbo;
.float turbo_held;
.float turbo_fuel;
.float drift;
.float clearcprint_finished;
.float clearcprint;
.float car_stabilizer;
.float radius;
.entity driving;
.vector checkpoint_lastpos;
.vector checkpoint_lastpos_ang;
.float teleport_finished;
.float speedboost_finished; // How long speed booster lasts for
.vector spawn_loc;
.vector spawn_loc_angles;
float human_players; // human players in-game
float human_players_ready; // ready human players in-game
.float player_id;
.float collide_finished;
float total_waypoints;
float total_checkpoints;
.float mgun_finished;
.float spcl_finished;
.float commandspcl_finished;
.float deathcount_finished;
.float deathcount; // death counter
.float invulnerable_finished;
.float removeme_finished;
.float onfire_finished; // targets on fire
.float onfire_tic; // damage dealer
.entity igniter; // who set who on fire
.float deadflag; // if TRUE, player is dead
.float observer;
.float forcejump;
.float forcejump_strength;
.float energy;
.float shield_finished;
.float cloak_finished;
float intermission_running;
float intermission_exittime;
.string enemy_displayname;
.float enemy_displayhealth;
.float enemy_displaymaxhealth;
.vector oldvelocity;
string nextmap;
.entity plyrremote;
.float frozen_finished;
.entity frozen;
.float spawncar;
.float backward; // used when user is backing up the car, used for weapons also
.float max_speed;
.float handling;
.float blind_finished;
.float slow_finished;
.float turrets; // max # of deployable king turrets
.float car_reset_finished;
.float car_reset;
.float ready;
.float max_colormod; // Used for removing colour off damage cars via colormod
.float pushfactor;

// Key flags
.float keyflags;
float KEY_UP = 1;
float KEY_DOWN = 2;
float KEY_LEFT = 4;
float KEY_RIGHT = 8;

.float moveprog1_finished; // Timer to remove moveprog
.float moveprog2_finished; // Timer to remove moveprog
.float moveprog3_finished; // Timer to remove moveprog
.float moveprog4_finished; // Timer to remove moveprog
.float moveprog1; // Holds a value for each key pressed, used for special moves
.float moveprog2; // Holds a value for each key pressed, used for special moves
.float moveprog3; // Holds a value for each key pressed, used for special moves
.float moveprog4; // Holds a value for each key pressed, used for special moves
.float FL_MP1PRESSED; // Up press check
.float FL_MP2PRESSED; // Down press check
.float FL_MP3PRESSED; // Left press check
.float FL_MP4PRESSED; // Right press check

// Weapons
.float weapon;
float WEP_ROCKET = 0;
float WEP_HROCKET = 1;
float WEP_PROCKET = 2;
float WEP_NAPALM = 4;
float WEP_RICOCHET = 8;
float WEP_REMOTE = 16;
float WEP_FREEZE = 32;
float WEP_SPECIAL = 64; // Weapon 1
.float special_regen_finished;
.float special_max;

// Vehicles
.float vehicle;
float VEH_HOTROD = 0;
float VEH_WRAITH = 1;
float VEH_ROADBASTARD = 2;
float VEH_SKYSCRAPER = 4;
float VEH_REDRAGE = 8;
float VEH_LAWBREAKER = 16;
float VEH_RAZORBACK = 32;
float VEH_MINCEMEAT = 64;
float VEH_STREETKING = 128;
float VEH_SANDROAMER = 256;
float VEH_THOROGOOD = 512;
float VEH_NIGHTSHADE = 1024;
float VEH_SERVANT = 2048;
float VEH_WARWIENER = 4096;
// Ammo
.float ammo_firerocket, ammo_homingrocket, ammo_powerrocket, ammo_napalm, ammo_rico, ammo_remote, ammo_freeze, ammo_special;

// Particle defs
var float PART_DIRT;
var float PART_TURBO;
var float PART_SPEEDBOOST;
var float PART_BUBBLE;
var float PART_ROCKET1;
var float PART_ROCKET2;
var float PART_ROCKET3;
var float PART_NAPALM;
var float PART_MGUNSMOKE;
var float PART_FREEZEBLAST;
var float PART_FLAME;
var float PART_GROCKET;
var float PART_HOTDOGSPLAT;
var float PART_WATERDIRT;

// Lap time stats
.float start_laptime; // ON / OFF
.float laptime_tic;
.float laptime;
.float fastest_lap;
.float overall_time;

// FrikBot X
.float count;
.float search_time;
.float state;
.float waypoint;
.float last_waypoint;
.float waypoint_speed;

.vector dest1;
.vector dest2;

.entity trail; // Snail trail entity to help bots become unstuck
.entity fire; // Fire on objects

//
//CSQC 
//
#define STAT_TURBOFUEL 32
#define STAT_SPEED 33
#define STAT_DRIFT 34
#define STAT_DRIVING 35
#define STAT_RACESTATUS 36
#define STAT_TIME 37
#define STAT_TURBO 38
#define STAT_SPEEDBOOST 39
#define STAT_HEALTH 40
#define STAT_MAXHEALTH 41
#define STAT_AMMO_FIREROCKET 42
#define STAT_AMMO_HOMINGROCKET 43
#define STAT_AMMO_POWERROCKET 44
#define STAT_AMMO_NAPALM 45
#define STAT_WEAPON 46
#define STAT_ENERGY 47
#define STAT_ENEMYNAME 48
#define STAT_ENEMYHEALTH 49
#define STAT_ENEMYMAXHEALTH 50
#define STAT_AMMO_RICOCHET 51
#define STAT_AMMO_REMOTE 52
#define STAT_AMMO_FREEZE 53
#define STAT_PLAYERID 54
#define STAT_AMMO_SPECIAL 55
#define SERVER_RAGEWAR 56
#define STAT_VEHICLE 57
#define STAT_BLIND 58
#define STAT_ORIGINX 59 // Player origin X
#define STAT_ORIGINY 60 // Player origin Y
#define STAT_ORIGINZ 61 // Player origin Z
#define STAT_FIRE 62
#define STAT_FROZE 63
#define STAT_OBSERVE 64
#define STAT_SLOW 65

#define STAT_INTERMISSION 75

#define isnan(n) (((int)(__variant)n)&0x7f800000i == 0x7f800000i)
#define deg2rad(n) ((n)*(M_PI/180))
#define rad2deg(n) ((n)*(180/M_PI))

// Define bitmask constants
#define FLAG_1 (1 << 0)  // 00000001
#define FLAG_2 (1 << 1)  // 00000010
#define FLAG_3 (1 << 2)  // 00000100
#define FLAG_4 (1 << 3)  // 00001000
#define FLAG_5 (1 << 4)  // 00010000
#define FLAG_6 (1 << 5)  // 00100000
#define FLAG_7 (1 << 6)  // 01000000
#define FLAG_8 (1 << 7)  // 10000000

float player_dimension_hit = FLAG_1;
float player_dimension_solid = FLAG_2;