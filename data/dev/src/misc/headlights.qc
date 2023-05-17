void() headlights_toggle =
{
	if (self.headlights == FALSE)
	{
		self.effects = EF_MUZZLEFLASH;
		sprint(self, "Headlights: ON\n");
		self.effects = EF_BRIGHTLIGHT;
		self.headlights = TRUE;
	}
	else
	{
		sprint(self, "Headlights: OFF\n");
		self.effects = 0;
		self.headlights = FALSE;
	}
}; 