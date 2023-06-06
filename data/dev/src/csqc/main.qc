//
// Main Loop
//

entity sky;
void(float width, float height, float menushown) CSQC_UpdateView =
{
	g_width = width;
	g_height = height;

	framecount = framecount + 1;

	clearscene(); //wipe entity lists, reset view properties to their defaults
	setproperty(VF_DRAWENGINESBAR, 0); // Turn off status bar

	if (cvar("developer") != 1)
	{
		GameCamera(); // Games camera
		setproperty(VF_DRAWCROSSHAIR, 0); // Turn off crosshair
	}

	sky.origin = campos - '0 0 0';
	sky.angles = '0 0 0';
	addentity(sky);

	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);

	renderscene();

	DrawTurbo('25 315'); // Draw Turbo Stats
	DrawSpeed('25 325'); // Draw Speed Stats
	DrawDrift('80 315'); // Draw Drift Stats

	// Engine sounds (taken from build a delivery)
	local float speed = getstatf(STAT_SPEED);
	local float incar = getstatf(STAT_DRIVING);
	if (incar)
	{
		//if (time > next_sound)
		//{
			float vol = min(1, 0.25 + (speed / 4));
			float pitchadd = min(1000, speed);
			float pitch = 120 + pitchadd;

			soundupdate(self, CHAN_BODY, "engine/engine.wav", vol * 1, 0, pitch, SOUNDFLAG_FORCELOOP, 0);

			//float(entity e, float channel, string newsample, float volume, float attenuation, float pitchpct, float flags, float timeoffset) soundupdate = #0:soundupdate; /*
			//next_sound = time + 1 - (0.75 * pitch/200);
		//}
	}
	//

	if (framecount == 10)
		localcmd("exec haze.cfg\n");
};

noref void(float apiver, string enginename, float enginever) CSQC_Init = {};

//
// First loaded, run once
//

void() CSQC_WorldLoaded  =
{
	precache_sound ("engine/engine.wav");
	// Spawn sky
	sky = spawn();
	sky.scale = 6;
	precache_model ("progs/sky.iqm");
	setmodel(sky, "progs/sky.iqm");

	// Ask SSQC for values to send
	sendevent("GrabCSQCValues", "");
};