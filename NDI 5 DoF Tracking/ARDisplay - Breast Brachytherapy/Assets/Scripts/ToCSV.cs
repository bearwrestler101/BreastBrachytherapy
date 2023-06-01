using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Threading;
using System.Net.Sockets;
using System.Diagnostics;

//https://www.youtube.com/watch?v=sU_Y2g1Nidk
//https://stackoverflow.com/questions/62598952/exporting-in-game-data-to-csv-in-unity - don't think I used this

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
        tw.WriteLine("Time, NDI.Pos.x, NDI.Pos.y, NDI.Pos.z, NDI.Eul.x, NDI.Eul.y, NDI.Eul.z," +
            "Panda.Pos.x, Panda.Pos.y, Panda.Pos.z, Panda.Eul.x, Panda.Eul.y, Panda.Eul.z," +
            "Motoman.Pos.x, Motoman.Pos.y, Motoman.Pos.z, Motoman.Eul.x, Motoman.Eul.y, Motoman.Eul.z," +
            "Seroma.x, Seroma.y, Seroma.z," +
            "Click");
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

        //Pretty sure this is wrong because not supposed to request EulerAngles from Unity as it does its own calculation
        UnityEulerAngles = toUnityEulerAngles(NDIsens.EulerAngles);
        //Convert Euler angles from 0-360 to -180-180
        UnityEulerAngles.x = Mathf.Repeat(UnityEulerAngles.x + 180, 360) - 180;
        UnityEulerAngles.y = Mathf.Repeat(UnityEulerAngles.y + 180, 360) - 180;
        UnityEulerAngles.z = Mathf.Repeat(UnityEulerAngles.z + 180, 360) - 180;

        //track mouse clicks for seed depositing - does not track if held down
        int Click = 0;
        if (Input.GetMouseButtonDown(0))
        {
            Click = 1; 
        }

        //Read stopwatch
        TimeSpan ts = timer.Elapsed;
        print(ts);

        tw.WriteLine(ts
        + "," + NDIsens.currentPosition.x / 100
        + "," + NDIsens.currentPosition.z / 100
        + "," + NDIsens.currentPosition.y / 100
        + "," + UnityEulerAngles.x
        + "," + UnityEulerAngles.y
        + "," + UnityEulerAngles.z
        + "," + PandaPos.x
        + "," + PandaPos.y
        + "," + PandaPos.z
        + "," + PandaRot.x
        + "," + PandaRot.y
        + "," + PandaRot.z
        + "," + MotomanPos.x
        + "," + MotomanPos.y
        + "," + MotomanPos.z
        + "," + MotomanRot.x
        + "," + MotomanRot.y
        + "," + MotomanRot.z
        + "," + Seroma.transform.position.x / 100
        + "," + Seroma.transform.position.y / 100
        + "," + Seroma.transform.position.z / 100
        + "," + Click

        );
        Click = 0;
        tw.Close();
    }
    private static Vector3 toUnityEulerAngles(Vector3 EulerAngles) {
        //If you edit here, also edit NDISensor file
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
    Thread sendThread;
    UdpClient client;
    UdpClient clientSend;
    public int port;
    public int sendPort;
    private string sendIP;
    private Vector3 PandaPos;
    private Vector3 PandaRot;
    private Vector3 MotomanPos;
    private Vector3 MotomanRot;
    public GameObject Seroma;

    private void init()
    {
        // define port
        port = 35000;
        sendPort = 1508;
        sendIP = "10.1.38.190";

        // status
        print("Sending to 10.1.38.190: " + port);
        print("Test-Sending to this Port: nc -u 10.1.38.190  " + port + "");

        receiveThread = new Thread(
            new ThreadStart(ReceiveData));
        receiveThread.IsBackground = true;
        receiveThread.Start();

        sendThread = new Thread(
            new ThreadStart(SendData));
        sendThread.IsBackground = true;
        sendThread.Start();
    }
    // Same as in NDISensor, to record NDI sensor Euler angles
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
                PandaPos = new Vector3(ddata[0], ddata[1], ddata[2]);
                PandaRot = new Vector3(ddata[3], ddata[4], ddata[5]);
                MotomanPos = new Vector3(ddata[6], ddata[7], ddata[8]);
                MotomanRot = new Vector3(ddata[9], ddata[10], ddata[11]);

            }
            catch (Exception err)
            {
                print(err.ToString());
            }
        }
    }

    //sending the y-axis rotation of the needle to rotate US probe
    private void SendData()
    {
        clientSend = new UdpClient(sendPort);
        while (true)
        {
            try
            {
                IPEndPoint pandaPC = new IPEndPoint(IPAddress.Parse(sendIP), sendPort);

                byte[] sendData = BitConverter.GetBytes((double)UnityEulerAngles.y);

                clientSend.Send(sendData, sendData.Length, pandaPC);

            }
            catch (Exception err)
            {
                print(err.ToString());
            }
        }
    }
}


