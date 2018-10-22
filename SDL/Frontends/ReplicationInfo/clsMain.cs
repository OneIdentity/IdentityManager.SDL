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
using System.Collections;
using System.Windows.Forms;
using System.Threading;

using VI.DB;
using VI.Base;

namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Summary description for clsMain.
	/// </summary>
	public class clsMain
	{
		private static clsMain _instance = null;

		private ConnectData      _currentConnection = null;

		private string           _queueName = "JobQueue";
		private bool             _errorOnly = false;
		private int              _timeout   = 24;
		private string           _domainfilter = "";

		private volatile object	 _sync = new object();


		public event EventHandler ConnectionChanged;


		private clsMain()
		{
			//
			// TODO: Add constructor logic here
			//
		}

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main()
		{
			Thread.CurrentThread.Name = "Main thread";

			Application.EnableVisualStyles();
			Application.DoEvents();	// Enable toolbar buttons (http://windowsforms.net/Forums/ShowPost.aspx?tabIndex=1&tabId=41&PostID=604)

			Application.Run(new frmMain());
		}

		public static clsMain Instance
		{
			get
			{
				if (_instance == null)
				{
					_instance = new clsMain();
				}

				return _instance;
			}
		}

		public string QueueName
		{
			get { return _queueName;  }
			set { _queueName = value; }
		}


		public ConnectData CurrentConnection
		{
			get { return _currentConnection;  }
			set
			{
				if ( value != _currentConnection )
				{
					_currentConnection = value;

					if ( ConnectionChanged != null )
						ConnectionChanged(this, new EventArgs() );
				}
			}
		}

		public string DomainFilter
		{
			get { return _domainfilter;  }
			set { _domainfilter = value; }
		}

		public void Save()
		{
			IConfigData	conf = AppData.Instance.Config( "Settings", false);

			conf.Put("DomainFilter", _domainfilter );

			//conf.Put( "Language",   LanguageManager.Instance.Language );
		}

		public void Load()
		{
			IConfigData	conf = AppData.Instance.Config( "Settings", false);

			if ( conf.Get("DomainFilter").Length > 0)
				_domainfilter =  conf.Get("DomainFilter");

			//if ( conf.Get("Language").Length > 0)
			//	LanguageManager.Instance.Language = conf.Get("Language");
		}

		public static Hashtable DBSystems
		{
			get
			{
				Hashtable ht = new Hashtable();

				ht.Add("SQL-Server", "VI.DB.ViSqlFactory, VI.DB");
				ht.Add("Oracle"    , "VI.DB.Oracle.ViOracleFactory, VI.DB.Oracle");

				return ht;
			}
		}

		public bool ErrorOnly
		{
			get { return _errorOnly;  }
			set { _errorOnly = value; }
		}


		public int TimeOut
		{
			get { return _timeout;  }
			set { _timeout = value; }
		}
	}
}
