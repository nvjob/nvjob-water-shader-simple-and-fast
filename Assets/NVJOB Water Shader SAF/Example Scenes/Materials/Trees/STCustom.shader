// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVGen shader for SpeedTree (STC). MIT license - license_nvjob.txt
// #NVJOB Shader for Unity SpeedTree (STC) - https://nvjob.github.io/unity/nvjob-stc
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.github.io


Shader "#NVJOB/SpeedTree/STC" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



Properties {
//----------------------------------------------

[Header(................... Main Settings ...................)][Space]
[NoScaleOffset]_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
[NoScaleOffset]_DetailTex("Detail", 2D) = "black" {}
[NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
_HueVariation("Hue Variation", Color) = (1.0,0.5,0.0,0.1)
_Color("Main Color", Color) = (1,1,1,1)
_IntensityNm("Strength Normal", Range(-10, 10)) = 1
_Cutoff("Alpha Cutoff", Range(0.01,0.99)) = 0.333
_Shadow_Cutoff("Shadow Cutoff", Range(0.001,0.999)) = 0.333

[Header(................... Other Settings ...................)][Space]
[NoScaleOffset]_OcclusionMap("Occlusion Map", 2D) = "white" {}
_IntensityOc("Strength Occlusion", Range(0.03, 10)) = 1
_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
_Shininess("Shininess", Range(0.03, 1)) = 0.078125
_Light("Light", Range(0, 10)) = 1
_Saturation("Saturation", Range(0, 10)) = 1
_Brightness("Brightness", Range(0, 5)) = 1
_Contrast("Contrast", Range(-1, 5)) = 1
[MaterialEnum(Off,0,Front,1,Back,2)] _Cull("Cull", Int) = 2

[Header(................... Wind Settings ...................)][Space]
[MaterialEnum(None,0,Fastest,1,Fast,2,Better,3,Best,4,Palm,5)] _WindQuality("Wind Quality", Range(0,5)) = 0
_WindSpeed("Wind Speed", Range(0.01, 10)) = 1
_WindAmplitude("Wind Amplitude", Range(0.01, 10)) = 1
_WindDegreeSlope("Wind Degree Slope", Range(0.01, 10)) = 1
_WindConstantTilt("Wind Constant Tilt", Range(0.01, 10)) = 1
_LeafRipple("Leaf Ripple", Range(0.01, 100)) = 1
_LeafRippleSpeed("Leaf Ripple Speed", Range(0.01, 10)) = 1
_LeafTumble("Leaf Tumble, only Best", Range(0.01, 10)) = 1
_LeafTumbleSpeed("Leaf Tumble Speed, only Best", Range(0.01, 5)) = 1
_BranchRipple("Branch Ripple, from Better", Range(0.01, 20)) = 1
_BranchRippleSpeed("Branch Ripple Speed, from Better", Range(0.01, 10)) = 1
_BranchTwitch("Branch Twitch, from Best", Range(0.01, 10)) = 1
_BranchWhip("Elasticity, Palm", Range(0.01, 10)) = 1
_BranchTurbulences("Turbulences, Palm", Range(0.01, 10)) = 1
_BranchForceHeaviness("Branch Force Wind, Palm", Range(0.01, 10)) = 1
_BranchHeaviness("Branch Heaviness, Palm", Range(-10, 10)) = 1


//----------------------------------------------
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



SubShader {
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque" "DisableBatching"="LODFading" }
LOD 400
Cull [_Cull]

CGPROGRAM
#pragma surface surf BlinnPhong vertex:TreeShaderVert exclude_path:prepass nolightmap dithercrossfade nodirlightmap nodynlightmap nometa noforwardadd nolppv noshadowmask halfasview interpolateview novertexlights
#pragma target 3.0
#pragma multi_compile_vertex  LOD_FADE_PERCENTAGE
#pragma instancing_options assumeuniformscaling lodfade maxcount:50
#pragma shader_feature GEOM_TYPE_BRANCH GEOM_TYPE_BRANCH_DETAIL GEOM_TYPE_FROND GEOM_TYPE_LEAF GEOM_TYPE_MESH
#pragma shader_feature EFFECT_BUMP
#pragma shader_feature EFFECT_HUE_VARIATION
#define ENABLE_WIND

//----------------------------------------------

#include "STCustomCore.cginc"

//----------------------------------------------

void surf(Input IN, inout SurfaceOutput OUT) {
TreeShaderFragOut o;
TreeShaderFrag(IN, o);
TreeShader_COPY_FRAG(OUT, o)
}

ENDCG


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// For Vertex Lit Rendering


Pass {
//----------------------------------------------

Tags { "LightMode" = "Vertex" }

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#pragma multi_compile_fog
#pragma multi_compile_vertex  LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
#pragma multi_compile_fragment __ LOD_FADE_CROSSFADE
#pragma multi_compile_instancing
#pragma instancing_options assumeuniformscaling lodfade maxcount:50
#pragma shader_feature GEOM_TYPE_BRANCH GEOM_TYPE_BRANCH_DETAIL GEOM_TYPE_FROND GEOM_TYPE_LEAF GEOM_TYPE_MESH
#pragma shader_feature EFFECT_HUE_VARIATION
#define ENABLE_WIND

//----------------------------------------------

#include "STCustomCore.cginc"

//----------------------------------------------

struct v2f {
UNITY_POSITION(vertex);
UNITY_FOG_COORDS(0)
Input data      : TEXCOORD1;
UNITY_VERTEX_INPUT_INSTANCE_ID
UNITY_VERTEX_OUTPUT_STEREO
};

//----------------------------------------------

v2f vert(TreeShaderVB v) {
v2f o;
UNITY_SETUP_INSTANCE_ID(v);
UNITY_TRANSFER_INSTANCE_ID(v, o);
UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
TreeShaderVert(v, o.data);
//o.data.color.rgb *= ShadeVertexLightsFull(v.vertex, v.normal, 4, true);
o.vertex = UnityObjectToClipPos(v.vertex);
UNITY_TRANSFER_FOG(o,o.vertex);
return o;
}

//----------------------------------------------

fixed4 frag(v2f i) : SV_Target {
UNITY_SETUP_INSTANCE_ID(i);
TreeShaderFragOut o;
TreeShaderFrag(i.data, o);
UNITY_APPLY_DITHER_CROSSFADE(i.vertex.xy);
fixed4 c = fixed4(o.Albedo, o.Alpha);
UNITY_APPLY_FOG(i.fogCoord, c);
return c;
}

//----------------------------------------------

ENDCG
//----------------------------------------------
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Shadow Caster


Pass{
//----------------------------------------------

Tags { "LightMode" = "ShadowCaster" }

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#pragma instancing_options assumeuniformscaling lodfade maxcount:50
#pragma multi_compile_instancing
#pragma shader_feature GEOM_TYPE_BRANCH GEOM_TYPE_BRANCH_DETAIL GEOM_TYPE_FROND GEOM_TYPE_LEAF GEOM_TYPE_MESH
#pragma multi_compile_shadowcaster
#define ENABLE_WIND
//----------------------------------------------

#include "STCustomCore.cginc"

//----------------------------------------------

fixed _Shadow_Cutoff;

struct v2f {
V2F_SHADOW_CASTER;
#ifdef TreeShader_ALPHATEST
float2 uv : TEXCOORD1;
#endif
UNITY_VERTEX_INPUT_INSTANCE_ID
UNITY_VERTEX_OUTPUT_STEREO
};

//----------------------------------------------

v2f vert(TreeShaderVB v) {
v2f o;
UNITY_SETUP_INSTANCE_ID(v);
UNITY_TRANSFER_INSTANCE_ID(v, o);
UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
#ifdef TreeShader_ALPHATEST
o.uv = v.texcoord.xy;
#endif
OffsetTreeShaderVertex(v, 0);
TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
return o;
}

//----------------------------------------------

float4 frag(v2f i) : SV_Target {
UNITY_SETUP_INSTANCE_ID(i);
#ifdef TreeShader_ALPHATEST
clip(tex2D(_MainTex, i.uv).a - _Shadow_Cutoff);
#endif
SHADOW_CASTER_FRAGMENT(i)
}

//----------------------------------------------

ENDCG
//----------------------------------------------
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


FallBack "Transparent/Cutout/VertexLit"
CustomEditor "SpeedTreeMaterialInspector"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
