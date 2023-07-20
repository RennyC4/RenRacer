progs/frozen.mdl_0
{
    {
		map progs/frozen.mdl_0
		rgbGen lightingDiffuse // proper shading for vertex lit models, or something. 
    }		
	{
		map progs/frozen.mdl_0
		blendFunc GL_SRC_ALPHA GL_ONE
		alphaGen const 0.25
		tcGen environment
		rgbgen entity
	}
}