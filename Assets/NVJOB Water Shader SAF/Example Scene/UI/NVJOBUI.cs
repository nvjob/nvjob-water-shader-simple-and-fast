// Copyright (c) 2016 Unity Technologies. MIT license - license_unity.txt
// #NVJOB Nicholas Veselov - https://nvjob.pro, http://nvjob.dx.am


using UnityEngine;
using UnityEngine.UI;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



public class NVJOBUI : MonoBehaviour
{
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    GameObject panelB;


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    private void Awake()
    {
        //---------------------------------

        panelB = transform.Find("Panel B").gameObject;
        transform.Find("Panel A/logo").GetComponent<Button>().onClick.AddListener(Logo);
        transform.Find("Panel A/donation").GetComponent<Button>().onClick.AddListener(Donation);
        transform.Find("Panel B/close").GetComponent<Button>().onClick.AddListener(Donation);
        transform.Find("Panel B/ko-fi").GetComponent<Button>().onClick.AddListener(KoFi);
        transform.Find("Panel B/liberapay").GetComponent<Button>().onClick.AddListener(Liberapay);
        transform.Find("Panel B/issuehunt").GetComponent<Button>().onClick.AddListener(Issuehunt);
        transform.Find("Panel B/paypal").GetComponent<Button>().onClick.AddListener(PayPal);
        transform.Find("Panel B/btc").GetComponent<Button>().onClick.AddListener(BTC);
        transform.Find("Panel B/thanks you").GetComponent<Button>().onClick.AddListener(ThanksYou);

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    void Logo()
    {
        //---------------------------------

        Application.OpenURL("https://assetstore.unity.com/packages/vfx/shaders/nvjob-water-shader-simple-and-fast-149916");

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    void Donation()
    {
        //---------------------------------

        if (panelB.activeSelf == true) panelB.SetActive(false);
        else panelB.SetActive(true);

        //---------------------------------
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    void KoFi()
    {
        //---------------------------------

        Application.OpenURL("https://ko-fi.com/nvjob_dev");

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    void Liberapay()
    {
        //---------------------------------

        Application.OpenURL("https://liberapay.com/nvjob");

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    void Issuehunt()
    {
        //---------------------------------

        Application.OpenURL("https://issuehunt.io/r/nvjob");

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    void PayPal()
    {
        //---------------------------------

        Application.OpenURL("https://www.paypal.me/nvjob");

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    void BTC()
    {
        //---------------------------------

        Application.OpenURL("https://btc.com/3NrN2GBmbZMaqEYPBtid1KeoHLmYE8HrCf");

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    void ThanksYou()
    {
        //---------------------------------

        Application.OpenURL("http://nvjob.pro/");

        //---------------------------------
    }



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
