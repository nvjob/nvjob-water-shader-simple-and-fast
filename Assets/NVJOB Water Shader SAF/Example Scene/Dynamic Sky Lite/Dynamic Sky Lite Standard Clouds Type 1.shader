// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Dynamic Sky Lite (Standard render) V2.2. MIT license - license_nvjob.txt
// #NVJOB Nicholas Veselov - https://nvjob.pro, http://nvjob.dx.am


Shader "#NVJOB/Dynamic Sky Lite (Standard)/Clouds Type 1" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



Properties{
//----------------------------------------------

[Header(Main Texture)]
_TextureUv1("Uv Scale", Float) = 1
_IntensityT1("Intensity", Range(-10, 10)) = 1.5
_TextureV1("Motion Vector", Vector) = (0.9, 1, 0, 0)
[NoScaleOffset]_Texture1("Main Texture", 2D) = "white" {}

[Space(5)][Header(Mixed Texture 1)]
_TextureUv2("Uv Scale", Float) = 1
_IntensityT2("Intensity", Range(-10, 10)) = 1.5
_TextureV2("Motion Vector", Vector) = (1.3, 1.2, 0, 0)
[NoScaleOffset]_Texture2("Texture 2", 2D) = "gray" {}

[Space(5)][Header(Mixed Texture 2)]
_TextureUv3("Uv Scale", Float) = 1
_IntensityT3("Intensity", Range(-10, 10)) = -0.5
_TextureV3("Motion Vector", Vector) = (-1, -1, 0, 0)
[NoScaleOffset]_Texture3("Texture 3", 2D) = "gray" {}

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

sampler2D _Texture1, _Texture2, _Texture3;
half4 _Color;
half4 _TextureV1, _TextureV2, _TextureV3;
half _IntensityT1, _IntensityT2, _IntensityT3, _IntensityInput, _IntensityOutput, _Fluffiness;
half _TextureUv1, _TextureUv2, _TextureUv3;
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
uv.xy += half2(_SkyShaderUvX * _TextureV1.x, _SkyShaderUvZ * _TextureV1.y);
tex *= tex2D(_Texture1, uv * _TextureUv1) * _IntensityT1;

half2 uvd = IN.posTex;
uvd.xy += half2(_SkyShaderUvX * _TextureV2.x, _SkyShaderUvZ * _TextureV2.y);
tex *= tex2D(_Texture2, uvd * _TextureUv2).r * _IntensityT2;

half2 uvdd = IN.posTex;
uvdd.xy += half2(_SkyShaderUvX * _TextureV3.x, _SkyShaderUvZ * _TextureV3.y);
tex *= tex2D(_Texture3, uvdd * _TextureUv3).r * _IntensityT3;

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