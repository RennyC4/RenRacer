//
// Game Camera - TODO: Add wall detection
//

void() GameCamera =
{
	campos = getproperty(VF_ORIGIN);
	camang = getproperty(VF_ANGLES);
	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, campos);

	local vector plyr_pos = [getstatf(STAT_ORIGINX), getstatf(STAT_ORIGINY), getstatf(STAT_ORIGINZ)];
	//camang_x = 15; // Lock angle, can mess up controls until level restart is called
	makevectors(camang);
	campos = plyr_pos - v_forward * 128 + v_up * 40;
		
	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, campos);
	setproperty(VF_AFOV, 90);
};