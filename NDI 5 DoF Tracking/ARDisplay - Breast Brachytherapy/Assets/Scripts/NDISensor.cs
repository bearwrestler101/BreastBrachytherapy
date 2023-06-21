/*
 
    -----------------------
    UDP-Receive (send to)
    -----------------------
    // [url]http://msdn.microsoft.com/de-de/library/bb979228.aspx#ID0E3BAC[/url]

    // https://forum.unity.com/threads/simple-udp-implementation-send-read-via-mono-c.15900/
   
   
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

    Vector3 localPosition = new Vector3(0, 0, 0);
    Quaternion localRotation = new Quaternion(0, 0, 0, 1);
    Vector3 originPosition = new Vector3(0, 0, 0);
    Quaternion originRotation = new Quaternion(0, 0, 0, 1);

    public Vector3 EulerAngles = new Vector3(0, 0, 0);

    public Vector3 currentPosition = new Vector3(0, 0, 0);
    public Quaternion currentRotation = new Quaternion(0, 0, 0, 1);

    int counter = 1;

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
                
                float[] ddata = new float[data.Length / 8];
                for (int i = 0; i < ddata.Length; i++)
                {
                    ddata[i] = (float)BitConverter.ToDouble(data, i * 8);
                }

                //print(">>\n" + ddata[0] + "\n" + ddata[1] + "\n" + ddata[2] + "\n" + ddata[3] + "\n" + ddata[4] + "\n" + ddata[5] + "\n" + ddata[6]);
                localPosition = new Vector3(0.001f*ddata[0], 0.001f*ddata[1], 0.001f*ddata[2]);
                localPosition = ToPandaBase(localPosition);
                //print("Local position: " + localPosition.x + "\n" + localPosition.y + "\n" + localPosition.z);
                localPosition = new Vector3(100.0f * localPosition.x, 100.0f * localPosition.z, 100.0f * localPosition.y);

                //data comes in as quaternion, convert to euler angles, create matrices with euler angles, convert back to quaternion
                localRotation.Set(ddata[4], ddata[5], ddata[6], ddata[3]);
                EulerAngles = ToEulerAngles(localRotation);

                // Assignment has something to do with Unity using ZXY rotations
                //If you edit here, also edit ToCSV file
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

                localRotation.eulerAngles = tForm.rotation.eulerAngles;
                print(tForm.rotation.eulerAngles);

                // add tool status, error code -> change object color, add info to log
            }
            catch (Exception err)
            {
                print(err.ToString());
            }
        }
    }

    private static Vector3 ToEulerAngles(Quaternion q)
    {
        //https://stackoverflow.com/questions/70462758/c-sharp-how-to-convert-quaternions-to-euler-angles-xyz
        Vector3 angles = new Vector3();

        // roll / x
        double sinr_cosp = 2 * (q.w * q.x + q.y * q.z);
        double cosr_cosp = 1 - 2 * (q.x * q.x + q.y * q.y);
        angles.x = (float)Math.Atan2(sinr_cosp, cosr_cosp);

        // pitch / y
        double sinp = 2 * (q.w * q.y - q.z * q.x);
        if (Math.Abs(sinp) >= 1)
        {
            angles.y = (float)Math.Sign(sinp) * (float)Math.PI;
        }
        else
        {
            angles.y = (float)Math.Asin(sinp);
        }

        // yaw / z
        double siny_cosp = 2 * (q.w * q.z + q.x * q.y);
        double cosy_cosp = 1 - 2 * (q.y * q.y + q.z * q.z);
        angles.z = (float)Math.Atan2(siny_cosp, cosy_cosp);
        return angles;
        
    }

    private static Vector3 ToPandaBase(Vector3 pos)
    {
        double[,] transform = new double[4, 4] {
            //{ 0.0157, -0.0208, -0.9820, 0.0 }, 
            //{ 1.0071, 0.0053, 0.0197, 0.0 }, 
            //{ 0.0034, -1.0071, 0.0285, 0.0 }, 
            //{ 0.4598, -0.2811, 0.0175, 1.0 } };
            {0.1742, 0.9918, 0.5463, 0.0 },
            {0.8595, -0.7297, -0.0298, 0.0 },
            {-0.1544, -0.9591, -0.0756, 0.0 },
            {0.3959, -0.3642, 0.3008, 1.0 } };
        double[,] PosNeedleBase = new double[1, 4] { { pos.x, pos.y, pos.z, 1 } };
        double[,] PosPandaBase = MultiplyMatrix(PosNeedleBase, transform);
        Vector3 InPandaBase = new Vector3((float)PosPandaBase[0, 0], (float)PosPandaBase[0, 1], (float)PosPandaBase[0, 2]);
        return InPandaBase;
    }

    private static double[,] MultiplyMatrix(double[,] A, double[,] B)
    {
        // https://stackoverflow.com/questions/6311309/how-can-i-multiply-two-matrices-in-c
        int rA = A.GetLength(0);
        int cA = A.GetLength(1);
        int rB = B.GetLength(0);
        int cB = B.GetLength(1);

        if (cA != rB)
        {
            Console.WriteLine("Matrixes can't be multiplied!!");
            return null;
        }
        else
        {
            double temp = 0;
            double[,] kHasil = new double[rA, cB];

            for (int i = 0; i < rA; i++)
            {
                for (int j = 0; j < cB; j++)
                {
                    temp = 0;
                    for (int k = 0; k < cA; k++)
                    {
                        temp += A[i, k] * B[k, j];
                    }
                    kHasil[i, j] = temp;
                }
            }

            return kHasil;
        }
    }
    public void Update()
    {
        if (localPosition[0] != 0 && localPosition[1] != 0 && localPosition [2] != 0)
        {
            if (counter == 1)
            {
                originPosition = localPosition;
                originRotation = localRotation;
            }

            currentPosition = localPosition;
            //currentPosition = localPosition - originPosition;
            //currentRotation = localRotation * Quaternion.Inverse(originRotation);
            currentRotation = localRotation ;
            transform.localPosition = currentPosition;
            transform.localRotation = currentRotation;
            counter++;
        }
    }
}