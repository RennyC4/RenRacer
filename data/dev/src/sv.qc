//+------+
//|SV    |
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Handle's SV_ stuff		                                                   |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

//shpuld
void() SV_RunClientCommand =
{		
	if (self.deadflag)
		input_movevalues *= 0;

	runstandardplayerphysics(self);

	makevectors([0, self.angles_y, 0]);

	vector hvel = [self.velocity_x, self.velocity_y];
	vector proposed_velocity = self.velocity + (input_movevalues_x * v_forward + input_movevalues_y * v_right) * input_timelength * 1.5;

	if (vlen([proposed_velocity_x, proposed_velocity_y]) < 320)
		self.velocity = proposed_velocity;
};