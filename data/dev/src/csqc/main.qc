//
// Main Loop
//

void(float width, float height, float menushown) CSQC_UpdateView =
{
	framecount = framecount + 1;

	clearscene(); //wipe entity lists, reset view properties to their defaults

	// Turn off crosshair & status bar
	setproperty(VF_DRAWENGINESBAR, 0);	
	setproperty(VF_DRAWCROSSHAIR, 0);

	GameCamera(); // Games camera

	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);
	renderscene();
	
};

//
// First loaded, run once
//

void() CSQC_WorldLoaded  =
{
	// Ask SSQC for values to send, fixes 0 display on HUD elements
	sendevent("GrabCSQCValues", "");
};