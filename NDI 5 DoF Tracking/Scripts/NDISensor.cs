/*
 
    -----------------------
    UDP-Receive (send to)
    -----------------------
    // [url]http://msdn.microsoft.com/de-de/library/bb979228.aspx#ID0E3BAC[/url]
   
   
    // > receive
    // 127.0.0.1 : 8051
   
    // send
    // nc -u 127.0.0.1 8051
 
*/
using UnityEngine;
using System.Collections;

using System;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;

public class NDISensor : MonoBehaviour
{

    // receiving Thread
    Thread receiveThread;

    // udpclient object
    UdpClient client;

    // public
    // public string IP = "127.0.0.1"; default local
    public int port; // define > init

    public GameObject NeedleTip;
    public Vector3 NeedleTipPos = new Vector3(0, 0, 0);
    Vector3 dataPosition;
    
    // start from shell
    private static void Main()
    {
        NDISensor receiveObj = new NDISensor();
        receiveObj.init();

        string text = "";
        do
        {
            text = Console.ReadLine();
        }
        while (!text.Equals("exit"));
    }
    // start from unity3d
    public void Start()
    {

        init();
    }
    // init
    private void init()
    {
        // define port
        port = 1501;

        // status
        print("Sending to 127.0.0.1 : " + port);
        print("Test-Sending to this Port: nc -u 127.0.0.1  " + port + "");

        receiveThread = new Thread(
            new ThreadStart(ReceiveData));
        receiveThread.IsBackground = true;
        receiveThread.Start();
    }

    // receive thread
    private void ReceiveData()
    {

        client = new UdpClient(port);
        while (true)
        {

            try
            {
                // Bytes empfangen.
                IPEndPoint anyIP = new IPEndPoint(IPAddress.Any, 1500);
                byte[] data = client.Receive(ref anyIP);

                print(data.Length);
                double[] ddata = new double[data.Length / 8];
                for (int i = 0; i < ddata.Length; i++)
                {
                    ddata[i] = BitConverter.ToDouble(data, i * 8);
                }

                print(">>\n" + ddata[0] + "\n" + ddata[1] + "\n" + ddata[2] + "\n" + ddata[3] + "\n" + ddata[4] + "\n" + ddata[5] + "\n" + ddata[6]);
                dataPosition = new Vector3((float)ddata[0], (float)ddata[1], (float)ddata[2]);
                 
            }
            catch (Exception err)
            {
                print(err.ToString());
            }
        }
    }
    public void Update()
    {
        transform.NeedleTipPos = dataPosition;
    }
}