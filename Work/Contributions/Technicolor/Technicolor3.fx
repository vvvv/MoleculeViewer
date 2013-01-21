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
float4 greenfilter : COLOR  = {0.0, 1.0, 0.0, 1.0};
float4 bluefilter : COLOR  = {0.0, 0.0, 1.0, 1.0};
float4 redorangefilter : COLOR  = {.99, 0.263, 0.0, 1.0};
float4 cyanfilter : COLOR  = {0.0, 1.0, 1.0, 1.0};
float4 magentafilter : COLOR  = {1.0, 0.0, 1.0, 1.0};
float4 yellowfilter : COLOR  = {1.0, 1.0, 0.0, 1.0};

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

float4 PS_Technicolor3(vs2ps In): COLOR

{
    float4 col0 = tex2D(Samp, In.TexCd);
    
    float4 filtgreen = col0 * greenfilter;
    float4 filtblue = col0 * magentafilter;
    float4 filtred = col0 * redorangefilter;

    float4 rednegative = float((filtred.r + filtred.g + filtred.b)/3.0);
    float4 greennegative = float((filtgreen.r + filtgreen.g + filtgreen.b)/3.0);
    float4 bluenegative = float((filtblue.r+ filtblue.g + filtblue.b)/3.0);
    
    float4 redoutput = rednegative + cyanfilter;
    float4 greenoutput = greennegative + magentafilter;
    float4 blueoutput = bluenegative + yellowfilter;
    
    float4 result = redoutput * greenoutput * blueoutput;

    return lerp(col0, result, amount);
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Technicolor3
{
    pass p0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader = compile ps_2_0 PS_Technicolor3();
    }

}

//EOF//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
