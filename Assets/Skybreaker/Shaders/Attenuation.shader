// Upgrade NOTE: replaced 'PositionFog()' with multiply of UNITY_MATRIX_MVP by position
// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'

Shader "Custom/Attenuation" {
	Properties {
	    _Color ("Main Color", Color) = (1,1,1,0.5)
	}



    // Fragment program cards
    #warning Upgrade NOTE: SubShader commented out; uses Unity 2.x per-pixel lighting. You should rewrite shader into a Surface Shader.
/*SubShader {
        
        Pass { 
            Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase 
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			// Define the structure
			struct v2f {
			    float4 pos : SV_POSITION;
			    LIGHTING_COORDS // <= note no semicolon!
			    float4 color : COLOR0;
			};

			// Vertex program
			v2f vert (appdata_base v)
			{
			    v2f o;
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);

			    // compute a simple diffuse per-vertex
			    float3 ldir = normalize( ObjSpaceLightDir( v.vertex ) );
			    float diffuse = dot( v.normal, ldir );
			    o.color = diffuse * _ModelLightColor0;

			    // compute&pass data for attenuation/shadows
			    TRANSFER_VERTEX_TO_FRAGMENT(o);
			    return o;
			}

			// Fragment program
			float4 frag (v2f i) : COLOR
			{
			    // Just multiply interpolated color with attenuation
			    return i.color * LIGHT_ATTENUATION(i) * 2;
			}
			ENDCG
        }
    }*/

Fallback "VertexLit"
}