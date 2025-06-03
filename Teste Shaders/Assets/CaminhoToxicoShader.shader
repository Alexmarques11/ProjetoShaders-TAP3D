Shader "Unlit/CaminhoToxicoShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _pontoCsharp ("Ponto C#", Vector) = (0,0,0,0)
        _BubbleColor ("Cor da Bolha", Color) = (0, 1, 0, 1)
        _Radius ("Raio da Bolha", Float) = 1.0
        _Height ("Altura Máxima", Float) = 0.5
        _BubbleSharpness ("Nitidez da Bolha", Range(0.1, 5.0)) = 1.0
        _BubbleCurvature ("Curvatura da Bolha", Range(0.1, 3.0)) = 2.0
        _EdgeSoftness ("Suavidade das Bordas", Range(0.0, 1.0)) = 0.3
        _PulseSpeed ("Velocidade do Pulsar", Float) = 2.0
        _PulseIntensity ("Intensidade do Pulsar", Range(0.0, 1.0)) = 0.5
        _MinBrightness ("Brilho Mínimo", Range(0.0, 1.0)) = 0.3
        _RandomnessAmount ("Nível de Aleatoriedade", Range(0.0, 1.0)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                float4 vertex : SV_POSITION;
                float deformAmount : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _pontoCsharp;
            fixed4 _BubbleColor;

            float _Radius;
            float _Height;
            float _BubbleSharpness;
            float _BubbleCurvature;
            float _EdgeSoftness;
            float _PulseSpeed;
            float _PulseIntensity;
            float _MinBrightness;
            float _RandomnessAmount;

            float rand(float3 seed)
            {
                return frac(sin(dot(seed.xyz, float3(12.9898, 78.233, 37.719))) * 43758.5453);
            }

            float3 deformBubble(float3 position, float3 center, float radius, float height, out float displacementAmount)
            {
                float3 offset = position - center;
                float dist = length(offset);
                displacementAmount = 0;

                if(dist < radius)
                {
                    float t = dist / radius;

                    float bubbleProfile = 1.0 - pow(t, _BubbleCurvature);

                    float edgeFactor = 1.0 - smoothstep(1.0 - _EdgeSoftness, 1.0, t);
                    bubbleProfile *= edgeFactor;

                    bubbleProfile = pow(bubbleProfile, 1.0 / _BubbleSharpness);

                    float displacement = height * bubbleProfile;

                    float3 direction = normalize(offset);
                    float radialDeformation = displacement * 0.05;

                    position.y += displacement;
                    position.x += direction.x * radialDeformation;
                    position.z += direction.z * radialDeformation;

                    displacementAmount = displacement;
                }

                return position;
            }

            v2f vert (appdata v)
            {
                v2f o;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float displacement;

                float noise = rand(worldPos);
                float variableRadius = _Radius * (1.0 + (noise - 0.5) * _RandomnessAmount);
                float variableHeight = _Height * (1.0 + (noise - 0.5) * _RandomnessAmount);

                worldPos = deformBubble(worldPos, _pontoCsharp.xyz, variableRadius, variableHeight, displacement);
                float4 localDeformed = mul(unity_WorldToObject, float4(worldPos, 1.0));

                o.vertex = UnityObjectToClipPos(localDeformed);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.deformAmount = displacement;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 baseColor = tex2D(_MainTex, i.uv);

                if(i.deformAmount > 0.001)
                {
                    float pulseValue = sin(_Time.y * _PulseSpeed) * 0.5 + 0.5;
                    float pulseBrightness = lerp(_MinBrightness, 1.0, pulseValue * _PulseIntensity + (1.0 - _PulseIntensity));

                    fixed4 bubbleColor = _BubbleColor * pulseBrightness;
                    bubbleColor.a = 1.0;

                    float intensity = saturate(i.deformAmount * 3);
                    baseColor = lerp(baseColor, bubbleColor, intensity * 0.8);
                }

                return baseColor;
            }

            ENDCG
        }
    }
}
