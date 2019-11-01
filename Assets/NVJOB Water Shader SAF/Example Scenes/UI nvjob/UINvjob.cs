using System.Collections;
using UnityEngine;
using UnityEngine.UI;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public class UINvjob : MonoBehaviour
{
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    GameObject logo, donation, report;
    static WaitForSeconds delay0 = new WaitForSeconds(4.0f);


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Awake()
    {
        //---------------------------------

        logo = transform.Find("Panel/logo").gameObject;
        donation = transform.Find("Panel/donation").gameObject;
        report = transform.Find("Panel/report").gameObject;
        
        logo.GetComponent<Button>().onClick.AddListener(Logo);
        donation.GetComponent<Button>().onClick.AddListener(Donation);
        report.GetComponent<Button>().onClick.AddListener(Report);

        StartCoroutine("_Rotation");

        //---------------------------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    IEnumerator _Rotation()
    {
        //--------------

        while (true)
        {
            logo.SetActive(true);
            donation.SetActive(false);
            report.SetActive(false);
            yield return delay0;
            logo.SetActive(false);
            donation.SetActive(true);
            report.SetActive(false);
            yield return delay0;
            logo.SetActive(false);
            donation.SetActive(false);
            report.SetActive(true);
            yield return delay0;
        }

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    void Logo()
    {
        //--------------

        Application.OpenURL("https://nvjob.github.io/unity/nvjob-water-shader");

        //--------------
    }

    void Donation()
    {
        //--------------

        Application.OpenURL("https://nvjob.github.io/donate");

        //--------------
    }

    void Report()
    {
        //--------------

        Application.OpenURL("https://nvjob.github.io/reportaproblem/");

        //--------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
