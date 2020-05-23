// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Simple Water Shaders. MIT license - license_nvjob.txt
// #NVJOB Simple Water Shaders v1.5 - https://nvjob.github.io/unity/nvjob-water-shader
// #NVJOB Nicholas Veselov - https://nvjob.github.io


Shader "#NVJOB/Simple Water Shader/Water Surface" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Properties{
//----------------------------------------------

[HideInInspector]_AlbedoTex1("Albedo Texture 1", 2D) = "white" {}
[HideInInspector][HDR]_AlbedoColor("Albedo Color", Color) = (0.15,0.161,0.16,1)
[HideInInspector][NoScaleOffset]_AlbedoTex2("Albedo Texture 2", 2D) = "gray" {}
[HideInInspector]_Albedo2Tiling("Albedo 2 Tiling", float) = 1
[HideInInspector]_Albedo2Flow("Albedo 2 Flow", float) = 1
[HideInInspector]_AlbedoIntensity("Albedo Intensity", Range(0.1, 5)) = 1
[HideInInspector]_AlbedoContrast("Albedo Contrast", Range(-0.5, 3)) = 1
[HideInInspector]_Glossiness("Glossiness", Range(0,1)) = 0.5
[HideInInspector]_Metallic("Metallic", Range(0,1)) = 0.0
[HideInInspector]_SoftFactor("Soft Factor", Range(0.0001, 1)) = 0.5
[HideInInspector]_NormalMap1("Normal Map 1", 2D) = "bump" {}
[HideInInspector]_NormalMap1Strength("Normal Map 1 Strength", Range(0.001, 10)) = 1
[HideInInspector][NoScaleOffset]_NormalMap2("Normal Map 2", 2D) = "bump" {}
[HideInInspector]_NormalMap2Tiling("Normal Map 2 Tiling", float) = 1.2
[HideInInspector]_NormalMap2Strength("Normal Map 2 Strength", Range(0.001, 10)) = 1
[HideInInspector]_NormalMap2Flow("Normal Map 2 Flow", float) = 0.5
[HideInInspector]_MicrowaveScale("Microwave Scale", Range(0.5, 10)) = 1
[HideInInspector]_MicrowaveStrength("Microwave Strength", Range(0.001, 1.5)) = 0.5
[HideInInspector][NoScaleOffset]_ParallaxMap("Parallax Map", 2D) = "black" {}
[HideInInspector]_ParallaxMapTiling("Parallax Map Tiling", float) = 1
[HideInInspector]_ParallaxAmount("Parallax Amount", float) = 0.1
[HideInInspector]_ParallaxNormal2Offset("Parallax Normal Map 2 Offset", float) = 1
[HideInInspector]_ParallaxFlow("Parallax Flow", float) = 1

//----------------------------------------------
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



SubShader{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tags{ "Queue" = "Geometry+800" "IgnoreProjector" = "True" "RenderType" = "Transparent" "ForceNoShadowCasting" = "True" }
LOD 200
Cull Off
ZWrite On

CGPROGRAM
#pragma shader_feature_local EFFECT_ALBEDO2
#pragma shader_feature_local EFFECT_NORMALMAP2
#pragma shader_feature_local EFFECT_MICROWAVE
#pragma shader_feature_local EFFECT_PARALLAX
#pragma surface surf Standard alpha:fade vertex:vert noshadowmask noshadow
#pragma target 3.0

//----------------------------------------------

sampler2D _AlbedoTex1;
sampler2D _NormalMap1;
sampler2D_float _CameraDepthTexture;
float4 _CameraDepthTexture_TexelSize;
fixed4 _AlbedoColor;
half _Glossiness;
half _Metallic;
half _AlbedoIntensity;
half _AlbedoContrast;
half _NormalMap1Strength;
half _SoftFactor;
half _WaterLocalUvX;
half _WaterLocalUvZ;
half _WaterLocalUvNX;
half _WaterLocalUvNZ;

#ifdef EFFECT_ALBEDO2
sampler2D _AlbedoTex2;
half _Albedo2Tiling;
half _Albedo2Flow;
#endif

#ifdef EFFECT_NORMALMAP2
sampler2D _NormalMap2;
half _NormalMap2Tiling;
half _NormalMap2Strength;
half _ParallaxNormal2Offset;
half _NormalMap2Flow;
#endif

#ifdef EFFECT_MICROWAVE
half _MicrowaveScale;
half _MicrowaveStrength;
#endif

#ifdef EFFECT_PARALLAX
sampler2D _ParallaxMap;
half _ParallaxAmount;
half _ParallaxMapTiling;
half _ParallaxFlow;
#endif

//----------------------------------------------

struct Input {
float2 uv_AlbedoTex1;
float2 uv_NormalMap1;
float3 worldRefl;
float4 screenPos;
float eyeDepth;
float3 viewDir;
INTERNAL_DATA
};

//----------------------------------------------

void vert(inout appdata_full v, out Input o) {
UNITY_INITIALIZE_OUTPUT(Input, o);
COMPUTE_EYEDEPTH(o.eyeDepth);
}

//----------------------------------------------

void surf(Input IN, inout SurfaceOutputStandard o) {

#ifdef EFFECT_PARALLAX
half2 uvnh = IN.uv_NormalMap1;
uvnh.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ) * -_ParallaxFlow;
half h = tex2D(_ParallaxMap, uvnh * _ParallaxMapTiling).r;
half2 offset = ParallaxOffset(h, _ParallaxAmount, IN.viewDir);
IN.uv_AlbedoTex1 -= offset;
IN.uv_NormalMap1 += offset;
half2 uvn = IN.uv_NormalMap1;
uvn.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ);
#ifdef EFFECT_NORMALMAP2
half2 uvnd = IN.uv_NormalMap1 + (offset * _ParallaxNormal2Offset);
uvnd.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ) * _NormalMap2Flow;
#endif
#else
half2 uvn = IN.uv_NormalMap1;
uvn.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ);
#ifdef EFFECT_NORMALMAP2
half2 uvnd = IN.uv_NormalMap1;
uvnd.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ) * _NormalMap2Flow;
#endif
#endif

