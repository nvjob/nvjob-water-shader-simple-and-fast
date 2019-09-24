// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVJOB Sky Shader - simple and fast. MIT license - license_nvjob.txt
// NVJOB Sky Shader - simple and fast V2.1 - https://github.com/nvjob/nvjob-sky-shader-simple-and-fast
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.pro, http://nvjob.dx.am


Shader "#NVJOB/Nature/Sky/Sky (Detail, Parallax, Transparent, Nolight, Noshadow)" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



Properties{
//----------------------------------------------

_Color ("Main Color", Color) = (1,1,1,1)

_Texture1("Texture 1", 2D) = "white" {}
_IntensityT1("Intensity Texture 1", Range(-10, 10)) = 1.5
_TextureV1("Texture 1 Vector", Vector) = (0.9, 1, 0, 0)

_Texture2("Texture 2", 2D) = "gray" {}
_IntensityT2("Intensity Texture 2", Range(-10, 10)) = 1.5
_TextureV2("Texture 2 Vector", Vector) = (1.3, 1.2, 0, 0)

_Texture3("Texture 3", 2D) = "gray" {}
_IntensityT3("Intensity Texture 3", Range(-10, 10)) = -0.5
_TextureV3("Texture 3 Vector", Vector) = (-1, -1, 0, 0)

_IntensityTAll("Intensity All", Range(-5, 10)) = 0.6
_Fluffiness("Fluffiness", Range(-1, 1)) = 0.75

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
#pragma surface surf Nolight alpha:fade exclude_path:prepass nofog nolightmap nometa nolppv noshadowmask noshadow noforwardadd novertexlights halfasview

//----------------------------------------------

half4 LightingNolight(SurfaceOutput s, half3 nullA, half nullB) {
half4 c;
c.rgb = s.Albedo;
c.a = s.Alpha;
return c;
}

//----------------------------------------------

sampler2D _Texture1, _Texture2, _Texture3;
fixed4 _Color;
fixed4 _TextureV1, _TextureV2, _TextureV3;
half _IntensityT1, _IntensityT2, _IntensityT3, _IntensityTAll, _Fluffiness;
half _SkyShaderUvX, _SkyShaderUvZ;

//----------------------------------------------

struct Input {
float2 uv_Texture1;
float2 uv_Texture2;
float2 uv_Texture3;
};

//----------------------------------------------

void surf(Input IN, inout SurfaceOutput o) {

half2 uv = IN.uv_Texture1;
uv.xy += half2(_SkyShaderUvX * _TextureV1.x, _SkyShaderUvZ * _TextureV1.y);

half2 uvd = IN.uv_Texture2;
uvd.xy += half2(_SkyShaderUvX * _TextureV2.x, _SkyShaderUvZ * _TextureV2.y);

half2 uvdd = IN.uv_Texture3;
uvdd.xy += half2(_SkyShaderUvX * _TextureV3.x, _SkyShaderUvZ * _TextureV3.y);

fixed4 tex = _Color;

tex *= tex2D(_Texture1, uv) * _IntensityT1;
tex *= tex2D(_Texture2, uvd).r * _IntensityT2;
tex *= tex2D(_Texture3, uvdd).r * _IntensityT3;
tex *= _IntensityTAll;
o.Albedo = normalize((tex - 0.5) * _Fluffiness + 0.5);
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