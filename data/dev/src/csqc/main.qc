void() SUB_Remove = {remove(self);return;};

void(float is_new) CSQC_Ent_Update =
{
	float type = readbyte();
	switch(type)
	{
		case NETENTITY::RADARBLIP: EntUpdate_RadarBlip(is_new); break; // ent 1 = radar blip
	}
};

//
// Main Loop
//

entity sky;
entity engine_sound;
float blindness_fade;
void(float width, float height, float menushown) CSQC_UpdateView =
{
	g_width = width;
	g_height = height;

	vector virtsize;
	virtsize_x = width;
	virtsize_y = height;
	virtsize_z = 0;

	framecount = framecount + 1;
	float pause = serverkeyfloat(SERVERKEY_PAUSESTATE);
	float intermiss = getstatf(STAT_INTERMISSION);
	ragewar = getstatf(SERVER_RAGEWAR);
	float rs = getstatf(STAT_RACESTATUS); // Game status
	float obs = getstatf(STAT_OBSERVE);

	clearscene(); // wipe entity lists, reset view properties to their defaults
	setproperty(VF_DRAWENGINESBAR, 0); // turn off status bar

	if (sky)
	{
		sky.origin = campos - '0 0 0';
		sky.angles = '0 0 0';
		if (substring(world.model, -3, 3) == "hmp") // thanks reki
			addentity(sky);
	}

	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);

	if (cvar("developer") != 1)
	{
		if (!intermiss && !obs)
			GameCamera(); // Camera
		setproperty(VF_DRAWCROSSHAIR, 0); // Turn off crosshair
	}

	renderscene();

	if (pause > 0)
		pauseframe += 1;
	else
		pauseframe = 0;

	if (!intermiss)
	{
		if (rs >= RACE_COUNTDOWN)
		{
			float speed = getstatf(STAT_SPEED);
			float incar = getstatf(STAT_DRIVING);
			float blind = getstatf(STAT_BLIND);
			if (incar)
			{
				// Blind status
				if (blind > time)
					blindness_fade = min(1,blindness_fade + frametime*7.5);
				else if (blindness_fade > 0)
					blindness_fade = max(0,blindness_fade - frametime*3);
				if (blindness_fade > 0)
				{
					vector draw = [getstatf(STAT_ORIGINX), getstatf(STAT_ORIGINY), getstatf(STAT_ORIGINZ)];
					DrawBlindness(draw, '320 270' + ('640 640'*(1-blindness_fade)), width, height, blindness_fade);
				}
				//

				// Engine sounds (taken from build a delivery, optimized (thanks spike))
				float vol = min(1, 0.25 + (speed / 4));
				float pitchadd = min(1000, speed);
				float pitch = 120 + pitchadd;
				if (pitch > 300) // cap pitch since it's tied to velocity
					pitch = 300;
				float vehicle_type = getstatf(STAT_VEHICLE);
				// Engine noises
				if (!pause)
				{
					if (vehicle_type == VEH_HOTROD)
						soundupdate(engine_sound, CHAN_BODY, "engine/hotrod.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_WRAITH)
						soundupdate(engine_sound, CHAN_BODY, "engine/wraith.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_ROADBASTARD)
						soundupdate(engine_sound, CHAN_BODY, "engine/roadbstrd.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_SKYSCRAPER)
						soundupdate(engine_sound, CHAN_BODY, "engine/skyscraper.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_REDRAGE)
						soundupdate(engine_sound, CHAN_BODY, "engine/redrage.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_LAWBREAKER)
						soundupdate(engine_sound, CHAN_BODY, "engine/lawbreaker.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_RAZORBACK)
						soundupdate(engine_sound, CHAN_BODY, "engine/razorback.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_MINCEMEAT)
						soundupdate(engine_sound, CHAN_BODY, "engine/razorback.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_STREETKING)
						soundupdate(engine_sound, CHAN_BODY, "engine/streetking.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_SANDROAMER)
						soundupdate(engine_sound, CHAN_BODY, "engine/hotrod.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_THOROGOOD)
						soundupdate(engine_sound, CHAN_BODY, "engine/hotrod.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_NIGHTSHADE)
						soundupdate(engine_sound, CHAN_BODY, "engine/skyscraper.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
					if (vehicle_type == VEH_SERVENT)
						soundupdate(engine_sound, CHAN_BODY, "engine/razorback.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
				}
				else
					soundupdate(engine_sound, CHAN_BODY, __NULL__ , -1, 0, 0, 0, 0);
			}

			if (!obs)
			{
				DrawTurbo(); // Draw Turbo Stats
				DrawDrift(); // Draw Drift Stats
				if (!ragewar)
					DrawTime();  // Draw Lap Time Stats
				else
					HUD_Ragewar(); // Draw ammo, etc
				DrawSpeed(); // Draw Speed Stats
			}
			else
			{
				vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-24, (g_height - 46)];
				drawstring (pos + '1 1', "Observer", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
				drawstring (pos, "Observer", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
			}
			//
		}
	}
	else
	{
		if (engine_sound) // kill engine sound on intermission
		{
			soundupdate(engine_sound, CHAN_BODY, __NULL__ , -1, 0, 0, 0, 0);
			engine_sound = world;
		}
	}

	if (showscores || intermiss)
	{
		Hud_UpdateScores();
		Hud_Scoreboard('0 0 0', virtsize);
	}

	// Turbo Press Status
	local float speedl = getstatf(STAT_TURBO);
	local float turbof = getstatf(STAT_TURBOFUEL);
	local float speedb = getstatf(STAT_SPEEDBOOST);
	local float h = getstatf(STAT_HEALTH);
	if (!intermiss && h > 0)
	{
		if (speedl && turbof > 0 && rs != RACE_FINISHED)
			DrawSpeedLines(FALSE); // Draw speed lines on turbo
		if (speedb > time)
			DrawSpeedLines(TRUE); // Draw blue speed lines on speed boost
	}
	
	//

	if (framecount == 10)
		localcmd("exec haze.cfg\n");
};

float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch (evtype)
	{
		case IE_KEYDOWN:
			if (getkeybind(scanx) == "+moveleft")
			{
				localcmd("+left\n");
				return FALSE;
			}
			if (getkeybind(scanx) == "+left")
			{
				localcmd("+moveleft\n");
				return FALSE;
			}
			if (getkeybind(scanx) == "+moveright")
			{
				localcmd("+right\n");
				return FALSE;
			}
			if (getkeybind(scanx) == "+right")
			{
				localcmd("+moveright\n");
				return FALSE;
			}
		case IE_KEYUP:
			if (getkeybind(scanx) == "+moveleft")
			{
				localcmd("-left\n");
				return FALSE;
			}
			if (getkeybind(scanx) == "+left")
			{
				localcmd("-moveleft\n");
				return FALSE;
			}
			if (getkeybind(scanx) == "+moveright")
			{
				localcmd("-right\n");
				return FALSE;
			}
			if (getkeybind(scanx) == "+right")
			{
				localcmd("-moveright\n");
				return FALSE;
			}
		return FALSE;
	}
	return FALSE;
};

void() CSQC_Input_Frame = {};

noref void(float apiver, string enginename, float enginever) CSQC_Init = {};

float(string strCommand) CSQC_ConsoleCommand =
{
	local float rs = getstatf(STAT_RACESTATUS); // Game status

	if (strCommand == "+showscores" && rs == RACE_STARTED)
		showscores = TRUE;
	else
		showscores = FALSE;

    return FALSE;
}

//
// First loaded, run once
//

void() CSQC_WorldLoaded  =
{
	precache_model ("progs/v_speed.mdl");
	precache_sound ("engine/hotrod.wav");
	precache_sound ("engine/wraith.wav");
	precache_sound ("engine/roadbstrd.wav");
	precache_sound ("engine/skyscraper.wav");
	precache_sound ("engine/redrage.wav");
	precache_sound ("engine/lawbreaker.wav");

	engine_sound = spawn();
	if (world.model != "maps/map4.hmp")
	{
		// Spawn sky for height maps
		sky = spawn();
		sky.scale = 6;

		// Sky colours here
		if (world.model == "maps/map3.hmp")
			sky.colormod = '2 .5 .5';
		if (world.model == "maps/map6.hmp")
			sky.colormod = '.01 .01 0.5';

		precache_model ("progs/sky.iqm");
		setmodel(sky, "progs/sky.iqm");
	}

	// Ask SSQC for values to send
	sendevent("GrabCSQCValues", "");
	registercommand("+showscores", "Show scoreboard");
	
	registercvar("cam_height", "0");
	registercvar("cam_dist", "0");
};