//All: 8.3 ms
//No flowmap: 5.6 ms
//Pervertex aniso: 6 ms
//Pervertex baked aniso: 7.8 ms

//From now on: all - flowmap:
//Caustics off: 5.1 ms
//Foam off: 4.9 ms
//Calc normals off: 3.6 ms
//Refractions off: 3.0 ms


Shader "Water+/Desktop" {

Properties {
	_MainTex("Main texture", 2D) = "bump" {}
	_NormalMap("Normalmap", 2D) = "bump" {}
	//_FoamTex("Seafoam texture", 2D) = "white" {}
	//_HeightGlossMap ("Height(R), Gloss(G)", 2D) = "white" { }
	_DUDVFoamMap ("DUDV(RG) Foam(B)", 2D) = "white" { }	//All the stuff affected by flowmaps goes in here
	_Cube ("Cubemap", CUBE) = "" {}
	_WaterMap ("Depth (R), Foam (G), Transparency(B) Refr strength(A)", 2D) = "white" {}
	//_RefractionMap ("Refraction map", 2D) = "white" {}
	_SecondaryRefractionTex("Refraction texture", 2D) = "bump" {}
	//_RefractionTileTexture ("Refraction tile texture", 2D) = "white" {}
	_FlowMap ("Flowmap (RG)", 2D) = "white" {}
	_AnisoMap ("AnisoDir(RGB), AnisoLookup(A)", 2D) = "bump" {}
	_CausticsAnimationTexture ("Caustics animation", 2D) = "white" {}
	_Reflectivity("Reflectivity", Range (.0, 1.0)) = .3
	_Refractivity("Refractivity", Range (1.0, 5.0)) = 1.0
	_WaterAttenuation("Water attenuation", Range (0.0, 2.0)) = 1.0
	_ShallowWaterTint("Shallow water wint", Color) = (.0, .26, .39, 1.0)
	_DeepWaterTint("Deep water tint", Color) = (.0, .26, .39, 1.0)
	//_DeepWaterCoefficient("DeepWaterCoefficient", Range(1.0, 10.0) ) = 5.0
	_Shininess ("Shininess", Range (.05, 20.0)) = 1.0
	_Gloss("Gloss", Range(0.0, 20.0)) = 10.0
	_Fresnel0 ("fresnel0", Float) = 0.1
	_EdgeFoamStrength ("Edge foam strength", Range (.0, 3.0) ) = 1.0
	//_EdgeBlendStrength ("Edge blend strength", Range (10.0, 100.0) ) = 50.0
	////////////////////////
	
	_CausticsStrength ("Caustics strength", Range (0.05, 0.3) ) = 0.1
	_CausticsScale ("Caustics scale", Range (10.0, 2000.0) ) = 500.0
	
	_normalStrength("Normal strength",  Range (.01, 5.0)) = .5
	_refractionsWetness("Refractions wetness", Range (.0, 1.0)) = .8
	
	//All of the following is provided by script:
	//_yOffset ("internal yOffset", Float) = .0									//Provided by script
	flowMapOffset0 ("internal FlowMapOffset0", Float) = 0.0						//Provided by script
	flowMapOffset1 ("internal FlowMapOffset1", Float) = 0.5						//Provided by script
	halfCycle ("internal HalfCycle", Float) = 0.25								//Provided by script
	//flowTide ("internal FlowTide", Float) = 0.0									//Provided by script
	//anisoDirAnimationOffset("internal Aniso dir animation offset", Vector) = (.0, .0, .0, .0)
	causticsOffsetAndScale("internal caustics animation offset and scale", Vector) = (.0, .0, .25, .0)
	causticsAnimationColorChannel("internal caustics animation color channel", Vector) = (1.0, .0, .0, .0)
	//anisoAnimationOffset("Anisotropic animation offset", Float) = 0.0	//Provided by script
}

	Category {
		Tags {"Queue"="Transparent-10" "IgnoreProjector"="True" "LightMode" = "ForwardBase" "ForceNoShadowCasting" = "True"}
		Lighting on
	    
	
		 SubShader {
		 //GrabPass { }
		 
		 	Pass {
				ZWrite Off
			    Blend SrcAlpha OneMinusSrcAlpha
			    
				Program "vp" {
// Vertex combos: 2
//   d3d9 - ALU: 15 to 15
SubProgram "opengl " {
Keywords { "FLOWMAP_ANIMATION_ON" }
"!!GLSL
#ifdef VERTEX
varying vec2 xlv_TEXCOORD6;
varying vec3 xlv_TEXCOORD3;
varying vec3 xlv_TEXCOORD2;
varying vec2 xlv_TEXCOORD1;
varying vec2 xlv_TEXCOORD0;
uniform vec4 _SecondaryRefractionTex_ST;
uniform vec4 _WaterMap_ST;
uniform vec4 _MainTex_ST;
uniform mat4 _Object2World;

uniform vec4 _WorldSpaceLightPos0;
uniform vec3 _WorldSpaceCameraPos;
void main ()
{
  gl_Position = (gl_ModelViewProjectionMatrix * gl_Vertex);
  xlv_TEXCOORD0 = ((gl_MultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = ((gl_MultiTexCoord0.xy * _WaterMap_ST.xy) + _WaterMap_ST.zw);
  xlv_TEXCOORD2 = (_WorldSpaceCameraPos - (_Object2World * gl_Vertex).xyz);
  xlv_TEXCOORD3 = normalize((_WorldSpaceLightPos0.xyz - ((_Object2World * gl_Vertex).xyz * _WorldSpaceLightPos0.w)));
  xlv_TEXCOORD6 = ((gl_MultiTexCoord0.xy * _SecondaryRefractionTex_ST.xy) + _SecondaryRefractionTex_ST.zw);
}


#endif
#ifdef FRAGMENT
varying vec2 xlv_TEXCOORD6;
varying vec3 xlv_TEXCOORD3;
varying vec3 xlv_TEXCOORD2;
varying vec2 xlv_TEXCOORD1;
varying vec2 xlv_TEXCOORD0;
uniform vec4 causticsAnimationColorChannel;
uniform vec3 causticsOffsetAndScale;
uniform sampler2D _CausticsAnimationTexture;
uniform float _CausticsScale;
uniform float _CausticsStrength;
uniform float _Fresnel0;
uniform float _Gloss;
uniform float _Shininess;
uniform vec3 _ShallowWaterTint;
uniform vec3 _DeepWaterTint;
uniform float _WaterAttenuation;
uniform float _Reflectivity;
uniform samplerCube _Cube;
uniform sampler2D _NormalMap;
uniform float _normalStrength;
uniform float halfCycle;
uniform float flowMapOffset1;
uniform float flowMapOffset0;
uniform sampler2D _FlowMap;
uniform float _Refractivity;
uniform float _refractionsWetness;
uniform vec4 _SecondaryRefractionTex_ST;
uniform sampler2D _SecondaryRefractionTex;
uniform sampler2D _WaterMap;
uniform sampler2D _DUDVFoamMap;
uniform float _EdgeFoamStrength;
uniform vec4 _LightColor0;

void main ()
{
  vec4 outColor_1;
  vec4 tmpvar_2;
  tmpvar_2 = texture2D (_WaterMap, xlv_TEXCOORD1);
  vec3 tmpvar_3;
  tmpvar_3 = normalize(xlv_TEXCOORD2);
  vec2 tmpvar_4;
  tmpvar_4 = ((texture2D (_FlowMap, xlv_TEXCOORD1).xy * 2.0) - 1.0);
  float tmpvar_5;
  tmpvar_5 = sqrt(dot (tmpvar_4, tmpvar_4));
  float tmpvar_6;
  tmpvar_6 = (abs((halfCycle - flowMapOffset0)) / halfCycle);
  vec3 pNormal_7;
  vec3 normal_8;
  normal_8.xy = ((texture2D (_NormalMap, (xlv_TEXCOORD0 + (tmpvar_4 * flowMapOffset0))).wy * 2.0) - 1.0);
  normal_8.z = sqrt(((1.0 - (normal_8.x * normal_8.x)) - (normal_8.y * normal_8.y)));
  vec3 normal_9;
  normal_9.xy = ((texture2D (_NormalMap, (xlv_TEXCOORD0 + (tmpvar_4 * flowMapOffset1))).wy * 2.0) - 1.0);
  normal_9.z = sqrt(((1.0 - (normal_9.x * normal_9.x)) - (normal_9.y * normal_9.y)));
  vec3 tmpvar_10;
  tmpvar_10 = mix (normal_8, normal_9, vec3(tmpvar_6));
  pNormal_7.xy = tmpvar_10.xy;
  pNormal_7.z = (tmpvar_10.z / max (tmpvar_5, 0.1));
  pNormal_7.z = (pNormal_7.z / _normalStrength);
  vec3 tmpvar_11;
  tmpvar_11 = normalize(pNormal_7);
  pNormal_7 = tmpvar_11;
  vec3 tmpvar_12;
  tmpvar_12.x = -(tmpvar_11.x);
  tmpvar_12.y = tmpvar_11.z;
  tmpvar_12.z = -(tmpvar_11.y);
  float tmpvar_13;
  tmpvar_13 = clamp ((tmpvar_2.x * _WaterAttenuation), 0.0, 1.0);
  vec3 tmpvar_14;
  tmpvar_14 = mix (texture2D (_DUDVFoamMap, (xlv_TEXCOORD0 + (tmpvar_4 * flowMapOffset0))), texture2D (_DUDVFoamMap, (xlv_TEXCOORD0 + (tmpvar_4 * flowMapOffset1))), vec4(tmpvar_6)).xyz;
  vec2 tmpvar_15;
  tmpvar_15 = ((((tmpvar_14.xy * 2.0) - vec2(1.0, 1.0)) * _Refractivity) / 100000.0);
  vec4 tmpvar_16;
  tmpvar_16 = texture2D (_CausticsAnimationTexture, ((fract(((xlv_TEXCOORD1 + tmpvar_15) * _CausticsScale)) * causticsOffsetAndScale.zz) + causticsOffsetAndScale.xy));
  vec3 i_17;
  i_17 = -(tmpvar_3);
  float tmpvar_18;
  tmpvar_18 = dot (tmpvar_12, tmpvar_3);
  vec3 tmpvar_19;
  tmpvar_19 = normalize(((tmpvar_12.yzx * xlv_TEXCOORD3.zxy) - (tmpvar_12.zxy * xlv_TEXCOORD3.yzx)));
  float tmpvar_20;
  tmpvar_20 = dot (xlv_TEXCOORD3, tmpvar_19);
  float tmpvar_21;
  tmpvar_21 = dot (tmpvar_3, tmpvar_19);
  float tmpvar_22;
  tmpvar_22 = max (0.0, ((_Fresnel0 + ((1.0 - _Fresnel0) * pow ((1.0 - tmpvar_18), 5.0))) - 0.1));
  float tmpvar_23;
  tmpvar_23 = (((((pow (((sqrt((1.0 - (tmpvar_20 * tmpvar_20))) * sqrt((1.0 - (tmpvar_21 * tmpvar_21)))) - (tmpvar_20 * tmpvar_21)), (_Shininess * 128.0)) * _Gloss) * (max (0.0, tmpvar_18) * max (0.0, dot (tmpvar_12, xlv_TEXCOORD3)))) * max (sign(dot (tmpvar_3, -(xlv_TEXCOORD3))), 0.0)) * _LightColor0.xyz).x * tmpvar_22);
  outColor_1.xyz = ((((mix (mix (mix (((texture2D (_SecondaryRefractionTex, (xlv_TEXCOORD6 + (tmpvar_15 * _SecondaryRefractionTex_ST.x))).xyz * _refractionsWetness) + (((((causticsAnimationColorChannel.x * tmpvar_16.x) + (causticsAnimationColorChannel.y * tmpvar_16.y)) + (causticsAnimationColorChannel.z * tmpvar_16.z)) * _CausticsStrength) * (1.0 - tmpvar_13))), mix (_ShallowWaterTint, _DeepWaterTint, vec3(tmpvar_13)), vec3(clamp ((max (tmpvar_13, (tmpvar_2.w * 0.5)) * 0.8), 0.0, 1.0))), textureCube (_Cube, (i_17 - (2.0 * (dot (tmpvar_12, i_17) * tmpvar_12)))).xyz, vec3(clamp (tmpvar_22, 0.0, _Reflectivity))), tmpvar_14.zzz, vec3(clamp ((max ((tmpvar_2.y * _EdgeFoamStrength), ((tmpvar_5 * tmpvar_14.z) * 0.5)) * tmpvar_14.z), 0.0, 1.0))) * _LightColor0.xyz) + ((tmpvar_23 * tmpvar_23) * 10.0)) * 2.0) + gl_LightModel.ambient.xyz);
  outColor_1.w = tmpvar_2.z;
  gl_FragData[0] = outColor_1;
}


#endif
"
}

SubProgram "d3d9 " {
Keywords { "FLOWMAP_ANIMATION_ON" }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Vector 9 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Vector 10 [_MainTex_ST]
Vector 11 [_WaterMap_ST]
Vector 12 [_SecondaryRefractionTex_ST]
"vs_3_0
; 15 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord6 o5
dcl_position0 v0
dcl_texcoord0 v1
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
mad r1.xyz, -r0, c9.w, c9
dp3 r0.w, r1, r1
rsq r0.w, r0.w
mul o4.xyz, r0.w, r1
add o3.xyz, -r0, c8
mad o1.xy, v1, c10, c10.zwzw
mad o2.xy, v1, c11, c11.zwzw
mad o5.xy, v1, c12, c12.zwzw
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "FLOWMAP_ANIMATION_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _SecondaryRefractionTex_ST;
uniform highp vec4 _WaterMap_ST;
uniform highp vec4 _MainTex_ST;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  mediump vec2 tmpvar_1;
  mediump vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  highp vec2 tmpvar_4;
  tmpvar_4 = ((_glesMultiTexCoord0.xy * _WaterMap_ST.xy) + _WaterMap_ST.zw);
  tmpvar_1 = tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_2 = tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize((_WorldSpaceLightPos0.xyz - ((_Object2World * _glesVertex).xyz * _WorldSpaceLightPos0.w)));
  tmpvar_3 = tmpvar_6;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = tmpvar_1;
  xlv_TEXCOORD2 = tmpvar_2;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD6 = ((_glesMultiTexCoord0.xy * _SecondaryRefractionTex_ST.xy) + _SecondaryRefractionTex_ST.zw);
}



#endif
#ifdef FRAGMENT
#define unity_LightColor0 _glesLightSource[0].diffuse
#define unity_LightColor1 _glesLightSource[1].diffuse
#define unity_LightColor2 _glesLightSource[2].diffuse
#define unity_LightColor3 _glesLightSource[3].diffuse
#define unity_LightPosition0 _glesLightSource[0].position
#define unity_LightPosition1 _glesLightSource[1].position
#define unity_LightPosition2 _glesLightSource[2].position
#define unity_LightPosition3 _glesLightSource[3].position
#define glstate_light0_spotDirection _glesLightSource[0].spotDirection
#define glstate_light1_spotDirection _glesLightSource[1].spotDirection
#define glstate_light2_spotDirection _glesLightSource[2].spotDirection
#define glstate_light3_spotDirection _glesLightSource[3].spotDirection
#define unity_LightAtten0 _glesLightSource[0].atten
#define unity_LightAtten1 _glesLightSource[1].atten
#define unity_LightAtten2 _glesLightSource[2].atten
#define unity_LightAtten3 _glesLightSource[3].atten
#define glstate_lightmodel_ambient _glesLightModel.ambient
#define gl_LightSource _glesLightSource
#define gl_LightSourceParameters _glesLightSourceParameters
struct _glesLightSourceParameters {
  vec4 diffuse;
  vec4 position;
  vec3 spotDirection;
  vec4 atten;
};
uniform _glesLightSourceParameters _glesLightSource[4];
#define gl_LightModel _glesLightModel
#define gl_LightModelParameters _glesLightModelParameters
struct _glesLightModelParameters {
  vec4 ambient;
};
uniform _glesLightModelParameters _glesLightModel;
#define gl_FrontMaterial _glesFrontMaterial
#define gl_BackMaterial _glesFrontMaterial
#define gl_MaterialParameters _glesMaterialParameters
struct _glesMaterialParameters {
  vec4 emission;
  vec4 ambient;
  vec4 diffuse;
  vec4 specular;
  float shininess;
};
uniform _glesMaterialParameters _glesFrontMaterial;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform mediump vec4 causticsAnimationColorChannel;
uniform mediump vec3 causticsOffsetAndScale;
uniform sampler2D _CausticsAnimationTexture;
uniform mediump float _CausticsScale;
uniform mediump float _CausticsStrength;
uniform mediump float _Fresnel0;
uniform mediump float _Gloss;
uniform mediump float _Shininess;
uniform lowp vec3 _ShallowWaterTint;
uniform lowp vec3 _DeepWaterTint;
uniform mediump float _WaterAttenuation;
uniform mediump float _Reflectivity;
uniform samplerCube _Cube;
uniform sampler2D _NormalMap;
uniform mediump float _normalStrength;
uniform mediump float halfCycle;
uniform mediump float flowMapOffset1;
uniform mediump float flowMapOffset0;
uniform sampler2D _FlowMap;
uniform mediump float _Refractivity;
uniform mediump float _refractionsWetness;
uniform highp vec4 _SecondaryRefractionTex_ST;
uniform sampler2D _SecondaryRefractionTex;
uniform sampler2D _WaterMap;
uniform sampler2D _DUDVFoamMap;
uniform mediump float _EdgeFoamStrength;
uniform lowp vec4 _LightColor0;

void main ()
{
  highp vec2 dudvValue_1;
  mediump vec2 flowmapValue_2;
  lowp vec4 outColor_3;
  lowp vec4 tmpvar_4;
  tmpvar_4 = texture2D (_WaterMap, xlv_TEXCOORD1);
  mediump vec3 tmpvar_5;
  tmpvar_5 = normalize(xlv_TEXCOORD2);
  lowp vec2 tmpvar_6;
  tmpvar_6 = ((texture2D (_FlowMap, xlv_TEXCOORD1).xy * 2.0) - 1.0);
  flowmapValue_2 = tmpvar_6;
  mediump float tmpvar_7;
  tmpvar_7 = sqrt(dot (flowmapValue_2, flowmapValue_2));
  mediump float tmpvar_8;
  tmpvar_8 = (abs((halfCycle - flowMapOffset0)) / halfCycle);
  mediump vec2 uv_MainTex_9;
  uv_MainTex_9 = xlv_TEXCOORD0;
  mediump vec3 pNormal_10;
  mediump vec3 normalT1_11;
  mediump vec3 normalT0_12;
  highp vec2 normalmapUV_13;
  normalmapUV_13 = uv_MainTex_9;
  highp vec2 P_14;
  P_14 = (normalmapUV_13 + (flowmapValue_2 * flowMapOffset0));
  lowp vec3 tmpvar_15;
  tmpvar_15 = ((texture2D (_NormalMap, P_14).xyz * 2.0) - 1.0);
  normalT0_12 = tmpvar_15;
  highp vec2 P_16;
  P_16 = (normalmapUV_13 + (flowmapValue_2 * flowMapOffset1));
  lowp vec3 tmpvar_17;
  tmpvar_17 = ((texture2D (_NormalMap, P_16).xyz * 2.0) - 1.0);
  normalT1_11 = tmpvar_17;
  mediump vec3 tmpvar_18;
  tmpvar_18 = mix (normalT0_12, normalT1_11, vec3(tmpvar_8));
  pNormal_10.xy = tmpvar_18.xy;
  pNormal_10.z = (tmpvar_18.z / max (tmpvar_7, 0.1));
  pNormal_10.z = (pNormal_10.z / _normalStrength);
  mediump vec3 tmpvar_19;
  tmpvar_19 = normalize(pNormal_10);
  pNormal_10 = tmpvar_19;
  mediump vec3 tmpvar_20;
  tmpvar_20.x = -(tmpvar_19.x);
  tmpvar_20.y = tmpvar_19.z;
  tmpvar_20.z = -(tmpvar_19.y);
  mediump float tmpvar_21;
  tmpvar_21 = clamp ((tmpvar_4.x * _WaterAttenuation), 0.0, 1.0);
  lowp vec4 tmpvar_22;
  lowp vec4 tmpvar_23;
  highp vec2 P_24;
  P_24 = (xlv_TEXCOORD0 + (flowmapValue_2 * flowMapOffset0));
  tmpvar_23 = texture2D (_DUDVFoamMap, P_24);
  lowp vec4 tmpvar_25;
  highp vec2 P_26;
  P_26 = (xlv_TEXCOORD0 + (flowmapValue_2 * flowMapOffset1));
  tmpvar_25 = texture2D (_DUDVFoamMap, P_26);
  mediump vec4 tmpvar_27;
  tmpvar_27 = mix (tmpvar_23, tmpvar_25, vec4(tmpvar_8));
  tmpvar_22 = tmpvar_27;
  lowp vec2 tmpvar_28;
  tmpvar_28 = tmpvar_22.xy;
  dudvValue_1 = tmpvar_28;
  highp vec2 tmpvar_29;
  tmpvar_29 = ((dudvValue_1 * 2.0) - vec2(1.0, 1.0));
  dudvValue_1 = tmpvar_29;
  highp vec2 uv_WaterMap_30;
  uv_WaterMap_30 = xlv_TEXCOORD1;
  lowp vec3 refractionColor_31;
  highp vec2 tmpvar_32;
  tmpvar_32 = ((tmpvar_29 * _Refractivity) / 100000.0);
  lowp vec4 tmpvar_33;
  highp vec2 P_34;
  P_34 = (xlv_TEXCOORD6 + (tmpvar_32 * _SecondaryRefractionTex_ST.x));
  tmpvar_33 = texture2D (_SecondaryRefractionTex, P_34);
  mediump vec3 tmpvar_35;
  tmpvar_35 = (tmpvar_33.xyz * _refractionsWetness);
  refractionColor_31 = tmpvar_35;
  mediump float tmpvar_36;
  highp vec4 causticsFrame_37;
  lowp vec4 tmpvar_38;
  highp vec2 P_39;
  P_39 = ((fract(((uv_WaterMap_30 + tmpvar_32) * _CausticsScale)) * causticsOffsetAndScale.zz) + causticsOffsetAndScale.xy);
  tmpvar_38 = texture2D (_CausticsAnimationTexture, P_39);
  causticsFrame_37 = tmpvar_38;
  tmpvar_36 = (((((causticsAnimationColorChannel.x * causticsFrame_37.x) + (causticsAnimationColorChannel.y * causticsFrame_37.y)) + (causticsAnimationColorChannel.z * causticsFrame_37.z)) * _CausticsStrength) * (1.0 - tmpvar_21));
  mediump vec3 tmpvar_40;
  tmpvar_40 = (refractionColor_31 + tmpvar_36);
  refractionColor_31 = tmpvar_40;
  mediump vec3 tmpvar_41;
  mediump vec3 i_42;
  i_42 = -(tmpvar_5);
  tmpvar_41 = (i_42 - (2.0 * (dot (tmpvar_20, i_42) * tmpvar_20)));
  lowp vec4 tmpvar_43;
  tmpvar_43 = textureCube (_Cube, tmpvar_41);
  lowp vec3 tmpvar_44;
  mediump float refrStrength_45;
  refrStrength_45 = tmpvar_4.w;
  lowp vec3 finalColor_46;
  mediump float tmpvar_47;
  tmpvar_47 = dot (tmpvar_20, tmpvar_5);
  mediump vec3 tmpvar_48;
  tmpvar_48 = normalize(((tmpvar_20.yzx * xlv_TEXCOORD3.zxy) - (tmpvar_20.zxy * xlv_TEXCOORD3.yzx)));
  mediump float tmpvar_49;
  tmpvar_49 = dot (xlv_TEXCOORD3, tmpvar_48);
  mediump float tmpvar_50;
  tmpvar_50 = dot (tmpvar_5, tmpvar_48);
  mediump float tmpvar_51;
  tmpvar_51 = max (0.0, ((_Fresnel0 + ((1.0 - _Fresnel0) * pow ((1.0 - tmpvar_47), 5.0))) - 0.1));
  mediump float tmpvar_52;
  tmpvar_52 = (((((pow (((sqrt((1.0 - (tmpvar_49 * tmpvar_49))) * sqrt((1.0 - (tmpvar_50 * tmpvar_50)))) - (tmpvar_49 * tmpvar_50)), (_Shininess * 128.0)) * _Gloss) * (max (0.0, tmpvar_47) * max (0.0, dot (tmpvar_20, xlv_TEXCOORD3)))) * max (sign(dot (tmpvar_5, -(xlv_TEXCOORD3))), 0.0)) * _LightColor0.xyz).x * tmpvar_51);
  mediump float tmpvar_53;
  tmpvar_53 = ((tmpvar_52 * tmpvar_52) * 10.0);
  mediump vec3 tmpvar_54;
  tmpvar_54 = mix (_ShallowWaterTint, _DeepWaterTint, vec3(tmpvar_21));
  finalColor_46 = tmpvar_54;
  mediump float tmpvar_55;
  tmpvar_55 = clamp ((max (tmpvar_21, (refrStrength_45 * 0.5)) * 0.8), 0.0, 1.0);
  lowp vec3 tmpvar_56;
  tmpvar_56 = mix (refractionColor_31, finalColor_46, vec3(tmpvar_55));
  mediump vec3 tmpvar_57;
  tmpvar_57 = mix (tmpvar_56, tmpvar_43.xyz, vec3(clamp (tmpvar_51, 0.0, _Reflectivity)));
  finalColor_46 = tmpvar_57;
  mediump vec3 tmpvar_58;
  tmpvar_58 = mix (finalColor_46, tmpvar_22.zzz, vec3(clamp ((max ((tmpvar_4.y * _EdgeFoamStrength), ((tmpvar_7 * tmpvar_22.z) * 0.5)) * tmpvar_22.z), 0.0, 1.0)));
  finalColor_46 = tmpvar_58;
  tmpvar_44 = ((((finalColor_46 * _LightColor0.xyz) + tmpvar_53) * 2.0) + gl_LightModel.ambient.xyz);
  outColor_3.xyz = tmpvar_44;
  outColor_3.w = tmpvar_4.z;
  gl_FragData[0] = outColor_3;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "FLOWMAP_ANIMATION_ON" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _SecondaryRefractionTex_ST;
uniform highp vec4 _WaterMap_ST;
uniform highp vec4 _MainTex_ST;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  mediump vec2 tmpvar_1;
  mediump vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  highp vec2 tmpvar_4;
  tmpvar_4 = ((_glesMultiTexCoord0.xy * _WaterMap_ST.xy) + _WaterMap_ST.zw);
  tmpvar_1 = tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_2 = tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize((_WorldSpaceLightPos0.xyz - ((_Object2World * _glesVertex).xyz * _WorldSpaceLightPos0.w)));
  tmpvar_3 = tmpvar_6;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = tmpvar_1;
  xlv_TEXCOORD2 = tmpvar_2;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD6 = ((_glesMultiTexCoord0.xy * _SecondaryRefractionTex_ST.xy) + _SecondaryRefractionTex_ST.zw);
}



#endif
#ifdef FRAGMENT
#define unity_LightColor0 _glesLightSource[0].diffuse
#define unity_LightColor1 _glesLightSource[1].diffuse
#define unity_LightColor2 _glesLightSource[2].diffuse
#define unity_LightColor3 _glesLightSource[3].diffuse
#define unity_LightPosition0 _glesLightSource[0].position
#define unity_LightPosition1 _glesLightSource[1].position
#define unity_LightPosition2 _glesLightSource[2].position
#define unity_LightPosition3 _glesLightSource[3].position
#define glstate_light0_spotDirection _glesLightSource[0].spotDirection
#define glstate_light1_spotDirection _glesLightSource[1].spotDirection
#define glstate_light2_spotDirection _glesLightSource[2].spotDirection
#define glstate_light3_spotDirection _glesLightSource[3].spotDirection
#define unity_LightAtten0 _glesLightSource[0].atten
#define unity_LightAtten1 _glesLightSource[1].atten
#define unity_LightAtten2 _glesLightSource[2].atten
#define unity_LightAtten3 _glesLightSource[3].atten
#define glstate_lightmodel_ambient _glesLightModel.ambient
#define gl_LightSource _glesLightSource
#define gl_LightSourceParameters _glesLightSourceParameters
struct _glesLightSourceParameters {
  vec4 diffuse;
  vec4 position;
  vec3 spotDirection;
  vec4 atten;
};
uniform _glesLightSourceParameters _glesLightSource[4];
#define gl_LightModel _glesLightModel
#define gl_LightModelParameters _glesLightModelParameters
struct _glesLightModelParameters {
  vec4 ambient;
};
uniform _glesLightModelParameters _glesLightModel;
#define gl_FrontMaterial _glesFrontMaterial
#define gl_BackMaterial _glesFrontMaterial
#define gl_MaterialParameters _glesMaterialParameters
struct _glesMaterialParameters {
  vec4 emission;
  vec4 ambient;
  vec4 diffuse;
  vec4 specular;
  float shininess;
};
uniform _glesMaterialParameters _glesFrontMaterial;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform mediump vec4 causticsAnimationColorChannel;
uniform mediump vec3 causticsOffsetAndScale;
uniform sampler2D _CausticsAnimationTexture;
uniform mediump float _CausticsScale;
uniform mediump float _CausticsStrength;
uniform mediump float _Fresnel0;
uniform mediump float _Gloss;
uniform mediump float _Shininess;
uniform lowp vec3 _ShallowWaterTint;
uniform lowp vec3 _DeepWaterTint;
uniform mediump float _WaterAttenuation;
uniform mediump float _Reflectivity;
uniform samplerCube _Cube;
uniform sampler2D _NormalMap;
uniform mediump float _normalStrength;
uniform mediump float halfCycle;
uniform mediump float flowMapOffset1;
uniform mediump float flowMapOffset0;
uniform sampler2D _FlowMap;
uniform mediump float _Refractivity;
uniform mediump float _refractionsWetness;
uniform highp vec4 _SecondaryRefractionTex_ST;
uniform sampler2D _SecondaryRefractionTex;
uniform sampler2D _WaterMap;
uniform sampler2D _DUDVFoamMap;
uniform mediump float _EdgeFoamStrength;
uniform lowp vec4 _LightColor0;

void main ()
{
  highp vec2 dudvValue_1;
  mediump vec2 flowmapValue_2;
  lowp vec4 outColor_3;
  lowp vec4 tmpvar_4;
  tmpvar_4 = texture2D (_WaterMap, xlv_TEXCOORD1);
  mediump vec3 tmpvar_5;
  tmpvar_5 = normalize(xlv_TEXCOORD2);
  lowp vec2 tmpvar_6;
  tmpvar_6 = ((texture2D (_FlowMap, xlv_TEXCOORD1).xy * 2.0) - 1.0);
  flowmapValue_2 = tmpvar_6;
  mediump float tmpvar_7;
  tmpvar_7 = sqrt(dot (flowmapValue_2, flowmapValue_2));
  mediump float tmpvar_8;
  tmpvar_8 = (abs((halfCycle - flowMapOffset0)) / halfCycle);
  mediump vec2 uv_MainTex_9;
  uv_MainTex_9 = xlv_TEXCOORD0;
  mediump vec3 pNormal_10;
  mediump vec3 normalT1_11;
  mediump vec3 normalT0_12;
  highp vec2 normalmapUV_13;
  normalmapUV_13 = uv_MainTex_9;
  highp vec2 P_14;
  P_14 = (normalmapUV_13 + (flowmapValue_2 * flowMapOffset0));
  lowp vec3 normal_15;
  normal_15.xy = ((texture2D (_NormalMap, P_14).wy * 2.0) - 1.0);
  normal_15.z = sqrt(((1.0 - (normal_15.x * normal_15.x)) - (normal_15.y * normal_15.y)));
  normalT0_12 = normal_15;
  highp vec2 P_16;
  P_16 = (normalmapUV_13 + (flowmapValue_2 * flowMapOffset1));
  lowp vec3 normal_17;
  normal_17.xy = ((texture2D (_NormalMap, P_16).wy * 2.0) - 1.0);
  normal_17.z = sqrt(((1.0 - (normal_17.x * normal_17.x)) - (normal_17.y * normal_17.y)));
  normalT1_11 = normal_17;
  mediump vec3 tmpvar_18;
  tmpvar_18 = mix (normalT0_12, normalT1_11, vec3(tmpvar_8));
  pNormal_10.xy = tmpvar_18.xy;
  pNormal_10.z = (tmpvar_18.z / max (tmpvar_7, 0.1));
  pNormal_10.z = (pNormal_10.z / _normalStrength);
  mediump vec3 tmpvar_19;
  tmpvar_19 = normalize(pNormal_10);
  pNormal_10 = tmpvar_19;
  mediump vec3 tmpvar_20;
  tmpvar_20.x = -(tmpvar_19.x);
  tmpvar_20.y = tmpvar_19.z;
  tmpvar_20.z = -(tmpvar_19.y);
  mediump float tmpvar_21;
  tmpvar_21 = clamp ((tmpvar_4.x * _WaterAttenuation), 0.0, 1.0);
  lowp vec4 tmpvar_22;
  lowp vec4 tmpvar_23;
  highp vec2 P_24;
  P_24 = (xlv_TEXCOORD0 + (flowmapValue_2 * flowMapOffset0));
  tmpvar_23 = texture2D (_DUDVFoamMap, P_24);
  lowp vec4 tmpvar_25;
  highp vec2 P_26;
  P_26 = (xlv_TEXCOORD0 + (flowmapValue_2 * flowMapOffset1));
  tmpvar_25 = texture2D (_DUDVFoamMap, P_26);
  mediump vec4 tmpvar_27;
  tmpvar_27 = mix (tmpvar_23, tmpvar_25, vec4(tmpvar_8));
  tmpvar_22 = tmpvar_27;
  lowp vec2 tmpvar_28;
  tmpvar_28 = tmpvar_22.xy;
  dudvValue_1 = tmpvar_28;
  highp vec2 tmpvar_29;
  tmpvar_29 = ((dudvValue_1 * 2.0) - vec2(1.0, 1.0));
  dudvValue_1 = tmpvar_29;
  highp vec2 uv_WaterMap_30;
  uv_WaterMap_30 = xlv_TEXCOORD1;
  lowp vec3 refractionColor_31;
  highp vec2 tmpvar_32;
  tmpvar_32 = ((tmpvar_29 * _Refractivity) / 100000.0);
  lowp vec4 tmpvar_33;
  highp vec2 P_34;
  P_34 = (xlv_TEXCOORD6 + (tmpvar_32 * _SecondaryRefractionTex_ST.x));
  tmpvar_33 = texture2D (_SecondaryRefractionTex, P_34);
  mediump vec3 tmpvar_35;
  tmpvar_35 = (tmpvar_33.xyz * _refractionsWetness);
  refractionColor_31 = tmpvar_35;
  mediump float tmpvar_36;
  highp vec4 causticsFrame_37;
  lowp vec4 tmpvar_38;
  highp vec2 P_39;
  P_39 = ((fract(((uv_WaterMap_30 + tmpvar_32) * _CausticsScale)) * causticsOffsetAndScale.zz) + causticsOffsetAndScale.xy);
  tmpvar_38 = texture2D (_CausticsAnimationTexture, P_39);
  causticsFrame_37 = tmpvar_38;
  tmpvar_36 = (((((causticsAnimationColorChannel.x * causticsFrame_37.x) + (causticsAnimationColorChannel.y * causticsFrame_37.y)) + (causticsAnimationColorChannel.z * causticsFrame_37.z)) * _CausticsStrength) * (1.0 - tmpvar_21));
  mediump vec3 tmpvar_40;
  tmpvar_40 = (refractionColor_31 + tmpvar_36);
  refractionColor_31 = tmpvar_40;
  mediump vec3 tmpvar_41;
  mediump vec3 i_42;
  i_42 = -(tmpvar_5);
  tmpvar_41 = (i_42 - (2.0 * (dot (tmpvar_20, i_42) * tmpvar_20)));
  lowp vec4 tmpvar_43;
  tmpvar_43 = textureCube (_Cube, tmpvar_41);
  lowp vec3 tmpvar_44;
  mediump float refrStrength_45;
  refrStrength_45 = tmpvar_4.w;
  lowp vec3 finalColor_46;
  mediump float tmpvar_47;
  tmpvar_47 = dot (tmpvar_20, tmpvar_5);
  mediump vec3 tmpvar_48;
  tmpvar_48 = normalize(((tmpvar_20.yzx * xlv_TEXCOORD3.zxy) - (tmpvar_20.zxy * xlv_TEXCOORD3.yzx)));
  mediump float tmpvar_49;
  tmpvar_49 = dot (xlv_TEXCOORD3, tmpvar_48);
  mediump float tmpvar_50;
  tmpvar_50 = dot (tmpvar_5, tmpvar_48);
  mediump float tmpvar_51;
  tmpvar_51 = max (0.0, ((_Fresnel0 + ((1.0 - _Fresnel0) * pow ((1.0 - tmpvar_47), 5.0))) - 0.1));
  mediump float tmpvar_52;
  tmpvar_52 = (((((pow (((sqrt((1.0 - (tmpvar_49 * tmpvar_49))) * sqrt((1.0 - (tmpvar_50 * tmpvar_50)))) - (tmpvar_49 * tmpvar_50)), (_Shininess * 128.0)) * _Gloss) * (max (0.0, tmpvar_47) * max (0.0, dot (tmpvar_20, xlv_TEXCOORD3)))) * max (sign(dot (tmpvar_5, -(xlv_TEXCOORD3))), 0.0)) * _LightColor0.xyz).x * tmpvar_51);
  mediump float tmpvar_53;
  tmpvar_53 = ((tmpvar_52 * tmpvar_52) * 10.0);
  mediump vec3 tmpvar_54;
  tmpvar_54 = mix (_ShallowWaterTint, _DeepWaterTint, vec3(tmpvar_21));
  finalColor_46 = tmpvar_54;
  mediump float tmpvar_55;
  tmpvar_55 = clamp ((max (tmpvar_21, (refrStrength_45 * 0.5)) * 0.8), 0.0, 1.0);
  lowp vec3 tmpvar_56;
  tmpvar_56 = mix (refractionColor_31, finalColor_46, vec3(tmpvar_55));
  mediump vec3 tmpvar_57;
  tmpvar_57 = mix (tmpvar_56, tmpvar_43.xyz, vec3(clamp (tmpvar_51, 0.0, _Reflectivity)));
  finalColor_46 = tmpvar_57;
  mediump vec3 tmpvar_58;
  tmpvar_58 = mix (finalColor_46, tmpvar_22.zzz, vec3(clamp ((max ((tmpvar_4.y * _EdgeFoamStrength), ((tmpvar_7 * tmpvar_22.z) * 0.5)) * tmpvar_22.z), 0.0, 1.0)));
  finalColor_46 = tmpvar_58;
  tmpvar_44 = ((((finalColor_46 * _LightColor0.xyz) + tmpvar_53) * 2.0) + gl_LightModel.ambient.xyz);
  outColor_3.xyz = tmpvar_44;
  outColor_3.w = tmpvar_4.z;
  gl_FragData[0] = outColor_3;
}



#endif"
}

SubProgram "opengl " {
Keywords { "FLOWMAP_ANIMATION_OFF" }
"!!GLSL
#ifdef VERTEX
varying vec2 xlv_TEXCOORD6;
varying vec3 xlv_TEXCOORD3;
varying vec3 xlv_TEXCOORD2;
varying vec2 xlv_TEXCOORD1;
varying vec2 xlv_TEXCOORD0;
uniform vec4 _SecondaryRefractionTex_ST;
uniform vec4 _WaterMap_ST;
uniform vec4 _MainTex_ST;
uniform mat4 _Object2World;

uniform vec4 _WorldSpaceLightPos0;
uniform vec3 _WorldSpaceCameraPos;
void main ()
{
  gl_Position = (gl_ModelViewProjectionMatrix * gl_Vertex);
  xlv_TEXCOORD0 = ((gl_MultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = ((gl_MultiTexCoord0.xy * _WaterMap_ST.xy) + _WaterMap_ST.zw);
  xlv_TEXCOORD2 = (_WorldSpaceCameraPos - (_Object2World * gl_Vertex).xyz);
  xlv_TEXCOORD3 = normalize((_WorldSpaceLightPos0.xyz - ((_Object2World * gl_Vertex).xyz * _WorldSpaceLightPos0.w)));
  xlv_TEXCOORD6 = ((gl_MultiTexCoord0.xy * _SecondaryRefractionTex_ST.xy) + _SecondaryRefractionTex_ST.zw);
}


#endif
#ifdef FRAGMENT
varying vec2 xlv_TEXCOORD6;
varying vec3 xlv_TEXCOORD3;
varying vec3 xlv_TEXCOORD2;
varying vec2 xlv_TEXCOORD1;
varying vec2 xlv_TEXCOORD0;
uniform vec4 causticsAnimationColorChannel;
uniform vec3 causticsOffsetAndScale;
uniform sampler2D _CausticsAnimationTexture;
uniform float _CausticsScale;
uniform float _CausticsStrength;
uniform float _Fresnel0;
uniform float _Gloss;
uniform float _Shininess;
uniform vec3 _ShallowWaterTint;
uniform vec3 _DeepWaterTint;
uniform float _WaterAttenuation;
uniform float _Reflectivity;
uniform samplerCube _Cube;
uniform sampler2D _NormalMap;
uniform float _normalStrength;
uniform float _Refractivity;
uniform float _refractionsWetness;
uniform vec4 _SecondaryRefractionTex_ST;
uniform sampler2D _SecondaryRefractionTex;
uniform sampler2D _WaterMap;
uniform sampler2D _DUDVFoamMap;
uniform float _EdgeFoamStrength;
uniform vec4 _LightColor0;

void main ()
{
  vec4 outColor_1;
  vec4 tmpvar_2;
  tmpvar_2 = texture2D (_WaterMap, xlv_TEXCOORD1);
  vec3 tmpvar_3;
  tmpvar_3 = normalize(xlv_TEXCOORD2);
  vec3 pNormal_4;
  vec3 normal_5;
  normal_5.xy = ((texture2D (_NormalMap, xlv_TEXCOORD0).wy * 2.0) - 1.0);
  normal_5.z = sqrt(((1.0 - (normal_5.x * normal_5.x)) - (normal_5.y * normal_5.y)));
  pNormal_4.xy = normal_5.xy;
  pNormal_4.z = (normal_5.z / _normalStrength);
  vec3 tmpvar_6;
  tmpvar_6 = normalize(pNormal_4);
  pNormal_4 = tmpvar_6;
  vec3 tmpvar_7;
  tmpvar_7.x = -(tmpvar_6.x);
  tmpvar_7.y = tmpvar_6.z;
  tmpvar_7.z = -(tmpvar_6.y);
  float tmpvar_8;
  tmpvar_8 = clamp ((tmpvar_2.x * _WaterAttenuation), 0.0, 1.0);
  vec3 tmpvar_9;
  tmpvar_9 = texture2D (_DUDVFoamMap, xlv_TEXCOORD0).xyz;
  vec2 tmpvar_10;
  tmpvar_10 = ((((tmpvar_9.xy * 2.0) - vec2(1.0, 1.0)) * _Refractivity) / 100000.0);
  vec4 tmpvar_11;
  tmpvar_11 = texture2D (_CausticsAnimationTexture, ((fract(((xlv_TEXCOORD1 + tmpvar_10) * _CausticsScale)) * causticsOffsetAndScale.zz) + causticsOffsetAndScale.xy));
  vec3 i_12;
  i_12 = -(tmpvar_3);
  float tmpvar_13;
  tmpvar_13 = dot (tmpvar_7, tmpvar_3);
  vec3 tmpvar_14;
  tmpvar_14 = normalize(((tmpvar_7.yzx * xlv_TEXCOORD3.zxy) - (tmpvar_7.zxy * xlv_TEXCOORD3.yzx)));
  float tmpvar_15;
  tmpvar_15 = dot (xlv_TEXCOORD3, tmpvar_14);
  float tmpvar_16;
  tmpvar_16 = dot (tmpvar_3, tmpvar_14);
  float tmpvar_17;
  tmpvar_17 = max (0.0, ((_Fresnel0 + ((1.0 - _Fresnel0) * pow ((1.0 - tmpvar_13), 5.0))) - 0.1));
  float tmpvar_18;
  tmpvar_18 = (((((pow (((sqrt((1.0 - (tmpvar_15 * tmpvar_15))) * sqrt((1.0 - (tmpvar_16 * tmpvar_16)))) - (tmpvar_15 * tmpvar_16)), (_Shininess * 128.0)) * _Gloss) * (max (0.0, tmpvar_13) * max (0.0, dot (tmpvar_7, xlv_TEXCOORD3)))) * max (sign(dot (tmpvar_3, -(xlv_TEXCOORD3))), 0.0)) * _LightColor0.xyz).x * tmpvar_17);
  outColor_1.xyz = ((((mix (mix (mix (((texture2D (_SecondaryRefractionTex, (xlv_TEXCOORD6 + (tmpvar_10 * _SecondaryRefractionTex_ST.x))).xyz * _refractionsWetness) + (((((causticsAnimationColorChannel.x * tmpvar_11.x) + (causticsAnimationColorChannel.y * tmpvar_11.y)) + (causticsAnimationColorChannel.z * tmpvar_11.z)) * _CausticsStrength) * (1.0 - tmpvar_8))), mix (_ShallowWaterTint, _DeepWaterTint, vec3(tmpvar_8)), vec3(clamp ((max (tmpvar_8, (tmpvar_2.w * 0.5)) * 0.8), 0.0, 1.0))), textureCube (_Cube, (i_12 - (2.0 * (dot (tmpvar_7, i_12) * tmpvar_7)))).xyz, vec3(clamp (tmpvar_17, 0.0, _Reflectivity))), tmpvar_9.zzz, vec3(clamp (((tmpvar_2.y * _EdgeFoamStrength) * tmpvar_9.z), 0.0, 1.0))) * _LightColor0.xyz) + ((tmpvar_18 * tmpvar_18) * 10.0)) * 2.0) + gl_LightModel.ambient.xyz);
  outColor_1.w = tmpvar_2.z;
  gl_FragData[0] = outColor_1;
}


#endif
"
}

SubProgram "d3d9 " {
Keywords { "FLOWMAP_ANIMATION_OFF" }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Vector 9 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Vector 10 [_MainTex_ST]
Vector 11 [_WaterMap_ST]
Vector 12 [_SecondaryRefractionTex_ST]
"vs_3_0
; 15 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord6 o5
dcl_position0 v0
dcl_texcoord0 v1
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
mad r1.xyz, -r0, c9.w, c9
dp3 r0.w, r1, r1
rsq r0.w, r0.w
mul o4.xyz, r0.w, r1
add o3.xyz, -r0, c8
mad o1.xy, v1, c10, c10.zwzw
mad o2.xy, v1, c11, c11.zwzw
mad o5.xy, v1, c12, c12.zwzw
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "gles " {
Keywords { "FLOWMAP_ANIMATION_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _SecondaryRefractionTex_ST;
uniform highp vec4 _WaterMap_ST;
uniform highp vec4 _MainTex_ST;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  mediump vec2 tmpvar_1;
  mediump vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  highp vec2 tmpvar_4;
  tmpvar_4 = ((_glesMultiTexCoord0.xy * _WaterMap_ST.xy) + _WaterMap_ST.zw);
  tmpvar_1 = tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_2 = tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize((_WorldSpaceLightPos0.xyz - ((_Object2World * _glesVertex).xyz * _WorldSpaceLightPos0.w)));
  tmpvar_3 = tmpvar_6;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = tmpvar_1;
  xlv_TEXCOORD2 = tmpvar_2;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD6 = ((_glesMultiTexCoord0.xy * _SecondaryRefractionTex_ST.xy) + _SecondaryRefractionTex_ST.zw);
}



#endif
#ifdef FRAGMENT
#define unity_LightColor0 _glesLightSource[0].diffuse
#define unity_LightColor1 _glesLightSource[1].diffuse
#define unity_LightColor2 _glesLightSource[2].diffuse
#define unity_LightColor3 _glesLightSource[3].diffuse
#define unity_LightPosition0 _glesLightSource[0].position
#define unity_LightPosition1 _glesLightSource[1].position
#define unity_LightPosition2 _glesLightSource[2].position
#define unity_LightPosition3 _glesLightSource[3].position
#define glstate_light0_spotDirection _glesLightSource[0].spotDirection
#define glstate_light1_spotDirection _glesLightSource[1].spotDirection
#define glstate_light2_spotDirection _glesLightSource[2].spotDirection
#define glstate_light3_spotDirection _glesLightSource[3].spotDirection
#define unity_LightAtten0 _glesLightSource[0].atten
#define unity_LightAtten1 _glesLightSource[1].atten
#define unity_LightAtten2 _glesLightSource[2].atten
#define unity_LightAtten3 _glesLightSource[3].atten
#define glstate_lightmodel_ambient _glesLightModel.ambient
#define gl_LightSource _glesLightSource
#define gl_LightSourceParameters _glesLightSourceParameters
struct _glesLightSourceParameters {
  vec4 diffuse;
  vec4 position;
  vec3 spotDirection;
  vec4 atten;
};
uniform _glesLightSourceParameters _glesLightSource[4];
#define gl_LightModel _glesLightModel
#define gl_LightModelParameters _glesLightModelParameters
struct _glesLightModelParameters {
  vec4 ambient;
};
uniform _glesLightModelParameters _glesLightModel;
#define gl_FrontMaterial _glesFrontMaterial
#define gl_BackMaterial _glesFrontMaterial
#define gl_MaterialParameters _glesMaterialParameters
struct _glesMaterialParameters {
  vec4 emission;
  vec4 ambient;
  vec4 diffuse;
  vec4 specular;
  float shininess;
};
uniform _glesMaterialParameters _glesFrontMaterial;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform mediump vec4 causticsAnimationColorChannel;
uniform mediump vec3 causticsOffsetAndScale;
uniform sampler2D _CausticsAnimationTexture;
uniform mediump float _CausticsScale;
uniform mediump float _CausticsStrength;
uniform mediump float _Fresnel0;
uniform mediump float _Gloss;
uniform mediump float _Shininess;
uniform lowp vec3 _ShallowWaterTint;
uniform lowp vec3 _DeepWaterTint;
uniform mediump float _WaterAttenuation;
uniform mediump float _Reflectivity;
uniform samplerCube _Cube;
uniform sampler2D _NormalMap;
uniform mediump float _normalStrength;
uniform mediump float _Refractivity;
uniform mediump float _refractionsWetness;
uniform highp vec4 _SecondaryRefractionTex_ST;
uniform sampler2D _SecondaryRefractionTex;
uniform sampler2D _WaterMap;
uniform sampler2D _DUDVFoamMap;
uniform mediump float _EdgeFoamStrength;
uniform lowp vec4 _LightColor0;

void main ()
{
  highp vec2 dudvValue_1;
  lowp vec4 outColor_2;
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (_WaterMap, xlv_TEXCOORD1);
  mediump vec3 tmpvar_4;
  tmpvar_4 = normalize(xlv_TEXCOORD2);
  mediump vec2 uv_MainTex_5;
  uv_MainTex_5 = xlv_TEXCOORD0;
  mediump vec3 pNormal_6;
  highp vec2 normalmapUV_7;
  normalmapUV_7 = uv_MainTex_5;
  lowp vec3 tmpvar_8;
  tmpvar_8 = ((texture2D (_NormalMap, normalmapUV_7).xyz * 2.0) - 1.0);
  pNormal_6 = tmpvar_8;
  pNormal_6.z = (pNormal_6.z / _normalStrength);
  mediump vec3 tmpvar_9;
  tmpvar_9 = normalize(pNormal_6);
  pNormal_6 = tmpvar_9;
  mediump vec3 tmpvar_10;
  tmpvar_10.x = -(tmpvar_9.x);
  tmpvar_10.y = tmpvar_9.z;
  tmpvar_10.z = -(tmpvar_9.y);
  mediump float tmpvar_11;
  tmpvar_11 = clamp ((tmpvar_3.x * _WaterAttenuation), 0.0, 1.0);
  lowp vec3 tmpvar_12;
  tmpvar_12 = texture2D (_DUDVFoamMap, xlv_TEXCOORD0).xyz;
  lowp vec2 tmpvar_13;
  tmpvar_13 = tmpvar_12.xy;
  dudvValue_1 = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14 = ((dudvValue_1 * 2.0) - vec2(1.0, 1.0));
  dudvValue_1 = tmpvar_14;
  highp vec2 uv_WaterMap_15;
  uv_WaterMap_15 = xlv_TEXCOORD1;
  lowp vec3 refractionColor_16;
  highp vec2 tmpvar_17;
  tmpvar_17 = ((tmpvar_14 * _Refractivity) / 100000.0);
  lowp vec4 tmpvar_18;
  highp vec2 P_19;
  P_19 = (xlv_TEXCOORD6 + (tmpvar_17 * _SecondaryRefractionTex_ST.x));
  tmpvar_18 = texture2D (_SecondaryRefractionTex, P_19);
  mediump vec3 tmpvar_20;
  tmpvar_20 = (tmpvar_18.xyz * _refractionsWetness);
  refractionColor_16 = tmpvar_20;
  mediump float tmpvar_21;
  highp vec4 causticsFrame_22;
  lowp vec4 tmpvar_23;
  highp vec2 P_24;
  P_24 = ((fract(((uv_WaterMap_15 + tmpvar_17) * _CausticsScale)) * causticsOffsetAndScale.zz) + causticsOffsetAndScale.xy);
  tmpvar_23 = texture2D (_CausticsAnimationTexture, P_24);
  causticsFrame_22 = tmpvar_23;
  tmpvar_21 = (((((causticsAnimationColorChannel.x * causticsFrame_22.x) + (causticsAnimationColorChannel.y * causticsFrame_22.y)) + (causticsAnimationColorChannel.z * causticsFrame_22.z)) * _CausticsStrength) * (1.0 - tmpvar_11));
  mediump vec3 tmpvar_25;
  tmpvar_25 = (refractionColor_16 + tmpvar_21);
  refractionColor_16 = tmpvar_25;
  mediump vec3 tmpvar_26;
  mediump vec3 i_27;
  i_27 = -(tmpvar_4);
  tmpvar_26 = (i_27 - (2.0 * (dot (tmpvar_10, i_27) * tmpvar_10)));
  lowp vec4 tmpvar_28;
  tmpvar_28 = textureCube (_Cube, tmpvar_26);
  lowp vec3 tmpvar_29;
  mediump float refrStrength_30;
  refrStrength_30 = tmpvar_3.w;
  lowp vec3 finalColor_31;
  mediump float tmpvar_32;
  tmpvar_32 = dot (tmpvar_10, tmpvar_4);
  mediump vec3 tmpvar_33;
  tmpvar_33 = normalize(((tmpvar_10.yzx * xlv_TEXCOORD3.zxy) - (tmpvar_10.zxy * xlv_TEXCOORD3.yzx)));
  mediump float tmpvar_34;
  tmpvar_34 = dot (xlv_TEXCOORD3, tmpvar_33);
  mediump float tmpvar_35;
  tmpvar_35 = dot (tmpvar_4, tmpvar_33);
  mediump float tmpvar_36;
  tmpvar_36 = max (0.0, ((_Fresnel0 + ((1.0 - _Fresnel0) * pow ((1.0 - tmpvar_32), 5.0))) - 0.1));
  mediump float tmpvar_37;
  tmpvar_37 = (((((pow (((sqrt((1.0 - (tmpvar_34 * tmpvar_34))) * sqrt((1.0 - (tmpvar_35 * tmpvar_35)))) - (tmpvar_34 * tmpvar_35)), (_Shininess * 128.0)) * _Gloss) * (max (0.0, tmpvar_32) * max (0.0, dot (tmpvar_10, xlv_TEXCOORD3)))) * max (sign(dot (tmpvar_4, -(xlv_TEXCOORD3))), 0.0)) * _LightColor0.xyz).x * tmpvar_36);
  mediump float tmpvar_38;
  tmpvar_38 = ((tmpvar_37 * tmpvar_37) * 10.0);
  mediump vec3 tmpvar_39;
  tmpvar_39 = mix (_ShallowWaterTint, _DeepWaterTint, vec3(tmpvar_11));
  finalColor_31 = tmpvar_39;
  mediump float tmpvar_40;
  tmpvar_40 = clamp ((max (tmpvar_11, (refrStrength_30 * 0.5)) * 0.8), 0.0, 1.0);
  lowp vec3 tmpvar_41;
  tmpvar_41 = mix (refractionColor_16, finalColor_31, vec3(tmpvar_40));
  mediump vec3 tmpvar_42;
  tmpvar_42 = mix (tmpvar_41, tmpvar_28.xyz, vec3(clamp (tmpvar_36, 0.0, _Reflectivity)));
  finalColor_31 = tmpvar_42;
  mediump vec3 tmpvar_43;
  tmpvar_43 = mix (finalColor_31, tmpvar_12.zzz, vec3(clamp (((tmpvar_3.y * _EdgeFoamStrength) * tmpvar_12.z), 0.0, 1.0)));
  finalColor_31 = tmpvar_43;
  tmpvar_29 = ((((finalColor_31 * _LightColor0.xyz) + tmpvar_38) * 2.0) + gl_LightModel.ambient.xyz);
  outColor_2.xyz = tmpvar_29;
  outColor_2.w = tmpvar_3.z;
  gl_FragData[0] = outColor_2;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "FLOWMAP_ANIMATION_OFF" }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _SecondaryRefractionTex_ST;
uniform highp vec4 _WaterMap_ST;
uniform highp vec4 _MainTex_ST;
uniform highp mat4 _Object2World;

uniform highp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  mediump vec2 tmpvar_1;
  mediump vec3 tmpvar_2;
  mediump vec3 tmpvar_3;
  highp vec2 tmpvar_4;
  tmpvar_4 = ((_glesMultiTexCoord0.xy * _WaterMap_ST.xy) + _WaterMap_ST.zw);
  tmpvar_1 = tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_5 = (_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz);
  tmpvar_2 = tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize((_WorldSpaceLightPos0.xyz - ((_Object2World * _glesVertex).xyz * _WorldSpaceLightPos0.w)));
  tmpvar_3 = tmpvar_6;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = tmpvar_1;
  xlv_TEXCOORD2 = tmpvar_2;
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD6 = ((_glesMultiTexCoord0.xy * _SecondaryRefractionTex_ST.xy) + _SecondaryRefractionTex_ST.zw);
}



#endif
#ifdef FRAGMENT
#define unity_LightColor0 _glesLightSource[0].diffuse
#define unity_LightColor1 _glesLightSource[1].diffuse
#define unity_LightColor2 _glesLightSource[2].diffuse
#define unity_LightColor3 _glesLightSource[3].diffuse
#define unity_LightPosition0 _glesLightSource[0].position
#define unity_LightPosition1 _glesLightSource[1].position
#define unity_LightPosition2 _glesLightSource[2].position
#define unity_LightPosition3 _glesLightSource[3].position
#define glstate_light0_spotDirection _glesLightSource[0].spotDirection
#define glstate_light1_spotDirection _glesLightSource[1].spotDirection
#define glstate_light2_spotDirection _glesLightSource[2].spotDirection
#define glstate_light3_spotDirection _glesLightSource[3].spotDirection
#define unity_LightAtten0 _glesLightSource[0].atten
#define unity_LightAtten1 _glesLightSource[1].atten
#define unity_LightAtten2 _glesLightSource[2].atten
#define unity_LightAtten3 _glesLightSource[3].atten
#define glstate_lightmodel_ambient _glesLightModel.ambient
#define gl_LightSource _glesLightSource
#define gl_LightSourceParameters _glesLightSourceParameters
struct _glesLightSourceParameters {
  vec4 diffuse;
  vec4 position;
  vec3 spotDirection;
  vec4 atten;
};
uniform _glesLightSourceParameters _glesLightSource[4];
#define gl_LightModel _glesLightModel
#define gl_LightModelParameters _glesLightModelParameters
struct _glesLightModelParameters {
  vec4 ambient;
};
uniform _glesLightModelParameters _glesLightModel;
#define gl_FrontMaterial _glesFrontMaterial
#define gl_BackMaterial _glesFrontMaterial
#define gl_MaterialParameters _glesMaterialParameters
struct _glesMaterialParameters {
  vec4 emission;
  vec4 ambient;
  vec4 diffuse;
  vec4 specular;
  float shininess;
};
uniform _glesMaterialParameters _glesFrontMaterial;

varying highp vec2 xlv_TEXCOORD6;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec2 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform mediump vec4 causticsAnimationColorChannel;
uniform mediump vec3 causticsOffsetAndScale;
uniform sampler2D _CausticsAnimationTexture;
uniform mediump float _CausticsScale;
uniform mediump float _CausticsStrength;
uniform mediump float _Fresnel0;
uniform mediump float _Gloss;
uniform mediump float _Shininess;
uniform lowp vec3 _ShallowWaterTint;
uniform lowp vec3 _DeepWaterTint;
uniform mediump float _WaterAttenuation;
uniform mediump float _Reflectivity;
uniform samplerCube _Cube;
uniform sampler2D _NormalMap;
uniform mediump float _normalStrength;
uniform mediump float _Refractivity;
uniform mediump float _refractionsWetness;
uniform highp vec4 _SecondaryRefractionTex_ST;
uniform sampler2D _SecondaryRefractionTex;
uniform sampler2D _WaterMap;
uniform sampler2D _DUDVFoamMap;
uniform mediump float _EdgeFoamStrength;
uniform lowp vec4 _LightColor0;

void main ()
{
  highp vec2 dudvValue_1;
  lowp vec4 outColor_2;
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (_WaterMap, xlv_TEXCOORD1);
  mediump vec3 tmpvar_4;
  tmpvar_4 = normalize(xlv_TEXCOORD2);
  mediump vec2 uv_MainTex_5;
  uv_MainTex_5 = xlv_TEXCOORD0;
  mediump vec3 pNormal_6;
  highp vec2 normalmapUV_7;
  normalmapUV_7 = uv_MainTex_5;
  lowp vec3 normal_8;
  normal_8.xy = ((texture2D (_NormalMap, normalmapUV_7).wy * 2.0) - 1.0);
  normal_8.z = sqrt(((1.0 - (normal_8.x * normal_8.x)) - (normal_8.y * normal_8.y)));
  pNormal_6 = normal_8;
  pNormal_6.z = (pNormal_6.z / _normalStrength);
  mediump vec3 tmpvar_9;
  tmpvar_9 = normalize(pNormal_6);
  pNormal_6 = tmpvar_9;
  mediump vec3 tmpvar_10;
  tmpvar_10.x = -(tmpvar_9.x);
  tmpvar_10.y = tmpvar_9.z;
  tmpvar_10.z = -(tmpvar_9.y);
  mediump float tmpvar_11;
  tmpvar_11 = clamp ((tmpvar_3.x * _WaterAttenuation), 0.0, 1.0);
  lowp vec3 tmpvar_12;
  tmpvar_12 = texture2D (_DUDVFoamMap, xlv_TEXCOORD0).xyz;
  lowp vec2 tmpvar_13;
  tmpvar_13 = tmpvar_12.xy;
  dudvValue_1 = tmpvar_13;
  highp vec2 tmpvar_14;
  tmpvar_14 = ((dudvValue_1 * 2.0) - vec2(1.0, 1.0));
  dudvValue_1 = tmpvar_14;
  highp vec2 uv_WaterMap_15;
  uv_WaterMap_15 = xlv_TEXCOORD1;
  lowp vec3 refractionColor_16;
  highp vec2 tmpvar_17;
  tmpvar_17 = ((tmpvar_14 * _Refractivity) / 100000.0);
  lowp vec4 tmpvar_18;
  highp vec2 P_19;
  P_19 = (xlv_TEXCOORD6 + (tmpvar_17 * _SecondaryRefractionTex_ST.x));
  tmpvar_18 = texture2D (_SecondaryRefractionTex, P_19);
  mediump vec3 tmpvar_20;
  tmpvar_20 = (tmpvar_18.xyz * _refractionsWetness);
  refractionColor_16 = tmpvar_20;
  mediump float tmpvar_21;
  highp vec4 causticsFrame_22;
  lowp vec4 tmpvar_23;
  highp vec2 P_24;
  P_24 = ((fract(((uv_WaterMap_15 + tmpvar_17) * _CausticsScale)) * causticsOffsetAndScale.zz) + causticsOffsetAndScale.xy);
  tmpvar_23 = texture2D (_CausticsAnimationTexture, P_24);
  causticsFrame_22 = tmpvar_23;
  tmpvar_21 = (((((causticsAnimationColorChannel.x * causticsFrame_22.x) + (causticsAnimationColorChannel.y * causticsFrame_22.y)) + (causticsAnimationColorChannel.z * causticsFrame_22.z)) * _CausticsStrength) * (1.0 - tmpvar_11));
  mediump vec3 tmpvar_25;
  tmpvar_25 = (refractionColor_16 + tmpvar_21);
  refractionColor_16 = tmpvar_25;
  mediump vec3 tmpvar_26;
  mediump vec3 i_27;
  i_27 = -(tmpvar_4);
  tmpvar_26 = (i_27 - (2.0 * (dot (tmpvar_10, i_27) * tmpvar_10)));
  lowp vec4 tmpvar_28;
  tmpvar_28 = textureCube (_Cube, tmpvar_26);
  lowp vec3 tmpvar_29;
  mediump float refrStrength_30;
  refrStrength_30 = tmpvar_3.w;
  lowp vec3 finalColor_31;
  mediump float tmpvar_32;
  tmpvar_32 = dot (tmpvar_10, tmpvar_4);
  mediump vec3 tmpvar_33;
  tmpvar_33 = normalize(((tmpvar_10.yzx * xlv_TEXCOORD3.zxy) - (tmpvar_10.zxy * xlv_TEXCOORD3.yzx)));
  mediump float tmpvar_34;
  tmpvar_34 = dot (xlv_TEXCOORD3, tmpvar_33);
  mediump float tmpvar_35;
  tmpvar_35 = dot (tmpvar_4, tmpvar_33);
  mediump float tmpvar_36;
  tmpvar_36 = max (0.0, ((_Fresnel0 + ((1.0 - _Fresnel0) * pow ((1.0 - tmpvar_32), 5.0))) - 0.1));
  mediump float tmpvar_37;
  tmpvar_37 = (((((pow (((sqrt((1.0 - (tmpvar_34 * tmpvar_34))) * sqrt((1.0 - (tmpvar_35 * tmpvar_35)))) - (tmpvar_34 * tmpvar_35)), (_Shininess * 128.0)) * _Gloss) * (max (0.0, tmpvar_32) * max (0.0, dot (tmpvar_10, xlv_TEXCOORD3)))) * max (sign(dot (tmpvar_4, -(xlv_TEXCOORD3))), 0.0)) * _LightColor0.xyz).x * tmpvar_36);
  mediump float tmpvar_38;
  tmpvar_38 = ((tmpvar_37 * tmpvar_37) * 10.0);
  mediump vec3 tmpvar_39;
  tmpvar_39 = mix (_ShallowWaterTint, _DeepWaterTint, vec3(tmpvar_11));
  finalColor_31 = tmpvar_39;
  mediump float tmpvar_40;
  tmpvar_40 = clamp ((max (tmpvar_11, (refrStrength_30 * 0.5)) * 0.8), 0.0, 1.0);
  lowp vec3 tmpvar_41;
  tmpvar_41 = mix (refractionColor_16, finalColor_31, vec3(tmpvar_40));
  mediump vec3 tmpvar_42;
  tmpvar_42 = mix (tmpvar_41, tmpvar_28.xyz, vec3(clamp (tmpvar_36, 0.0, _Reflectivity)));
  finalColor_31 = tmpvar_42;
  mediump vec3 tmpvar_43;
  tmpvar_43 = mix (finalColor_31, tmpvar_12.zzz, vec3(clamp (((tmpvar_3.y * _EdgeFoamStrength) * tmpvar_12.z), 0.0, 1.0)));
  finalColor_31 = tmpvar_43;
  tmpvar_29 = ((((finalColor_31 * _LightColor0.xyz) + tmpvar_38) * 2.0) + gl_LightModel.ambient.xyz);
  outColor_2.xyz = tmpvar_29;
  outColor_2.w = tmpvar_3.z;
  gl_FragData[0] = outColor_2;
}



#endif"
}

}
Program "fp" {
// Fragment combos: 2
//   d3d9 - ALU: 104 to 133, TEX: 6 to 9
SubProgram "opengl " {
Keywords { "FLOWMAP_ANIMATION_ON" }
"!!GLSL"
}

SubProgram "d3d9 " {
Keywords { "FLOWMAP_ANIMATION_ON" }
Vector 0 [glstate_lightmodel_ambient]
Vector 1 [_LightColor0]
Float 2 [_EdgeFoamStrength]
Vector 3 [_SecondaryRefractionTex_ST]
Float 4 [_refractionsWetness]
Float 5 [_Refractivity]
Float 6 [flowMapOffset0]
Float 7 [flowMapOffset1]
Float 8 [halfCycle]
Float 9 [_normalStrength]
Float 10 [_Reflectivity]
Float 11 [_WaterAttenuation]
Vector 12 [_DeepWaterTint]
Vector 13 [_ShallowWaterTint]
Float 14 [_Shininess]
Float 15 [_Gloss]
Float 16 [_Fresnel0]
Float 17 [_CausticsStrength]
Float 18 [_CausticsScale]
Vector 19 [causticsOffsetAndScale]
Vector 20 [causticsAnimationColorChannel]
SetTexture 0 [_WaterMap] 2D
SetTexture 1 [_FlowMap] 2D
SetTexture 2 [_NormalMap] 2D
SetTexture 3 [_DUDVFoamMap] 2D
SetTexture 4 [_SecondaryRefractionTex] 2D
SetTexture 5 [_CausticsAnimationTexture] 2D
SetTexture 6 [_Cube] CUBE
"ps_3_0
; 133 ALU, 9 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_cube s6
def c21, 2.00000000, -1.00000000, 0.50000000, 1.00000000
def c22, 0.09997559, 5.00000000, -0.09997559, 0.00000000
def c23, 0.79980469, 0.00001000, 128.00000000, 10.00000000
def c24, 0.00000000, 1.00000000, 0, 0
dcl_texcoord0 v0.xy
dcl_texcoord1 v1.xy
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord6 v4.xy
texld r0.xy, v1, s1
mad r0.zw, r0.xyxy, c21.x, c21.y
mul_pp r0.xy, r0.zwzw, c7.x
add r3.xy, v0, r0
mul_pp r0.xy, r0.zwzw, c6.x
texld r1.yw, r3, s2
mad_pp r1.xy, r1.wyzw, c21.x, c21.y
add r4.xy, v0, r0
texld r2.yw, r4, s2
mad_pp r0.xy, r2.wyzw, c21.x, c21.y
mul_pp r2.xy, r0.zwzw, r0.zwzw
add_pp r0.w, r2.x, r2.y
mul_pp r1.z, r1.y, r1.y
mad_pp r1.z, -r1.x, r1.x, -r1
mul_pp r1.w, r0.y, r0.y
mad_pp r1.w, -r0.x, r0.x, -r1
add_pp r1.z, r1, c21.w
rsq_pp r1.z, r1.z
add_pp r1.w, r1, c21
rsq_pp r1.w, r1.w
texld r4.xyz, r4, s3
rcp_pp r0.z, r1.w
rsq_pp r0.w, r0.w
rcp_pp r1.z, r1.z
add_pp r1.xyz, r1, -r0
rcp_pp r1.w, r0.w
mov_pp r2.x, c8
add_pp r0.w, -c6.x, r2.x
rcp_pp r2.x, c8.x
abs_pp r0.w, r0
mul_pp r2.w, r0, r2.x
mad_pp r0.xyz, r2.w, r1, r0
max_pp r0.w, r1, c22.x
rcp_pp r0.w, r0.w
mul_pp r0.z, r0, r0.w
rcp_pp r1.x, c9.x
mul_pp r0.z, r0, r1.x
dp3_pp r0.w, r0, r0
rsq_pp r0.w, r0.w
mul_pp r0.xyz, r0.w, r0
dp3_pp r0.w, v2, v2
mov_pp r1.x, -r0
mov_pp r1.z, -r0.y
mov_pp r1.y, r0.z
mul_pp r0.xyz, r1.zxyw, v3.yzxw
mad_pp r0.xyz, r1.yzxw, v3.zxyw, -r0
dp3_pp r2.x, r0, r0
rsq_pp r2.x, r2.x
mul_pp r0.xyz, r2.x, r0
rsq_pp r0.w, r0.w
mul_pp r2.xyz, r0.w, v2
dp3_pp r0.w, v3, r0
dp3_pp r0.z, r2, r0
mul_pp r0.x, r0.w, r0.z
mad_pp r0.y, -r0.w, r0.w, c21.w
mov_pp r0.w, c14.x
rsq_pp r0.y, r0.y
mad_pp r0.z, -r0, r0, c21.w
rsq_pp r0.z, r0.z
dp3_pp r4.w, r1, r2
mul_pp r3.z, c23, r0.w
rcp_pp r0.y, r0.y
rcp_pp r0.z, r0.z
mad_pp r3.w, r0.y, r0.z, -r0.x
pow_pp r0, r3.w, r3.z
dp3_pp r0.z, r1, v3
dp3_pp r0.w, r2, -v3
cmp_pp r3.z, r0.w, c24.x, c24.y
cmp_pp r0.w, -r0, c24.x, c24.y
add_pp r0.w, r0, -r3.z
mul_pp r1.xyz, -r4.w, r1
mad_pp r1.xyz, -r1, c21.x, -r2
max_pp r0.z, r0, c22.w
max_pp r0.y, r4.w, c22.w
mul_pp r0.y, r0, r0.z
mul_pp r0.x, r0, c15
mul_pp r0.x, r0, r0.y
max_pp r0.z, r0.w, c22.w
mul_pp r0.x, r0, r0.z
mul_pp r3.w, r0.x, c1.x
add_pp r3.z, -r4.w, c21.w
pow_pp r0, r3.z, c22.y
texld r3.xyz, r3, s3
add_pp r3.xyz, r3, -r4
mov_pp r0.z, c16.x
mad_pp r3.xyz, r2.w, r3, r4
mov_pp r0.w, r0.x
mad r0.xy, r3, c21.x, c21.y
mul r0.xy, r0, c5.x
mul r3.xy, r0, c23.y
add r0.xy, v1, r3
add_pp r0.z, c21.w, -r0
mad_pp r0.z, r0, r0.w, c16.x
add_pp r0.z, r0, c22
max_pp r2.w, r0.z, c22
mul_pp r0.z, r2.w, r3.w
mul_pp r0.z, r0, r0
mul r0.xy, r0, c18.x
frc r0.xy, r0
mul_pp r3.w, r0.z, c23
mad r0.xy, r0, c19.z, c19
texld r0.xyz, r0, s5
mul r0.y, r0, c20
mad r0.x, r0, c20, r0.y
mad r2.x, r0.z, c20.z, r0
texld r0, v1, s0
mul r4.x, r2, c17
mad r2.xy, r3, c3.x, v4
mul_pp_sat r0.x, r0, c11
add_pp r3.x, -r0, c21.w
texld r2.xyz, r2, s4
mul_pp r0.w, r0, c21.z
max_pp r0.w, r0.x, r0
mul r2.xyz, r2, c4.x
mul r3.x, r4, r3
add_pp r4.xyz, r2, r3.x
mov_pp r2.xyz, c12
add_pp r2.xyz, -c13, r2
mad_pp r2.xyz, r0.x, r2, c13
mul_pp_sat r0.x, r0.w, c23
add_pp r2.xyz, r2, -r4
mad_pp r2.xyz, r0.x, r2, r4
min_pp r0.x, r2.w, c10
max_pp r0.w, r0.x, c22
texld r1.xyz, r1, s6
add_pp r1.xyz, r1, -r2
mad_pp r1.xyz, r0.w, r1, r2
mul_pp r0.x, r1.w, r3.z
mul_pp r0.w, r0.x, c21.z
mul_pp r0.x, r0.y, c2
max_pp r0.x, r0, r0.w
add_pp r2.xyz, r3.z, -r1
mul_pp_sat r0.x, r0, r3.z
mad_pp r1.xyz, r0.x, r2, r1
mad_pp r1.xyz, r1, c1, r3.w
mul_pp r1.xyz, r1, c21.x
add oC0.xyz, r1, c0
mov_pp oC0.w, r0.z
"
}

SubProgram "gles " {
Keywords { "FLOWMAP_ANIMATION_ON" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "FLOWMAP_ANIMATION_ON" }
"!!GLES"
}

SubProgram "opengl " {
Keywords { "FLOWMAP_ANIMATION_OFF" }
"!!GLSL"
}

SubProgram "d3d9 " {
Keywords { "FLOWMAP_ANIMATION_OFF" }
Vector 0 [glstate_lightmodel_ambient]
Vector 1 [_LightColor0]
Float 2 [_EdgeFoamStrength]
Vector 3 [_SecondaryRefractionTex_ST]
Float 4 [_refractionsWetness]
Float 5 [_Refractivity]
Float 6 [_normalStrength]
Float 7 [_Reflectivity]
Float 8 [_WaterAttenuation]
Vector 9 [_DeepWaterTint]
Vector 10 [_ShallowWaterTint]
Float 11 [_Shininess]
Float 12 [_Gloss]
Float 13 [_Fresnel0]
Float 14 [_CausticsStrength]
Float 15 [_CausticsScale]
Vector 16 [causticsOffsetAndScale]
Vector 17 [causticsAnimationColorChannel]
SetTexture 0 [_WaterMap] 2D
SetTexture 1 [_NormalMap] 2D
SetTexture 2 [_DUDVFoamMap] 2D
SetTexture 3 [_SecondaryRefractionTex] 2D
SetTexture 4 [_CausticsAnimationTexture] 2D
SetTexture 5 [_Cube] CUBE
"ps_3_0
; 104 ALU, 6 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_cube s5
def c18, 1.00000000, 2.00000000, -1.00000000, 5.00000000
def c19, -0.09997559, 0.00000000, 0.50000000, 0.79980469
def c20, 0.00001000, 128.00000000, 0.00000000, 1.00000000
def c21, 10.00000000, 0, 0, 0
dcl_texcoord0 v0.xy
dcl_texcoord1 v1.xy
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord6 v4.xy
texld r0.yw, v0, s1
mad_pp r0.xy, r0.wyzw, c18.y, c18.z
mul_pp r0.z, r0.y, r0.y
mad_pp r0.z, -r0.x, r0.x, -r0
add_pp r0.z, r0, c18.x
rsq_pp r0.z, r0.z
mov_pp r4.xyz, c9
rcp_pp r0.w, c6.x
rcp_pp r0.z, r0.z
mul_pp r0.z, r0, r0.w
dp3_pp r0.w, r0, r0
rsq_pp r0.w, r0.w
mul_pp r0.xyz, r0.w, r0
dp3_pp r0.w, v2, v2
mov_pp r1.x, -r0
mov_pp r1.z, -r0.y
mov_pp r1.y, r0.z
mul_pp r0.xyz, r1.zxyw, v3.yzxw
mad_pp r0.xyz, r1.yzxw, v3.zxyw, -r0
dp3_pp r1.w, r0, r0
rsq_pp r1.w, r1.w
mul_pp r2.xyz, r1.w, r0
rsq_pp r0.w, r0.w
mul_pp r0.xyz, r0.w, v2
dp3_pp r0.w, v3, r2
dp3_pp r2.x, r0, r2
mul_pp r2.y, r0.w, r2.x
mad_pp r1.w, -r0, r0, c18.x
rsq_pp r0.w, r1.w
mad_pp r1.w, -r2.x, r2.x, c18.x
mov_pp r2.x, c11
rsq_pp r1.w, r1.w
mul_pp r3.x, c20.y, r2
rcp_pp r1.w, r1.w
rcp_pp r0.w, r0.w
mad_pp r0.w, r0, r1, -r2.y
pow_pp r2, r0.w, r3.x
mov_pp r0.w, r2.x
mul_pp r1.w, r0, c12.x
dp3_pp r2.x, r1, v3
dp3_pp r0.w, r1, r0
max_pp r2.y, r2.x, c19
max_pp r2.x, r0.w, c19.y
mul_pp r2.x, r2, r2.y
mul_pp r1.xyz, -r0.w, r1
mad_pp r1.xyz, -r1, c18.y, -r0
dp3_pp r2.y, r0, -v3
mul_pp r3.x, r1.w, r2
cmp_pp r1.w, -r2.y, c20.z, c20
cmp_pp r2.x, r2.y, c20.z, c20.w
add_pp r2.x, r1.w, -r2
add_pp r1.w, -r0, c18.x
texld r0, v1, s0
max_pp r3.y, r2.x, c19
pow_pp r2, r1.w, c18.w
mul_pp r1.w, r3.x, r3.y
mul_pp r2.z, r1.w, c1.x
mov_pp r1.w, c13.x
texld r3.xyz, v0, s2
mov_pp r2.w, r2.x
mad r2.xy, r3, c18.y, c18.z
mul r2.xy, r2, c5.x
mul r3.xy, r2, c20.x
add_pp r1.w, c18.x, -r1
mad_pp r1.w, r1, r2, c13.x
add_pp r1.w, r1, c19.x
max_pp r1.w, r1, c19.y
add r2.xy, v1, r3
mul_pp r2.z, r1.w, r2
mul_pp r2.z, r2, r2
mul r2.xy, r2, c15.x
frc r2.xy, r2
mul_pp r2.w, r2.z, c21.x
mad r2.xy, r2, c16.z, c16
texld r2.xyz, r2, s4
mul r2.y, r2, c17
mad r2.y, r2.x, c17.x, r2
mul_pp r2.x, r0.w, c19.z
mul_pp_sat r0.w, r0.x, c8.x
max_pp r0.x, r0.w, r2
mad r2.x, r2.z, c17.z, r2.y
add_pp r4.xyz, -c10, r4
add_pp r2.y, -r0.w, c18.x
mul r2.x, r2, c14
mul r3.w, r2.x, r2.y
mad r2.xy, r3, c3.x, v4
texld r2.xyz, r2, s3
mul r2.xyz, r2, c4.x
add_pp r2.xyz, r2, r3.w
mad_pp r4.xyz, r0.w, r4, c10
mul_pp_sat r0.x, r0, c19.w
add_pp r4.xyz, r4, -r2
mad_pp r2.xyz, r0.x, r4, r2
texld r1.xyz, r1, s5
min_pp r0.x, r1.w, c7
add_pp r1.xyz, r1, -r2
max_pp r0.x, r0, c19.y
mad_pp r1.xyz, r0.x, r1, r2
mul_pp r0.x, r0.y, c2
add_pp r2.xyz, r3.z, -r1
mul_pp_sat r0.x, r0, r3.z
mad_pp r1.xyz, r0.x, r2, r1
mad_pp r1.xyz, r1, c1, r2.w
mul_pp r1.xyz, r1, c18.y
add oC0.xyz, r1, c0
mov_pp oC0.w, r0.z
"
}

SubProgram "gles " {
Keywords { "FLOWMAP_ANIMATION_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "FLOWMAP_ANIMATION_OFF" }
"!!GLES"
}

}

#LINE 103

		
			}
		
		 }
		 
	}
	
	Fallback "Water+/Desktop Fast"
 }