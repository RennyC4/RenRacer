void() HUD_Deathmatch =
{
	//
	// Fire rocket information on HUD
	//

	vector pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/4, (g_height)/1.05];
	drawpic (pos + '1 1', "progs/hud/hud_frckt.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_frckt.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float firerocket_ammo = getstatf(STAT_AMMO_FIREROCKET);
	string printammo = ftos(firerocket_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Homing rocket information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/3.25, (g_height)/1.05];
	drawpic (pos + '1 1', "progs/hud/hud_hrckt.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_hrckt.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float homingrocket_ammo = getstatf(STAT_AMMO_HOMINGROCKET);
	printammo = ftos(homingrocket_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Power rocket information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/2.75, (g_height)/1.05];
	drawpic (pos + '1 1', "progs/hud/hud_prckt.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_prckt.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float powerrocket_ammo = getstatf(STAT_AMMO_POWERROCKET);
	printammo = ftos(powerrocket_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Napalm information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/2.4, (g_height)/1.05];
	drawpic (pos + '1 1', "progs/hud/hud_napalm.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_napalm.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float napalm_ammo = getstatf(STAT_AMMO_NAPALM);
	printammo = ftos(napalm_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);
};