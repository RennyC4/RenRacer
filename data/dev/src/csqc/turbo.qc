void(vector pos) DrawTurbo =
{
	local float turbof = getstatf(STAT_TURBOFUEL);
	local string f = ftos(turbof);
	
	if (turbof > 99)
		f = "MAX";

	drawstring (pos + '1 1', "Turbo: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "Turbo: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '34 1', f, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '33 0', f, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
};