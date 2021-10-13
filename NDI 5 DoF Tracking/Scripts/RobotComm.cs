using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using UnityEngine;
using System.Diagnostics;

public class RobotComm : MonoBehaviour
{
    readonly object signalLock = new object();
    readonly object dataLock = new object();
    bool signalStop = false;
    Thread commThread;

    //UDP Client Listener Variables
    //public String Address = "127.0.0.1";
    public int LocalPort = 20000;
    //public int RemotePort = 0;
    int UDPRecvTimeOut = 100;
    
    //Gameobject Updaters
    public Vector3 RobotPosition = new Vector3(0, 0, 0);
    public Quaternion RobotRotation = new Quaternion(0, 0, 0, 1);
    public int RobotPlane = 0;
    //Kinect Unity Transform
    //static Matrix4x4 Trans_kin = new Matrix4x4(new Vector4(3.9247f, 2.0078f, -2.2426f, 0.0000f), new Vector4(-60.7463f, 81.3727f, 32.0765f, 0.0000f), new Vector4(31.0808f, 1.4579f, 38.4086f, -0.0000f), new Vector4(-37.7617f, 62.7370f, -123.8510f, 1.0000f));

    Vector3 dataPosition;
    Quaternion dataRotation;

    Stopwatch timer = new Stopwatch();

    void ThreadCode()
    {
        //Setup Socket for TCP Client
        byte[] msgBuffer = new byte[4096];
        int msgRecvLen = 0;
        IPEndPoint endPoint;
        Socket sock;
        endPoint = new IPEndPoint(IPAddress.Any, LocalPort);
        sock = new Socket(endPoint.AddressFamily, SocketType.Dgram, ProtocolType.Udp);

        //IPEndPoint sender = new IPEndPoint(IPAddress.Parse(Address), RemotePort);
        //EndPoint senderRemote = (EndPoint)sender;

        int CurrentPlane = 0;
        float[] data = new float[6];

        String debugData;

        try
        {
            sock.Bind(endPoint);
        }
        catch (SocketException ex)
        {
            UnityEngine.Debug.LogWarning(String.Format("UDP Connection Failed: {0}", ex.ToString()));
            return;
        }
        UnityEngine.Debug.Log(String.Format("UDP Bound: Port {0}", LocalPort));
        sock.ReceiveTimeout = UDPRecvTimeOut;

        bool runLoop = true;
        //bool getData = false;
        while (runLoop)
        {
            msgRecvLen = 0;
            //Get Packet or Time Out
            try
            {
                msgRecvLen = sock.Receive(msgBuffer, 0, 7*sizeof(double), SocketFlags.None); //TODO: Change to 7 Doubles
            }
            catch (SocketException ex)
            {
                if (ex.ErrorCode != (int)SocketError.TimedOut)
                {
                    UnityEngine.Debug.LogWarning(String.Format("Socket Recv Error: {0}", ex.ToString()));
                    runLoop = false;
                    break;
                }
            }

            if (msgRecvLen > 0)
            {
                //Parse Data
                //TimeStamp = GetSingle(ref msgBuffer, 0);
                debugData = String.Format("Recved Data:");
                for (int ii = 0; ii < 6; ii++)
                {
                    data[ii] = (float)GetDouble(ref msgBuffer, sizeof(double)* ii);
                    debugData = debugData + String.Format(", {0:F6}",data[ii]);
                }

                CurrentPlane = Mathf.RoundToInt((float)GetDouble(ref msgBuffer, sizeof(double) * 6));

                Quaternion Qz = new Quaternion();
                Qz.eulerAngles = new Vector3(0, 0, -data[4] * Mathf.Rad2Deg);
                Quaternion Qy = new Quaternion();
                Qy.eulerAngles = new Vector3(0, -data[5] * Mathf.Rad2Deg, 0);
                Quaternion Qx = new Quaternion();
                Qx.eulerAngles = new Vector3(-data[3] * Mathf.Rad2Deg, 0, 0);

                Matrix4x4 Rz = Matrix4x4.Rotate(Qz);
                Matrix4x4 Ry = Matrix4x4.Rotate(Qy);
                Matrix4x4 Rx = Matrix4x4.Rotate(Qx);
                Matrix4x4 tForm = Rz * Ry * Rx;

                //Quaternion rotValue = new Quaternion();
                //Vector3 eulAng = tForm.rotation.eulerAngles;

                //Robot to Unity frame transform done here
                dataPosition = new Vector3(100.0f * data[0], 100.0f * data[2], 100.0f * data[1]);
                dataRotation.eulerAngles = tForm.rotation.eulerAngles;
                //dataRotation.eulerAngles = new Vector3(-data[3] * Mathf.Rad2Deg, -data[5] * Mathf.Rad2Deg, -data[4] * Mathf.Rad2Deg);
                //dataRotation.eulerAngles = new Vector3(-data[4]*Mathf.Rad2Deg, -data[5] * Mathf.Rad2Deg, -data[3] * Mathf.Rad2Deg);
                //dataPosition = KinectPositionToUnity(dataPosition);

                //dataPosition = PLUSPositionToUnity(dataPosition);
                //UnityEngine.Debug.Log(debugData);

                lock (dataLock)
                {
                    RobotPosition = dataPosition;
                    RobotRotation = dataRotation;
                    RobotPlane = CurrentPlane;
                }
            }

            //Thread.Sleep(50);
            lock (signalLock)
            {
                if(signalStop)
                {
                    runLoop = false;
                }
            }
        }

        //Cleanup Code on Shutdown
        sock.Close();
    }

