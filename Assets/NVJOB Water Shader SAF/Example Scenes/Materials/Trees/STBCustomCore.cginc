// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVGen shader for SpeedTree (STC). MIT license - license_nvjob.txt
// #NVJOB Shader for Unity SpeedTree (STC) - https://nvjob.github.io/unity/nvjob-stc
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.github.io


#ifndef TreeShader_BILLBOARD_COMMON_INCLUDED
#define TreeShader_BILLBOARD_COMMON_INCLUDED
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#define TreeShader_ALPHATEST
fixed _Cutoff;

#include "STCustomCore.cginc"

CBUFFER_START(UnityBillboardPerCamera)
float3 unity_BillboardNormal;
float3 unity_BillboardTangent;
float4 unity_BillboardCameraParams;
#define unity_BillboardCameraPosition (unity_BillboardCameraParams.xyz)
#define unity_BillboardCameraXZAngle (unity_BillboardCameraParams.w)
CBUFFER_END

CBUFFER_START(UnityBillboardPerBatch)
float4 unity_BillboardInfo;
float4 unity_BillboardSize;
float4 unity_BillboardImageTexCoords[16];
CBUFFER_END


///////////////////////////////////////////////////////////////////////////////////////////////////////////////


struct TreeShaderBillboardData {
float4 vertex       : POSITION;
float2 texcoord     : TEXCOORD0;
float4 texcoord1    : TEXCOORD1;
float3 normal       : NORMAL;
float4 tangent      : TANGENT;
float4 color        : COLOR;
UNITY_VERTEX_INPUT_INSTANCE_ID
};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////


void CustomWindBillboard() {
_ST_WindGlobal.y *= _WindAmplitude;
_ST_WindGlobal.z *= _WindDegreeSlope;
_ST_WindBranchAdherences.x *= _WindConstantTilt;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////


void TreeShaderBillboardVert(inout TreeShaderBillboardData IN, out Input OUT) {
CustomWindBillboard();
UNITY_INITIALIZE_OUTPUT(Input, OUT);
float3 worldPos = IN.vertex.xyz + float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
#ifdef BILLBOARD_FACE_CAMERA_POS
float3 eyeVec = normalize(unity_BillboardCameraPosition - worldPos);
float3 billboardTangent = normalize(float3(-eyeVec.z, 0, eyeVec.x));
float3 billboardNormal = float3(billboardTangent.z, 0, -billboardTangent.x);
float3 angle = atan2(billboardNormal.z, billboardNormal.x);
angle += angle < 0 ? 2 * UNITY_PI : 0;
#else
float3 billboardTangent = unity_BillboardTangent;
float3 billboardNormal = unity_BillboardNormal;
float angle = unity_BillboardCameraXZAngle;
#endif
float widthScale = IN.texcoord1.x;
float heightScale = IN.texcoord1.y;
float rotation = IN.texcoord1.z;
float2 percent = IN.texcoord.xy;
float3 billboardPos = (percent.x - 0.5f) * unity_BillboardSize.x * widthScale * billboardTangent;
billboardPos.y += (percent.y * unity_BillboardSize.y + unity_BillboardSize.z) * heightScale;
#ifdef ENABLE_WIND
if (_WindQuality * _WindEnabled > 0)
billboardPos = GlobalWind(billboardPos, worldPos, true, _ST_WindVector.xyz, IN.texcoord1.w * _WindSpeed);
#endif
IN.vertex.xyz += billboardPos;
IN.vertex.w = 1.0f;
IN.normal = billboardNormal.xyz;
IN.tangent = float4(billboardTangent.xyz,-1);
float slices = unity_BillboardInfo.x;
float invDelta = unity_BillboardInfo.y;
angle += rotation;
float imageIndex = fmod(floor(angle * invDelta + 0.5f), slices);
float4 imageTexCoords = unity_BillboardImageTexCoords[imageIndex];
if (imageTexCoords.w < 0) OUT.mainTexUV = imageTexCoords.xy - imageTexCoords.zw * percent.yx;
else OUT.mainTexUV = imageTexCoords.xy + imageTexCoords.zw * percent;
OUT.color = _Color;
OUT.color.rgb *= IN.color.r;
OUT.color.rgb *= _Light;
#ifdef EFFECT_HUE_VARIATION
float hueVariationAmount = frac(worldPos.x + worldPos.y + worldPos.z);
OUT.HueVariationAmount = saturate(hueVariationAmount * _HueVariation.a);
#endif
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#endif