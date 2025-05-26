Shader "Unlit/PortalCloudShader"
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
        [Header(FBM)] [Space]
        _FBMScale("FBM Scale", Float) = 3.0
        _FBMSpeed("FBM Speed", Float) = 0.2
        _FBMStrength("FBM Strength", Float) = 1.0
        [Header(Ripple)] [Space]
        _RippleCenter("Ripple Center", Vector) = (0.5, 0.5, 0, 0)
        _RippleTime("Ripple Time", Float) = 0.0
        _RippleStrength("Ripple Strength", Float) = 0.03
        _RippleFrequency("Ripple Frequency", Float) = 20.0
        _RippleSpeed("Ripple Speed", Float) = 5.0
        [Toggle] _EnableRipple("Enable Ripple Effect", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float _Speed, _Intensity, _DistortionStrength, _DistortionScale, _Transparency;
            float _FadeStart, _FadeEnd;
            float _FBMScale, _FBMSpeed, _FBMStrength;
            float4 _RippleCenter;
            float _RippleTime, _RippleStrength, _RippleFrequency, _RippleSpeed;
            float _EnableRipple;

            float random(float2 st) {
                return frac(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
            }

            float noise(float2 st) {
                float2 i = floor(st);
                float2 f = frac(st);

                float a = random(i);
                float b = random(i + float2(1,0));
                float c = random(i + float2(0,1));
                float d = random(i + float2(1,1));

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(a, b, u.x) + (c - a) * u.y * (1 - u.x) + (d - b) * u.x * u.y;
            }

            float fbm(float2 st) {
                float v = 0.0, a = 0.5;
                for (int i = 0; i < 6; i++) {
                    v += a * noise(st);
                    st *= 2.0;
                    a *= 0.5;
                }
                return v;
            }

            float2 RippleUV(float2 uv) {
                float2 toCenter = uv - _RippleCenter.xy;
                float dist = length(toCenter);
                float ripple = sin(dist * _RippleFrequency - _RippleTime * _RippleSpeed);
                float rippleOffset = ripple * exp(-dist * 10.0) * _RippleStrength;
                return uv + normalize(toCenter) * rippleOffset;
            }

            float2 DistortUV(float2 uv, float time) {
                float n = sin(uv.y * _DistortionScale * 0.5 + time * _Speed * 1.2)
                         * cos(uv.x * _DistortionScale * 0.5 + time * _Speed * 0.8);

                float2 offset = float2(n, n);
                return uv + offset * _DistortionStrength;
            }

            float3 GetRainbowColor(float t) {
                float r = sin(t * 6.2831 + 0.0) * 0.5 + 0.5;
                float g = sin(t * 6.2831 + 2.094) * 0.5 + 0.5;
                float b = sin(t * 6.2831 + 4.188) * 0.5 + 0.5;
                return float3(r, g, b);
            }

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float time = _Time.y;

                float2 finalUV = i.uv;
                
                if (_EnableRipple > 0.5) {
                    finalUV = RippleUV(i.uv);
                }

                float2 uv = DistortUV(finalUV, time);

                float t = frac(uv.y + sin(uv.x * 5.0 + time * 0.5) * 0.1 + time * _Speed * 0.5);
                float fbmMod = fbm(uv * _FBMScale + time * _FBMSpeed);
                float3 rainbow = GetRainbowColor(t) * fbmMod * _FBMStrength * _Intensity;

                float dist = distance(_WorldSpaceCameraPos, i.worldPos);
                float fade = saturate((_FadeEnd - dist) / (_FadeEnd - _FadeStart));
                float alpha = _Transparency * fade;

                return float4(rainbow, alpha);
            }
            ENDCG
        }
    }
}
