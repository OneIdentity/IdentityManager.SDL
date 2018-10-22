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
using System.Net;
using System.Net.Sockets;
using System.Text.RegularExpressions;

using VI.Base;
using VI.Base.JobProcessing;


namespace VI.JobService.JobComponents
{
	//we derive our class from a standard one
	public class WOLClient: UdpClient
	{
		public WOLClient(): base()
		{ }

		//this is needed to send broadcast packet
		public void SetClientToBrodcastMode()
		{
			if (this.Active)
				this.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Broadcast, 0 );
		}
	}


	/// <summary>
	/// Summary description for MailComponent.
	/// </summary>
	public class WakeOnLanComponent : JobComponent
	{
		#region private members

		private static Regex _regRemoveZeros = new Regex(@"0*(?<val>\d+)", RegexOptions.CultureInvariant);

		#endregion // private members

		#region Constructor

		public WakeOnLanComponent()
		{
		}

		#endregion // Constructor

		#region Public members

		public override void Initialize()
		{
			base.Initialize();
		}

		public override void Activate(string task)
		{
			base.Activate(task);

			switch ( task.ToUpperInvariant() )
			{
				case "WAKEONLAN":
					_Task_WakeOnLan();
					break;

				default:
					throw new ViException(865001, task);
			}

			Result.ReturnCode = JobReturnCode.OK;
		}

		#endregion // Public members

		#region Task_ members

		private void _Task_WakeOnLan()
		{
			// check required parameters
			CheckRequiredParameters("MACID");

			IPAddress ipBroadCast;

			if ( Parameters.Contains("IPAddress") && Parameters.Contains("SubNetMask") )
			{
				// Build the BroadcastAddress
				ipBroadCast = _BuildBroadCastAddress( Parameters["IPAddress"].Value, Parameters["SubNetMask"].Value );
			}
			else if ( Parameters.Contains("BroadCastIPAddress") )
			{
				// get the BroadcastAddress
				ipBroadCast = _SafeParse( Parameters["BroadCastIPAddress"].Value );
			}
			else
			{
				// invalid parameter
				throw new ViException( 865003 );
			}

			// build the Wake-On-LAN Header
			byte[] vMagicHeader = _BuildMagicFrameHeader( Parameters["MACID"].Value );

			WOLClient client = new WOLClient();

			client.Connect(	ipBroadCast, 0); // port=12287 let's use this one   - 0x2fff

			client.SetClientToBrodcastMode();

			//now send wake up packet
			int reterned_value = client.Send(vMagicHeader, 1024);
		}

		#endregion

		#region Additional Members

		/// <summary>
		/// Create Magic WakeOnLAN-Header
		/// </summary>
		/// <param name="strMACID"></param>
		/// <returns></returns>
		private static byte[] _BuildMagicFrameHeader( string strMACID )
		{
			byte[]  vMacID  = new byte[6];	// Buffer for MACID
			byte[]  vReturn = new byte[1024];
			int     iCo = 0;

			// head --> 6 x 0xFF
			for (iCo = 0; iCo < 6; iCo ++)
				vReturn[iCo] = (byte) 0xff;		// magic frame header

			// build the MACID-Buffer
			for (iCo = 0; iCo < 6; iCo++)
			{
				vMacID[iCo] = Convert.ToByte( strMACID.Substring(iCo * 2, 2), 16 );
			}

			// body --> 16 x MACID
			for (iCo = 0; iCo < 16; iCo++)
			{
				Buffer.BlockCopy(vMacID, 0, vReturn, (iCo * 6) + 6, 6);
			}

			return vReturn;
		}

		private static IPAddress _BuildBroadCastAddress( string strIPAddress, string strSubNetMask )
		{
			IPAddress ipAddress = _SafeParse( strIPAddress );
			IPAddress ipReturn  = null;

			switch ( ipAddress.AddressFamily )
			{
				case AddressFamily.InterNetwork:
					long lipAddress = ipAddress.Address;
					long lipSubNet = _SafeParse( strSubNetMask ).Address;
					long lipBroadCast;

					lipBroadCast = lipAddress | (~lipSubNet) & 0x00000000FFFFFFFF;

					ipReturn = new IPAddress( lipBroadCast );

					break;

				case AddressFamily.InterNetworkV6:
					byte[] vipAddress = ipAddress.GetAddressBytes();
					byte[] vipSubNet = _SafeParse( strSubNetMask ).GetAddressBytes();
					byte[] vipBroadCast = new byte[vipAddress.GetLength(0)];

					for ( int i = 0; i < vipAddress.GetLength(0); i++ )
					{
						vipBroadCast[i] = (byte) (vipAddress[i] | (~vipSubNet[i]));
					}

					ipReturn = new IPAddress( vipBroadCast );

					break;

				default:
					throw new FormatException( String.Format("{0} is not a valid IP address.", strIPAddress ) );
			}

			return ipReturn;
		}

		private static IPAddress _SafeParse(string address)
		{
			if ( string.IsNullOrEmpty(address) )
				throw new ArgumentNullException("address");

			// Remove leading zeros to avoid oktal problem (#11611)
			string normalized = _regRemoveZeros.Replace(address, "${val}");

			return IPAddress.Parse(normalized);
		}

		#endregion
	}
}
