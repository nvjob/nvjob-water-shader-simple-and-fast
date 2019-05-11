// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVJOB Water Shader - simple and fast. MIT license - license_nvjob.txt
// NVJOB Water Shader - simple and fast V1.2 - https://github.com/nvjob/nvjob-water-shader-simple-and-fast
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.pro, http://nvjob.dx.am


Shader "#NVJOB/Nature/Fast Water" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	


Properties{
//----------------------------------------------

_Color("Main Color", Color) = (0.15,0.161,0.16,1)
_SpecColor("Specular Color", Color) = (0.086,0.086,0.086,1)
_ReflectColor("Reflection Color", Color) = (0.28,0.29,0.25,0.5)
_Shininess("Shininess", Range(0.01, 1)) = 0.15
_IntensityNm("Intensity Normalmap", Range(0, 20)) = 1
_IntensityRef("Intensity Reflection", Range(0, 20)) = 0.9
_Parallax("Heightmap", Range(-0.2, 0.2)) = 0.1
_MainTex("Main Texture", 2D) = "white" {}
_Detail("Main Detail", 2D) = "gray" {}
_BumpMap("Normalmap", 2D) = "bump" {}
_BumpMapDetail("Normalmap Detail", 2D) = "bump" {}
_ParallaxMap("Heightmap", 2D) = "black" {}
_Cube("Reflection Cubemap", Cube) = "" {}

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
ColorMask 0

CGPROGRAM
#pragma surface surf BlinnPhong alpha:fade vertex:vert exclude_path:prepass nolightmap nometa nolppv noshadowmask noshadow noforwardadd novertexlights //halfasview
#pragma target 3.0

//----------------------------------------------

sampler2D _MainTex, _Detail, _BumpMap, _BumpMapDetail, _ParallaxMap;
samplerCUBE _Cube;

fixed4 _Color, _ReflectColor;
half _Shininess, _IntensityNm, _IntensityRef, _Parallax;
half _WaterLocalWaves, _WaterLocalWavesSpeed;
half _WaterLocalUvX, _WaterLocalUvZ;
half _WaterLocalUvNX, _WaterLocalUvNZ;
half _WaterSoftFactor;

sampler2D_float _CameraDepthTexture;
float4 _CameraDepthTexture_TexelSize;

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
float timeYspeed = _Time.y * _WaterLocalWavesSpeed;
float3 waveMoveX = sin(timeYspeed + v.vertex.x);
float3 waveMoveZ = sin(timeYspeed + v.vertex.z);

v.vertex.y -= mul((float3x3)unity_WorldToObject, (waveMoveX + waveMoveZ) * _WaterLocalWaves).y;

UNITY_INITIALIZE_OUTPUT(Input, o);
COMPUTE_EYEDEPTH(o.eyeDepth);
}

//----------------------------------------------

void surf(Input IN, inout SurfaceOutput o) {

half h = tex2D(_ParallaxMap, IN.uv_BumpMap).r;
half2 offset = ParallaxOffset(h, _Parallax, IN.viewDir);
IN.uv_MainTex -= offset;
IN.uv_BumpMap += offset;

half2 uv = IN.uv_MainTex;
uv.xy += half2(_WaterLocalUvX * 0.7, _WaterLocalUvZ * 1.3);

half2 uvd = IN.uv_MainTex;
uvd.xy += half2(_WaterLocalUvX * 0.7, _WaterLocalUvZ * 0.35);

half2 uvn = IN.uv_BumpMap;
uvn.xy += half2(_WaterLocalUvNX * 0.7, _WaterLocalUvNZ * 1.3);

half2 uvnd = IN.uv_BumpMap;
uvnd.xy += half2(_WaterLocalUvNX * 0.7, _WaterLocalUvNZ * 0.35);

fixed4 tex = tex2D(_MainTex, uv * 1.2);
tex *= tex2D(_Detail, uvd * 0.7);
tex *= 2;
o.Albedo = (tex * _Color).rgb;

o.Gloss = tex.a;
o.Specular = _Shininess;

fixed3 normal = UnpackNormal(tex2D(_BumpMap, uvn));
normal *= tex2D(_BumpMapDetail, uvnd * 0.7);
normal.x *= _IntensityNm;
normal.y *= _IntensityNm;
o.Normal = normalize(normal);

fixed4 reflcol = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));
reflcol *= _IntensityRef;
reflcol *= tex.a;
o.Emission = reflcol.rgb * _ReflectColor.rgb;

half rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos + 0.0001));
half fade = saturate(_WaterSoftFactor * (LinearEyeDepth(rawZ) - IN.eyeDepth));
o.Alpha = _Color.a * fade;

}

//----------------------------------------------

ENDCG

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


FallBack "Legacy Shaders/Reflective/Bumped Diffuse"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
