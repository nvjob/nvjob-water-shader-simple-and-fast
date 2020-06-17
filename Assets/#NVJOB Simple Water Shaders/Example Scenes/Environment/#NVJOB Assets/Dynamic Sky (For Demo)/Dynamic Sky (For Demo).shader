// #NVJOB Dynamic Sky (for Demo)
// Full Asset #NVJOB Dynamic Sky - https://nvjob.github.io/unity/nvjob-dynamic-sky-lite
// #NVJOB Nicholas Veselov - https://nvjob.github.io


Shader "Custom/Dynamic Sky (For Demo)" {


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Properties{
//----------------------------------------------

[HideInInspector][NoScaleOffset]_Texture1("Texture 1", 2D) = "white" {}
[HideInInspector]_TextureUv1("Texture 1 Tiling", Float) = 1
[HideInInspector]_IntensityT1("Intensity", float) = 1.5
[HideInInspector]_VectorX1("Motion Vector X", float) = 0.9
[HideInInspector]_VectorY1("Motion Vector Y", float) = 1.0
[HideInInspector][NoScaleOffset]_Texture2("Texture 2", 2D) = "gray" {}
[HideInInspector]_TextureUv2("Texture 2 Tiling", Float) = 1
[HideInInspector]_IntensityT2("Intensity", float) = 1.5
[HideInInspector]_VectorX2("Motion Vector X", float) = 1.3
[HideInInspector]_VectorY2("Motion Vector Y", float) = 1.2
[HideInInspector][NoScaleOffset]_Texture3("Texture 3", 2D) = "gray" {}
[HideInInspector]_TextureUv3("Texture 3 Tiling", Float) = 1
[HideInInspector]_IntensityT3("Intensity", float) = -0.5
[HideInInspector]_VectorX3("Motion Vector X", float) = -1
[HideInInspector]_VectorY3("Motion Vector Y", float) = -1
[HideInInspector][HDR]_Color("Color", Color) = (1,1,1,1)
[HideInInspector]_IntensityInput("Intensity Input", float) = 1.6
[HideInInspector]_Fluffiness("Fluffiness", float) = 0.75
[HideInInspector]_IntensityOutput("Intensity Output", float) = 1
[HideInInspector][HDR]_Level1Color("Top Horizon Color", Color) = (0.65,0.86,0.63,1)
[HideInInspector]_Level1("Top Horizon Level", Float) = 10
[HideInInspector][HDR]_Level0Color("Bottom Horizon Color", Color) = (0.37,0.78,0.92,1)
[HideInInspector]_Level0("Bottom Horizon Level", Float) = 0

//----------------------------------------------
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



SubShader {
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tags{ "Queue" = "Geometry+500" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
Blend SrcAlpha OneMinusSrcAlpha
LOD 400

CGPROGRAM
#pragma surface surf Nolight alpha:fade vertex:vert exclude_path:prepass nofog nolightmap nometa nolppv noshadowmask noshadow noforwardadd novertexlights halfasview
#pragma shader_feature_local DSKY_CLOUD_1 DSKY_CLOUD_2 DSKY_HORIZON

//----------------------------------------------

half4 LightingNolight(SurfaceOutput s, half3 nullA, half nullB) {
half4 c;
c.rgb = s.Albedo;
c.a = s.Alpha;
return c;
}

//----------------------------------------------

#if defined(DSKY_CLOUD_1) || defined(DSKY_CLOUD_2)
sampler2D _Texture1, _Texture2, _Texture3;
float4 _Color;
float _TextureUv1, _VectorX1, _VectorY1, _IntensityT1;
float _TextureUv2, _VectorX2, _VectorY2, _IntensityT2;
float _TextureUv3, _VectorX3, _VectorY3, _IntensityT3;
float _IntensityInput, _IntensityOutput, _Fluffiness;
float _SkyShaderUvX, _SkyShaderUvZ;
#endif

#if defined(DSKY_HORIZON)
float _Level0, _Level1;
fixed4 _Level0Color, _Level1Color;
#endif

//----------------------------------------------

struct Input {
#if defined(DSKY_CLOUD_1) || defined(DSKY_CLOUD_2)
float2 posTex;
#endif
#if defined(DSKY_HORIZON)
float3 worldPos;
#endif
};

//----------------------------------------------

struct appdata {
float4 vertex : POSITION;
float3 normal : NORMAL;
float2 texcoord : TEXCOORD0;
float4 texcoord1 : TEXCOORD1;
float4 color : COLOR;
};

//----------------------------------------------

void vert(inout appdata v, out Input o) {
UNITY_INITIALIZE_OUTPUT(Input, o);
#if defined(DSKY_CLOUD_1) || defined(DSKY_CLOUD_2)
o.posTex = float4(v.texcoord * 1.0 - 1.0, 0.0, 1.0);
#endif
}

//----------------------------------------------

void surf(Input IN, inout SurfaceOutput o) {

half4 tex;

#if defined(DSKY_CLOUD_1)
tex = _Color;
float2 uv = IN.posTex;
uv.xy += float2(_SkyShaderUvX * _VectorX1, _SkyShaderUvZ * _VectorY1);
tex *= tex2D(_Texture1, uv * _TextureUv1) * _IntensityT1;
float2 uvd = IN.posTex;
uvd.xy += float2(_SkyShaderUvX * _VectorX2, _SkyShaderUvZ * _VectorY2);
tex *= tex2D(_Texture2, uvd * _TextureUv2).r * _IntensityT2;
float2 uvdd = IN.posTex;
uvdd.xy += float2(_SkyShaderUvX * _VectorX3, _SkyShaderUvZ * _VectorY3);
tex *= tex2D(_Texture3, uvdd * _TextureUv3).r * _IntensityT3;
tex *= _IntensityInput;
float4 albedoEnd = normalize((tex - 0.5) * _Fluffiness + 0.5);
albedoEnd *= _IntensityOutput;
float alphaEnd = tex.a;
#endif

#if defined(DSKY_CLOUD_2)
tex = _Color;
float2 uv = IN.posTex;
uv.xy += float2(_SkyShaderUvX * _VectorX1, _SkyShaderUvZ * _VectorY1);
tex *= tex2D(_Texture1, uv * _TextureUv1).r * _IntensityT1;
float2 uvd = IN.posTex;
uvd.xy += float2(_SkyShaderUvX * _VectorX2, _SkyShaderUvZ * _VectorY2);
tex *= tex2D(_Texture2, uvd * _TextureUv2).g * _IntensityT2;
float2 uvdd = IN.posTex;
uvdd.xy += float2(_SkyShaderUvX * _VectorX3, _SkyShaderUvZ * _VectorY3);
tex *= tex2D(_Texture3, uvdd * _TextureUv3).b * _IntensityT3;
tex *= _IntensityInput;
float4 albedoEnd = normalize((tex - 0.5) * _Fluffiness + 0.5);
albedoEnd *= _IntensityOutput;
float alphaEnd = tex.a;
#endif

#if defined(DSKY_HORIZON)
float4 pixelWorldSpacePosition = IN.worldPos.y;
float pixelWpY = pixelWorldSpacePosition.y;
if (pixelWpY >= _Level1) tex = lerp(_Level0Color, _Level1Color, (pixelWpY - _Level0) / (_Level1 - _Level0));
if (pixelWpY < _Level0) tex = _Level0Color;
float3 albedoEnd = tex.rgb;
float alphaEnd = tex.a;
#endif

o.Albedo = albedoEnd;
o.Alpha = alphaEnd;

}

//----------------------------------------------

ENDCG

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


FallBack "Diffuse"
CustomEditor "NVDSkyDemoMaterials"


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
