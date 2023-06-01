//
// CSQC Game Camera
//

void() GameCamera =
{
	camang = getproperty(VF_ANGLES);

	makevectors(camang);
	campos = getproperty(VF_ORIGIN) - v_forward * 150 + v_up * 24;

	tracebox(campos, '-16 -16 -16', '16 16 16', campos, TRUE, self);

	setproperty(VF_ORIGIN, trace_endpos);
	setproperty(VF_AFOV, 90);
};