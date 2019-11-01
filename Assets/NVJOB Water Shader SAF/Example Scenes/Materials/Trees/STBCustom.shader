// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVGen shader for SpeedTree (STC). MIT license - license_nvjob.txt
// #NVJOB Shader for Unity SpeedTree (STC) - https://nvjob.github.io/unity/nvjob-stc
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.github.io


Shader "#NVJOB/SpeedTree/STC Billboard" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Properties {
//----------------------------------------------

[Header(...................Main Settings ...................)][Space]
_MainTex ("Base (RGB)", 2D) = "white" {}
_BumpMap ("Normalmap", 2D) = "bump" {}
_Color("Main Color", Color) = (1,1,1,1)
_HueVariation("Hue Variation", Color) = (1.0,0.5,0.0,0.1)
_IntensityNm("Strength Normal", Range(-10, 10)) = 1
_Cutoff("Alpha cutoff", Range(0.01,0.99)) = 0.5

[Header(...................Other Settings ...................)][Space]
_OcclusionMap("Occlusion Map", 2D) = "white" {}
_IntensityOc("Strength Occlusion", Range(0.03, 10)) = 1
_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
_Shininess("Shininess", Range(0.03, 1)) = 0.078125
_Light("Light", Range(0, 10)) = 1
_Saturation("Saturation", Range(0, 10)) = 1
_Brightness("Brightness", Range(0, 5)) = 1
_Contrast("Contrast", Range(-1, 5)) = 1

[Header(...................Wind Settings ...................)][Space]
[MaterialEnum(None,0,Fastest,1)] _WindQuality ("Wind Quality", Range(0,1)) = 0
_WindSpeed("Wind Speed", Range(0.01, 10)) = 1
_WindAmplitude("Wind Amplitude", Range(0.01, 10)) = 1
_WindDegreeSlope("Wind Degree Slope", Range(0.01, 10)) = 1
_WindConstantTilt("Wind Constant Tilt", Range(0.01, 10)) = 1

//----------------------------------------------
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



SubShader {
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" "DisableBatching"="LODFading" }
LOD 400

CGPROGRAM
#pragma surface surf BlinnPhong vertex:TreeShaderBillboardVert exclude_path:prepass nolightmap dithercrossfade nodirlightmap nodynlightmap nometa noforwardadd nolppv noshadowmask halfasview interpolateview novertexlights addshadow noinstancing dithercrossfade
#pragma target 3.0
#pragma multi_compile __ BILLBOARD_FACE_CAMERA_POS
#pragma shader_feature EFFECT_BUMP
#pragma shader_feature EFFECT_HUE_VARIATION
#define ENABLE_WIND

//----------------------------------------------

#include "STBCustomCore.cginc"

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
Tags { "LightMode" = "Vertex" }

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#pragma multi_compile_fog
#pragma multi_compile __ LOD_FADE_CROSSFADE
#pragma multi_compile __ BILLBOARD_FACE_CAMERA_POS
#pragma shader_feature EFFECT_HUE_VARIATION
#define ENABLE_WIND

//----------------------------------------------

#include "STBCustomCore.cginc"

//----------------------------------------------


struct v2f {
UNITY_POSITION(vertex);
UNITY_FOG_COORDS(0)
Input data      : TEXCOORD1;
UNITY_VERTEX_OUTPUT_STEREO
};

//----------------------------------------------

v2f vert(TreeShaderBillboardData v) {
v2f o;
UNITY_SETUP_INSTANCE_ID(v);
UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
TreeShaderBillboardVert(v, o.data);
o.data.color.rgb *= ShadeVertexLightsFull(v.vertex, v.normal, 4, true);
o.vertex = UnityObjectToClipPos(v.vertex);
UNITY_TRANSFER_FOG(o,o.vertex);
return o;
}

//----------------------------------------------

fixed4 frag(v2f i) : SV_Target {
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
}


FallBack "Transparent/Cutout/VertexLit"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
