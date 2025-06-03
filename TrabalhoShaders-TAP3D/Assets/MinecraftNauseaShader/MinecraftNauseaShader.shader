Shader "Hidden/MinecraftNauseaShader_Simple"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortionIntensity ("Distortion Intensity", Range(0, 0.3)) = 0.1
        _WaveSpeed ("Wave Speed", Range(0.1, 10)) = 3.0
        _WaveFrequency ("Wave Frequency", Range(1, 50)) = 15.0
        _TimeScale ("Time Scale", Range(0.1, 5)) = 1.0
        _EffectStrength ("Effect Strength", Range(0, 1)) = 1.0
        [Toggle] _NauseaEffect("Enable Ripples", Float) = 0
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

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
            };

            sampler2D _MainTex;
            float _DistortionIntensity;
            float _WaveSpeed;
            float _WaveFrequency;
            float _TimeScale;
            float _EffectStrength;
            float _NauseaEffect;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if(_NauseaEffect == 0)
                {
                    return tex2D(_MainTex, i.uv);
                }

                float2 uv = i.uv;
                float time = _Time.y * _TimeScale;

                float2 waveOffset = float2(
                    sin(uv.y * _WaveFrequency + time * _WaveSpeed),
                    cos(uv.x * _WaveFrequency + time * _WaveSpeed * 1.3)
                ) * _DistortionIntensity * _EffectStrength;

                float2 finalUV = uv + waveOffset;

                fixed4 col = tex2D(_MainTex, finalUV);
                return col;
            }
            ENDCG
        }
    }
}
