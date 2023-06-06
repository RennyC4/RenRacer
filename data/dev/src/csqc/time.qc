void(vector pos) DrawTime =
{
	local float laptime = getstatf(STAT_TIME);
	local string f = ftos(laptime);
	
	drawstring (pos + '1 1', "Time: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "Time: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '34 1', f, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '33 0', f, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
};