    public static UInt16 GetUInt16(ref byte[] data, int ind, bool swapEndianess = false)
    {
        if (!swapEndianess)
        {
            return BitConverter.ToUInt16(data, ind);
        }
        else
        {
            return (UInt16)IPAddress.NetworkToHostOrder(BitConverter.ToUInt16(data, ind));
        }
    }

    public static UInt64 GetUInt64(ref byte[] data, int ind, bool swapEndianess = false)
    {
        if (!swapEndianess)
        {
            return BitConverter.ToUInt64(data, ind);
        }
        else
        {
            return (UInt64)IPAddress.NetworkToHostOrder(BitConverter.ToInt64(data, ind));
        }
    }

    public static Single GetSingle(ref byte[] data, int ind, bool swapEndianess = false)
    {
        byte[] bytes = new byte[sizeof(Single)];
        for (int ii = 0; ii < sizeof(Single); ii++)
        {
            bytes[ii] = data[ind + ii];
        }
        if (!swapEndianess)
        {
            return BitConverter.ToSingle(bytes, 0);
        }
        else
        {
            Array.Reverse(bytes);
            return BitConverter.ToSingle(bytes, 0);
        }
    }

    public static Double GetDouble(ref byte[] data, int ind, bool swapEndianess = false)
    {
        byte[] bytes = new byte[sizeof(Double)];
        for (int ii = 0; ii < sizeof(Double); ii++)
        {
            bytes[ii] = data[ind + ii];
        }
        if (!swapEndianess)
        {
            return BitConverter.ToDouble(bytes, 0);
        }
        else
        {
            Array.Reverse(bytes);
            return BitConverter.ToDouble(bytes, 0);
        }
    }

    public static String GetString(ref byte[] data, int ind, int len)
    {
        return System.Text.Encoding.ASCII.GetString(data, ind, len).Trim('\0');
    }

    public Vector3 GetRobotPosition()
    {
        lock(dataLock)
        {
            return RobotPosition;
        }
    }

    public Quaternion GetRobotRotation()
    {
        lock(dataLock)
        {
            return RobotRotation;
        }
    }

    public int GetRobotPlane()
    {
        lock (dataLock)
        {
            return RobotPlane;
        }
    }


    /*public static Vector3 KinectPositionToUnity(Vector3 KinectPosition)
    {
        //Vector3 unityPosition = new Vector3(0, 0, 0);

        //Vector3 unityPosition = Trans_kin.MultiplyPoint(KinectPosition);
        //unityPosition.x = KinectPosition.x * 100.0f;
        //unityPosition.y = KinectPosition.y * 100.0f;
        //unityPosition.z = -1.0f * KinectPosition.z * 100.0f;

        return unityPosition;
    }*/


    // Start is called before the first frame update
    void Start()
    {
        //Start TCP Thread
        commThread = new Thread(new ThreadStart(ThreadCode));
        commThread.Start();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnApplicationQuit()
    {
        UnityEngine.Debug.Log("Sending Thread Shutdown Code");
        lock(signalLock)
        {
            signalStop = true;
        }
        Thread.Sleep(500);
        if (commThread.ThreadState != System.Threading.ThreadState.Stopped)
        {
            UnityEngine.Debug.Log("Sending Thread Abort");
            commThread.Abort();
        }
        else
        {
            UnityEngine.Debug.Log("Thread Stopped Properly");
        }
        //Console.WriteLine("ThreadState: {0}", newThread.ThreadState);
    }
}
