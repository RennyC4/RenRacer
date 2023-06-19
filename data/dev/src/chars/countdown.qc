void(float type) countdown_announce =
{
	local entity y, head, ent = world;
	head = world;

	local string f = ftos(countdown_count);

	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (!type)
			centerprint (targ, "/PRACE STARTS IN\n\n[^1^b", f, "^b^7]\n");
		else
			centerprint (targ, "^1! GO GO GO !\n");
	}
};

.float spawncar;
void() countdown_think = // Race start countdown
{
	local entity oself;
	
	// Spawn players cars
	for (entity targ = world;(targ = find(targ, classname, "player"));)
	{
		if (!targ.spawncar)
		{
			oself = self;
			self = targ;
			local entity car = hotrod();
			makevectors(targ.angles);
			car = Phys_ObjectCreate(car, self.origin, v_forward, -v_right, v_up, '0 0 1', 0);
			Car_InitVehicle(car);
			self = oself;
			targ.spawncar = TRUE;
		}
	}

	if (countdown_finished < time && countdown_count > -1)
	{
		local string f = ftos(countdown_count);
		if (countdown_count > 0)
		{
			if (countdown_count == 3)
				sound (self, CHAN_AUTO, "3.wav", 1, ATTN_NONE);
			if (countdown_count == 2)
				sound (self, CHAN_AUTO, "2.wav", 1, ATTN_NONE);
			sound (self, CHAN_AUTO, "cntdwn.wav", 1, ATTN_NONE);
			if (countdown_count == 1)
				sound (self, CHAN_AUTO, "1.wav", 1, ATTN_NONE);
			countdown_announce(0);
		}
		else
		{
			sound (self, CHAN_AUTO, "gogo.wav", 1, ATTN_NONE);
			countdown_announce(1);
			race_status = RACE_STARTED;
		}
		countdown_count = countdown_count - 1;
		countdown_finished = time + 1;
		if (countdown_count < 0) // Done my job, goodbye!
		{
			remove(self);
			return;
		}
	}
	frameskip(0.1);
};

void() spawn_car_countdown =
{
	local entity cd = spawn();
	cd.think = countdown_think;
	cd.nextthink = time + 0.1;
};