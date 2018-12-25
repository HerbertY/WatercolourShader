// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Custom/DuotoneShadows"
{
    Properties
    {
        //[NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        
		_Color ("Tint Color 1", Color) = (1,1,1,1)
		_Color2 ("Tint Color 2", Color) = (1,1,1,1)
		_InkCol ("Ink Color", Color) = (1,1,1,1)
		
		_BlotchTex ("Blotches (RGB)", 2D) = "white" {}
		_DetailTex ("Detail (RGB)", 2D) = "white" {}
		_PaperTex ("Paper (RGB)", 2D) = "white" {}
		_RampTex ("Ramp (RGB)", 2D) = "white" {}
		
		_TintScale ("Tint Scale", Range(2,32)) = 4
		_PaperStrength ("Paper Strength", Range(0,1)) = 1
		_BlotchMulti ("Blotch Multiply", Range(0,8)) = 4
		_BlotchSub ("Blotch Subtract", Range(0,8)) = 2
    }
    SubShader
    {
    	
    	
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            //Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma multi_compile_fwdadd_fullshadows
            // shadow helper functions and macros
            #include "AutoLight.cginc"            

            sampler2D _BlotchTex;
			sampler2D _DetailTex;
			sampler2D _PaperTex;
			sampler2D _RampTex;
			
            float4 _BlotchTex_ST;
			float4 _DetailTex_ST;
			float4 _PaperTex_ST;
			//float4 _RampTex_ST;
			half _Glossiness;
			half _Metallic;
			half _BlotchMulti;
			half _BlotchSub;
			half _TintScale;
			half _PaperStrength;
			fixed4 _Color;
			fixed4 _Color2;
			fixed4 _InkCol;
			
	// sampler2D unity_Lightmap;
	// float4 unity_LightmapST;

            struct v2f
            {
                //float2 uv : TEXCOORD0;
                //SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                
                LIGHTING_COORDS(0,1)
                
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
                float4 pos : SV_POSITION;
                
				float2 uv_BlotchTex : TEXCOORD2;
				float2 uv_DetailTex : TEXCOORD3;
				float2 uv_PaperTex : TEXCOORD4;
				float2 uv_Lightmap : TEXCOORD5;
            };
            
            struct appdata_lightmap {
		        float4 vertex : POSITION;
				float3 normal : NORMAL;
		        float2 texcoord : TEXCOORD0;
		        float2 texcoord1 : TEXCOORD1;
		      };
            
            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv_BlotchTex = TRANSFORM_TEX(v.texcoord, _BlotchTex);
                o.uv_DetailTex = TRANSFORM_TEX(v.texcoord, _DetailTex);
                o.uv_PaperTex = TRANSFORM_TEX(v.texcoord, _PaperTex);
				o.uv_Lightmap = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                
                return o;
            }
			
			fixed4 screen (fixed4 colA, fixed4 colB)
			{
				fixed4 white = (1,1,1,1);
				return white - (white-colA) * (white-colB);
			}
			fixed4 softlight (fixed4 colA, fixed4 colB)
			{
				fixed4 white = (1,1,1,1);
				return (white-2*colB)*pow(colA, 2) + 2*colB*colA;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col; // = tex2D(_MainTex, i.uv);
                
                
                fixed c = 0.5f*(tex2D (_DetailTex, i.uv_DetailTex).r + tex2D (_BlotchTex, i.uv_BlotchTex).r);	
                fixed shadow = LIGHT_ATTENUATION(i);
                //return shadow;
                fixed3 lighting = 1.0f - shadow; // clamp (i.diff * shadow + i.ambient, 0.0, 1.0);
				//lighting = 1.0f - DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv_Lightmap)).r;
                c += (lighting-0.75)*3;
                
				
				//return c;				
				c = tex2D (_RampTex, half2(c, 0)).r;
				c = saturate(c);
				
				fixed4 tint = tex2D (_BlotchTex, i.uv_BlotchTex / _TintScale);	
				tint = lerp(_Color, _Color2, tint.r);
				
				fixed4 ink = screen(_InkCol, fixed4(c,c,c,1) );
				col = lerp(ink * tint, softlight(tex2D (_PaperTex, i.uv_PaperTex), ink * tint), _PaperStrength);
                
               
                
                return col;
            }
            ENDCG
        }

        // shadow casting support
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}