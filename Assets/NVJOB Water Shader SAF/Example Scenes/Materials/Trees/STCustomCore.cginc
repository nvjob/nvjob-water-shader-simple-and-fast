// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// NVGen shader for SpeedTree (STC). MIT license - license_nvjob.txt
// #NVJOB Shader for Unity SpeedTree (STC) - https://nvjob.github.io/unity/nvjob-stc
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.github.io


#ifndef TreeShader_COMMON_INCLUDED
#define TreeShader_COMMON_INCLUDED
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#include "UnityCG.cginc"

#define TreeShader_Y_UP

#ifdef GEOM_TYPE_BRANCH_DETAIL
#define GEOM_TYPE_BRANCH
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// texcoord setup

struct TreeShaderVB {
float4 vertex : POSITION;
float4 tangent : TANGENT;
float3 normal : NORMAL;
float4 texcoord : TEXCOORD0;
float4 texcoord1 : TEXCOORD1;
float4 texcoord2 : TEXCOORD2;
float2 texcoord3 : TEXCOORD3;
half4 color : COLOR;
UNITY_VERTEX_INPUT_INSTANCE_ID
};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
#ifdef ENABLE_WIND  //  Winds



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Wind Info

#define wind_cross(a, b) cross((a), (b))
#define WIND_QUALITY_NONE 0
#define WIND_QUALITY_FASTEST 1
#define WIND_QUALITY_FAST 2
#define WIND_QUALITY_BETTER 3
#define WIND_QUALITY_BEST 4
#define WIND_QUALITY_PALM 5
uniform half _WindQuality,_WindEnabled;

CBUFFER_START(TreeShaderWind)
float4 _ST_WindVector,_ST_WindGlobal,_ST_WindBranch,_ST_WindBranchTwitch,_ST_WindBranchWhip,_ST_WindBranchAnchor,_ST_WindBranchAdherences,_ST_WindTurbulences,_ST_WindLeaf1Ripple,_ST_WindLeaf1Tumble,_ST_WindLeaf1Twitch,_ST_WindLeaf2Ripple,_ST_WindLeaf2Tumble,_ST_WindLeaf2Twitch,_ST_WindFrondRipple,_ST_WindAnimation;
CBUFFER_END

uniform half _WindSpeed, _WindAmplitude, _WindDegreeSlope, _WindConstantTilt, _LeafRipple, _LeafRippleSpeed, _BranchRipple, _BranchRippleSpeed, _LeafTumble, _LeafTumbleSpeed, _BranchTwitch, _BranchWhip, _BranchTurbulences, _BranchForceHeaviness, _BranchHeaviness;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Unpack Normal From Float

