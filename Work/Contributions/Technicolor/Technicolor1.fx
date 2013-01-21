/*

Original code from vade
http://001.vade.info/

converted from GLSL to HLSL for use with vvvv by desaxismundi
http://vvvv.org/tiki-index.php?page=UserPageDesaxismundi
http://vvvv.org/tiki-index.php?page=desaxismundi_Shaders

*/

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//Transforms
float4x4 tWVP : WorldViewProjection;

//Colors
float4 redfilter : COLOR  = {1.0, 0.0, 0.0, 1.0};
float4 bluegreenfilter : COLOR  = {0.0, 1.0, 0.7, 1.0};

float amount;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0
    )
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Out.Pos = mul(PosO, tWVP);

    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

// -------------------------------------------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// -------------------------------------------------------------------------------------------------------------------------------------

float4 PS_Technicolor1(vs2ps In): COLOR

{
    float4 col0 = tex2D(Samp, In.TexCd);
    
    float4 filtred = col0 * redfilter;
    float4 filtbluegreen = col0 * bluegreenfilter;
    
    float4 rednegative = float(filtred.r);
    float4 bluegreennegative = float((filtbluegreen.g + filtbluegreen.b)/2.0);
    
    float4 redoutput = rednegative * redfilter;
    float4 bluegreenoutput = bluegreennegative * bluegreenfilter;
    
    float4 result = redoutput + bluegreenoutput;

    return lerp(col0, result, amount);
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Technicolor1
{
    pass p0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader = compile ps_2_0 PS_Technicolor1();
    }

}

//EOF//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
