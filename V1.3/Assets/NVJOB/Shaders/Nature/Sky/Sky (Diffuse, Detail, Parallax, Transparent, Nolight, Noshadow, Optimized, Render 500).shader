// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVJOB Sky Shader - simple and fast. MIT license - license_nvjob.txt
// NVJOB Sky Shader - simple and fast V1.2 - https://github.com/nvjob/nvjob-sky-shader-simple-and-fast
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.pro, http://nvjob.dx.am


Shader "#NVJOB/Nature/Sky/Sky (Detail, Parallax, Transparent, Nolight, Noshadow)" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



Properties{
//----------------------------------------------

_Color ("Main Color", Color) = (1,1,1,1)
_MainTex ("Texture", 2D) = "white" {}
_Detail ("Detail", 2D) = "gray" {}
_Parallax ("Height", Range(-0.2, 0.2)) = 0
_ParallaxMap ("Heightmap (A)", 2D) = "black" {}

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

sampler2D _MainTex, _Detail, _ParallaxMap;
fixed4 _Color;
half _SkyShaderUvX, _SkyShaderUvZ, _Parallax;

//----------------------------------------------

struct Input {
float2 uv_MainTex;
float2 uv_ParalaxMap;
float2 uv_Detail;
float3 viewDir;
float4 screenPos;
};

//----------------------------------------------

void surf(Input IN, inout SurfaceOutput o) {
half h = tex2D(_ParallaxMap, IN.uv_ParalaxMap).r;
half2 offset = ParallaxOffset(h, _Parallax, IN.screenPos);
IN.uv_MainTex -= offset;
IN.uv_Detail += offset;

half2 uv = IN.uv_MainTex;
uv.xy += half2(_SkyShaderUvX * 0.7, _SkyShaderUvZ * 1.3);

half2 uvd = IN.uv_Detail;
uvd.xy += half2(_SkyShaderUvX * 0.7, _SkyShaderUvZ * 0.35);

half2 uvdd = IN.uv_Detail;
uvdd.xy += half2(_SkyShaderUvX * 0.35, _SkyShaderUvZ * 0.35);

fixed4 col = _Color;

col *= tex2D(_MainTex, uv);
col *= tex2D(_Detail, uvd);
col *= tex2D(_Detail, uvdd * 0.5);
col *= 3;
o.Albedo = col.rgb;
o.Alpha = col.a;
}

//----------------------------------------------

ENDCG

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


Fallback "Legacy Shaders/Transparent/VertexLit"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}