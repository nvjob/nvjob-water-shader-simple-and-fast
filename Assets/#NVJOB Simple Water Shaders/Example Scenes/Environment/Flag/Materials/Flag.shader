Shader "#NVJOB/Flag" {

Properties {
_MainTex("Texture", 2D) = "white" {}
_Ambient("Ambient", Range(0., 1.)) = 0.2
[Header(Waves)]
_WaveSpeed("Speed", float) = 0.0
_WaveStrength("Strength", Range(0.0, 1.0)) = 0.0
_WaveAmount("Amount", Range(0.0, 10.0)) = 1
}

SubShader {
Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
Cull Off

Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

struct v2f {
float4 pos : SV_POSITION;
float4 vertex : TEXCOORD1;
float2 uv : TEXCOORD0;
};

sampler2D _MainTex;
half _WaveStrength, _WaveSpeed;
fixed4 _LightColor0;
half _Ambient, _WaveAmount;

fixed3 diffuseLambert(half3 normal) {
half diffuse = max(_Ambient, dot(normalize(normal), _WorldSpaceLightPos0.xyz));
return _LightColor0.rgb * diffuse;
}

float4 movement(half4 pos, half2 uv) {
half sinOff = (pos.x + pos.y + pos.z) * _WaveStrength;
half t = _Time.y * _WaveSpeed;
half fx = uv.x;
half fy = uv.x * uv.y;
pos.x += (sin(t * 1.45 + sinOff) * fx * 0.5) * _WaveAmount;
pos.y = (sin(t * 3.12 + sinOff) * fx * 0.5 - fy * 0.9) * _WaveAmount;
pos.z -= (sin(t * 2.2 + sinOff) * fx * 0.2) * _WaveAmount;
return pos;
}

v2f vert(appdata_base v) {
v2f o;
o.vertex = v.vertex;
o.pos = UnityObjectToClipPos(movement(v.vertex, v.texcoord));
o.uv = v.texcoord;
return o;
}

fixed4 frag(v2f i) : SV_Target {
fixed4 col = tex2D(_MainTex, i.uv);
half3 pos0 = movement(half4(i.vertex.x, i.vertex.y, i.vertex.z, i.vertex.w), i.uv).xyz;
half3 pos1 = movement(half4(i.vertex.x + 0.01, i.vertex.y, i.vertex.z, i.vertex.w), i.uv).xyz;
half3 pos2 = movement(half4(i.vertex.x, i.vertex.y, i.vertex.z + 00.1, i.vertex.w), i.uv).xyz;
half3 normal = cross(normalize(pos2 - pos0), normalize(pos1 - pos0));
half3 worldNormal = mul(normal, (half3x3) unity_WorldToObject);
col.rgb *= diffuseLambert(worldNormal);
return col;
}

ENDCG
}
}
}