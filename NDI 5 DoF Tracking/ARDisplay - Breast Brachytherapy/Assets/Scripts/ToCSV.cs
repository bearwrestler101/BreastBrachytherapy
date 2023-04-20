using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Threading;
using System.Net.Sockets;
using System.Diagnostics;

public class ToCSV : MonoBehaviour
{
    string filename = "";
    public GameObject NDI;
    private Vector3 UnityEulerAngles = new Vector3(0, 0, 0);
    private Stopwatch timer;

    // Start is called before the first frame update
    void Start()
    {
        init();
        filename = Application.dataPath + "/test.csv";
        timer = new Stopwatch();
        timer.Start();

        TextWriter tw = new StreamWriter(filename, false);
        tw.WriteLine(", NDI.pos.x, NDI.pos.y, NDI.pos.z,NDI.Eul.x, NDI.Eul.y, NDI.Eul.z, Seroma, Click");
        tw.Close();

    }

    // Update is called once per frame
    void Update()
    {
        WriteCSV();
    }

    public void WriteCSV()
    {
        TextWriter tw = new StreamWriter(filename, true);
        NDISensor NDIsens = NDI.GetComponent<NDISensor>();
        UnityEulerAngles = toUnityEulerAngles(NDIsens.EulerAngles);

        //track mouse clicks for seed depositing - does not track hold
        int Click = 0;
        if (Input.GetMouseButtonDown(0))
        {
            Click = 1; 
        }

        tw.WriteLine(timer
        + "," + NDIsens.currentPosition.x / 100
        + "," + NDIsens.currentPosition.y / 100
        + "," + NDIsens.currentPosition.z / 100
        + "," + UnityEulerAngles.x
        + "," + UnityEulerAngles.y
        + "," + UnityEulerAngles.z
        + "," + PandaPos.x
        + "," + PandaPos.y
        + "," + PandaPos.z
        + "," + PandaRot.x
        + "," + PandaRot.y
        + "," + PandaRot.z
        + "," + Click

        );
        Click = 0;
        tw.Close();
    }
    private static Vector3 toUnityEulerAngles(Vector3 EulerAngles) {
        Quaternion Qz = new Quaternion();
        Qz.eulerAngles = new Vector3(0, 0, EulerAngles.z * Mathf.Rad2Deg);
        Quaternion Qy = new Quaternion();
        Qy.eulerAngles = new Vector3(0, EulerAngles.x * Mathf.Rad2Deg, 0);
        Quaternion Qx = new Quaternion();
        Qx.eulerAngles = new Vector3(EulerAngles.y * Mathf.Rad2Deg, 0, 0);

        Matrix4x4 Rz = Matrix4x4.Rotate(Qz);
        Matrix4x4 Ry = Matrix4x4.Rotate(Qy);
        Matrix4x4 Rx = Matrix4x4.Rotate(Qx);
        Matrix4x4 tForm = Rz * Ry * Rx;
        return tForm.rotation.eulerAngles;
    }

    Thread receiveThread;
    UdpClient client;
    public int port;
    private Vector3 PandaPos;
    private Vector3 PandaRot;


    private void init()
    {
        // define port
        port = 35000;

        // status
        print("Sending to 10.1.38.190: " + port);
        print("Test-Sending to this Port: nc -u 10.1.38.190  " + port + "");

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
                IPEndPoint anyIP = new IPEndPoint(IPAddress.Any, port);
                byte[] data = client.Receive(ref anyIP);
                
                float[] ddata = new float[data.Length / 8];
                
                for (int i = 0; i < ddata.Length; i++)
                {
                    ddata[i] = (float)BitConverter.ToDouble(data, i * 8);
                }
                PandaPos = new Vector3(ddata[0],ddata[1],ddata[2]);
                PandaRot = new Vector3(ddata[3], ddata[4], ddata[5]);

            }
            catch (Exception err)
            {
                print(err.ToString());
            }
        }
    }
}

