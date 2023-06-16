void() DrawDrift =
{
	local vector pos = [(g_width - stringwidth("", TRUE, '18 18 0'))/7.5, (g_height - 46)];

	local float drift = getstatf(STAT_DRIFT);
	local string f = ftos(drift);

	if (drift)
	{
		drawstring (pos + '1 1', "+ Drift!", '8 8 0', '0 0 0', 1, DRAWFLAG_NORMAL); // text shadow
		drawstring (pos, "+ Drift!", '8 8 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	}
};