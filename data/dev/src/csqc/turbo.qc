void() DrawTurbo =
{
	vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-24, (g_height - 46)];

	float turbof = getstatf(STAT_TURBOFUEL);
	string f = ftos(turbof);
	
	// Bar
	vector tbar_size = '58 8 0';
	vector tbar_border_size = tbar_size + '1.6 1.5 0';
	vector tbarpos = pos - '-32 1.5 0';
	tbar_size_x = (turbof / 100) * tbar_size_x; // keep bar updated

	drawfill(tbarpos + '1 1 0', tbar_size, '1 1 0', 1, DRAWFLAG_NORMAL);

	// Text
	if (turbof > 99)
		f = "MAX";
	if (turbof <= 15)
		f = strcat("^1", f);

	drawstring (pos + '1 1', "Turbo: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "^3Turbo: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '34 1', f, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '33 0', f, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
};