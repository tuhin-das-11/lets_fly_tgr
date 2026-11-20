using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace LetsFlyTgr.FocusMonitor
{
    /// <summary>
    /// Lightweight Windows Native Focus Monitor.
    /// Tracks the active foreground window and detects distracting processes
    /// transparently during study sessions without low-level root hooks.
    /// </summary>
    public class FocusMonitor
    {
        [DllImport("user32.dll")]
        private static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll", SetLastError = true)]
        private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

        private readonly HashSet<string> _blocklist;
        private bool _isRunning;

        public FocusMonitor(IEnumerable<string> blockedProcessNames)
        {
            _blocklist = new HashSet<string>(blockedProcessNames, StringComparer.OrdinalIgnoreCase);
        }

        public void Start()
        {
            _isRunning = true;
            Console.WriteLine("[LET'S FLY TGR] Windows Focus Shield Active.");

            while (_isRunning)
            {
                IntPtr hWnd = GetForegroundWindow();
                if (hWnd != IntPtr.Zero)
                {
                    GetWindowThreadProcessId(hWnd, out uint processId);
                    try
                    {
                        using (Process proc = Process.GetProcessById((int)processId))
                        {
                            string procName = proc.ProcessName;
                            if (_blocklist.Contains(procName))
                            {
                                Console.WriteLine($"[SHIELD] Distracting application detected: {procName}. Re-engaging focus.");
                                // Transparent intervention: restore focus or notify student
                            }
                        }
                    }
                    catch
                    {
                        // Process exited or access restriction
                    }
                }
                Thread.Sleep(1000);
            }
        }

        public void Stop()
        {
            _isRunning = false;
        }
    }
}
