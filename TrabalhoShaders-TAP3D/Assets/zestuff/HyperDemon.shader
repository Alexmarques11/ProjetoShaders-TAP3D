Shader "Custom/HyperDemon"
{
    Properties
    {
        _Color("Tint", Color) = (1,0,0,1)
        _Color2("Tint2", Color) = (1,0,0,1)
        _Pow("Intensity", Range(0,15)) = 1
        _Offset("Offset", Range(-15,15)) = 0
        _Distance("LSDDistance", Range(0,30)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        float _Pow;
        float _Offset;
        float _Distance;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 worldRefl; INTERNAL_DATA // reflection vector
            float3 viewDir;
            float4 screenPos;
        };

        fixed4 _Color;
        fixed4 _Color2;
        float _Intense;
        half _Height;
        
        static const float PI = 3.14159265359;

        float2 spherePositionToCoords(float3 position) {
            float2 normalizedWithoutY = normalize(position.xz);

            float2 newUV;

            if (normalizedWithoutY.y < 0) {
                newUV = float2(1 - acos(normalizedWithoutY.x) / PI / 2, 1 - acos(position.y) / PI);
            } else {
                newUV = float2(acos(normalizedWithoutY.x) / PI / 2, 1 - acos(position.y) / PI);
            }

            return newUV;
        }

        float2 unity_gradientNoise_dir(float2 p)
        {
	        p = p % 289;
	        float x = (34 * p.x + 1) * p.x % 289 + p.y;
	        x = (34 * x + 1) * x % 289;
	        x = frac(x / 41) * 2 - 1;
	        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        float unity_gradientNoise(float2 p)
        {
	        float2 ip = floor(p);
	        float2 fp = frac(p);
	        float d00 = dot(unity_gradientNoise_dir(ip), fp);
	        float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
	        float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
	        float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
	        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
	        return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
	        Out = unity_gradientNoise(UV * Scale) + 0.5;
        }

        float2 random2(float2 p ) {
            return frac(sin(float2(dot(p,float2(127.1,311.7)),dot(p,float2(269.5,183.3))))*43758.5453);
        }

        float3 voronoi(float2 st, float scroll)
        {
            float3 color = float3(0.0, 0.0, 0.0);

            // Scale
            st *= 3;

            // Tile the space
            float2 i_st = floor(st);
            float2 f_st = frac(st);

            float m_dist = 1.;  // minimum distance

            for (int y = -1; y <= 1; y++) {
                for (int x = -1; x <= 1; x++) {
                    // Neighbor place in the grid
                    float2 neighbor = float2(x,y);

                    // Random position from current + neighbor place in the grid
                    float2 point2 = random2(i_st + neighbor);

			        // Animate the point
                    point2 = 0.5 + 0.5*sin(scroll + 6.2831*point2);

			        // Vector between the pixel and the point
                    float2 diff = neighbor + point2 - f_st;

                    // Distance to the point
                    float dist = length(diff);

                    // Keep the closer distance
                    m_dist = min(m_dist, dist);
                }
            }

            // Draw the min distance (distance field)
            color += m_dist;

            return color;
        }
        
        int close(Input IN) {
            return distance(_WorldSpaceCameraPos, IN.worldPos) < _Distance;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // otherstuff
            float3 reflexion = reflect(IN.viewDir, o.Normal);
            float2 newUV = spherePositionToCoords(reflexion);

            fixed3 noise = unity_gradientNoise(float2(3 * newUV.x, (3 * newUV.y - _Time.y)));
            noise *= _Pow;
            noise += _Offset;

            noise = clamp(noise, -1, 1);

            noise = noise * 0.5 + 0.5;

            fixed3 color3 = _Color + (_Color2 - _Color) * noise;

            float2 st = (IN.screenPos.xy / IN.screenPos.w) * 3;
            st.y += _Time.y * -1.2;

            // Chromatic aberration effect
            float r = voronoi(st + 0.02, 5).r;
            float g = voronoi(st, 5).g;
            float b = voronoi(st - 0.02, 5).b;

            float3 color = float3(r, g, b);
            
            color = pow(color + 0.2, 5);

            float h = sin(_Time.w * 10) * 0.5 + 0.5;

            color *= pow(h, 5);

            color *= close(IN);
            
            o.Albedo = color3 + color;
        }
        ENDCG
    }
    FallBack "Diffuse"
}