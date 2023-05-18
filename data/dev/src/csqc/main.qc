//
// Main Loop
//

void(float width, float height, float menushown) CSQC_UpdateView =
{
	framecount = framecount + 1;

	clearscene();												//wipe entity lists. reset view properties to their defaults.
	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);	//add various entities to the scene's lists.
	renderscene();												//draw the scene to the screen using the various properties.

};

//
// First loaded, run once
//
void() CSQC_WorldLoaded  =
{
	// Ask SSQC for values to send, fixes 0 display on HUD elements
	//sendevent("GrabCSQCValues", "");
};