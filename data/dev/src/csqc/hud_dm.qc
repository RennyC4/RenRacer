float WEP_ROCKET = 0;
float WEP_HROCKET = 1;
float WEP_PROCKET = 2;
float WEP_NAPALM = 4;
float WEP_RICOCHET = 8;
float WEP_REMOTE = 16;
float WEP_FREEZE = 32;
float WEP_SPECIAL = 64; // Weapon 1

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
		// FIXME (Reki July 14 2023): this should get resent with a `blip.SendFlags |= 0x02;` if/when the player's color changes
		self.colormap = readbyte(); // just using this as a player index
		self.colormod = stov(getplayerkeyvalue(self.colormap, INFOKEY_P_BOTTOMCOLOR_RGB)); // scrape the RGB bottom color from the player info
	}
	self.classname = "radarblip";
}

void() DrawRadar =
{
	vector radar_position = [(g_width / 1.15), (g_height / 32)];
	vector radar_size = '75 75 0';
	vector radar_centerpoint = radar_position + (radar_size / 2);
	vector blip_size = '2 2';

	// Draw radars view area
	drawfill(radar_position, radar_size, '0 1 0', 0.25, DRAWFLAG_NORMAL); // draw radar
	drawfill(radar_centerpoint - (blip_size / 2), blip_size, '1 0 0', 0.5, DRAWFLAG_NORMAL); // draw centerdot (rotation point)

	vector view_org = getproperty(VF_ORIGIN);
	float view_ang = deg2rad(view_angles_y + 90); // convert to radians because cos/sin are in radians not degrees

	for(entity radarblip = find(world, classname, "radarblip"); radarblip; radarblip = find(radarblip, classname, "radarblip"))
	{
		vector blip_origin = radarblip.origin - view_org;
		vector translated_origin;
		translated_origin_x = (-blip_origin_x * cos(view_ang)) + (blip_origin_y * -sin(view_ang));
		translated_origin_y = (blip_origin_y * cos(view_ang)) + (-blip_origin_x * sin(view_ang));
		translated_origin_z = 0;

		translated_origin /= 200; // each radar pixel is equal to 200 units
		translated_origin += radar_centerpoint; // align to the center of the radar
		translated_origin -= blip_size / 2; // we want the blip to be on the car's center

		translated_origin_x = bound(radar_position_x, translated_origin_x, radar_position_x + radar_size_x - blip_size_x);
		translated_origin_y = bound(radar_position_y, translated_origin_y, radar_position_y + radar_size_y - blip_size_y);

		drawfill(translated_origin, blip_size, radarblip.colormod * 2, 0.7, DRAWFLAG_NORMAL); // Draw other car blips
	}
};

void() HUD_Deathmatch =
{
	vector pos;

	DrawRadar();

	//
	// Draw Enemy Health+Name Stats
	//

	pos = [(g_width / 1.15), (g_height / 32)];
	pos_y = pos_y + 80;
	float health = getstatf(STAT_ENEMYHEALTH);
	float maxhealth = getstatf(STAT_ENEMYMAXHEALTH);
	vector hbar_size = '75 6 0';
	vector hbar_border_size = hbar_size + '6 6 0';
	vector hbar_border_pos = pos - '3 3 0';
	hbar_size_x = (health / maxhealth) * hbar_size_x;

	if (health)
	{
		drawfill(hbar_border_pos, hbar_border_size, '1 0 0', 0.25, DRAWFLAG_NORMAL);
		drawfill(pos, hbar_size, '1 0 0', 0.75, DRAWFLAG_NORMAL);

		pos = [(g_width / 1.15), (g_height / 32)];
		string name = getstats(STAT_ENEMYNAME);

		drawstring (pos + '0 81', name, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
		drawstring (pos + '0 80', name, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	}

	//
	// Draw Health
	//

	pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-28, (g_height - 36)];

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
	// Draw Player ID
	//

	pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-50, (g_height - 8)];
	float i = getstatf(STAT_PLAYERID);
	string i1 = ftos(i);

	drawstring (pos + '1 1', "ID: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "ID: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '17 1', i1, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '16 0', i1, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Special weapon information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/5.5, (g_height)/1.05];
	if (wep == WEP_SPECIAL)
		drawfill(pos - '0 11', '33 23 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos - '-1 14', "progs/hud/hud_spcl.png", '32 32', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos - '0 15', "progs/hud/hud_spcl.png", '32 32', '1 1 1', 1, DRAWFLAG_NORMAL);

	float special_ammo = getstatf(STAT_AMMO_SPECIAL);
	string printammo = ftos(special_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "1", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^11", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Fire rocket information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/4, (g_height)/1.05];
	if (wep == WEP_ROCKET)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos + '1 1', "progs/hud/hud_frckt.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_frckt.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float firerocket_ammo = getstatf(STAT_AMMO_FIREROCKET);
	printammo = ftos(firerocket_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "2", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^12", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

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
	drawstring (pos - '-2 -6', "3", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^13", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

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
	drawstring (pos - '-2 -6', "4", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^14", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

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
	drawstring (pos - '-2 -6', "5", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^15", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);
	
	//
	// Richochet Bomb information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/2.125, (g_height)/1.05];
	if (wep == WEP_RICOCHET)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos + '1 1', "progs/hud/hud_rico.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_rico.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float ricochet_ammo = getstatf(STAT_AMMO_RICOCHET);
	printammo = ftos(ricochet_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "6", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^16", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Remote Bomb information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/1.9, (g_height)/1.05];
	if (wep == WEP_REMOTE)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos + '1 1', "progs/hud/hud_remote.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_remote.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float remote_ammo = getstatf(STAT_AMMO_REMOTE);
	printammo = ftos(remote_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "7", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^17", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);

	//
	// Freeze Blast information on HUD
	//

	pos = [(g_width - stringwidth("", TRUE, '32 16 0'))/1.725, (g_height)/1.05];
	if (wep == WEP_FREEZE)
		drawfill(pos, '33 20 0', '1 0 0', 0.3, DRAWFLAG_NORMAL);

	drawpic (pos + '1 1', "progs/hud/hud_freeze.png", '32 16', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawpic (pos, "progs/hud/hud_freeze.png", '32 16', '1 1 1', 1, DRAWFLAG_NORMAL);

	float freeze_ammo = getstatf(STAT_AMMO_FREEZE);
	printammo = ftos(freeze_ammo);

	drawstring (pos - '-14 9', printammo, '8 8', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-13 10', printammo, '8 8', '1 1 1', 1, DRAWFLAG_NORMAL);

	// Draw weapon select #
	drawstring (pos - '-2 -6', "8", '6 6', '0 0 0', 1, DRAWFLAG_NORMAL); // shadow
	drawstring (pos - '-1 -5', "^18", '6 6', '1 1 1', 1, DRAWFLAG_NORMAL);
};