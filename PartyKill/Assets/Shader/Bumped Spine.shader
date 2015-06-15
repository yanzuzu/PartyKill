Shader "Spine/BumpedSkeleton" {
       Properties
       {
       		_MainTex ( "Diffuse Texture", 2D) = "white" {}
       		_NormalDepth ("Normal Depth", 2D) = "bump" {}
       		_SpecGloss ("Specular Gloss", 2D) = "" {}	
       		
       		 _CelShadingLevels ("Cel Shading Levels", Float) = 0		//Set to zero to have no cel shading.
          _CellShadingRamp("Cel shading ramp", Range (0,1.0)) = .5
          _CelSmoothing("Cel smoothing", Range ( 0, 1.0)) = 0.0
          
       		_AboveAmbientColor("Upper Ambient Color", Color) = (0.5,0.5,0.5)
       		_BelowAmbientColor("Lower Ambient Color", Color) = (0.5,0.5,0.5)
       		_AmbientStrength("Ambient Color strength",float) = 1.0
       		
       		_AmbientCelShadingLevels ("Ambient Cel Shading Levels", Float) = 0		//Set to zero to have no cel shading.
          _AmbientCellShadingRamp("Ambient Cel shading ramp", Range (0,1.0)) = .5
          _AmbientCelSmoothing("Ambient Cel smoothing", Range ( 0, 1.0)) = 0.0
       	 	
       	 	_Shininess ("Shininess", Range (1.0,50.0)) = 10.0
       		_LightWrap("Wraparound lighting", Range (0,1.0)) = 0.0	//Higher values of this will cause diffuse light to 'wrap around' and light the away-facing pixels a bit.
			 _AmplifyDepth ("Amplify Depth", Range (0,1.0)) = 0.0	//Affects the 'severity' of the depth map - affects shadows (and shading to a lesser extent).
		//	_TextureRes("Texture Resolution", Vector) = (256, 256, 0, 0)
			
			_DiscardPixelThresHold("Discard Fragement when Alpha is lower", Range(0, 1.0)) = 0.5
			_DiscardPixelThresHold2("Discard Fragement 2nd pass when Alpha is lower", Range(0, 1.0)) = 0.5
			
			
		//	_StartAlphaFallOffAtAlpha("falloff", Range(0, 1.0)) = 0.5
		//	_StartAlphaFallOffAtAlpha2("falloff pass 2", Range(0, 1.0)) = 0.5
       }
       
  SubShader
       {
          
       			
       		Tags {  "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
       		Lighting On 
				
			// first pass
			
       		Pass
       		{
       			Tags{ "LightMode" = "ForwardBase" }
       		
       			
       			ZWrite On Cull Off
       			//AlphaTest Greater 0.5
       			
       			Blend SrcAlpha OneMinusSrcAlpha
       			 
       			CGPROGRAM
       				
       			#pragma vertex vert
       			#pragma fragment frag
       			
       			#pragma target 3.0
       			
       			#include "UnityCG.cginc"
       			
       			uniform sampler2D _MainTex;
       			uniform sampler2D _NormalDepth;
       			uniform fixed4 _AboveAmbientColor;			
       			uniform fixed4 _BelowAmbientColor;
       			uniform fixed4 _MainTex_ST;
       			uniform half _DiscardPixelThresHold;
       			uniform float4 _LightColor0; 
       			uniform half _AmbientStrength ;
       			uniform fixed _StartAlphaFallOffAtAlpha;
       			uniform float _AmbientCelShadingLevels;
            	uniform float _AmbientCelShadingRamp;
             	uniform float _AmbientCelSmoothing; 
       			
       			struct VertexInput	
       			{
       				half4 vertex : POSITION;
       				fixed4 color : COLOR;
       				fixed2 uv : TEXCOORD0;
       						
       				fixed4 tangent : TANGENT;  
            		//float3 normal : Normal;
            		 //out float3 oNormal   : TEXCOORD2,
	            	fixed4 texcoord1 : TEXCOORD1; 
       			
       			};
       			
       			struct VertexOutput
            	{
	                half4 pos : POSITION;
	                fixed4 color : COLOR;
	                
	                //float3 normal : Normal;
	                fixed2 uv : TEXCOORD0;
	                
	                half4 posWorld : TEXCOORD1;
                	fixed4 info : TEXCOORD2;
                	float3 normalDir : TEXCOORD3;
                	float3 vertexLighting : TEXCOORD4;
                	//float3 normalDir : TEXCOORD5;
	              
            	};

       			
       			VertexOutput vert(VertexInput input)
       			{
       				VertexOutput output;
       				
       				output.pos	 = mul(UNITY_MATRIX_MVP, input.vertex);
       				output.uv 	 = TRANSFORM_TEX(input.uv, _MainTex);
       				output.color = input.color;
       				
       				output.posWorld = mul(_Object2World, input.vertex);
       				output.info.x = input.tangent.x;
		        	output.info.y = input.tangent.y;
		        	output.info.z = input.tangent.z;
		        	output.info.w = input.tangent.w;
		        	output.normalDir =  float3(0,0,-1);
		     
       				return output;
       				
       			}
       			
       			half4 frag( VertexOutput input) : COLOR
       			{
       				half4 diffuseColor = tex2D(_MainTex, input.uv);
       				
       				
	            	if(diffuseColor.a == 0 || diffuseColor.a < _DiscardPixelThresHold){
               				
               				discard;
               				return 0 ;
               		}
       				fixed3 normalDirection = (tex2D(_NormalDepth, input.uv).xyz * 2.0f) - 1.0f;
				
				//rotation matrix
					half angle = -input.info.x;
					half scale = input.info.y;
					half4x4 rotMatrix = float4x4(cos(angle) * scale,  -sin(angle) * scale,  0, 0, 
												  sin(angle) * scale,	cos(angle) * scale, 	 0, 0, 
												  0, 			0, 			 1, 0, 
												  0, 			0, 			 0, 1);
										  					  				  
					normalDirection = fixed3(mul(float4(normalDirection, 1.0f), mul(rotMatrix, _World2Object)));
					normalDirection.z *= -1;
					normalDirection = normalize(normalDirection);
       				
       				fixed upness = normalDirection.y * 0.5 + 0.5; //'upness' - 1.0 means the normal is facing straight up,
       				
       				if (_AmbientCelShadingLevels >= 2.0)
                	{
                		float storeUpness = upness;
                		float celshadingInterval = 1.0/(_AmbientCelShadingLevels - _AmbientCelShadingRamp);
                    	upness = floor(upness/celshadingInterval) * celshadingInterval ;
                    
                     	float smoothStepCel = smoothstep(upness - celshadingInterval, upness + celshadingInterval,
                      									storeUpness);
                    
                    	if(_AmbientCelSmoothing > 0 && smoothStepCel > 1.0- _AmbientCelSmoothing){
                    
	                    	float smoothing= 0;
	                    	
	           		     	if(smoothStepCel > 1.0- _AmbientCelSmoothing)
	                    	{
	                    		
	                    		smoothing = smoothstep( upness + celshadingInterval - celshadingInterval * _AmbientCelSmoothing, upness + celshadingInterval, 
	                    		     storeUpness);
	                    		upness = lerp(upness ,upness + celshadingInterval, smoothing);
	                    		
	                    	}        
                    	}
                	}
       				
       				
       				fixed4 ambientColor = (_BelowAmbientColor * (1.0 - upness) + _AboveAmbientColor * upness);
       				
       				half3 ambientReflection =  ambientColor * _AmbientStrength;      			       			       			       			       			       					       			
		            fixed3 diffuseReflection =  diffuseColor.rgb * input.color.rgb * ambientReflection;
		            
		            fixed alpha =  diffuseColor.a;
		            
		            //if(alpha < _StartAlphaFallOffAtAlpha)
              		//{
              		//alpha = alpha + ( -2 * alpha* alpha);
              			
              	//	}
              		
              		alpha = smoothstep(0.5, 0.9 , alpha) * alpha;
       				
       				fixed4 col = fixed4( diffuseReflection , alpha );
       				return col;
       			
       			}
       			ENDCG
       		}
       		
       		

			// light pass
			Pass
           {
            	Tags { "LightMode" = "ForwardAdd" }
        
        
        		ZWrite Off Cull Off
        		//Offset 0, -0.1
            	Blend SrcAlpha  One
              
              
               CGPROGRAM
               
               	#pragma multi_compile_lightpass
              	 #pragma vertex vert  
            	#pragma fragment frag 
				#pragma target 3.0
				
			
                #pragma fragmentoption ARB_precision_hint_fastest
               
				#include "UnityCG.cginc"
				
				 uniform float4 _LightColor0; 
		            // color of light source (from "Lighting.cginc".)
				uniform float4x4 _LightMatrix0; // transformation 
		            // from world to light space (from Autolight.cginc)
		         #if defined (DIRECTIONAL_COOKIE) || defined (SPOT)
		            uniform sampler2D _LightTexture0; 
					uniform sampler2D _LightTextureB0; 

		               // cookie alpha texture map (from Autolight.cginc)
		         #elif defined (POINT_COOKIE) || defined (POINT)
		            uniform samplerCUBE _LightTexture0; 	
					uniform sampler2D _LightTextureB0; 

		               // cookie alpha texture map (from Autolight.cginc)
		         #endif
 
			
			  
				uniform sampler2D _MainTex;
	            uniform sampler2D _NormalDepth;
	            uniform sampler2D _SpecGloss;
	          	
	            uniform float _Shininess;
	            uniform float _AmplifyDepth;
	            uniform float _LightWrap;
	            uniform float4 _TextureRes;
	            uniform float4 _MainTex_ST;	             	       			
	            uniform float _DiscardPixelThresHold2;
	            
	            uniform fixed _StartAlphaFallOffAtAlpha2;
	            
	            uniform float _CelShadingLevels;
            uniform float _CellShadingRamp;
           uniform float _CelSmoothing;
	             
               struct VertexInput
	            {
	               	half4 vertex : POSITION;
       				fixed4 color : COLOR;
       				fixed2 uv : TEXCOORD0;
       				
       				fixed4 tangent : TANGENT;  
            		//fixe//d3 normal : NORMAL;
            		fixed4 texcoord1 : TEXCOORD1; 
            		 
       			
	            };

	            struct VertexOutput
	            {      
	            
	            	half4 pos :SV_POSITION;
	            	
	                fixed4 color : COLOR;
	                fixed2 uv : TEXCOORD0;
	                
	                half4 posWorld : TEXCOORD1;
	                half4 posLight : TEXCOORD2;
	                //float3 normalDir : TEXCOORD3;
                	fixed4 info : TEXCOORD3;
                	float3 _LightCoord : TEXCOORD4;
	              //	LIGHTING_COORDS(4,5) 
	              	
	            };
			
				 VertexOutput vert(VertexInput v)
	            {
	                VertexOutput output;
					
					
					 float4x4 modelMatrix = _Object2World;
           			 float4x4 modelMatrixInverse = _World2Object; 
             
 
            		output.posWorld = mul(modelMatrix, v.vertex);
            		output.posLight = mul(_LightMatrix0, output.posWorld);
           		 	//output.normalDir = normalize(float3( mul(float4(input.normal, 0.0), modelMatrixInverse)));

	                output.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	                output.uv 	 = TRANSFORM_TEX(v.uv, _MainTex);
	                output.color = v.color;
	                
	                output.info.x = v.tangent.x;
			        output.info.y = v.tangent.y;
			        output.info.z = v.tangent.z;
			        output.info.w = v.tangent.w;
			        output._LightCoord = mul(_LightMatrix0, mul(modelMatrix, v.vertex)).xyz;
				
			        
			       
			       
	                return output;
	            }
	            
            
	            fixed4 frag(VertexOutput input) : COLOR
	            {
	            	fixed4 diffuseColor = tex2D(_MainTex, input.uv);
					fixed4 normalDepth = tex2D(_NormalDepth, input.uv);		
	            	fixed4 specGlossValues = tex2D(_SpecGloss, input.uv);
	            	
	   
	            	if(diffuseColor.a == 0 || normalDepth.a == 0 || diffuseColor.a < _DiscardPixelThresHold2){
               				
               				discard;
               				return 0 ;
               		}
	            	
	            	
	         
	            	fixed3 normalDirection = (tex2D(_NormalDepth, input.uv).xyz * 2.0f) - 1.0f;
				
				//rotation matrix
					half angle = -input.info.x;
					half scale = input.info.y;
					half4x4 rotMatrix = float4x4(cos(angle) * scale,  -sin(angle) * scale,  0, 0, 
											  sin(angle) * scale,	cos(angle) * scale, 	 0, 0, 
											  0, 			0, 			 1, 0, 
											  0, 			0, 			 0, 1);
										  					  				  
					normalDirection = float3(mul(float4(normalDirection, 1.0f), mul(rotMatrix, _World2Object)));
					normalDirection.z *= -1;
					normalDirection = normalize(normalDirection);
					
					fixed depthColour = normalDepth.a;
					fixed2 positionOffset = input.uv;
                	fixed2 roundedUVs = input.uv;
               		
               		roundedUVs *= _TextureRes.xy;
               	 	roundedUVs = floor(roundedUVs);
               		roundedUVs /= _TextureRes.xy;
               		
               		
                	
               // 	positionOffset = roundedUVs * 2.0 - 1.0;
               //	positionOffset *= _TextureRes.xy;
               // positionOffset *= 0.005;	//Apologies for the magic number - based on how Unity2D seems to relate a sprite's pixels to its world position.
                
             //   	half4 posWorld = float4(mul(_Object2World, float4(positionOffset.x, positionOffset.y, 0.0, 1.0)));	//And then translate/rotate/scale.


					fixed3 viewDirection = normalize( _WorldSpaceCameraPos - float3(input.posWorld));
					fixed3 lightDirection;
           			half attenuation = 1.0;
           			
           			half4 posWorld = input.posWorld;
					posWorld.z -= depthColour * _AmplifyDepth;
            
            		#if defined (DIRECTIONAL) || defined (DIRECTIONAL_COOKIE)
		               lightDirection = normalize(fixed3(_WorldSpaceLightPos0));
		            #elif defined (POINT_NOATT)
		               lightDirection = normalize(fixed3(_WorldSpaceLightPos0 - posWorld));
		            #elif defined(POINT)||defined(POINT_COOKIE)||defined(SPOT)
		               fixed3 vertexToLightSource = 
		               fixed3(_WorldSpaceLightPos0 - input.posWorld);
		               
					
                  		lightDirection = normalize(vertexToLightSource);
                  
                  #endif
                  		
                  #if defined(SPOT)
                  
                  		 float distance = input.posLight.z; 
               			attenuation = tex2D(_LightTextureB0, float2(distance)).a;
               			
               		#elif defined(POINT) ||defined(POINT_COOKIE)
               			float distance = length(vertexToLightSource);
               		
						attenuation = tex2D(_LightTextureB0, dot(input._LightCoord,input._LightCoord).rr).UNITY_ATTEN_CHANNEL;
               		
               		#endif
               			
		               
		            




               	   	
               	   	
               	   	half aspectRatio = _TextureRes.x / _TextureRes.y;
               	   	     //We calculate shadows here. Magic numbers incoming (FIXME).
	                fixed shadowMult = 1.0;
	                half3 moveVec = lightDirection.xyz * 0.006 * half3(1.0, aspectRatio, -1.0);
	                half thisHeight = depthColour * _AmplifyDepth;
	               
	                half3 tapPos = half3(roundedUVs, thisHeight + 0.1);
	                //This loop traces along the light ray and checks if that ray is inside the depth map at each point.
	                //If it is, darken that pixel a bit.
	                for (int i = 0; i < 8; i++)
					{
						tapPos += moveVec;
						half tapDepth = tex2D(_NormalDepth, tapPos.xy).a * _AmplifyDepth;
						if (tapDepth > tapPos.z)
						{
							shadowMult -= 0.125;
						}
					}
	                shadowMult = clamp(shadowMult, 0.0, 1.0);
	                
	               	half normalDotLight = dot(normalDirection, lightDirection);
                
                	//Slightly awkward maths for light wrap.
	               	half diffuseLevel =  clamp(normalDotLight + _LightWrap, 0.0, _LightWrap + 1.0) / (_LightWrap + 1.0) 
	               								* attenuation  * shadowMult;
	                
	                // Compute specular part of lighting
	                half specularLevel;
	                if (normalDotLight < 0.0)
	                {
	                    // Light is on the wrong side, no specular reflection
	                    specularLevel = 0.0;
	                }
	                else
	                {
	                	 half3 viewDirection = half3(0.0, 0.0, -1.0);
                    	specularLevel = attenuation * pow(max(0.0, dot(reflect(-lightDirection, normalDirection),
                        viewDirection)), _Shininess * specGlossValues.a);
                	}
                	
                	if (_CelShadingLevels >= 2.0)
               		{
                		float storeDiffuse = diffuseLevel;
                		float celshadingInterval = 1.0/(_CelShadingLevels - _CellShadingRamp);
                    	diffuseLevel = floor(diffuseLevel/celshadingInterval) * celshadingInterval ;
                    
                     	float smoothStepCel = smoothstep(diffuseLevel - celshadingInterval, diffuseLevel + celshadingInterval,
                      								storeDiffuse);
                    
	                    if(_CelSmoothing > 0 && smoothStepCel > 1.0- _CelSmoothing){
	                    
	                    	float smoothing= 0;
	                    	
	           		     	if(smoothStepCel > 1.0- _CelSmoothing)
	                    	{
	                    		
	                    		smoothing = smoothstep( diffuseLevel + celshadingInterval - celshadingInterval * _CelSmoothing, diffuseLevel + celshadingInterval, 
	                    		     storeDiffuse);
	                    		diffuseLevel = lerp(diffuseLevel ,diffuseLevel + celshadingInterval, smoothing);
	                    		
	                    	}
	                    	
	                    	
	                    
	                    }
                  //  diffuseLevel = smoothstep(diffuseLevel - (1.0/(_CelShadingLevels - _CellShadingRamp)), diffuseLevel + (1.0/(_CelShadingLevels - _CellShadingRamp)),storeDiffuse) * (diffuseLevel  + (1.0/(_CelShadingLevels - _CellShadingRamp)));
                    
                   // floor(diffuseLevel * _CelShadingLevels) / (_CelShadingLevels - 0.5);
	                  	float  storeSpec = specularLevel;
	                    specularLevel = floor(specularLevel/celshadingInterval) * celshadingInterval ;
	                    
	                    
	                    
	                     smoothStepCel = smoothstep(specularLevel - celshadingInterval, specularLevel + celshadingInterval,
	                      storeSpec);
	                    
	                    if(_CelSmoothing > 0 && smoothStepCel > 1.0- _CelSmoothing){
	                    
	                    	float smoothing= 0;
	                    	
	           		     	if(smoothStepCel > 1.0- _CelSmoothing)
	                    	{
	                    		
	                    		smoothing = smoothstep( specularLevel + celshadingInterval - celshadingInterval * _CelSmoothing, specularLevel + celshadingInterval, 
	                    		     storeSpec);
	                    		specularLevel = lerp(specularLevel ,specularLevel + celshadingInterval, smoothing);
	                    		
	                    	}
	                    	
	                    	
	                    
	                    }
                    
                    
                	}

                	

	                //The easy bits - assemble the final values based on light and map colours and combine.
                	fixed3 diffuseReflection = fixed3(diffuseColor) * input.color * fixed3(_LightColor0) * diffuseLevel;
                	fixed3 specularReflection = fixed3(_LightColor0) * input.color * specularLevel * specGlossValues.rgb;
                                	
                	fixed3 reflection = fixed3(diffuseReflection + specularReflection);
              		
              		 fixed cookieAttenuation = 1.0; 
		               // by default no cookie attenuation
		            #if defined (DIRECTIONAL_COOKIE)
		               cookieAttenuation = tex2D(_LightTexture0, float2(input.posLight)).a;
		               
		            #elif defined (POINT_COOKIE)
		               cookieAttenuation = texCUBE(_LightTexture0, float3(input.posLight)).a;
		            #elif defined (SPOT)
		               cookieAttenuation = tex2D(_LightTexture0, float2(input.posLight) / input.posLight.w + float2(0.5)).a;
		            #endif
		              		
              		float alpha = diffuseColor.a;
              		
              		alpha = smoothstep( 0.3, 1,  alpha);
              	//	if(alpha < _StartAlphaFallOffAtAlpha2 )
              	//	{
              	//		alpha = max(0,alpha + ( -2*  alpha * alpha) );
              			
              	//	}
              		fixed4 col = fixed4(cookieAttenuation * reflection , alpha);
              		
              	
              		
                 return col;
               	  
	            }
       		 	ENDCG
      		}
      		
      	}	
     		
      	
       FallBack "Transparent/VertexLit"
}

