Shader "Unlit/PortalShader"
{
     Properties
    {
        [Header(Rainbow)] [Space]
        _Speed("Scroll Speed", Float) = 0.2
        _Intensity("Color Intensity", Float) = 1.0
        _DistortionStrength("Distortion Strength", Float) = 0.25
        _DistortionScale("Distortion Scale", Float) = 3.0
        [Header(Transparency)] [Space]
        _Transparency("Transparency", Range(0 ,1)) = 1.0
        _FadeStart("Fade Start Distance", Float) = 10.0
        _FadeEnd("Fade End Distance", Float) = 30.0
        [Header(Clouds)] [Space]
        _CloudOpacity("Cloud Opacity", Range(0,1)) = 0.3
        _CloudScale("Cloud Scale", Float) = 5.0
        _CloudSpeed("Cloud Speed", Float) = 0.2
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float _Speed;
            float _Intensity;
            float _DistortionScale;
            float _DistortionStrength;
            float _Transparency;
            float _FadeEnd;
            float _FadeStart;

            float _CloudOpacity;
            float _CloudScale;
            float _CloudSpeed;

            float2 random2(float2 st) {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            float noise(float2 st) {
                float2 i = floor(st);
                float2 f = frac(st);
                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(
                    lerp(dot(random2(i + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
                         dot(random2(i + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
                    lerp(dot(random2(i + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
                         dot(random2(i + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            float2 DistortUV(float2 uv, float time) {
                float n1 = sin((uv.y * _DistortionScale + time * _Speed)) * 0.5;
                float n2 = cos((uv.x * _DistortionScale + time * _Speed * 1.5)) * 0.5;
                float n3 = sin((uv.y * _DistortionScale * 0.5 + time * _Speed * 1.2)) 
                         * cos((uv.x * _DistortionScale * 0.5 + time * _Speed * 0.8));
                float2 offset = float2(n1 + n3, n2 + n3);
                return uv + offset * _DistortionStrength;
            }

            float3 GetRainbowColor(float t) {
                float r = sin(t * 6.2831 + 0.0) * 0.5 + 0.5;
                float g = sin(t * 6.2831 + 2.094) * 0.5 + 0.5;
                float b = sin(t * 6.2831 + 4.188) * 0.5 + 0.5;
                return float3(r, g, b);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float time = _Time.y;

                float2 uv = DistortUV(i.uv, time);

                float t = frac(uv.y + sin(uv.x * 5.0 + time * 0.5) * 0.1 + time * _Speed * 0.5);
                float3 portalColor = GetRainbowColor(t) * _Intensity;

                float2 cloudUV = i.uv * _CloudScale + time * _CloudSpeed;
                float cloudVal = noise(cloudUV);
                float cloudMask = smoothstep(0.4, 0.6, cloudVal);
                float3 cloudColor = float3(1.0, 1.0, 1.0) * _CloudOpacity * cloudMask;

                float3 finalColor = portalColor + cloudColor;

                float dist = distance(_WorldSpaceCameraPos, i.worldPos);
                float fade = saturate((_FadeEnd - dist) / (_FadeEnd - _FadeStart));
                float finalAlpha = _Transparency * fade;

                return fixed4(finalColor, finalAlpha);
            }
            ENDCG
        }
    }
}