half2 uv = IN.uv_AlbedoTex1;
uv.xy += half2(_WaterLocalUvX, _WaterLocalUvZ);
#ifdef EFFECT_ALBEDO2
half2 uvd = IN.uv_AlbedoTex1;
uvd.xy += half2(_WaterLocalUvX, _WaterLocalUvZ) * _Albedo2Flow;
#endif

fixed4 tex = tex2D(_AlbedoTex1, uv) * _AlbedoColor;
#ifdef EFFECT_ALBEDO2
tex *= tex2D(_AlbedoTex2, uvd * _Albedo2Tiling);
#endif
tex *= _AlbedoIntensity;
o.Albedo = ((tex - 0.5) * _AlbedoContrast + 0.5).rgb;

o.Metallic = _Metallic;
o.Smoothness = _Glossiness;

fixed3 normal = UnpackNormal(tex2D(_NormalMap1, uvn)) * _NormalMap1Strength;
#ifdef EFFECT_NORMALMAP2
normal += UnpackNormal(tex2D(_NormalMap2, uvnd * _NormalMap2Tiling)) * _NormalMap2Strength;
#ifdef EFFECT_MICROWAVE
normal -= UnpackNormal(tex2D(_NormalMap2, (uv + uvnd) * 2 * _MicrowaveScale)) * _MicrowaveStrength;
o.Normal = normalize(normal / 3);
#else
o.Normal = normalize(normal / 2);
#endif
#else
o.Normal = normal;
#endif

half rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + 0.0001));
half fade = saturate(_SoftFactor * (LinearEyeDepth(rawZ) - IN.eyeDepth));
o.Alpha = _AlbedoColor.a * fade;

}

//----------------------------------------------

ENDCG

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


FallBack "Legacy Shaders/Reflective/Bumped Diffuse"
CustomEditor "NVWaterMaterials"


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
