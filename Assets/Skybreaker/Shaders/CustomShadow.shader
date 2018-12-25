Shader "Custom/CustomShadow" {
    Properties {
        _ColorA ("Color A", Color) = (1,1,0,1)       
        _ColorB ("Color B", Color) = (0,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
       
        CGPROGRAM
        #include "AutoLight.cginc"
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
            LIGHTING_COORDS(1,2) 
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _ColorA;
        fixed4 _ColorB;

        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _ColorA;
            float atten = SHADOW_ATTENUATION(IN);
            o.Albedo = (1.0-atten)*_ColorA + atten*_ColorB;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}