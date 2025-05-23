Shader "Unlit/CrtShader"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(Scanlines)] [Space]
        _ScanlineIntensity ("Scanline Intensity", Range(0, 1)) = 0.04
        _ScanlineCount ("Scanline Count", Range(100, 1000)) = 800
        
        [Header(Vignette)] [Space]
        _VignetteIntensity ("Vignette Intensity", Range(0, 1)) = 0.3
        _VignetteSmoothness ("Vignette Smoothness", Range(0.1, 1)) = 0.5

        [Header(Noise)] [Space]
        _NoiseIntensity ("Noise Intensity", Range(0, 0.1)) = 0.02
        _NoiseSpeed ("Noise Speed", Range(0, 10)) = 1.0
        
        [Header(Brightness)] [Space]
        _Brightness ("Brightness", Range(0.5, 2)) = 1.1
        _Contrast ("Contrast", Range(0.5, 2)) = 1.2
        _Saturation ("Saturation", Range(0, 2)) = 1.1
        
        [Header(HorizontalLines)] [Space]
        _HorizontalLines ("Horizontal Lines", Range(0, 1)) = 0.02
        _HorizontalLineCount ("Horizontal Line Count", Range(50, 500)) = 200
        
        [Header(FlickerIntensity)] [Space]
        _FlickerIntensity ("Flicker Intensity", Range(0, 0.1)) = 0.01
        _FlickerSpeed ("Flicker Speed", Range(0, 20)) = 5.0
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float _DistortionStrength;;
            float _ScanlineIntensity;
            float _ScanlineCount;
            float _VignetteIntensity;
            float _VignetteSmoothness;
            float _NoiseIntensity;
            float _NoiseSpeed;
            float _Brightness;
            float _Contrast;
            float _Saturation;
            float _HorizontalLines;
            float _HorizontalLineCount;
            float _FlickerIntensity;
            float _FlickerSpeed;

            float random(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float2 crtDistortion(float2 uv)
            {
                uv = uv * 2.0 - 1.0; 
                

                uv = uv * 0.5 + 0.5; 
                return uv;
            }

            float vignette(float2 uv)
            {
                uv *= 1.0 - uv.yx;
                float vig = uv.x * uv.y * 15.0;
                vig = pow(vig, _VignetteSmoothness);
                return lerp(1.0, vig, _VignetteIntensity);
            }

            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                
                float2 distortedUV = crtDistortion(uv);
                
                if (distortedUV.x < 0.0 || distortedUV.x > 1.0 || 
                    distortedUV.y < 0.0 || distortedUV.y > 1.0)
                {
                    return fixed4(0, 0, 0, 1);
                }
                
                fixed3 col = tex2D(_MainTex, distortedUV).rgb;
                
                col = ((col - 0.5) * _Contrast) + 0.5;
                col *= _Brightness;
                
                float3 hsv = rgb2hsv(col);
                hsv.y *= _Saturation;
                col = hsv2rgb(hsv);
                
                float scanline = sin(distortedUV.y * _ScanlineCount * 3.14159) * 0.5 + 0.5;
                scanline = lerp(1.0, scanline, _ScanlineIntensity);
                col *= scanline;
                
                float horizontalLine = sin(distortedUV.x * _HorizontalLineCount * 3.14159) * 0.5 + 0.5;
                horizontalLine = lerp(1.0, horizontalLine, _HorizontalLines);
                col *= horizontalLine;
                
                float noise = random(distortedUV + frac(_Time.y * _NoiseSpeed));
                noise = (noise - 0.5) * _NoiseIntensity;
                col += noise;
                
                float flicker = sin(_Time.y * _FlickerSpeed) * _FlickerIntensity + 1.0;
                col *= flicker;
                
                col *= vignette(distortedUV);
                
                col = saturate(col);
                
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}