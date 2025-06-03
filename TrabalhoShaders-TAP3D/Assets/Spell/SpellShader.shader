Shader "Unlit/SpellEffect_WithFresnel_Fixed"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1, 0.5, 1, 1)
        _Speed ("UV Scroll Speed", Vector) = (0.1, 0.1, 0, 0)
        _EmissionStrength ("Emission Strength", Float) = 2.0
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelPower ("Fresnel Power", Float) = 5.0
        _FresnelStrength ("Fresnel Strength", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200

        Blend One One
        ZWrite Off
        Cull Off
        Lighting Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _TintColor;
            float4 _Speed;
            float _EmissionStrength;
            float4 _FresnelColor;
            float _FresnelPower;
            float _FresnelStrength;

            v2f vert (appdata v)
            {
                v2f o;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                float3 viewDir = normalize(worldPos - _WorldSpaceCameraPos);

                o.worldNormal = worldNormal;
                o.viewDir = viewDir;

                o.vertex = UnityObjectToClipPos(v.vertex);

                float2 offset = _Speed.xy * _Time.y;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex) + offset;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _TintColor;
                col.rgb *= _EmissionStrength;

                float fresnel = pow(1.0 - saturate(dot(normalize(i.worldNormal), normalize(i.viewDir))), _FresnelPower);
                col.rgb += fresnel * _FresnelColor.rgb * _FresnelStrength;

                return col;
            }
            ENDCG
        }
    }
}
