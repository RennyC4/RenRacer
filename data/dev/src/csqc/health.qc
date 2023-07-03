void() DrawHealth =
{
	//local vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-34, (g_height - 16)];
	local vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-28, (g_height - 36)];

	local float h = getstatf(STAT_HEALTH);
	local float hmax = getstatf(STAT_MAXHEALTH);

	local string h1 = ftos(h);
	local string h2 = ftos(hmax);

	drawstring (pos + '1 1', "Health: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "Health: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '37 1', h1, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '36 0', h1, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '57 1', "/", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '56 0', "/", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '67 1', h2, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '66 0', h2, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
};