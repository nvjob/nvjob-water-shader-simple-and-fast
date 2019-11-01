// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Water Shader - simple and fast. MIT license - license_nvjob.txt
// #NVJOB Water Shader - simple and fast V1.4.5 - https://nvjob.github.io/unity/nvjob-water-shader
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.github.io


Shader "#NVJOB/Nature/Water Shader Type 2" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Properties{
//----------------------------------------------

_Color("Main Color", Color) = (0.15,0.161,0.16,1)

_MainTex("Main Texture", 2D) = "white" {}
_Detail("Main Detail", 2D) = "gray" {}
_BumpMap("Normalmap", 2D) = "bump" {}
_BumpMapDetail("Normalmap Detail", 2D) = "bump" {}
_ParallaxMap("Heightmap", 2D) = "black" {}

_Glossiness("Smoothness", Range(0,1)) = 0.5
_Metallic("Metallic", Range(0,1)) = 0.0

_IntensityMt("Intensity Main Texture", Range(0.1, 5)) = 1
_ContrastMt("Contrast Main Texture", Range(-0.5, 3)) = 1
_MainDetailScale("Main Detail Uv", Range(0.001, 10)) = 1
_MainDetailFlow("Main Detail Flow", Range(0, 2)) = 1

_IntensityNm("Intensity Normalmap", Range(0.001, 10)) = 1
_NormalmapDetailScale("Normalmap Detail Uv", Range(0.001, 10)) = 0.5
_NormalmapDetailSpeed("Normalmap Detail Speed", Range(-1, 1)) = 0.5
_IntensityNmDetail("Intensity Normalmap Detail", Range(0.001, 10)) = 1

_MicrowaveScale("Microwave Uv", Range(0.5, 10)) = 1
_IntensityMicrowave("Intensity Microwave", Range(0.001, 1.5)) = 0.5

_ParallaxScale("Heightmap Uv", Range(0.001, 20)) = 1
_Parallax("Heightmap", Range(-0.2, 0.2)) = 0.1
_ReverseFlow("Reverse Flow", Range(-5, 5)) = 1

_SoftFactor("Soft Factor", Range(0.0001, 1)) = 0.5

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
//#pragma surface surf Standard alpha:fade vertex:vert exclude_path:prepass nolightmap nometa nolppv noshadowmask noshadow noforwardadd novertexlights
#pragma surface surf Standard alpha:fade vertex:vert noshadowmask noshadow
#pragma target 3.0

//----------------------------------------------

sampler2D _MainTex, _Detail, _BumpMap, _BumpMapDetail, _ParallaxMap;
fixed4 _Color;
half _IntensityMt, _ContrastMt, _IntensityNm, _IntensityNmDetail, _NormalmapDetailScale, _NormalmapDetailSpeed, _MicrowaveScale, _IntensityMicrowave, _MainDetailScale, _Parallax, _ParallaxScale, _SoftFactor;
half _WaterLocalUvX, _WaterLocalUvZ, _WaterLocalUvNX, _WaterLocalUvNZ;
half _MainDetailFlow, _ReverseFlow;
sampler2D_float _CameraDepthTexture;
float4 _CameraDepthTexture_TexelSize;

half _Glossiness;
half _Metallic;

//----------------------------------------------

struct Input {
float2 uv_MainTex;
float2 uv_BumpMap;
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

half2 uvnh = IN.uv_BumpMap;
uvnh.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ) * -_ReverseFlow;

half h = tex2D(_ParallaxMap, uvnh * _ParallaxScale).r;

half2 offset = ParallaxOffset(h, _Parallax, IN.viewDir);
IN.uv_MainTex -= offset;
IN.uv_BumpMap += offset;

half2 uv = IN.uv_MainTex;
uv.xy += half2(_WaterLocalUvX, _WaterLocalUvZ);

half2 uvd = IN.uv_MainTex;
uvd.xy += half2(_WaterLocalUvX, _WaterLocalUvZ) * _MainDetailFlow;

half2 uvn = IN.uv_BumpMap;
uvn.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ);

half2 uvnd = IN.uv_BumpMap;
uvnd.xy += half2(_WaterLocalUvNX, _WaterLocalUvNZ) * _NormalmapDetailSpeed;

fixed4 tex = tex2D(_MainTex, uv) * _Color;
tex *= tex2D(_Detail, uvd * _MainDetailScale);
tex *= _IntensityMt;
o.Albedo = ((tex - 0.5) * _ContrastMt + 0.5).rgb;

fixed3 normal = UnpackNormal(tex2D(_BumpMap, uvn)) * _IntensityNm;
normal += UnpackNormal(tex2D(_BumpMapDetail, uvnd * _NormalmapDetailScale)) * _IntensityNmDetail;
normal -= UnpackNormal(tex2D(_BumpMapDetail, (uv + uvnd) * 2 * _MicrowaveScale)) * _IntensityMicrowave;
o.Normal = normalize(normal / 3);

half rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + 0.0001));
half fade = saturate(_SoftFactor * (LinearEyeDepth(rawZ) - IN.eyeDepth));
o.Alpha = _Color.a * fade;

o.Metallic = _Metallic;
o.Smoothness = _Glossiness;

}

//----------------------------------------------

ENDCG

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


FallBack "Diffuse"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
