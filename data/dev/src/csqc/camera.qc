//
// CSQC Game Camera
//

vector plyr_pos;
void() GameCamera =
{
    camang = getproperty(VF_ANGLES);
    makevectors(camang);

    campos = getproperty(VF_ORIGIN) - v_forward * 150 + v_up * 24;
    plyr_pos = getproperty(VF_ORIGIN);

    tracebox(plyr_pos, '-16 -16 -16', '16 16 16', campos, TRUE, self);

    setproperty(VF_ORIGIN, trace_endpos);
    setproperty(VF_AFOV, 90);
};