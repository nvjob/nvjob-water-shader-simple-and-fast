// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Simple Water Shaders. MIT license - license_nvjob.txt
// #NVJOB Simple Water Shaders v1.6 - https://nvjob.github.io/unity/nvjob-simple-water-shaders
// #NVJOB Nicholas Veselov - https://nvjob.github.io


Shader "#NVJOB/Simple Water Shaders/Water Specular" {


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
[HideInInspector]_Shininess("Shininess", Range(0.01, 1)) = 0.15
[HideInInspector][HDR]_SpecColor("Specular Color", Color) = (0.086,0.086,0.086,1)
[HideInInspector]_SoftFactor("Soft Factor", Range(0.0001, 1)) = 0.5
[HideInInspector]_NormalMap1("Normal Map 1", 2D) = "bump" {}
[HideInInspector]_NormalMap1Strength("Normal Map 1 Strength", Range(0.001, 10)) = 1
[HideInInspector][NoScaleOffset]_NormalMap2("Normal Map 2", 2D) = "bump" {}
[HideInInspector]_NormalMap2Tiling("Normal Map 2 Tiling", float) = 0.7
[HideInInspector]_NormalMap2Strength("Normal Map 2 Strength", Range(0.001, 10)) = 1
[HideInInspector]_NormalMap2Flow("Normal Map 2 Flow", float) = 0.5
[HideInInspector]_MicrowaveScale("Micro Waves Scale", Range(0.5, 10)) = 1
[HideInInspector]_MicrowaveStrength("Micro Waves Strength", Range(0.001, 1.5)) = 0.5
[HideInInspector][NoScaleOffset]_ParallaxMap("Parallax Map", 2D) = "black" {}
[HideInInspector]_ParallaxMapTiling("Parallax Map Tiling", float) = 1
[HideInInspector]_ParallaxAmount("Parallax Amount", float) = 0.1
[HideInInspector]_ParallaxNormal2Offset("Parallax Normal Map 2 Offset", float) = 1
[HideInInspector]_ParallaxFlow("Parallax Flow", float) = 1
[HideInInspector]_ReflectionCube("Reflection Cubemap", Cube) = "" {}
[HideInInspector][HDR]_ReflectionColor("Reflection Color", Color) = (0.28,0.29,0.25,0.5)
[HideInInspector]_ReflectionStrength("Reflection Strength", Range(0, 10)) = 0.15
[HideInInspector]_ReflectionSaturation("Reflection Saturation", Range(0, 5)) = 1
[HideInInspector]_ReflectionContrast("Reflection Contrast", Range(0, 5)) = 1
[HideInInspector][HDR]_MirrorColor("Mirror Reflection Color", Color) = (1,1,1,0.5)
[HideInInspector]_MirrorDepthColor("Mirror Reflection Depth Color", Color) = (0,0,0,0.5)
[HideInInspector]_MirrorFPOW("Mirror FPOW", Float) = 5.0
[HideInInspector]_MirrorR0("Mirror R0", Float) = 0.01
[HideInInspector]_MirrorReflectionTex("_MirrorReflectionTex", 2D) = "gray" {}

//----------------------------------------------
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



SubShader{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tags{ "Queue" = "Geometry+800" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
LOD 200
Cull Off
ZWrite On

CGPROGRAM
#pragma shader_feature_local EFFECT_ALBEDO2
#pragma shader_feature_local EFFECT_NORMALMAP2
#pragma shader_feature_local EFFECT_MICROWAVE
#pragma shader_feature_local EFFECT_PARALLAX
#pragma shader_feature_local EFFECT_REFLECTION
#pragma shader_feature_local EFFECT_MIRROR
#pragma surface surf BlinnPhong alpha:fade vertex:vert exclude_path:prepass noshadowmask noshadow
#pragma target 3.0

//----------------------------------------------

sampler2D _AlbedoTex1;
sampler2D _NormalMap1;
sampler2D_float _CameraDepthTexture;
float4 _CameraDepthTexture_TexelSize;
float4 _AlbedoColor;
float _Shininess;
float _AlbedoIntensity;
float _AlbedoContrast;
float _NormalMap1Strength;
float _SoftFactor;
float _WaterLocalUvX;
float _WaterLocalUvZ;
float _WaterLocalUvNX;
float _WaterLocalUvNZ;

#ifdef EFFECT_ALBEDO2
sampler2D _AlbedoTex2;
float _Albedo2Tiling;
float _Albedo2Flow;
#endif

#ifdef EFFECT_NORMALMAP2
sampler2D _NormalMap2;
float _NormalMap2Tiling;
float _NormalMap2Strength;
float _NormalMap2Flow;
#endif

#ifdef EFFECT_MICROWAVE
float _MicrowaveScale;
float _MicrowaveStrength;
#endif

#ifdef EFFECT_PARALLAX
sampler2D _ParallaxMap;
float _ParallaxAmount;
float _ParallaxMapTiling;
float _ParallaxNormal2Offset;
float _ParallaxFlow;
#endif

#ifdef EFFECT_REFLECTION
samplerCUBE _ReflectionCube;
float4 _ReflectionColor;
float _ReflectionStrength;
float _ReflectionSaturation;
float _ReflectionContrast;
#endif

#ifdef EFFECT_MIRROR
sampler2D _GrabTexture : register(s0);
sampler2D _MirrorReflectionTex : register(s3);
float4 _MirrorColor;
float4 _MirrorDepthColor;
float _WeirdScale;
float _MirrorFPOW;
float _MirrorR0;
float4 _GrabTexture_TexelSize;
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

void surf(Input IN, inout SurfaceOutput o) {

#ifdef EFFECT_PARALLAX
float2 uvnh = IN.uv_NormalMap1;
uvnh.xy += float2(_WaterLocalUvNX, _WaterLocalUvNZ) * -_ParallaxFlow;
float h = tex2D(_ParallaxMap, uvnh * _ParallaxMapTiling).r;
float2 offset = ParallaxOffset(h, _ParallaxAmount, IN.viewDir);
IN.uv_AlbedoTex1 -= offset;
IN.uv_NormalMap1 += offset;
float2 uvn = IN.uv_NormalMap1;
uvn.xy += float2(_WaterLocalUvNX, _WaterLocalUvNZ);
#ifdef EFFECT_NORMALMAP2
float2 uvnd = IN.uv_NormalMap1 + (offset * _ParallaxNormal2Offset);
uvnd.xy += float2(_WaterLocalUvNX, _WaterLocalUvNZ) * _NormalMap2Flow;
#endif
#else
float2 uvn = IN.uv_NormalMap1;
uvn.xy += float2(_WaterLocalUvNX, _WaterLocalUvNZ);
#ifdef EFFECT_NORMALMAP2
float2 uvnd = IN.uv_NormalMap1;
uvnd.xy += float2(_WaterLocalUvNX, _WaterLocalUvNZ) * _NormalMap2Flow;
#endif
#endif

float2 uv = IN.uv_AlbedoTex1;
uv.xy += float2(_WaterLocalUvX, _WaterLocalUvZ);
#ifdef EFFECT_ALBEDO2
float2 uvd = IN.uv_AlbedoTex1;
uvd.xy += float2(_WaterLocalUvX, _WaterLocalUvZ) * _Albedo2Flow;
#endif

float4 tex = tex2D(_AlbedoTex1, uv) * _AlbedoColor;
#ifdef EFFECT_ALBEDO2
tex *= tex2D(_AlbedoTex2, uvd * _Albedo2Tiling);
#endif
tex *= _AlbedoIntensity;
o.Albedo = ((tex - 0.5) * _AlbedoContrast + 0.5).rgb;

o.Gloss = tex.a;
o.Specular = _Shininess;

float3 normal = UnpackNormal(tex2D(_NormalMap1, uvn)) * _NormalMap1Strength;
#ifdef EFFECT_NORMALMAP2
normal += UnpackNormal(tex2D(_NormalMap2, uvnd * _NormalMap2Tiling)) * _NormalMap2Strength;
#ifdef EFFECT_MICROWAVE
normal += UnpackNormal(tex2D(_NormalMap2, (uv + uvnd) * 2 * _MicrowaveScale)) * _MicrowaveStrength;
#endif
#endif
o.Normal = normal;

#ifdef EFFECT_REFLECTION
float4 reflcol = texCUBE(_ReflectionCube, WorldReflectionVector(IN, o.Normal));
reflcol *= tex.a;
reflcol *= _ReflectionStrength;
float LumRef = dot(reflcol, float3(0.2126, 0.7152, 0.0722));
float3 reflcolL = lerp(LumRef.xxx, reflcol, _ReflectionSaturation);
reflcolL = ((reflcolL - 0.5) * _ReflectionContrast + 0.5);
o.Emission = reflcolL * _ReflectionColor.rgb;
#endif

#ifdef EFFECT_MIRROR
IN.screenPos.xy = normal * _GrabTexture_TexelSize.xy * IN.screenPos.z + IN.screenPos.xy;
half4 reflcolm = tex2Dproj(_MirrorReflectionTex, IN.screenPos);
reflcolm = reflcolm * _MirrorColor;
float3 refrColor = tex2Dproj(_GrabTexture, IN.screenPos);
refrColor = _MirrorDepthColor * refrColor;
half fresnel = saturate(1.0 - dot(normal, normalize(IN.viewDir)));
fresnel = pow(fresnel, _MirrorFPOW);
fresnel = _MirrorR0 + (1.0 - _MirrorR0) * fresnel;
half4 resCol = reflcolm * fresnel + half4(refrColor.xyz, 1.0) * (1.0 - fresnel);
o.Emission = (o.Emission + resCol) * 0.5;
#endif

float rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + 0.0001));
float fade = saturate(_SoftFactor * (LinearEyeDepth(rawZ) - IN.eyeDepth));
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
