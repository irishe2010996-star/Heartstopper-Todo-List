using System;
using System.IO;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Threading;

public static class WidgetScrollbarDragV2 {
    [StructLayout(LayoutKind.Sequential)] struct Point { public int X,Y; }
    [StructLayout(LayoutKind.Sequential)] struct CopyData { public IntPtr Data; public int Size; public IntPtr Text; }
    [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern IntPtr FindWindow(string c,string t);
    [DllImport("user32.dll")] static extern bool GetCursorPos(out Point p);
    [DllImport("user32.dll")] static extern short GetAsyncKeyState(int k);
    [DllImport("user32.dll")] static extern int GetSystemMetrics(int k);
    [DllImport("user32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern IntPtr SendMessageTimeout(IntPtr h,uint m,IntPtr w,ref CopyData d,uint f,uint t,out IntPtr result);
    static void Log(string text) {
        try { File.WriteAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"scroll-drag-status.txt"),DateTime.Now.ToString("s")+" "+text); } catch { }
    }
    static void Send(IntPtr h,string action) {
        string command="[!CommandMeasure WidgetScroll \""+action+"\" ToDo]";
        IntPtr p=Marshal.StringToHGlobalUni(command);
        try {
            CopyData d=new CopyData {Data=(IntPtr)1,Size=(command.Length+1)*2,Text=p};
            IntPtr result;
            if(SendMessageTimeout(h,0x004A,IntPtr.Zero,ref d,2,300,out result)==IntPtr.Zero)
                throw new InvalidOperationException("Rainmeter message failed: "+Marshal.GetLastWin32Error());
        } finally { Marshal.FreeHGlobal(p); }
    }
    [STAThread] public static void Main() {
        try {
            Log("STARTED");
            IntPtr h=FindWindow("DummyRainWClass","Rainmeter control window");
            if(h==IntPtr.Zero) { Log("RAINMETER_WINDOW_NOT_FOUND");return; }
            int button=GetSystemMetrics(23)!=0 ? 2 : 1;
            Point origin;
            if(!GetCursorPos(out origin)) { Log("CURSOR_READ_FAILED");return; }
            if((GetAsyncKeyState(button)&0x8000)==0) { Log("BUTTON_RELEASED_BEFORE_START");return; }
            Send(h,"BeginDrag()");
            int previous=origin.Y,count=0;
            Log("TRACKING");
            DateTime limit=DateTime.UtcNow.AddSeconds(60);
            try {
                while((GetAsyncKeyState(button)&0x8000)!=0 && DateTime.UtcNow<limit) {
                    Point p;
                    if(!GetCursorPos(out p)) break;
                    if(p.Y!=previous) {
                        Send(h,"DragTo("+(p.Y-origin.Y).ToString(CultureInfo.InvariantCulture)+")");
                        previous=p.Y;count++;
                    }
                    Thread.Sleep(20);
                }
            } finally { Send(h,"EndDrag()"); }
            Log("ENDED movements="+count);
        } catch(Exception ex) { Log("ERROR "+ex.Message); }
    }
}
