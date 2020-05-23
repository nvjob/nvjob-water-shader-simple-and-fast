// #NVJOB Dynamic Sky (for Demo)
// Full Asset #NVJOB Dynamic Sky - https://nvjob.github.io/unity/nvjob-dynamic-sky-lite
// #NVJOB Nicholas Veselov - https://nvjob.github.io


using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


[CanEditMultipleObjects]
internal class NVDSkyDemoMaterials : MaterialEditor
{
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    enum DSKYType { Cloud1 = 0, Cloud2, Horizon }
    DSKYType[] skyTypes;
    string[] DSKYGTypeString = { "DSKY_CLOUD_1", "DSKY_CLOUD_2", "DSKY_HORIZON" };
    bool renderQueueOffset(DSKYType skyType) { return skyType == DSKYType.Horizon; }

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

        SkyTypeCH(allProps);
        if (skyTypes.Contains(DSKYType.Cloud1) || skyTypes.Contains(DSKYType.Cloud2)) Clouds(allProps);
        if (skyTypes.Contains(DSKYType.Horizon)) Horizon(allProps);

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


    void SkyTypeCH(List<MaterialProperty> allProps)
    {
        //--------------

        EditorGUILayout.LabelField("Sky Type:", EditorStyles.boldLabel);
        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        skyTypes = new DSKYType[targets.Length];

        for (int i = 0; i < targets.Length; ++i)
        {
            skyTypes[i] = DSKYType.Cloud1;
            for (int j = 0; j < DSKYGTypeString.Length; ++j)
            {
                if (((Material)targets[i]).shaderKeywords.Contains(DSKYGTypeString[j]))
                {
                    skyTypes[i] = (DSKYType)j;
                    break;
                }
            }
        }

        //--------------

        DSKYType setSkyType = (DSKYType)EditorGUILayout.EnumPopup("Sky Type", skyTypes[0]);

        if (EditorGUI.EndChangeCheck())
        {
            foreach (Material m in targets.Cast<Material>())
            {
                for (int i = 0; i < DSKYGTypeString.Length; ++i) m.DisableKeyword(DSKYGTypeString[i]);
                m.EnableKeyword(DSKYGTypeString[(int)setSkyType]);
                m.renderQueue = renderQueueOffset(setSkyType) ? (int)UnityEngine.Rendering.RenderQueue.Geometry + 501 : (int)UnityEngine.Rendering.RenderQueue.Geometry + 500;
            }
        }

        EditorGUI.showMixedValue = false;

        //--------------

        DrawUILine(bgLineColor, 2, bgLinePadding);

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Clouds(List<MaterialProperty> allProps)
    {
        //--------------

        EditorGUILayout.LabelField(skyTypes.Contains(DSKYType.Cloud1) ? "Clouds Type 1 (General texture mixing):" : "Clouds Type 2 (Mixing textures by channels):", EditorStyles.boldLabel);
        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty texture1 = allProps.Find(prop => prop.name == "_Texture1");
        MaterialProperty textureUv1 = allProps.Find(prop => prop.name == "_TextureUv1");
        MaterialProperty intensityT1 = allProps.Find(prop => prop.name == "_IntensityT1");
        MaterialProperty vectorX1 = allProps.Find(prop => prop.name == "_VectorX1");
        MaterialProperty vectorY1 = allProps.Find(prop => prop.name == "_VectorY1");

        if (texture1 != null && textureUv1 != null && intensityT1 != null && vectorX1 != null && vectorY1 != null)
        {
            allProps.Remove(texture1);
            allProps.Remove(textureUv1);
            allProps.Remove(intensityT1);
            allProps.Remove(vectorX1);
            allProps.Remove(vectorY1);
            ShaderProperty(texture1, texture1.displayName);
            ShaderProperty(textureUv1, textureUv1.displayName);
            ShaderProperty(intensityT1, intensityT1.displayName);
            ShaderProperty(vectorX1, vectorX1.displayName);
            ShaderProperty(vectorY1, vectorY1.displayName);
        }

        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty texture2 = allProps.Find(prop => prop.name == "_Texture2");
        MaterialProperty textureUv2 = allProps.Find(prop => prop.name == "_TextureUv2");
        MaterialProperty intensityT2 = allProps.Find(prop => prop.name == "_IntensityT2");
        MaterialProperty vectorX2 = allProps.Find(prop => prop.name == "_VectorX2");
        MaterialProperty vectorY2 = allProps.Find(prop => prop.name == "_VectorY2");

        if (texture2 != null && textureUv2 != null && intensityT2 != null && vectorX2 != null && vectorY2 != null)
        {
            allProps.Remove(texture2);
            allProps.Remove(textureUv2);
            allProps.Remove(intensityT2);
            allProps.Remove(vectorX2);
            allProps.Remove(vectorY2);
            ShaderProperty(texture2, texture2.displayName);
            ShaderProperty(textureUv2, textureUv2.displayName);
            ShaderProperty(intensityT2, intensityT2.displayName);
            ShaderProperty(vectorX2, vectorX2.displayName);
            ShaderProperty(vectorY2, vectorY2.displayName);
        }

        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty texture3 = allProps.Find(prop => prop.name == "_Texture3");
        MaterialProperty textureUv3 = allProps.Find(prop => prop.name == "_TextureUv3");
        MaterialProperty intensityT3 = allProps.Find(prop => prop.name == "_IntensityT3");
        MaterialProperty vectorX3 = allProps.Find(prop => prop.name == "_VectorX3");
        MaterialProperty vectorY3 = allProps.Find(prop => prop.name == "_VectorY3");

        if (texture3 != null && textureUv3 != null && intensityT3 != null && vectorX3 != null && vectorY3 != null)
        {
            allProps.Remove(texture3);
            allProps.Remove(textureUv3);
            allProps.Remove(intensityT3);
            allProps.Remove(vectorX3);
            allProps.Remove(vectorY3);
            ShaderProperty(texture3, texture3.displayName);
            ShaderProperty(textureUv3, textureUv3.displayName);
            ShaderProperty(intensityT3, intensityT3.displayName);
            ShaderProperty(vectorX3, vectorX3.displayName);
            ShaderProperty(vectorY3, vectorY3.displayName);
        }

        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty color = allProps.Find(prop => prop.name == "_Color");
        MaterialProperty intensityInput = allProps.Find(prop => prop.name == "_IntensityInput");
        MaterialProperty fluffiness = allProps.Find(prop => prop.name == "_Fluffiness");
        MaterialProperty intensityOutput = allProps.Find(prop => prop.name == "_IntensityOutput");

        if (color != null && intensityInput != null && fluffiness != null && intensityOutput != null)
        {
            allProps.Remove(color);
            allProps.Remove(intensityInput);
            allProps.Remove(fluffiness);
            allProps.Remove(intensityOutput);
            ShaderProperty(color, color.displayName);
            ShaderProperty(intensityInput, intensityInput.displayName);
            ShaderProperty(fluffiness, fluffiness.displayName);
            ShaderProperty(intensityOutput, intensityOutput.displayName);
        }

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Horizon(List<MaterialProperty> allProps)
    {
        //--------------

        EditorGUILayout.LabelField("Horizon:", EditorStyles.boldLabel);
        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty level1Color = allProps.Find(prop => prop.name == "_Level1Color");
        MaterialProperty level1 = allProps.Find(prop => prop.name == "_Level1");

        if (level1Color != null && level1 != null)
        {
            allProps.Remove(level1Color);
            allProps.Remove(level1);
            ShaderProperty(level1Color, level1Color.displayName);
            ShaderProperty(level1, level1.displayName);
        }

        DrawUILine(smLineColor, 1, smLinePadding);

        //--------------

        MaterialProperty level0Color = allProps.Find(prop => prop.name == "_Level0Color");
        MaterialProperty level0 = allProps.Find(prop => prop.name == "_Level0");

        if (level0Color != null && level0 != null)
        {
            allProps.Remove(level0Color);
            allProps.Remove(level0);
            ShaderProperty(level0Color, level0Color.displayName);
            ShaderProperty(level0, level0.displayName);
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
        EditorGUILayout.LabelField("#NVJOB Dynamic Sky (for Demo)", guiStyle);

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public static void Information()
    {
        //--------------

        if (GUILayout.Button("Full Asset #NVJOB Dynamic Sky")) Help.BrowseURL("https://nvjob.github.io/unity/nvjob-dynamic-sky-lite");
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


[CustomEditor(typeof(DynamicSkyForDemo))]
[CanEditMultipleObjects]

public class DynamicSkyForDemoEditor : Editor
{
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    Color smLineColor = Color.HSVToRGB(0, 0, 0.55f), bgLineColor = Color.HSVToRGB(0, 0, 0.3f);
    int smLinePadding = 20, bgLinePadding = 35;
    SerializedProperty uvRotateSpeed, uvRotateDistance, player;


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void OnEnable()
    {
        //--------------

        uvRotateSpeed = serializedObject.FindProperty("ssgUvRotateSpeed");
        uvRotateDistance = serializedObject.FindProperty("ssgUvRotateDistance");
        player = serializedObject.FindProperty("player");

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public override void OnInspectorGUI()
    {
        //--------------

        serializedObject.Update();

        //--------------

        EditorGUI.BeginChangeCheck();
        NVDSkyDemoMaterials.Header();
        NVDSkyDemoMaterials.DrawUILine(bgLineColor, 2, bgLinePadding);

        //--------------

        EditorGUILayout.LabelField("Sky Movement:", EditorStyles.boldLabel);
        NVDSkyDemoMaterials.DrawUILine(smLineColor, 1, smLinePadding);

        EditorGUILayout.PropertyField(uvRotateSpeed, new GUIContent("Rotate Speed"));
        EditorGUILayout.PropertyField(uvRotateDistance, new GUIContent("Rotate Distance"));

        NVDSkyDemoMaterials.DrawUILine(smLineColor, 1, smLinePadding);

        EditorGUILayout.PropertyField(player, new GUIContent("Player"));
        EditorGUILayout.HelpBox("Optional. To move the sky behind the player. X and Z axis only.", MessageType.None);

        //--------------

        serializedObject.ApplyModifiedProperties();

        NVDSkyDemoMaterials.DrawUILine(bgLineColor, 2, bgLinePadding);
        NVDSkyDemoMaterials.Information();

        EditorGUILayout.Space();
        EditorGUILayout.Space();

        //--------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}