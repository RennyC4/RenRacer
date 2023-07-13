float WEP_ROCKET = 0;
float WEP_HROCKET = 1;
float WEP_PROCKET = 2;
float WEP_NAPALM = 4;

void() HUD_Deathmatch =
{
	//
	// Draw Health
	//

	local vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-28, (g_height - 36)];

	local float h = getstatf(STAT_HEALTH);
	local float hmax = getstatf(STAT_MAXHEALTH);

	local string h1 = ftos(h);
	local string h2 = ftos(hmax);

	drawstring (pos + '1 1', "Health: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "^1Health: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '37 1', h1, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '36 0', h1, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '57 1', "/", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '56 0', "/", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '67 1', h2, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '66 0', h2, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Draw Energy
	//

	pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-32, (g_height - 26)];
	float e = getstatf(STAT_ENERGY);
	string e1 = ftos(e);

	drawstring (pos + '1 1', "Energy: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "^4Energy: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '37 1', e1, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '36 0', e1, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '57 1', "/", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '56 0', "/", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '67 1', "100", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '66 0', "100", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	local float wep = getstatf(STAT_WEAPON);

	//
	// Fire rocket information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/4, (g_height)/1.05];
	drawpic (pos + '1 1', "progs/hud/hud_frckt.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_frckt.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float firerocket_ammo = getstatf(STAT_AMMO_FIREROCKET);
	string printammo = ftos(firerocket_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "1", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^11", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

	if (wep == WEP_ROCKET)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

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

	// Draw weapon select #
	drawstring (pos - '-2 -6', "2", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^12", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);
	
	if (wep == WEP_HROCKET)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

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

	// Draw weapon select #
	drawstring (pos - '-2 -6', "1", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^13", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);
	
	if (wep == WEP_PROCKET)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

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

	// Draw weapon select #
	drawstring (pos - '-2 -6', "1", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^14", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

	if (wep == WEP_NAPALM)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);
};