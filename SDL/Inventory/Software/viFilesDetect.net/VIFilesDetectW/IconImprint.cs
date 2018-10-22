#region One Identity - Open Source License
//
// One Identity - Open Source License
//
// Copyright 2018 One Identity LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software. Any and all copies of the above
// copyright and this permission notice contained in the Software shall not be
// removed, obscured, or modified.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
#endregion


using System;
using System.Runtime.InteropServices;

namespace VIFilesDetectW
{
	public class IconImprint
	{
		[DllImport("shell32.dll", CharSet = CharSet.Auto)]
		static extern uint ExtractIconEx(string szFileName, int nIconIndex,
		   IntPtr[] phiconLarge, IntPtr[] phiconSmall, uint nIcons);


		[StructLayout(LayoutKind.Sequential)]
		struct ICONINFO
		{
			public bool fIcon;         // Specifies whether this structure defines an icon or a cursor. A value of TRUE specifies
			// an icon; FALSE specifies a cursor.
			public Int32 xHotspot;     // Specifies the x-coordinate of a cursor's hot spot. If this structure defines an icon, the hot
			// spot is always in the center of the icon, and this member is ignored.
			public Int32 yHotspot;     // Specifies the y-coordinate of the cursor's hot spot. If this structure defines an icon, the hot
			// spot is always in the center of the icon, and this member is ignored.
			public IntPtr hbmMask;     // (HBITMAP) Specifies the icon bitmask bitmap. If this structure defines a black and white icon,
			// this bitmask is formatted so that the upper half is the icon AND bitmask and the lower half is
			// the icon XOR bitmask. Under this condition, the height should be an even multiple of two. If
			// this structure defines a color icon, this mask only defines the AND bitmask of the icon.
			public IntPtr hbmColor;    // (HBITMAP) Handle to the icon color bitmap. This member can be optional if this
			// structure defines a black and white icon. The AND bitmask of hbmMask is applied with the SRCAND
			// flag to the destination; subsequently, the color bitmap is applied (using XOR) to the
			// destination by using the SRCINVERT flag.
		}

		[DllImport("user32.dll")]
		static extern bool GetIconInfo(IntPtr hIcon, out ICONINFO piconinfo);

		[DllImport("gdi32.dll")]
		static extern int GetBitmapBits(IntPtr hbmp, int cbBuffer,
		   [Out] byte[] lpvBits);

		[DllImport("user32.dll", EntryPoint="DestroyIcon", SetLastError=true)]
	    static unsafe extern int DestroyIcon(IntPtr hIcon);

		public static uint GetCRCFromIcon( string strFile )
		{
			IntPtr[] vhIcon = new IntPtr[1];		// vector for iconhandles
			ICONINFO IconInfo;      // icon-info-structure
			bool bOk;
			uint iRet;
			uint ulIconCRC;


			// try to extract the icon
			iRet = ExtractIconEx( strFile, 0, vhIcon, null, 1 );

			// no icon found
			if ( iRet != 1)
			{
				return 0;
			}

			// get infostructure from icon
			bOk = GetIconInfo( vhIcon[0], out IconInfo );

			// process CRC
			ulIconCRC = GetCRCFromIcon( IconInfo.hbmColor );

			// cleanup the memory
			DestroyIcon(vhIcon[0]);

			return ulIconCRC;
		}


		private static uint GetCRCFromIcon( IntPtr hBitmap )
		{
			byte[] vBuffer = new byte[2048];
			int  iRet;
			uint ulCRC = 5381;
			uint iPos;

			// get bitmapbuffer from icon
			iRet = GetBitmapBits( hBitmap, 2048, vBuffer );

			// initialize the CRC
			ulCRC=5381;

			// itterate through buffer
			for(iPos=0; iPos<iRet; iPos++)
			{
				ulCRC = ((ulCRC << 5) + ulCRC) + vBuffer[iPos];
			}

			return ulCRC;
		}
	}
}
