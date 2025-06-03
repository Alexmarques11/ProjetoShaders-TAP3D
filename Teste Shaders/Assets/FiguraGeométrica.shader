Shader "Unlit/FiguraGeométrica"
{
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SliderX ("Center X", Range(0, 1)) = 0.5
        _SliderY ("Center Y", Range(0, 1)) = 0.5
        _RadiusX ("Radius X", Range(0, 0.5)) = 0.15
        _RadiusY ("Radius Y", Range(0, 0.5)) = 0.1
        _TintColor ("Tint Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

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

            bool isInsideEllipse(float2 centroXY, float2 radii, float2 pontoATestar)
            {
                float2 delta = pontoATestar - centroXY;
                float normalizedX = delta.x / radii.x;
                float normalizedY = delta.y / radii.y;
                return (normalizedX * normalizedX + normalizedY * normalizedY) <= 1.0;
            }

            sampler2D _MainTex;
            float _SliderY;
            float _SliderX;
            float _RadiusX;
            float _RadiusY;
            fixed4 _TintColor;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 center = float2(_SliderX, _SliderY);
                
                float aspectRatio = _ScreenParams.x / _ScreenParams.y;
                float2 adjustedUV = float2(uv.x * aspectRatio, uv.y);
                float2 adjustedCenter = float2(center.x * aspectRatio, center.y);
                float2 adjustedRadii = float2(_RadiusX * aspectRatio, _RadiusY);

                if (!isInsideEllipse(adjustedCenter, adjustedRadii, adjustedUV))
                {
                    return float4(1, 0, 0, 1);
                }

                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}