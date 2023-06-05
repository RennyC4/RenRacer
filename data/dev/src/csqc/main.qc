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

	if (framecount == 10)
		localcmd("exec haze.cfg\n");
};

noref void(float apiver, string enginename, float enginever) CSQC_Init = {};

//
// First loaded, run once
//

void() CSQC_WorldLoaded  =
{
	// Spawn sky
	sky = spawn();
	sky.scale = 6;
	precache_model ("progs/sky.iqm");
	setmodel(sky, "progs/sky.iqm");

	// Ask SSQC for values to send
	sendevent("GrabCSQCValues", "");
};