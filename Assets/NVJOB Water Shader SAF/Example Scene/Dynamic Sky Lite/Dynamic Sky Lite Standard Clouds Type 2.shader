// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Dynamic Sky Lite (Standard render) V2.2. MIT license - license_nvjob.txt
// #NVJOB Nicholas Veselov - https://nvjob.pro, http://nvjob.dx.am


Shader "#NVJOB/Dynamic Sky Lite (Standard)/Clouds Type 2" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



Properties{
//----------------------------------------------

[Header(R Channel)]
_TextureUvR("R Uv Scale", Float) = 1
_IntensityR("R Intensity", Range(-10, 10)) = 1.5
_TextureVR("R Motion Vector", Vector) = (0.9, 1, 0, 0)
[NoScaleOffset]_TextureR("Texture R", 2D) = "white" {}

[Space(5)][Header(G Channel)]
_TextureUvG("G Uv Scale", Float) = 1
_IntensityG("G Intensity", Range(-10, 10)) = 1.5
_TextureVG("G Motion Vector", Vector) = (1.3, 1.2, 0, 0)
[NoScaleOffset]_TextureG("Texture G", 2D) = "white" {}

[Space(5)][Header(B Channel)]
_TextureUvB("B Uv Scale", Float) = 1
_IntensityB("B Intensity", Range(-10, 10)) = -0.5
_TextureVB("B Motion Vector", Vector) = (-1, -1, 0, 0)
[NoScaleOffset]_TextureB("Texture B", 2D) = "white" {}

[Space(5)][Header(General)]
_Color("Main Color", Color) = (1,1,1,1)
_IntensityInput("Intensity Input", Range(-20, 20)) = 1.6
_Fluffiness("Fluffiness", Range(-1, 1)) = 0.75
_IntensityOutput("Intensity Output", Range(-20, 20)) = 1

//----------------------------------------------
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



SubShader{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
Tags{ "Queue" = "Geometry+500" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
Blend SrcAlpha OneMinusSrcAlpha
LOD 200

CGPROGRAM
#pragma surface surf Nolight alpha:fade vertex:vert exclude_path:prepass nofog nolightmap nometa nolppv noshadowmask noshadow noforwardadd novertexlights halfasview

//----------------------------------------------

half4 LightingNolight(SurfaceOutput s, half3 nullA, half nullB) {
half4 c;
c.rgb = s.Albedo;
c.a = s.Alpha;
return c;
}

//----------------------------------------------

sampler2D _TextureR, _TextureG, _TextureB;
half4 _Color;
half4 _TextureVR, _TextureVG, _TextureVB;
half _IntensityR, _IntensityG, _IntensityB, _IntensityInput, _IntensityOutput, _Fluffiness;
half _TextureUvR, _TextureUvG, _TextureUvB;
half _SkyShaderUvX, _SkyShaderUvZ;

//----------------------------------------------

struct Input {
float2 posTex;
};

//----------------------------------------------

struct appdata {
float4 vertex : POSITION;
float3 normal : NORMAL;
float2 texcoord : TEXCOORD0;
float4 texcoord1 : TEXCOORD1;
float4 color : COLOR;
};

//----------------------------------------------

void vert(inout appdata v, out Input o) {
UNITY_INITIALIZE_OUTPUT(Input, o);
o.posTex = float4(v.texcoord * 1.0 - 1.0, 0.0, 1.0);
}

//----------------------------------------------

void surf(Input IN, inout SurfaceOutput o) {
half4 tex = _Color;

half2 uv = IN.posTex;
uv.xy += half2(_SkyShaderUvX * _TextureVR.x, _SkyShaderUvZ * _TextureVR.y);
tex *= tex2D(_TextureR, uv * _TextureUvR).r * _IntensityR;

half2 uvd = IN.posTex;
uvd.xy += half2(_SkyShaderUvX * _TextureVG.x, _SkyShaderUvZ * _TextureVG.y);
tex *= tex2D(_TextureG, uvd * _TextureUvG).g * _IntensityG;

half2 uvdd = IN.posTex;
uvdd.xy += half2(_SkyShaderUvX * _TextureVB.x, _SkyShaderUvZ * _TextureVB.y);
tex *= tex2D(_TextureB, uvdd * _TextureUvB).b * _IntensityB;

tex *= _IntensityInput;
half4 outTex = normalize((tex - 0.5) * _Fluffiness + 0.5);
outTex *= _IntensityOutput;

o.Albedo = outTex;
o.Alpha = tex.a;
}

//----------------------------------------------

ENDCG

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


Fallback "Legacy Shaders/Transparent/VertexLit"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}