progs/shield.mdl_0
{
    {
		map progs/shield.mdl_0
		rgbGen lightingDiffuse // proper shading for vertex lit models, or something. 
		tcMod scroll 0.25 0
    }		
	{
		map progs/shield.mdl_0
		blendFunc GL_SRC_ALPHA GL_ONE
		alphaGen const 0.15
		tcGen environment
		rgbgen entity
		tcMod scroll -0.25 0
	}
}