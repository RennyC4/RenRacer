void(vector pos) DrawTime =
{
	local float laptime = getstatf(STAT_TIME);
	local string f = ftos(laptime);
	
	f = sprintf("%.2f", laptime); // cut down numbers
	
	drawstring (pos + '1 1', "Time: ", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos, "Time: ", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);

	drawstring (pos + '28 1', f, '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
	drawstring (pos + '27 0', f, '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
};