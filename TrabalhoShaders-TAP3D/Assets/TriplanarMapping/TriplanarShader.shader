Shader "Unlit/TriplanarBuiltIn"
{
    Properties
    {
        _MainTex ("Texture X", 2D) = "white" {}
        _MainTexY ("Texture Y", 2D) = "white" {}
        _MainTexZ ("Texture Z", 2D) = "white" {}
        _Tiling ("Tiling", Float) = 1.0
        _BlendSharpness ("Blend Sharpness", Range(1, 64)) = 8.0
        [Toggle(_NORMALMAP)] _NormalMapToggle ("Toggle Normal Maps", Float) = 0
        [NoScaleOffset][Normal] _BumpMap ("Normal Map X", 2D) = "bump" {}
        [NoScaleOffset][Normal] _BumpMapY ("Normal Map Y", 2D) = "bump" {}
        [NoScaleOffset][Normal] _BumpMapZ ("Normal Map Z", 2D) = "bump" {}
        _BumpScale ("Normal Scale", Float) = 1.0
        [NoScaleOffset] _SmoothnessMap("Smoothness Map", 2D) = "white" {}
        _Smoothness ("Smoothness strength", Range(0,1))= 0.5
        [NoScaleOffset] _MetallicMap("Metallic Map",2D) = "white" {}
        _Metallic ("Metallic strength", Range(0,1)) = 0 
        _Occlusion("Occlusion strength", Range(0,1)) = 0.1
        _AmbientLight ("Ambient Light", Range(0, 1)) = 0.2
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
        #pragma shader_feature_local _NORMALMAP

        sampler2D _MainTex;
        sampler2D _MainTexY;
        sampler2D _MainTexZ;
        sampler2D _BumpMap;
        sampler2D _BumpMapY;
        sampler2D _BumpMapZ;
        sampler2D _SmoothnessMap;
        sampler2D _MetallicMap;

        float _Tiling;
        float _BlendSharpness;
        float _BumpScale;
        float _Metallic;
        float _Smoothness;
        float _Occlusion;
        float _AmbientLight;

        struct Input
        {
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };

        inline float3 blendWeights(float3 normal)
        {
            float3 weights = pow(abs(normal), _BlendSharpness);
            return weights / (weights.x + weights.y + weights.z);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float3 blend = blendWeights(IN.worldNormal);

            float2 texX = IN.worldPos.yz * _Tiling;
            float2 texY = IN.worldPos.xz * _Tiling;
            float2 texZ = IN.worldPos.xy * _Tiling;

            float4 colX = tex2D(_MainTex, texX);
            float4 colY = tex2D(_MainTexY, texY);
            float4 colZ = tex2D(_MainTexZ, texZ);

            float4 metX = tex2D(_MetallicMap, texX);
            float4 metY = tex2D(_MetallicMap, texY);
            float4 metZ = tex2D(_MetallicMap, texZ);

            float4 smoothX = tex2D(_SmoothnessMap, texX);
            float4 smoothY = tex2D(_SmoothnessMap, texY);
            float4 smoothZ = tex2D(_SmoothnessMap, texZ);

            float4 albedo = colX * blend.x + colY * blend.y + colZ * blend.z;
            float metallic = dot(metX * blend.x + metY * blend.y + metZ * blend.z, float3(0.3, 0.59, 0.11));
            float smooth = dot(smoothX * blend.x + smoothY * blend.y + smoothZ * blend.z, float3(0.3, 0.59, 0.11));

            o.Albedo = albedo.rgb;
            o.Metallic = metallic * _Metallic;
            o.Smoothness = smooth * _Smoothness;
            o.Occlusion = _Occlusion;

            #ifdef _NORMALMAP
                float3 normalX = UnpackNormal(tex2D(_BumpMap, texX)) * _BumpScale;
                float3 normalY = UnpackNormal(tex2D(_BumpMapY, texY)) * _BumpScale;
                float3 normalZ = UnpackNormal(tex2D(_BumpMapZ, texZ)) * _BumpScale;
                float3 normalTS = normalize(normalX * blend.x + normalY * blend.y + normalZ * blend.z);
                o.Normal = normalTS;
            #endif
        }
        ENDCG
    }

    FallBack "Diffuse"
}
