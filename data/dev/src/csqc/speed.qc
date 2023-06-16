void() DrawSpeed =
{
	local vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/12-28, (g_height - 36)];

	local float speed = getstatf(STAT_SPEED);
	speed = ceil(speed);
	if (speed < 5)
		speed = 0;

	local string f = ftos(speed);
	
	drawstring (pos + '1 1', "Speed: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "Speed: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '34 1', f, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '33 0', f, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '54 1', "km/h", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '53 0', "km/h", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
};