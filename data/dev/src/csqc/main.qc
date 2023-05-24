//
// Main Loop
//
entity sky;

void(float width, float height, float menushown) CSQC_UpdateView =
{
	framecount = framecount + 1;

	clearscene(); //wipe entity lists, reset view properties to their defaults

	// Turn off crosshair & status bar
	setproperty(VF_DRAWENGINESBAR, 0);	
	setproperty(VF_DRAWCROSSHAIR, 0);

	GameCamera(); // Games camera

	sky.origin = campos - '0 0 0';
	sky.angles = '0 0 0';
	addentity(sky);

	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);
	renderscene();
};

//
// First loaded, run once
//

void() CSQC_WorldLoaded  =
{
	// Spawn sky
	sky = spawn();
	sky.scale = 6;
	setmodel(sky, "progs/sky.iqm");
	
	// Ask SSQC for values to send
	sendevent("GrabCSQCValues", "");
};