float3 UnpackNormalFromFloat(float fValue) {
float3 vDecodeKey = float3(16.0, 1.0, 0.0625);
float3 vDecodedValue = frac(fValue / vDecodeKey);
return (vDecodedValue * 2.0 - 1.0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Trig Approximate

float4 TrigApproximate(float4 vData) {
float4 TrianglevData = abs((frac(vData + 0.5) * 2.0) - 1.0);
return ((TrianglevData * TrianglevData * (3.0 - 2.0 * TrianglevData)) - 0.5) * 2.0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Twitch

float Twitch(float3 vPos, float fAmount, float fSharpness, float fTime) {
const float c_fTwitchFudge = 0.87;
float4 vOscillations = TrigApproximate(float4(fTime + (vPos.x + vPos.z), c_fTwitchFudge * fTime + vPos.y, 0.0, 0.0));
float fTwitch = vOscillations.x * vOscillations.y * vOscillations.y;
fTwitch = (fTwitch + 1.0) * 0.5;
return fAmount * pow(saturate(fTwitch), fSharpness);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Oscillate

float Oscillate(float3 vPos, float fTime, float fOffset, float fWeight, float fWhip, bool bWhip, bool bRoll, bool bComplex, float fTwitch, float fTwitchFreqScale, inout float4 vOscillations, float3 vRotatedWindVector) {
float fOscillation = 1.0;
if (bComplex) {
if (bWhip) vOscillations = TrigApproximate(float4(fTime + fOffset, fTime * fTwitchFreqScale + fOffset, fTwitchFreqScale * 0.5 * (fTime + fOffset), fTime + fOffset + (1.0 - fWeight)));
else vOscillations = TrigApproximate(float4(fTime + fOffset, fTime * fTwitchFreqScale + fOffset, fTwitchFreqScale * 0.5 * (fTime + fOffset), 0.0));
float fFineDetail = vOscillations.x;
float fBroadDetail = vOscillations.y * vOscillations.z;
float fTarget = 1.0;
float fAmount = fBroadDetail;
if (fBroadDetail < 0.0) {
fTarget = -fTarget;
fAmount = -fAmount;
}
fBroadDetail = lerp(fBroadDetail, fTarget, fAmount);
fBroadDetail = lerp(fBroadDetail, fTarget, fAmount);
fOscillation = fBroadDetail * fTwitch * (1.0 - _ST_WindVector.w) + fFineDetail * (1.0 - fTwitch);
if (bWhip) fOscillation *= 1.0 + (vOscillations.w * fWhip);
}
else {
if (bWhip) vOscillations = TrigApproximate(float4(fTime + fOffset, fTime * 0.689 + fOffset, 0.0, fTime + fOffset + (1.0 - fWeight)));
else vOscillations = TrigApproximate(float4(fTime + fOffset, fTime * 0.689 + fOffset, 0.0, 0.0));
fOscillation = vOscillations.x + vOscillations.y * vOscillations.x;
if (bWhip) fOscillation *= 1.0 + (vOscillations.w * fWhip);
}
return fOscillation;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Turbulence

float Turbulence(float fTime, float fOffset, float fGlobalTime, float fTurbulence) {
const float c_fTurbulenceFactor = 0.1;
float4 vOscillations = TrigApproximate(float4(fTime * c_fTurbulenceFactor + fOffset, fGlobalTime * fTurbulence * c_fTurbulenceFactor + fOffset, 0.0, 0.0));
return 1.0 - (vOscillations.x * vOscillations.y * vOscillations.x * vOscillations.y * fTurbulence);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Global Wind

float3 GlobalWind(float3 vPos, float3 vInstancePos, bool bPreserveShape, float3 vRotatedWindVector, float time) {
float fLength = 1.0;
if (bPreserveShape) fLength = length(vPos.xyz);
#ifdef TreeShader_Z_UP
float fAdjust = max(vPos.z - (1.0 / _ST_WindGlobal.z) * 0.25, 0.0) * _ST_WindGlobal.z;
#else
float fAdjust = max(vPos.y - (1.0 / _ST_WindGlobal.z) * 0.25, 0.0) * _ST_WindGlobal.z;
#endif
if (fAdjust != 0.0) fAdjust = pow(fAdjust, _ST_WindGlobal.w);
float4 vOscillations = TrigApproximate(float4(vInstancePos.x + time, vInstancePos.y + time * 0.8, 0.0, 0.0));
float fOsc = vOscillations.x + (vOscillations.y * vOscillations.y);
float fMoveAmount = _ST_WindGlobal.y * fOsc;
fMoveAmount += _ST_WindBranchAdherences.x / _ST_WindGlobal.z;
fMoveAmount *= fAdjust;
#ifdef TreeShader_Z_UP
vPos.xy += vRotatedWindVector.xy * fMoveAmount;
#else
vPos.xz += vRotatedWindVector.xz * fMoveAmount;
#endif
if (bPreserveShape) vPos.xyz = normalize(vPos.xyz) * fLength;
return vPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Simple Branch Wind

float3 SimpleBranchWind(float3 vPos, float3 vInstancePos, float fWeight, float fOffset, float fTime, float fDistance, float fTwitch, float fTwitchScale, float fWhip, bool bWhip, bool bRoll, bool bComplex, float3 vRotatedWindVector) {
float3 vWindVector = UnpackNormalFromFloat(fOffset);
vWindVector = vWindVector * fWeight;
fTime += vInstancePos.x + vInstancePos.y;
float4 vOscillations;
float fOsc = Oscillate(vPos, fTime, fOffset, fWeight, fWhip, bWhip, bRoll, bComplex, fTwitch, fTwitchScale, vOscillations, vRotatedWindVector);
vPos.xyz += vWindVector * fOsc * fDistance;
return vPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Directional Branch Wind Frond Style

float3 DirectionalBranchWindFrondStyle(float3 vPos, float3 vInstancePos, float fWeight, float fOffset, float fTime, float fDistance, float fTurbulence, float fAdherence, float fTwitch, float fTwitchScale, float fWhip, bool bWhip, bool bRoll, bool bComplex, bool bTurbulence, float3 vRotatedWindVector, float3 vRotatedBranchAnchor) {
float3 vWindVector = UnpackNormalFromFloat(fOffset);
vWindVector = vWindVector * fWeight;
fTime += vInstancePos.x + vInstancePos.y;
float4 vOscillations;
float fOsc = Oscillate(vPos, fTime, fOffset, fWeight, fWhip, bWhip, false, bComplex, fTwitch, fTwitchScale, vOscillations, vRotatedWindVector);
vPos.xyz += vWindVector * fOsc * fDistance;
float fAdherenceScale = 1.0;
if (bTurbulence)
fAdherenceScale = Turbulence(fTime, fOffset, _ST_WindAnimation.x, fTurbulence);
if (bWhip) fAdherenceScale += vOscillations.w * _ST_WindVector.w * fWhip;
float3 vWindAdherenceVector = vRotatedBranchAnchor - vPos.xyz;
vPos.xyz += vWindAdherenceVector * fAdherence * fAdherenceScale * fWeight;
return vPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Branch Wind 

// Apply only to better, best, palm winds
float3 BranchWind(bool isPalmWind, float3 vPos, float3 vInstancePos, float4 vWindData, float3 vRotatedWindVector, float3 vRotatedBranchAnchor) {
if (isPalmWind) vPos = DirectionalBranchWindFrondStyle(vPos, vInstancePos, vWindData.x, vWindData.y, _ST_WindBranch.x, _ST_WindBranch.y, _ST_WindTurbulences.x, _ST_WindBranchAdherences.y, _ST_WindBranchTwitch.x, _ST_WindBranchTwitch.y, _ST_WindBranchWhip.x, true, false, true, true, vRotatedWindVector, vRotatedBranchAnchor);
else vPos = SimpleBranchWind(vPos, vInstancePos, vWindData.x, vWindData.y, _ST_WindBranch.x, _ST_WindBranch.y, _ST_WindBranchTwitch.x, _ST_WindBranchTwitch.y, _ST_WindBranchWhip.x, false, false, true, vRotatedWindVector);
return vPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Leaf Ripple

float3 LeafRipple(float3 vPos, inout float3 vDirection, float fScale, float fPackedRippleDir, float fTime, float fAmount, bool bDirectional, float fTrigOffset) {
float4 vInput = float4(fTime + fTrigOffset, 0.0, 0.0, 0.0);
float fMoveAmount = fAmount * TrigApproximate(vInput).x;
if (bDirectional) vPos.xyz += vDirection.xyz * fMoveAmount * fScale;
else {
float3 vRippleDir = UnpackNormalFromFloat(fPackedRippleDir);
vPos.xyz += vRippleDir * fMoveAmount * fScale;
}
return vPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Leaf Tumble

float3x3 RotationMatrix(float3 vAxis, float fAngle) {
float2 vSinCos;
#ifdef OPENGL
vSinCos.x = sin(fAngle);
vSinCos.y = cos(fAngle);
#else
sincos(fAngle, vSinCos.x, vSinCos.y);
#endif
const float c = vSinCos.y;
const float s = vSinCos.x;
const float t = 1.0 - c;
const float x = vAxis.x;
const float y = vAxis.y;
const float z = vAxis.z;
return float3x3(t * x * x + c, t * x * y - s * z, t * x * z + s * y, t * x * y + s * z, t * y * y + c, t * y * z - s * x, t * x * z - s * y, t * y * z + s * x, t * z * z + c);
}

//----------------------------------------------

float3 LeafTumble(float3 vPos, inout float3 vDirection, float fScale, float3 vAnchor, float3 vGrowthDir, float fTrigOffset, float fTime, float fFlip, float fTwist, float fAdherence, float3 vTwitch, float4 vRoll, bool bTwitch, bool bRoll, float3 vRotatedWindVector) {
float3 vFracs = frac((vAnchor + fTrigOffset) * 30.3);
float fOffset = vFracs.x + vFracs.y + vFracs.z;
float4 vOscillations = TrigApproximate(float4(fTime + fOffset, fTime * 0.75 - fOffset, fTime * 0.01 + fOffset, fTime * 1.0 + fOffset));
float3 vOriginPos = vPos.xyz - vAnchor;
float fLength = length(vOriginPos);
float fOsc = vOscillations.x + vOscillations.y * vOscillations.y;
float3x3 matTumble = RotationMatrix(vGrowthDir, fScale * fTwist * fOsc);
float3 vAxis = wind_cross(vGrowthDir, vRotatedWindVector);
float fDot = clamp(dot(vRotatedWindVector, vGrowthDir), -1.0, 1.0);
#ifdef TreeShader_Z_UP
vAxis.z += fDot;
#else
vAxis.y += fDot;
#endif
vAxis = normalize(vAxis);
float fAngle = acos(fDot);
float fAdherenceScale = 1.0;
fOsc = vOscillations.y - vOscillations.x * vOscillations.x;
float fTwitch = 0.0;
if (bTwitch)
fTwitch = Twitch(vAnchor.xyz, vTwitch.x, vTwitch.y, vTwitch.z + fOffset);
matTumble = mul(matTumble, RotationMatrix(vAxis, fScale * (fAngle * fAdherence * fAdherenceScale + fOsc * fFlip + fTwitch)));
vDirection = mul(matTumble, vDirection);
vOriginPos = mul(matTumble, vOriginPos);
vOriginPos = normalize(vOriginPos) * fLength;
return (vOriginPos + vAnchor);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Leaf Wind
//  Optimized (for instruction count) version. Assumes leaf 1 and 2 have the same options

float3 LeafWind(bool isBestWind, bool bLeaf2, float3 vPos, inout float3 vDirection, float fScale, float3 vAnchor, float fPackedGrowthDir, float fPackedRippleDir, float fRippleTrigOffset, float3 vRotatedWindVector) {
vPos = LeafRipple(vPos, vDirection, fScale, fPackedRippleDir, (bLeaf2 ? _ST_WindLeaf2Ripple.x : _ST_WindLeaf1Ripple.x), (bLeaf2 ? _ST_WindLeaf2Ripple.y : _ST_WindLeaf1Ripple.y), false, fRippleTrigOffset);
if (isBestWind) {
float3 vGrowthDir = UnpackNormalFromFloat(fPackedGrowthDir);
vPos = LeafTumble(vPos, vDirection, fScale, vAnchor, vGrowthDir, fPackedGrowthDir,
(bLeaf2 ? _ST_WindLeaf2Tumble.x : _ST_WindLeaf1Tumble.x),
(bLeaf2 ? _ST_WindLeaf2Tumble.y : _ST_WindLeaf1Tumble.y),
(bLeaf2 ? _ST_WindLeaf2Tumble.z : _ST_WindLeaf1Tumble.z),
(bLeaf2 ? _ST_WindLeaf2Tumble.w : _ST_WindLeaf1Tumble.w),
(bLeaf2 ? _ST_WindLeaf2Twitch.xyz : _ST_WindLeaf1Twitch.xyz),
0.0f,
(bLeaf2 ? true : true),
(bLeaf2 ? true : true),
vRotatedWindVector);
}
return vPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////v
//  Ripple Frond One Sided

float3 RippleFrondOneSided(float3 vPos, inout float3 vDirection, float fU, float fV, float fRippleScale
#ifdef WIND_EFFECT_FROND_RIPPLE_ADJUST_LIGHTING
, float3 vBinormal , float3 vTangent
#endif
) {
float fOffset = 0.0;
if (fU < 0.5)
fOffset = 0.75;
float4 vOscillations = TrigApproximate(float4((_ST_WindFrondRipple.x + fV) * _ST_WindFrondRipple.z + fOffset, 0.0, 0.0, 0.0));
float fAmount = fRippleScale * vOscillations.x * _ST_WindFrondRipple.y;
float3 vOffset = fAmount * vDirection;
vPos.xyz += vOffset;
#ifdef WIND_EFFECT_FROND_RIPPLE_ADJUST_LIGHTING
vTangent.xyz = normalize(vTangent.xyz + vOffset * _ST_WindFrondRipple.w);
float3 vNewNormal = normalize(wind_cross(vBinormal.xyz, vTangent.xyz));
if (dot(vNewNormal, vDirection.xyz) < 0.0)
vNewNormal = -vNewNormal;
vDirection.xyz = vNewNormal;
#endif
return vPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Ripple Frond Two Sided

float3 RippleFrondTwoSided(float3 vPos, inout float3 vDirection, float fU, float fLengthPercent, float fPackedRippleDir, float fRippleScale
#ifdef WIND_EFFECT_FROND_RIPPLE_ADJUST_LIGHTING
, float3 vBinormal , float3 vTangent
#endif
) {
float4 vOscillations = TrigApproximate(float4(_ST_WindFrondRipple.x * fLengthPercent * _ST_WindFrondRipple.z, 0.0, 0.0, 0.0));
float3 vRippleDir = UnpackNormalFromFloat(fPackedRippleDir);
float fAmount = fRippleScale * vOscillations.x * _ST_WindFrondRipple.y;
float3 vOffset = fAmount * vRippleDir;
vPos.xyz += vOffset;
#ifdef WIND_EFFECT_FROND_RIPPLE_ADJUST_LIGHTING
vTangent.xyz = normalize(vTangent.xyz + vOffset * _ST_WindFrondRipple.w);
float3 vNewNormal = normalize(wind_cross(vBinormal.xyz, vTangent.xyz));
if (dot(vNewNormal, vDirection.xyz) < 0.0)
vNewNormal = -vNewNormal;
vDirection.xyz = vNewNormal;
#endif
return vPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Ripple Frond

float3 RippleFrond(float3 vPos, inout float3 vDirection, float fU, float fV, float fPackedRippleDir, float fRippleScale, float fLenghtPercent
#ifdef WIND_EFFECT_FROND_RIPPLE_ADJUST_LIGHTING
, float3 vBinormal , float3 vTangent
#endif
) {
return RippleFrondOneSided(vPos, vDirection, fU, fV, fRippleScale
#ifdef WIND_EFFECT_FROND_RIPPLE_ADJUST_LIGHTING
, vBinormal, vTangent
#endif
);
}


#endif  //  End Winds



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Custom Wind

void CustomWind() {
_ST_WindGlobal.x *= _WindSpeed;
_ST_WindGlobal.y *= _WindAmplitude;
_ST_WindGlobal.z *= _WindDegreeSlope;
_ST_WindBranchAdherences.x *= _WindConstantTilt;
_ST_WindLeaf1Ripple.y *= _LeafRipple;
_ST_WindLeaf1Ripple.x *= _LeafRippleSpeed;
_ST_WindLeaf1Tumble.yzw *= _LeafTumble;
_ST_WindLeaf1Tumble.x *= _LeafTumbleSpeed;
_ST_WindBranch.y *= _BranchRipple;
_ST_WindBranch.x *= _BranchRippleSpeed;
_ST_WindBranchTwitch.x *= _BranchTwitch;
_ST_WindBranchWhip.x *= _BranchWhip;
_ST_WindTurbulences.x *= _BranchTurbulences; 
_ST_WindBranchAnchor.xyz *= float3(1, _BranchHeaviness, 1);
_ST_WindBranchAnchor.w *= _BranchForceHeaviness;


//_ST_WindVector _ST_WindGlobal _ST_WindBranch _ST_WindBranchTwitch _ST_WindBranchWhip
//_ST_WindBranchAnchor _ST_WindBranchAdherences _ST_WindTurbulences _ST_WindLeaf1Ripple
//_ST_WindLeaf1Tumble _ST_WindLeaf1Twitch _ST_WindLeaf2Ripple _ST_WindLeaf2Tumble
//_ST_WindLeaf2Twitch _ST_WindFrondRipple _ST_WindAnimation





}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Offset Vertex

void OffsetTreeShaderVertex(inout TreeShaderVB data, float lodValue) {
CustomWind();
float3 finalPosition = data.vertex.xyz;
#ifdef ENABLE_WIND
half windQuality = _WindQuality * _WindEnabled;
float3 rotatedWindVector, rotatedBranchAnchor;
if (windQuality <= WIND_QUALITY_NONE) {
rotatedWindVector = float3(0.0f, 0.0f, 0.0f);
rotatedBranchAnchor = float3(0.0f, 0.0f, 0.0f);
}
else {
rotatedWindVector = normalize(mul(_ST_WindVector.xyz, (float3x3)unity_ObjectToWorld));
rotatedBranchAnchor = normalize(mul(_ST_WindBranchAnchor.xyz, (float3x3)unity_ObjectToWorld)) * _ST_WindBranchAnchor.w;
}
#endif
#if defined(GEOM_TYPE_BRANCH) || defined(GEOM_TYPE_FROND)
#ifdef LOD_FADE_PERCENTAGE
finalPosition = lerp(finalPosition, data.texcoord1.xyz, lodValue);
#endif
#if defined(ENABLE_WIND) && defined(GEOM_TYPE_FROND)
if (windQuality == WIND_QUALITY_PALM)
finalPosition = RippleFrond(finalPosition, data.normal, data.texcoord.x, data.texcoord.y, data.texcoord2.x, data.texcoord2.y, data.texcoord2.z);
#endif
#elif defined(GEOM_TYPE_LEAF)
finalPosition -= data.texcoord1.xyz;
bool isFacingLeaf = data.color.a == 0;
if (isFacingLeaf) {
#ifdef LOD_FADE_PERCENTAGE
finalPosition *= lerp(1.0, data.texcoord1.w, lodValue);
#endif
float offsetLen = length(finalPosition);
finalPosition = mul(finalPosition.xyz, (float3x3)UNITY_MATRIX_IT_MV);
finalPosition = normalize(finalPosition) * offsetLen;
}
else {
#ifdef LOD_FADE_PERCENTAGE
float3 lodPosition = float3(data.texcoord1.w, data.texcoord3.x, data.texcoord3.y);
finalPosition = lerp(finalPosition, lodPosition, lodValue);
#endif
}
#ifdef ENABLE_WIND
if (windQuality > WIND_QUALITY_FASTEST && windQuality < WIND_QUALITY_PALM) {
float leafWindTrigOffset = data.texcoord1.x + data.texcoord1.y;
finalPosition = LeafWind(windQuality == WIND_QUALITY_BEST, data.texcoord2.w > 0.0, finalPosition, data.normal, data.texcoord2.x, float3(0, 0, 0), data.texcoord2.y, data.texcoord2.z, leafWindTrigOffset, rotatedWindVector);
}
#endif
finalPosition += data.texcoord1.xyz;
#endif
#ifdef ENABLE_WIND
float3 treePos = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
#ifndef GEOM_TYPE_MESH
if (windQuality >= WIND_QUALITY_BETTER) {
finalPosition = BranchWind(windQuality == WIND_QUALITY_PALM, finalPosition, treePos, float4(data.texcoord.zw, 0, 0), rotatedWindVector, rotatedBranchAnchor);
}
#endif
if (windQuality > WIND_QUALITY_NONE) {
finalPosition = GlobalWind(finalPosition, treePos, true, rotatedWindVector, _ST_WindGlobal.x);
}
#endif
data.vertex.xyz = finalPosition;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Surface


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Define Input structure

struct Input {
fixed4 color;
half3 interpolator1;
#ifdef GEOM_TYPE_BRANCH_DETAIL
half3 interpolator2;
#endif
};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Define uniforms


fixed4 _Color;
#define mainTexUV interpolator1.xy
sampler2D _MainTex, _OcclusionMap;
half _Shininess, _IntensityNm, _IntensityOc, _Light, _Saturation, _Contrast, _Brightness;

#ifdef GEOM_TYPE_BRANCH_DETAIL
#define Detail interpolator2
sampler2D _DetailTex;
#endif

#if defined(GEOM_TYPE_FROND) || defined(GEOM_TYPE_LEAF) || defined(GEOM_TYPE_FACING_LEAF)
#define TreeShader_ALPHATEST
fixed _Cutoff;
#endif

#ifdef EFFECT_HUE_VARIATION
#define HueVariationAmount interpolator1.z
half4 _HueVariation;
#endif

#if defined(EFFECT_BUMP) && !defined(LIGHTMAP_ON)
sampler2D _BumpMap;
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Vertex processing

void TreeShaderVert(inout TreeShaderVB IN, out Input OUT) {
UNITY_INITIALIZE_OUTPUT(Input, OUT);
OUT.mainTexUV = IN.texcoord.xy;
OUT.color = _Color;
OUT.color.rgb *= IN.color.r;
OUT.color.rgb *= _Light;
#ifdef EFFECT_HUE_VARIATION
float hueVariationAmount = frac(unity_ObjectToWorld[0].w + unity_ObjectToWorld[1].w + unity_ObjectToWorld[2].w);
hueVariationAmount += frac(IN.vertex.x + IN.normal.y + IN.normal.x) * 0.5 - 0.3;
OUT.HueVariationAmount = saturate(hueVariationAmount * _HueVariation.a);
#endif
#ifdef GEOM_TYPE_BRANCH_DETAIL
OUT.Detail.xy = IN.texcoord2.xy;
if (IN.color.a == 0) OUT.Detail.z = IN.texcoord2.z;
else OUT.Detail.z = 2.5f;
#endif
OffsetTreeShaderVertex(IN, unity_LODFade.x);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Fragment processing

#if defined(EFFECT_BUMP) && !defined(LIGHTMAP_ON)
#define TreeShader_DATA_NORMAL           fixed3 Normal;
#define TreeShader_COPY_NORMAL(to, from) to.Normal = from.Normal;
#else
#define TreeShader_DATA_NORMAL
#define TreeShader_COPY_NORMAL(to, from)
#endif

#define TreeShader_COPY_FRAG(to, from) \
to.Albedo = from.Albedo; \
to.Alpha = from.Alpha; \
to.Gloss = from.Gloss; \
to.Specular = from.Specular; \
TreeShader_COPY_NORMAL(to, from)

struct TreeShaderFragOut {
fixed3 Albedo;
fixed Alpha;
fixed Gloss;
fixed Specular;
TreeShader_DATA_NORMAL
};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FragOut

void TreeShaderFrag(Input IN, out TreeShaderFragOut OUT) {
half4 diffuseColor = tex2D(_MainTex, IN.mainTexUV);

OUT.Alpha = diffuseColor.a * _Color.a;
#ifdef TreeShader_ALPHATEST
clip(OUT.Alpha - _Cutoff);
#endif

#ifdef GEOM_TYPE_BRANCH_DETAIL
half4 detailColor = tex2D(_DetailTex, IN.Detail.xy);
diffuseColor.rgb = lerp(diffuseColor.rgb, detailColor.rgb, IN.Detail.z < 2.0f ? saturate(IN.Detail.z) : detailColor.a);
#endif

#ifdef EFFECT_HUE_VARIATION
half3 shiftedColor = lerp(diffuseColor.rgb, _HueVariation.rgb, IN.HueVariationAmount);
half maxBase = max(diffuseColor.r, max(diffuseColor.g, diffuseColor.b));
half newMaxBase = max(shiftedColor.r, max(shiftedColor.g, shiftedColor.b));
maxBase /= newMaxBase;
maxBase = maxBase * 0.5f + 0.5f;
shiftedColor.rgb *= maxBase;
diffuseColor.rgb = saturate(shiftedColor);
#endif

#if defined(EFFECT_BUMP) && !defined(LIGHTMAP_ON)
fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.mainTexUV));
normal.x *= _IntensityNm;
normal.y *= _IntensityNm;
OUT.Normal = normalize(normal);
#ifdef GEOM_TYPE_BRANCH_DETAIL
fixed3 detailNormal = UnpackNormal(tex2D(_BumpMap, IN.mainTexUV));
detailNormal.x *= _IntensityNm;
detailNormal.y *= _IntensityNm;
OUT.Normal = lerp(OUT.Normal, normalize(detailNormal), IN.Detail.z < 2.0f ? saturate(IN.Detail.z) : detailColor.a);
#endif
#endif

fixed occcol = tex2D(_OcclusionMap, IN.mainTexUV).r;
occcol *= _IntensityOc;
diffuseColor *= occcol;
diffuseColor.rgb *= IN.color.rgb;

float Lum = dot(diffuseColor, float3(0.2126, 0.7152, 0.0722));
half3 colorL = lerp(Lum.xxx, diffuseColor, _Saturation);
colorL = colorL * _Brightness;
OUT.Albedo = (colorL - 0.5) * _Contrast + 0.5;

OUT.Gloss = diffuseColor.a;
OUT.Specular = _Shininess;

}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#endif
