//
// CSQC Game Camera
//

void() GameCamera =
{
	campos = getproperty(VF_ORIGIN) - v_forward * 124 + v_up * 24;
	camang = getproperty(VF_ANGLES);
	plyr_pos = getproperty(VF_ORIGIN);

	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, campos);

	makevectors(camang);

	tracebox(plyr_pos, '-8 -8 -8', '8 8 8', campos, FALSE, self);

	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, trace_endpos);
	setproperty(VF_AFOV, 90);
};