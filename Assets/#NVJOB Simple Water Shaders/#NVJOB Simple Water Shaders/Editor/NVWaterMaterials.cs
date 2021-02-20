// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Simple Water Shaders. MIT license - license_nvjob.txt
// #NVJOB Simple Water Shaders v1.6 - https://nvjob.github.io/unity/nvjob-simple-water-shaders
// #NVJOB Nicholas Veselov - https://nvjob.github.io


using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


[CanEditMultipleObjects]
internal class NVWaterMaterials : MaterialEditor
{    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    Color smLineColor = Color.HSVToRGB(0, 0, 0.55f), bgLineColor = Color.HSVToRGB(0, 0, 0.3f);
    int smLinePadding = 20, bgLinePadding = 35;


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public override void OnInspectorGUI()
    {
        //--------------

        SetDefaultGUIWidths();
        serializedObject.Update();
        SerializedProperty shaderFind = serializedObject.FindProperty("m_Shader");
        if (!isVisible || shaderFind.hasMultipleDifferentValues || shaderFind.objectReferenceValue == null) return;

        //--------------

        List<MaterialProperty> allProps = new List<MaterialProperty>(GetMaterialProperties(targets));

        //--------------

        EditorGUI.BeginChangeCheck();
        Header();
        DrawUILine(bgLineColor, 2, bgLinePadding);

        //--------------

        Albedo(allProps);
        NormalMaps(allProps);
        ParallaxMap(allProps);
        Reflection(allProps);
        MirrorReflection(allProps);

        //--------------

        DrawUILine(bgLineColor, 2, bgLinePadding);
        Information();
        DrawUILine(bgLineColor, 2, bgLinePadding);
        RenderQueueField();
        EnableInstancingField();
        DoubleSidedGIField();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        //-------------- 
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Albedo(List<MaterialProperty> allProps)
    {
        //--------------

        EditorGUILayout.LabelField("Albedo Settings:", EditorStyles.boldLabel);
        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty albedoTex1 = allProps.Find(prop => prop.name == "_AlbedoTex1");
        MaterialProperty albedoColor = allProps.Find(prop => prop.name == "_AlbedoColor");

        if (albedoTex1 != null && albedoColor != null)
        {
            allProps.Remove(albedoTex1);
            allProps.Remove(albedoColor);
            ShaderProperty(albedoTex1, albedoTex1.displayName);
            ShaderProperty(albedoColor, albedoColor.displayName);
        }

        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty albedoTex2 = allProps.Find(prop => prop.name == "_AlbedoTex2");
        MaterialProperty albedo2Tiling = allProps.Find(prop => prop.name == "_Albedo2Tiling");
        MaterialProperty albedo2Flow = allProps.Find(prop => prop.name == "_Albedo2Flow");
        IEnumerable<bool> enableAlbedoTex2 = targets.Select(t => ((Material)t).shaderKeywords.Contains("EFFECT_ALBEDO2"));

        if (enableAlbedoTex2 != null && albedoTex2 != null && albedo2Tiling != null && albedo2Flow != null)
        {
            allProps.Remove(albedoTex2);
            allProps.Remove(albedo2Tiling);
            allProps.Remove(albedo2Flow);

            bool? enable = EditorGUILayout.Toggle("Albedo 2 Enable", enableAlbedoTex2.First());
            if (enable != null)
            {
                foreach (Material m in targets.Cast<Material>())
                {
                    if (enable.Value) m.EnableKeyword("EFFECT_ALBEDO2");
                    else m.DisableKeyword("EFFECT_ALBEDO2");
                }
            }
            if (enableAlbedoTex2.First())
            {
                ShaderProperty(albedoTex2, albedoTex2.displayName);
                ShaderProperty(albedo2Tiling, albedo2Tiling.displayName);
                ShaderProperty(albedo2Flow, albedo2Flow.displayName);
            }
        }

        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty albedoIntensity = allProps.Find(prop => prop.name == "_AlbedoIntensity");
        MaterialProperty albedoContrast = allProps.Find(prop => prop.name == "_AlbedoContrast");

        if (albedoIntensity != null && albedoContrast != null)
        {
            allProps.Remove(albedoIntensity);
            allProps.Remove(albedoContrast);
            ShaderProperty(albedoIntensity, albedoIntensity.displayName);
            ShaderProperty(albedoContrast, albedoContrast.displayName);
        }

        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty shininess = allProps.Find(prop => prop.name == "_Shininess");
        MaterialProperty specColor = allProps.Find(prop => prop.name == "_SpecColor");

        if (shininess != null && specColor != null)
        {
            allProps.Remove(shininess);
            allProps.Remove(specColor);
            ShaderProperty(shininess, shininess.displayName);
            ShaderProperty(specColor, specColor.displayName);
        }

        MaterialProperty glossiness = allProps.Find(prop => prop.name == "_Glossiness");
        MaterialProperty metallic = allProps.Find(prop => prop.name == "_Metallic");

        if (glossiness != null && metallic != null)
        {
            allProps.Remove(glossiness);
            allProps.Remove(metallic);
            ShaderProperty(glossiness, glossiness.displayName);
            ShaderProperty(metallic, metallic.displayName);
        }
  
        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty softFactor = allProps.Find(prop => prop.name == "_SoftFactor");

        if (softFactor != null)
        {
            allProps.Remove(softFactor);
            ShaderProperty(softFactor, softFactor.displayName);
        }

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void NormalMaps(List<MaterialProperty> allProps)
    {
        //--------------

        DrawUILine(bgLineColor, 2, bgLinePadding);
        EditorGUILayout.LabelField("Normal Map Settings:", EditorStyles.boldLabel);
        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty normalMap1 = allProps.Find(prop => prop.name == "_NormalMap1");
        MaterialProperty normalMap1Strength = allProps.Find(prop => prop.name == "_NormalMap1Strength");

        if (normalMap1 != null && normalMap1Strength != null)
        {
            allProps.Remove(normalMap1);
            allProps.Remove(normalMap1Strength);
            ShaderProperty(normalMap1, normalMap1.displayName);
            ShaderProperty(normalMap1Strength, normalMap1Strength.displayName);
        }

        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty normalMap2 = allProps.Find(prop => prop.name == "_NormalMap2");
        MaterialProperty normalMap2Tiling = allProps.Find(prop => prop.name == "_NormalMap2Tiling");
        MaterialProperty normalMap2Strength = allProps.Find(prop => prop.name == "_NormalMap2Strength");
        MaterialProperty normalMap2Flow = allProps.Find(prop => prop.name == "_NormalMap2Flow");
        IEnumerable<bool> enableNormalMap2 = targets.Select(t => ((Material)t).shaderKeywords.Contains("EFFECT_NORMALMAP2"));

        if (enableNormalMap2 != null && normalMap2 != null && normalMap2Tiling != null && normalMap2Strength != null && normalMap2Flow != null)
        {
            allProps.Remove(normalMap2);
            allProps.Remove(normalMap2Tiling);
            allProps.Remove(normalMap2Strength);
            allProps.Remove(normalMap2Flow);

            bool? enable = EditorGUILayout.Toggle("Normal Map 2 Enable", enableNormalMap2.First());
            if (enable != null)
            {
                foreach (Material m in targets.Cast<Material>())
                {
                    if (enable.Value) m.EnableKeyword("EFFECT_NORMALMAP2");
                    else m.DisableKeyword("EFFECT_NORMALMAP2");
                }
            }
            if (enableNormalMap2.First())
            {
                ShaderProperty(normalMap2, normalMap2.displayName);
                ShaderProperty(normalMap2Tiling, normalMap2Tiling.displayName);
                ShaderProperty(normalMap2Strength, normalMap2Strength.displayName);
                ShaderProperty(normalMap2Flow, normalMap2Flow.displayName);
            }
        }

        //--------------

        if (enableNormalMap2 != null && enableNormalMap2.First())
        {
            DrawUILine(smLineColor, 1, smLinePadding);

            MaterialProperty microwaveScale = allProps.Find(prop => prop.name == "_MicrowaveScale");
            MaterialProperty microwaveStrength = allProps.Find(prop => prop.name == "_MicrowaveStrength");
            IEnumerable<bool> enableMicrowave = targets.Select(t => ((Material)t).shaderKeywords.Contains("EFFECT_MICROWAVE"));

            if (enableMicrowave != null && microwaveScale != null && microwaveStrength != null)
            {
                allProps.Remove(microwaveScale);
                allProps.Remove(microwaveStrength);

                bool? enable = EditorGUILayout.Toggle("Micro Waves Enable", enableMicrowave.First());
                if (enable != null)
                {
                    foreach (Material m in targets.Cast<Material>())
                    {
                        if (enable.Value) m.EnableKeyword("EFFECT_MICROWAVE");
                        else m.DisableKeyword("EFFECT_MICROWAVE");
                    }
                }
                if (enableMicrowave.First())
                {
                    ShaderProperty(microwaveScale, microwaveScale.displayName);
                    ShaderProperty(microwaveStrength, microwaveStrength.displayName);
                }
            }
        }
        else
        {
            foreach (Material m in targets.Cast<Material>()) m.DisableKeyword("EFFECT_MICROWAVE");
        }

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void ParallaxMap(List<MaterialProperty> allProps)
    {
        //--------------

        DrawUILine(bgLineColor, 2, bgLinePadding);
        EditorGUILayout.LabelField("Parallax Map Settings:", EditorStyles.boldLabel);
        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty parallaxMap = allProps.Find(prop => prop.name == "_ParallaxMap");
        MaterialProperty parallaxMapTiling = allProps.Find(prop => prop.name == "_ParallaxMapTiling");
        MaterialProperty parallaxAmount = allProps.Find(prop => prop.name == "_ParallaxAmount");
        MaterialProperty parallaxNormal2Offset = allProps.Find(prop => prop.name == "_ParallaxNormal2Offset");
        MaterialProperty parallaxFlow = allProps.Find(prop => prop.name == "_ParallaxFlow");
        IEnumerable<bool> enableParallaxMap = targets.Select(t => ((Material)t).shaderKeywords.Contains("EFFECT_PARALLAX"));

        if (enableParallaxMap != null && parallaxMap != null && parallaxMapTiling != null && parallaxAmount != null && parallaxFlow != null && parallaxNormal2Offset != null)
        {
            allProps.Remove(parallaxMap);
            allProps.Remove(parallaxMapTiling);
            allProps.Remove(parallaxAmount);
            allProps.Remove(parallaxNormal2Offset);
            allProps.Remove(parallaxFlow);

            bool? enable = EditorGUILayout.Toggle("Parallax Map Enable", enableParallaxMap.First());
            if (enable != null)
            {
                foreach (Material m in targets.Cast<Material>())
                {
                    if (enable.Value) m.EnableKeyword("EFFECT_PARALLAX");
                    else m.DisableKeyword("EFFECT_PARALLAX");
                }
            }
            if (enableParallaxMap.First())
            {
                ShaderProperty(parallaxMap, parallaxMap.displayName);
                ShaderProperty(parallaxMapTiling, parallaxMapTiling.displayName);
                ShaderProperty(parallaxAmount, parallaxAmount.displayName);
                ShaderProperty(parallaxNormal2Offset, parallaxNormal2Offset.displayName);
                ShaderProperty(parallaxFlow, parallaxFlow.displayName);
            }
        }

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Reflection(List<MaterialProperty> allProps)
    {
        if (allProps.Find(prop => prop.name == "_ReflectionCube") != null)
        {
            //--------------

            DrawUILine(bgLineColor, 2, bgLinePadding);
            EditorGUILayout.LabelField("Reflection Settings:", EditorStyles.boldLabel);
            DrawUILine(smLineColor, 1, smLinePadding);

            //--------------

            MaterialProperty reflectionCube = allProps.Find(prop => prop.name == "_ReflectionCube");
            MaterialProperty reflectionColor = allProps.Find(prop => prop.name == "_ReflectionColor");
            MaterialProperty reflectionStrength = allProps.Find(prop => prop.name == "_ReflectionStrength");
            MaterialProperty reflectionSaturation = allProps.Find(prop => prop.name == "_ReflectionSaturation");
            MaterialProperty reflectionContrast = allProps.Find(prop => prop.name == "_ReflectionContrast");
            IEnumerable<bool> enableReflectionCube = targets.Select(t => ((Material)t).shaderKeywords.Contains("EFFECT_REFLECTION"));

            if (enableReflectionCube != null && reflectionCube != null && reflectionColor != null && reflectionStrength != null && reflectionSaturation != null && reflectionContrast != null)
            {
                allProps.Remove(reflectionCube);
                allProps.Remove(reflectionColor);
                allProps.Remove(reflectionStrength);
                allProps.Remove(reflectionSaturation);
                allProps.Remove(reflectionContrast);

                bool? enable = EditorGUILayout.Toggle("Reflection Cubemap Enable", enableReflectionCube.First());
                if (enable != null)
                {
                    foreach (Material m in targets.Cast<Material>())
                    {
                        if (enable.Value) m.EnableKeyword("EFFECT_REFLECTION");
                        else m.DisableKeyword("EFFECT_REFLECTION");
                    }
                }
                if (enableReflectionCube.First())
                {
                    ShaderProperty(reflectionCube, reflectionCube.displayName);
                    ShaderProperty(reflectionColor, reflectionColor.displayName);
                    ShaderProperty(reflectionStrength, reflectionStrength.displayName);
                    ShaderProperty(reflectionSaturation, reflectionSaturation.displayName);
                    ShaderProperty(reflectionContrast, reflectionContrast.displayName);
                }
            }

            //--------------
        }
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void MirrorReflection(List<MaterialProperty> allProps)
    {
        //--------------

        DrawUILine(bgLineColor, 2, bgLinePadding);
        EditorGUILayout.LabelField("Mirror Reflection Settings:", EditorStyles.boldLabel);
        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty mirrorColor = allProps.Find(prop => prop.name == "_MirrorColor");
        MaterialProperty mirrorDepthColor = allProps.Find(prop => prop.name == "_MirrorDepthColor");
        MaterialProperty mirrorFPOW = allProps.Find(prop => prop.name == "_MirrorFPOW");
        MaterialProperty mirrorR0 = allProps.Find(prop => prop.name == "_MirrorR0");
        IEnumerable<bool> enableMirrorReflection = targets.Select(t => ((Material)t).shaderKeywords.Contains("EFFECT_MIRROR"));

        if (enableMirrorReflection != null && mirrorColor != null && mirrorDepthColor != null && mirrorFPOW != null && mirrorR0 != null)
        {
            allProps.Remove(mirrorColor);
            allProps.Remove(mirrorDepthColor);
            allProps.Remove(mirrorFPOW);
            allProps.Remove(mirrorR0);

            bool? enable = EditorGUILayout.Toggle("Mirror Reflection Enable", enableMirrorReflection.First());
            if (enable != null)
            {
                foreach (Material m in targets.Cast<Material>())
                {
                    if (enable.Value) m.EnableKeyword("EFFECT_MIRROR");
                    else m.DisableKeyword("EFFECT_MIRROR");
                }
            }
            if (enableMirrorReflection.First())
            {
                ShaderProperty(mirrorColor, mirrorColor.displayName);
                ShaderProperty(mirrorDepthColor, mirrorDepthColor.displayName);
                ShaderProperty(mirrorFPOW, mirrorFPOW.displayName);
                ShaderProperty(mirrorR0, mirrorR0.displayName);
            }
        }

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public static void Header()
    {
        //--------------

        EditorGUILayout.Space();
        EditorGUILayout.Space();
        GUIStyle guiStyle = new GUIStyle();
        guiStyle.fontSize = 17;
        EditorGUILayout.LabelField("#NVJOB Simple Water Shaders (v1.6)", guiStyle);

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public static void Information()
    {
        //--------------

        if (GUILayout.Button("Description and Instructions")) Help.BrowseURL("https://nvjob.github.io/unity/nvjob-simple-water-shaders");
        if (GUILayout.Button("#NVJOB Store")) Help.BrowseURL("https://nvjob.github.io/store/");
        EditorGUILayout.Space();
        EditorGUILayout.TextArea("Development of assets, scripts and shaders for Unity nvjob.dev@gmail.com", EditorStyles.textArea);

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public static void DrawUILine(Color color, int thickness = 2, int padding = 10)
    {
        //--------------

        Rect line = EditorGUILayout.GetControlRect(GUILayout.Height(padding + thickness));
        line.height = thickness;
        line.y += padding / 2;
        line.x -= 2;
        EditorGUI.DrawRect(line, color);

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


[CustomEditor(typeof(SimpleWaterShaders))]
[CanEditMultipleObjects]

public class SimpleWaterShaderEditor : Editor
{
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    Color smLineColor = Color.HSVToRGB(0, 0, 0.55f), bgLineColor = Color.HSVToRGB(0, 0, 0.3f);
    int smLinePadding = 20, bgLinePadding = 35;
    SerializedProperty uvRotateSpeed, uvRotateDistance, uvBumpRotateSpeed, uvBumpRotateDistance, depthTextureModeOn, windZone, waterSyncWind;
    SerializedProperty mirrorOn, disablePixelLights, mirrorBackSide, textureSize, clipPlaneOffset;


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void OnEnable()
    {
        //--------------

        uvRotateSpeed = serializedObject.FindProperty("UvRotateSpeed");
        uvRotateDistance = serializedObject.FindProperty("UvRotateDistance");

        uvBumpRotateSpeed = serializedObject.FindProperty("UvBumpRotateSpeed");
        uvBumpRotateDistance = serializedObject.FindProperty("UvBumpRotateDistance");

        depthTextureModeOn = serializedObject.FindProperty("depthTextureModeOn");

        waterSyncWind = serializedObject.FindProperty("waterSyncWind");
        windZone = serializedObject.FindProperty("windZone");

        mirrorOn = serializedObject.FindProperty("mirrorOn");
        disablePixelLights = serializedObject.FindProperty("disablePixelLights");
        mirrorBackSide = serializedObject.FindProperty("mirrorBackSide");
        textureSize = serializedObject.FindProperty("textureSize");
        clipPlaneOffset = serializedObject.FindProperty("clipPlaneOffset");

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public override void OnInspectorGUI()
    {
        //--------------

        serializedObject.Update();

        //--------------

        EditorGUI.BeginChangeCheck();
        NVWaterMaterials.Header();
        NVWaterMaterials.DrawUILine(bgLineColor, 2, bgLinePadding);

        //--------------

        EditorGUILayout.LabelField("Albedo Movement:", EditorStyles.boldLabel);
        NVWaterMaterials.DrawUILine(smLineColor, 1, smLinePadding);

        EditorGUILayout.PropertyField(uvRotateSpeed, new GUIContent("Rotate Speed"));
        EditorGUILayout.PropertyField(uvRotateDistance, new GUIContent("Rotate Distance"));

        //--------------

        NVWaterMaterials.DrawUILine(bgLineColor, 2, bgLinePadding);

        EditorGUILayout.LabelField("Normal Map Movement:", EditorStyles.boldLabel);
        NVWaterMaterials.DrawUILine(smLineColor, 1, smLinePadding);

        EditorGUILayout.PropertyField(uvBumpRotateSpeed, new GUIContent("Rotate Speed"));
        EditorGUILayout.PropertyField(uvBumpRotateDistance, new GUIContent("Rotate Distance"));

        //--------------

        NVWaterMaterials.DrawUILine(bgLineColor, 2, bgLinePadding);

        EditorGUILayout.LabelField("Depth Texture Mode:", EditorStyles.boldLabel);
        NVWaterMaterials.DrawUILine(smLineColor, 1, smLinePadding);

        EditorGUILayout.PropertyField(depthTextureModeOn, new GUIContent("Depth Texture Mode"));
        EditorGUILayout.HelpBox("For working shaders on mobile platforms with Forward Rendering.", MessageType.None);

        //--------------

        NVWaterMaterials.DrawUILine(bgLineColor, 2, bgLinePadding);

        EditorGUILayout.LabelField("Wind Zone:", EditorStyles.boldLabel);
        NVWaterMaterials.DrawUILine(smLineColor, 1, smLinePadding);

        EditorGUILayout.PropertyField(waterSyncWind, new GUIContent("Water Sync With Wind"));

        EditorGUILayout.PropertyField(windZone, new GUIContent("Wind Zone Object"));
        EditorGUILayout.HelpBox("Optional. To synchronize the wind direction with the direction of water movement.", MessageType.None);

        //--------------

        NVWaterMaterials.DrawUILine(bgLineColor, 2, bgLinePadding);

        EditorGUILayout.LabelField("Mirror Reflection:", EditorStyles.boldLabel);
        NVWaterMaterials.DrawUILine(smLineColor, 1, smLinePadding);

        EditorGUILayout.PropertyField(mirrorOn, new GUIContent("Mirror Reflection Enable"));
        EditorGUILayout.PropertyField(disablePixelLights, new GUIContent("Disable Pixel Lights"));
        EditorGUILayout.PropertyField(mirrorBackSide, new GUIContent("Mirror Back Side"));
        EditorGUILayout.PropertyField(textureSize, new GUIContent("Mirror Texture Size"));
        EditorGUILayout.PropertyField(clipPlaneOffset, new GUIContent("Clipping plane offset"));

        //--------------

        serializedObject.ApplyModifiedProperties();

        NVWaterMaterials.DrawUILine(bgLineColor, 2, bgLinePadding);
        NVWaterMaterials.Information();

        EditorGUILayout.Space();
        EditorGUILayout.Space();

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}