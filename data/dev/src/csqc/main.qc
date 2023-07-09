void() SUB_Remove = {remove(self);return;};

//
// Main Loop
//

entity sky;
entity engine_sound;
void(float width, float height, float menushown) CSQC_UpdateView =
{
	g_width = width;
	g_height = height;

	local vector virtsize;
	virtsize_x = width;
	virtsize_y = height;
	virtsize_z = 0;

	framecount = framecount + 1;

	clearscene(); //wipe entity lists, reset view properties to their defaults
	setproperty(VF_DRAWENGINESBAR, 0); // Turn off status bar

	if (cvar("developer") != 1)
	{
		GameCamera(); // Games camera
		setproperty(VF_DRAWCROSSHAIR, 0); // Turn off crosshair
	}

	if (sky)
	{
		sky.origin = campos - '0 0 0';
		sky.angles = '0 0 0';
		addentity(sky);
	}

	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);

	renderscene();

	DrawTurbo(); // Draw Turbo Stats
	DrawDrift(); // Draw Drift Stats
	if (!deathmatch)
	{
		DrawTime();  // Draw Lap Time Stats
		DrawSpeed(); // Draw Speed Stats
	}
	else
	{
		DrawHealth(); // Draw Health Stats
		HUD_Deathmatch(); // Draw ammo, etc
	}

	if (showscores)
	{
		Hud_UpdateScores();
		Hud_Scoreboard('0 0 0', virtsize);
	}

	// Race Status
	local float rs = getstatf(STAT_RACESTATUS);

	// Engine sounds (taken from build a delivery, optimized (thanks spike))
	local float speed = getstatf(STAT_SPEED);
	local float incar = getstatf(STAT_DRIVING);
	if (incar)
	{
		float vol = min(1, 0.25 + (speed / 4));
		float pitchadd = min(1000, speed);
		float pitch = 120 + pitchadd;
		if (pitch > 300) // cap pitch since it's tied to velocity
			pitch = 300;
		soundupdate(engine_sound, CHAN_BODY, "engine/engine.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);
	}
	//
	
	// Turbo Press Status
	local float speedl = getstatf(STAT_TURBO);
	local float turbof = getstatf(STAT_TURBOFUEL);
	local float speedb = getstatf(STAT_SPEEDBOOST);
	if (speedl && turbof > 0 && rs != RACE_FINISHED)
		DrawSpeedLines(FALSE); // Draw speed lines on turbo
	if (speedb > time)
		DrawSpeedLines(TRUE); // Draw blue speed lines on speed boost
	
	//

	if (framecount == 10)
		localcmd("exec haze.cfg\n");
};

float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch (evtype)
	{
		case IE_KEYDOWN:
		if (getkeybind(scanx) == "+showscores")
		{
			showscores = TRUE;
			return TRUE;
		}
		case IE_KEYUP:
			showscores = FALSE;
		return FALSE;
	}
	return FALSE;
};

noref void(float apiver, string enginename, float enginever) CSQC_Init = {};

//
// First loaded, run once
//

void() CSQC_WorldLoaded  =
{
	precache_model ("progs/v_speed.mdl");
	precache_sound ("engine/engine.wav");

	engine_sound = spawn();
	if (world.model != "maps/map4.hmp")
	{
		// Spawn sky
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
};