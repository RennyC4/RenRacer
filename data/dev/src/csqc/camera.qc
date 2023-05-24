//
// CSQC Game Camera
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
	
	tracebox(plyr_pos, '-8 -8 -8', '8 8 8', campos, FALSE, self);

	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, trace_endpos);
	setproperty(VF_AFOV, 90);
};