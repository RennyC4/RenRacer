float WEP_ROCKET = 0;
float WEP_HROCKET = 1;
float WEP_PROCKET = 2;
float WEP_NAPALM = 4;

void EntUpdate_RadarBlip(float is_new)
{
	float sendflags = readbyte();

	if (sendflags & 0x01)
	{
		self.origin_x = readcoord();
		self.origin_y = readcoord();
	}
	if (sendflags & 0x02)
	{
		self.colormap = readlong();
	}
	self.classname = "radarblip";
}

void() DrawRadar =
{
	vector radar_position = [(g_width / 1.15), (g_height / 32)];
	vector radar_size = '75 75 0';
	vector radar_centerpoint = radar_position + (radar_size / 2);

	// Draw radars view area
	drawfill(radar_position, radar_size, '0 1 0', 0.25, DRAWFLAG_NORMAL); // draw radar
	drawfill(radar_centerpoint, '2 2 0', '1 0 0', 0.5, DRAWFLAG_NORMAL); // draw centerdot (rotation point)

	for(entity radarblip = find(world, classname, "radarblip"); radarblip; radarblip = find(radarblip, classname, "radarblip"))
	{
		vector view_org = getproperty(VF_ORIGIN);
		float view_ang = deg2rad(getproperty(VF_ANGLES_Y)); // convert to radians because cos/sin are in radians not degrees
		vector blip_origin = radarblip.origin - view_org;
		vector translated_origin;
		translated_origin_x = (blip_origin_x * cos(view_ang)) - (blip_origin_y * sin(view_ang));
		translated_origin_y = (blip_origin_y * cos(view_ang)) + (blip_origin_x * sin(view_ang));
		translated_origin_z = 0;

		drawfill(radar_centerpoint - translated_origin, '2 2 0', '1 1 1', 0.5, DRAWFLAG_NORMAL); // Draw other car blips
	}
};

void() HUD_Deathmatch =
{
	DrawRadar();
	
	//
	// Draw Health
	//

	vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-28, (g_height - 36)];

	float h = getstatf(STAT_HEALTH);
	float hmax = getstatf(STAT_MAXHEALTH);

	string h1 = ftos(h);
	string h2 = ftos(hmax);

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

	float wep = getstatf(STAT_WEAPON);

	//
	// Fire rocket information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/4, (g_height)/1.05];
	if (wep == WEP_ROCKET)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos + '1 1', "progs/hud/hud_frckt.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_frckt.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float firerocket_ammo = getstatf(STAT_AMMO_FIREROCKET);
	string printammo = ftos(firerocket_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "1", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^11", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Homing rocket information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/3.25, (g_height)/1.05];
	if (wep == WEP_HROCKET)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos + '1 1', "progs/hud/hud_hrckt.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_hrckt.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float homingrocket_ammo = getstatf(STAT_AMMO_HOMINGROCKET);
	printammo = ftos(homingrocket_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "2", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^12", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Power rocket information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/2.75, (g_height)/1.05];
	if (wep == WEP_PROCKET)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos + '1 1', "progs/hud/hud_prckt.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_prckt.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float powerrocket_ammo = getstatf(STAT_AMMO_POWERROCKET);
	printammo = ftos(powerrocket_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "1", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^13", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Napalm information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/2.4, (g_height)/1.05];
	if (wep == WEP_NAPALM)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos + '1 1', "progs/hud/hud_napalm.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_napalm.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float napalm_ammo = getstatf(STAT_AMMO_NAPALM);
	printammo = ftos(napalm_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "1", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^14", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);
};