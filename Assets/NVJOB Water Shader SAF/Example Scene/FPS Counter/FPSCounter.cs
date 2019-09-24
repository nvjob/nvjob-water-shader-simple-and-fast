// MIT license - license_nvjob.txt (basically, you can do whatever you want as long as you include the original copyright and license notice in any copy of the software/source)
// #NVJOB FPS counter and graph - simple and fast V1.2 - https://github.com/nvjob/Unity-FPS-Counter
// #NVJOB Nicholas Veselov (independent developer) - https://nvjob.pro, http://nvjob.dx.am


using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public class FPSCounter : MonoBehaviour
{
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public Text counterText;
    public Transform graph;
    public int frameUpdate = 60;
    public int highestPossibleFPS = 300;
    public float graphUpdate = 1.0f;
    public Color graphColor = new Color(1, 1, 1, 0.5f);

    //---------------------------------

    float ofsetX;
    int curCount, lineCount; 

    //---------------------------------

    static Transform stTr;
    static GameObject[] stLines;
    static int stNumLines;
    

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    

    void Awake()
    {
        //---------------------------------

        stTr = graph;
        stNumLines = 100;
        stLines = new GameObject[stNumLines];

        for (int i = 0; i < stNumLines; i++)
        {
            stLines[i] = new GameObject();
            stLines[i].SetActive(false);
            stLines[i].name = "Line_" + i;
            stLines[i].transform.parent = stTr;
            Image img = stLines[i].AddComponent<Image>();
            img.color = graphColor;
        }

        StartCoroutine(DrawGraph());

        //---------------------------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Update()
    {
        //---------------------------------

        curCount = StFPS.Counter(frameUpdate, Time.deltaTime);
        counterText.text = "FPS: " + curCount.ToString();

        //---------------------------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    IEnumerator DrawGraph()
    {
        //---------------------------------

        while (true)
        {
            yield return new WaitForSeconds(graphUpdate);

            GameObject obj = GiveLine();
            Image img = obj.GetComponent<Image>();
            img.rectTransform.anchorMin = new Vector2(ofsetX, 0);
            img.rectTransform.anchorMax = new Vector2(ofsetX + 0.01f, 1.0f / highestPossibleFPS * curCount);
            img.rectTransform.offsetMax = img.rectTransform.offsetMin = new Vector2(0, 0);
            obj.SetActive(true);

            if (lineCount++ > 49)
            {
                foreach (Transform child in graph) child.gameObject.SetActive(false);
                ofsetX = lineCount = 0;
            }
            else ofsetX += 0.02f;
        }

        //---------------------------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    static GameObject GiveLine()
    {
        //---------------------------------

        for (int i = 0; i < stNumLines; i++) if (!stLines[i].activeSelf) return stLines[i];
        return null;

        //---------------------------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public static class StFPS
{
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    static List<float> fpsBuffer = new List<float>();
    static float fpsB;
    static int fps;


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public static int Counter(int frameUpdate, float deltaTime)
    {
        //---------------------------------

        int fpsBCount = fpsBuffer.Count;

        if (fpsBCount <= frameUpdate) fpsBuffer.Add(1.0f / Time.deltaTime);
        else
        {
            for (int f = 0; f < fpsBCount; f++) fpsB += fpsBuffer[f];
            fpsBuffer = new List<float> { 1.0f / Time.deltaTime };
            fpsB = fpsB / fpsBCount;
            fps = Mathf.RoundToInt(fpsB);
            fpsB = 0;
        }

        return fps;

        //---------------------------------
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}