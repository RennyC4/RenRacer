void(float type) countdown_announce =
{
	local entity y, head, ent = world;
	head = world;

	local string f = ftos(countdown_count);

	y = find(world, classname, "player");
	while(y)
	{
		if (!type)
			centerprint (y, "RACE STARTS IN\n\n[", f, "]\n");
		else
			centerprint (y, "! GO GO GO !\n");
		y = find(y, classname, "player");
	}
	if (head)
		ent.chain = world;
};

void() countdown_think = // Race start countdown
{
	if (countdown_finished < time && countdown_count > -1)
	{
		local string f = ftos(countdown_count);
		if (countdown_count > 0)
		{
			localsound("cntdwn.wav");
			countdown_announce(0);
		}
		else
		{
			localsound("gogo.wav");
			countdown_announce(1);
			race_status = RACE_STARTED;
		}
		countdown_count = countdown_count - 1;
		countdown_finished = time + 1;
	}
	frameskip(0.1);
};

void() spawn_countdown =
{
	local entity cd = spawn();
	cd.think = countdown_think;
	cd.nextthink = time + 0.1;
};