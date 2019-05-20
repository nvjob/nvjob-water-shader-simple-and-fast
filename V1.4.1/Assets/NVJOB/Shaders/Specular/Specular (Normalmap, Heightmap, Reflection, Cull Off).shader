// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVJOB Specular Customizable Shaders. MIT license - license_nvjob.txt
// NVJOB Specular Customizable Shaders V1.1 - https://github.com/nvjob/nvjob-specular-customizable-shaders
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.pro, http://nvjob.dx.am


Shader "#NVJOB/Specular/Specular (Normalmap, Heightmap, Reflection, Cull Off)" {
	

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



Properties {
//----------------------------------------------

_Color ("Main Color", Color) = (1,1,1,1)
_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
_Shininess ("Shininess", Range(0.03, 1)) = 0.078125
_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
_BumpMap ("Normalmap", 2D) = "bump" {}
_IntensityNm("Intensity Normalmap", Range(-20, 20)) = 1
_ParallaxMap("Heightmap", 2D) = "white" {}
_ParallaxScale("Heightmap Scale", Range(0.01, 50)) = 1
_ReflectColor("Reflection Color", Color) = (1,1,1,0.5)
_IntensityRef("Intensity Reflection", Range(0, 20)) = 1
_Cube("Reflection Cubemap", Cube) = "" {}
_Saturation("Saturation", Range(0, 5)) = 1
_Brightness("Brightness", Range(0, 5)) = 1
_Contrast("Contrast", Range(0, 5)) = 1

//----------------------------------------------
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



SubShader{
//----------------------------------------------

Tags{ "RenderType" = "Opaque" }
Cull Off
LOD 200
CGPROGRAM
#pragma surface surf BlinnPhong exclude_path:prepass nolightmap nometa nolppv noshadowmask noforwardadd halfasview interpolateview novertexlights

//----------------------------------------------

sampler2D _MainTex, _BumpMap, _ParallaxMap;
fixed4 _Color, _ReflectColor;
half _Shininess, _IntensityNm, _ParallaxScale, _IntensityRef, _Saturation, _Contrast, _Brightness;
samplerCUBE _Cube;

//----------------------------------------------

struct Input {
float2 uv_MainTex;
float2 uv_BumpMap;
float3 viewDir;
float3 worldRefl;
INTERNAL_DATA
};

//----------------------------------------------

void surf (Input IN, inout SurfaceOutput o) {
half h = tex2D(_ParallaxMap, IN.uv_MainTex * _ParallaxScale).r;

fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) * _Color;
float Lum = dot(tex, float3(0.2126, 0.7152, 0.0722));
half3 color = lerp(Lum.xxx, tex, _Saturation);
color = color * _Brightness;
o.Albedo = ((color - 0.5) * _Contrast + 0.5) * h;

o.Gloss = tex.a;
o.Specular = _Shininess;

fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
normal.x *= _IntensityNm;
normal.y *= _IntensityNm;
o.Normal = normalize(normal);

fixed4 reflcol = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));
reflcol *= _IntensityRef;
reflcol *= tex.a;
o.Emission = reflcol.rgb * _ReflectColor.rgb;
}

//----------------------------------------------

ENDCG

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


Fallback "Legacy Shaders/VertexLit"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
