// Currently suffers from a glitch with engine sounds...

entity speedline;
float speedline_move;
void() speedline_think =
{
	if (speedline_move < time)
	{
		speedline.angles_z = random()*360;
		speedline_move = time + 0.05;
	}
	speedline.nextthink = time;
};

void() DrawSpeedLines =
{
	local vector pos = 0;
	pos_x = g_width / 100;
	pos_y = g_height / 100;
	
	local vector size = 0;
	size_x = g_width * 1.1;
	size_y = g_height * 1.1;

	if (!speedline)
	{
		speedline = spawn();
		setmodel (speedline, "progs/v_speed.mdl");
		setorigin(speedline, '0 0 0');
	}
	else
	{
		entdraw(speedline, pos - '10 10', size, -5);
		speedline.think = speedline_think;
		speedline.nextthink = time;
	}
};