void() DrawTurbo =
{
	local vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-24, (g_height - 46)];

	local float turbof = getstatf(STAT_TURBOFUEL);
	local string f = ftos(turbof);
	
	if (turbof > 99)
		f = "MAX";
	if (turbof <= 15)
		f = strcat("^1", f);

	drawstring (pos + '1 1', "Turbo: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "^3Turbo: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '34 1', f, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '33 0', f, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
};