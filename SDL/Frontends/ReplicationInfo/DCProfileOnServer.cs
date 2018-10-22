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
using System.Windows.Forms;
using System.Data;
using System.Threading;
using System.Diagnostics;

using VI.Base;
using VI.DB;
using VI.Controls;
using VI.CommonDialogs;


namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Summary description for frmJobHistory.
	/// </summary>
	public class DCProfileOnServer : UserControl
	{
		private System.ComponentModel.IContainer components;

		private System.Windows.Forms.ContextMenu cmPopup;
		private System.Windows.Forms.Panel panelServer;
		private System.Windows.Forms.Splitter splitter1;
		private System.Windows.Forms.Panel panelProfile;
		private System.Windows.Forms.ImageList imglProfile;

		private Thread m_JobQueueThread = null;
		private System.Windows.Forms.MenuItem mnuPopup_Copy;
		private VI.Controls.TreeListControl tlcProfile;
		private VI.Controls.TreeListControl tlcServer;
		private System.Windows.Forms.ImageList imglServer;

		TreeListNode m_tlnProfile = null;

		public DCProfileOnServer()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			_TranslateForm();

			_LoadFormSettings();

			clsMain.Instance.ConnectionChanged += new EventHandler(clsMain_ConnectionChanged);
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			clsMain.Instance.ConnectionChanged -= new EventHandler(clsMain_ConnectionChanged);

			if ( disposing )
			{
				if (components != null)
				{
					components.Dispose();
				}
			}

			base.Dispose( disposing );
		}

		protected override void OnHandleDestroyed(EventArgs e)
		{
			_SaveFormSettings();

			base.OnHandleDestroyed (e);
		}


		/// <summary>
		/// Translate all languagedepending strings
		/// </summary>
		private void _TranslateForm()
		{
			Text = LanguageManager.Instance.GetString( "frmProfileOnServer_Caption" );

			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmProfileOnServer_ColumnDomain" ), 300 ) );
			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmProfileOnServer_ColumnVersionSoll" ) , 60 ) );

			tlcServer.Columns.Add ( new TreeListColumn( LanguageManager.Instance.GetString( "frmProfileOnServer_ColumnServer" ), 200 ) );
			tlcServer.Columns.Add ( new TreeListColumn( LanguageManager.Instance.GetString( "frmProfileOnServer_ColumnVersionIst" ), 60) );
			tlcServer.Columns.Add ( new TreeListColumn( LanguageManager.Instance.GetString( "frmProfileOnServer_ColumnStateP" ), 60 ) );
			tlcServer.Columns.Add ( new TreeListColumn( LanguageManager.Instance.GetString( "frmProfileOnServer_ColumnStateS" ), 60 ) );
			tlcServer.Columns.Add ( new TreeListColumn( LanguageManager.Instance.GetString( "frmProfileOnServer_ColumnChanged" ), 120 ) );
			tlcServer.Columns.Add ( new TreeListColumn( LanguageManager.Instance.GetString( "frmProfileOnServer_ColumnJobs" ), 60 ) );

			mnuPopup_Copy.Text = LanguageManager.Instance.GetString( "frmProfileOnServer_mnuCopy" );
		}


		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.components = new System.ComponentModel.Container();
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(DCProfileOnServer));
			this.cmPopup = new System.Windows.Forms.ContextMenu();
			this.mnuPopup_Copy = new System.Windows.Forms.MenuItem();
			this.imglProfile = new System.Windows.Forms.ImageList(this.components);
			this.panelServer = new System.Windows.Forms.Panel();
			this.tlcProfile = new VI.Controls.TreeListControl();
			this.splitter1 = new System.Windows.Forms.Splitter();
			this.panelProfile = new System.Windows.Forms.Panel();
			this.tlcServer = new VI.Controls.TreeListControl();
			this.imglServer = new System.Windows.Forms.ImageList(this.components);
			this.panelServer.SuspendLayout();
			this.panelProfile.SuspendLayout();
			this.SuspendLayout();
			//
			// cmPopup
			//
			this.cmPopup.MenuItems.AddRange(new System.Windows.Forms.MenuItem[]
			{
				this.mnuPopup_Copy
			});
			this.cmPopup.Popup += new System.EventHandler(this.cmPopup_Popup);
			//
			// mnuPopup_Copy
			//
			this.mnuPopup_Copy.Index = 0;
			this.mnuPopup_Copy.Text = "~Copy";
			this.mnuPopup_Copy.Click += new System.EventHandler(this.mnuPopup_Copy_Click);
			//
			// imglProfile
			//
			this.imglProfile.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imglProfile.ImageStream")));
			this.imglProfile.TransparentColor = System.Drawing.Color.Transparent;
			this.imglProfile.Images.SetKeyName(0, "");
			this.imglProfile.Images.SetKeyName(1, "");
			this.imglProfile.Images.SetKeyName(2, "");
			this.imglProfile.Images.SetKeyName(3, "");
			this.imglProfile.Images.SetKeyName(4, "");
			this.imglProfile.Images.SetKeyName(5, "");
			this.imglProfile.Images.SetKeyName(6, "");
			this.imglProfile.Images.SetKeyName(7, "");
			//
			// panelServer
			//
			this.panelServer.BackColor = System.Drawing.SystemColors.ControlDark;
			this.panelServer.Controls.Add(this.tlcProfile);
			this.panelServer.Dock = System.Windows.Forms.DockStyle.Left;
			this.panelServer.Location = new System.Drawing.Point(0, 0);
			this.panelServer.Name = "panelServer";
			this.panelServer.Padding = new System.Windows.Forms.Padding(1);
			this.panelServer.Size = new System.Drawing.Size(248, 478);
			this.panelServer.TabIndex = 0;
			//
			// tlcProfile
			//
			this.tlcProfile.BackColor = System.Drawing.SystemColors.Window;
			this.tlcProfile.Dock = System.Windows.Forms.DockStyle.Fill;
			this.tlcProfile.HeaderFont = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.tlcProfile.HideSelection = false;
			this.tlcProfile.ImageList = this.imglProfile;
			this.tlcProfile.Location = new System.Drawing.Point(1, 1);
			this.tlcProfile.Margin = new System.Windows.Forms.Padding(0);
			this.tlcProfile.Name = "tlcProfile";
			this.tlcProfile.ShowRootLines = false;
			this.tlcProfile.Size = new System.Drawing.Size(246, 476);
			this.tlcProfile.SubTextColor = System.Drawing.Color.Blue;
			this.tlcProfile.TabIndex = 1;
			this.tlcProfile.Text = "treeListControl1";
			this.tlcProfile.SelectedNodeChanged += new VI.Controls.TreeListEventHandler(this.tlcProfile_SelectedNodeChanged);
			this.tlcProfile.KeyUp += new System.Windows.Forms.KeyEventHandler(this.tlcProfile_KeyUp);
			this.tlcProfile.NodeExpanding += new VI.Controls.TreeListEventHandler(this.tlcProfile_NodeExpanding);
			//
			// splitter1
			//
			this.splitter1.Location = new System.Drawing.Point(248, 0);
			this.splitter1.Name = "splitter1";
			this.splitter1.Size = new System.Drawing.Size(4, 478);
			this.splitter1.TabIndex = 1;
			this.splitter1.TabStop = false;
			//
			// panelProfile
			//
			this.panelProfile.BackColor = System.Drawing.SystemColors.ControlDark;
			this.panelProfile.Controls.Add(this.tlcServer);
			this.panelProfile.Dock = System.Windows.Forms.DockStyle.Fill;
			this.panelProfile.Location = new System.Drawing.Point(252, 0);
			this.panelProfile.Name = "panelProfile";
			this.panelProfile.Padding = new System.Windows.Forms.Padding(1);
			this.panelProfile.Size = new System.Drawing.Size(436, 478);
			this.panelProfile.TabIndex = 2;
			//
			// tlcServer
			//
			this.tlcServer.BackColor = System.Drawing.SystemColors.Window;
			this.tlcServer.ContextMenu = this.cmPopup;
			this.tlcServer.Dock = System.Windows.Forms.DockStyle.Fill;
			this.tlcServer.HeaderFont = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.tlcServer.ImageList = this.imglServer;
			this.tlcServer.Location = new System.Drawing.Point(1, 1);
			this.tlcServer.Margin = new System.Windows.Forms.Padding(0);
			this.tlcServer.Name = "tlcServer";
			this.tlcServer.ShowRootLines = false;
			this.tlcServer.Size = new System.Drawing.Size(434, 476);
			this.tlcServer.SubTextColor = System.Drawing.Color.Blue;
			this.tlcServer.TabIndex = 2;
			this.tlcServer.Text = "treeListControl1";
			this.tlcServer.KeyUp += new System.Windows.Forms.KeyEventHandler(this.tlcServer_KeyUp);
			//
			// imglServer
			//
			this.imglServer.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imglServer.ImageStream")));
			this.imglServer.TransparentColor = System.Drawing.Color.Transparent;
			this.imglServer.Images.SetKeyName(0, "");
			this.imglServer.Images.SetKeyName(1, "");
			this.imglServer.Images.SetKeyName(2, "");
			this.imglServer.Images.SetKeyName(3, "");
			this.imglServer.Images.SetKeyName(4, "");
			this.imglServer.Images.SetKeyName(5, "");
			//
			// DCProfileOnServer
			//
			this.Controls.Add(this.panelProfile);
			this.Controls.Add(this.splitter1);
			this.Controls.Add(this.panelServer);
			this.Name = "DCProfileOnServer";
			this.Size = new System.Drawing.Size(688, 478);
			this.panelServer.ResumeLayout(false);
			this.panelProfile.ResumeLayout(false);
			this.ResumeLayout(false);

		}
		#endregion

		#region DomainFillMethods

		private void _InsertDomainRootNode(  )
		{
			TreeListNode tlnRoot;

			try
			{
				Cursor.Current = Cursors.WaitCursor;

				// begin treeupdate
				tlcProfile.BeginUpdate();

				// remove all old items
				tlcProfile.Nodes.Clear();

				// create a new rootnode
				tlnRoot = tlcProfile.Nodes.Add( LanguageManager.Instance["frmProfileOnServer_ProfileRoot"], 0);
				tlnRoot.Tag = new NodeData( NodeType.Root, "", "" );

				// appand the JobChains
				_InsertDomains( tlnRoot, "" );

				// expand our rootnode
				tlnRoot.Expand(false);

				tlcProfile.SelectedNode = tlnRoot;

			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
			}
			finally
			{
				// end treeupdate
				tlcProfile.EndUpdate();

				Cursor.Current = Cursors.Default;
			}
		}

		private void _InsertDomains( TreeListNode tlnParent, string identParentDomain )
		{
			ISqlFormatter isql = clsMain.Instance.CurrentConnection.Connection.SqlFormatter;

			try
			{
				Cursor.Current = Cursors.WaitCursor;

				// create the collection
				IColDbObject  dbcolDomains = clsMain.Instance.CurrentConnection.Connection.CreateCol("SDLDomain");

				// assign the where-clause
				if (String.IsNullOrEmpty(identParentDomain))
				{
					dbcolDomains.Prototype.WhereClause = isql.Comparison("UID_SDLDomainParent", "", ValType.String);
				}
				else
					dbcolDomains.Prototype.WhereClause = isql.FkComparison("UID_SDLDomainParent", "UID_SDLDomain", "SDLDomain", 
						isql.Comparison("Ident_Domain", identParentDomain, ValType.String));

				// appand the userdefined filter
				if (clsMain.Instance.DomainFilter.Length > 0)
				{
					dbcolDomains.Prototype.WhereClause = "(" + dbcolDomains.Prototype.WhereClause + ") and (" + clsMain.Instance.DomainFilter + ")";
				}

				// mark as DisplayColumn
				dbcolDomains.Prototype["Ident_Domain"].IsDisplayItem = true;

				// load the collection
				dbcolDomains.Load();

				//now do for each domain
				foreach ( IColElem colElem in dbcolDomains )
				{
					// create a doamin-node
					TreeListNode tlnDomain = tlnParent.Nodes.Add( colElem.Display, 1);
					tlnDomain.Tag = new NodeData( NodeType.Domain, colElem.GetValue("Ident_Domain"), "" );

					// insert static subitems of domain
					_PrepareDomainNode( tlnDomain );

					// insert all childdomains
					_InsertDomains( tlnDomain, colElem.Display );

				}

			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
			}
			finally
			{
				Cursor.Current = Cursors.Default;
			}
		}

		private static void _PrepareDomainNode(TreeListNode tlnDomain)
		{
			TreeListNode tlnNode;
			NodeData nd = tlnDomain.Tag as NodeData;

			// Node for ApplicationProfiles
			tlnNode = tlnDomain.Nodes.Add( LanguageManager.Instance["frmProfileOnServer_NodeAppProfile"], 2);
			tlnNode.Tag = new NodeData( NodeType.AppProfiles, nd.Data1, "" );
			tlnNode.ShowExpansionIndicator = true;

			// Node for DriverProfiles
			tlnNode = tlnDomain.Nodes.Add( LanguageManager.Instance["frmProfileOnServer_NodeDrvProfile"], 3);
			tlnNode.Tag = new NodeData( NodeType.DrvProfiles, nd.Data1, "" );
			tlnNode.ShowExpansionIndicator = true;

			// Node for MachineTypes
			tlnNode = tlnDomain.Nodes.Add( LanguageManager.Instance["frmProfileOnServer_NodeMacType"], 4);
			tlnNode.Tag = new NodeData( NodeType.MacTypes, nd.Data1, "" );
			tlnNode.ShowExpansionIndicator = true;
		}

		private void _InsertProfiles( NodeType nodeType, TreeListNode tlnParent )
		{
			ISqlFormatter isql = clsMain.Instance.CurrentConnection.Connection.SqlFormatter;
			SqlExecutor   cSQL = clsMain.Instance.CurrentConnection.Connection.CreateSqlExecutor( clsMain.Instance.CurrentConnection.PublicKey );

			TreeListNode tlnProfile = null;

			string strSQL = "";
			NodeData nd = tlnParent.Tag as NodeData;

			try
			{
				Cursor.Current = Cursors.WaitCursor;

				tlcProfile.BeginUpdate();

				// remove old childs
				tlnParent.Nodes.Clear();

				switch ( nodeType )
				{
					case NodeType.AppProfiles:
						strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ApplicationProfile"];
						break;
					case NodeType.DrvProfiles:
						strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["DriverProfile"];
						break;
					case NodeType.MacTypes:
						strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["MachineType"];
						break;
				}

				// replace the Domain-Variable
				strSQL = strSQL.Replace( "@Ident_DomainRD", isql.FormatValue(nd.Data1, ValType.String) );

				if (clsMain.Instance.ErrorOnly)
					strSQL = strSQL.Replace( "@ErrorOnly", " and x.fehler > 0" + Environment.NewLine );
				else
					strSQL = strSQL.Replace( "@ErrorOnly", Environment.NewLine );

				// and now do it...
				using ( IDataReader rData = new CachedDataReader( cSQL.SqlExecute(strSQL) ) )
				{
					while ( rData.Read() )
					{
						bool bFehler = rData.GetBoolean(0);

						switch (nodeType)
						{
							case NodeType.AppProfiles:
								tlnProfile = tlnParent.Nodes.Add( rData.GetString(1), bFehler ? 5 : 2 );
								tlnProfile.Tag = new NodeData( NodeType.AppProfile, nd.Data1, rData.GetString(2) );
								break;
							case NodeType.DrvProfiles:
								tlnProfile = tlnParent.Nodes.Add( rData.GetString(1), bFehler ? 6 : 3 );
								tlnProfile.Tag = new NodeData( NodeType.DrvProfile, nd.Data1, rData.GetString(2) );
								break;
							case NodeType.MacTypes:
								tlnProfile = tlnParent.Nodes.Add( rData.GetString(1), bFehler ? 7 : 4 );
								tlnProfile.Tag = new NodeData( NodeType.MacType, nd.Data1, rData.GetString(2) );
								break;
						}

						tlnProfile.SubItems.Add( rData.GetInt32(3).ToString() );

					}
				}

				// no profiles --> remove + from Parent-Node
				if ( tlnParent.Nodes.Count == 0)
					tlnParent.ShowExpansionIndicator = false;
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
			}
			finally
			{
				tlcProfile.EndUpdate();

				Cursor.Current = Cursors.Default;
			}
		}


		#endregion

		#region ServerFillMethods

		private void _DisplayServerForProfile( TreeListNode tlnProfile )
		{
			try
			{
				// lock controlupdate
				tlcServer.BeginUpdate();

				// remove all items from this list
				tlcServer.Nodes.Clear();

				m_tlnProfile = tlnProfile;

				if (tlnProfile != null)
				{
					NodeData nd = tlnProfile.Tag as NodeData;

					if ( (nd.Type == NodeType.AppProfile) ||
						 (nd.Type == NodeType.DrvProfile) ||
						 (nd.Type == NodeType.MacType ))
					{
						// now load the collection
						ObjectBaseHash colServer = _GetServerCollection( nd.Data1, nd.Data2, nd.Type );

						// now insert in tree
						_InsertServerInTree( null, colServer );

						// start JobQueueThread
						_InitializeJobQueueThread();
					}
				}
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
			}
			finally
			{
				// release controlupdatelock
				tlcServer.EndUpdate();
			}
		}

		private static ObjectBaseHash _GetServerCollection(string Ident_Domain, string UID_Profile, NodeType nodeType)
		{
			ISqlFormatter isql = clsMain.Instance.CurrentConnection.Connection.SqlFormatter;
			SqlExecutor   cSQL = clsMain.Instance.CurrentConnection.Connection.CreateSqlExecutor( clsMain.Instance.CurrentConnection.PublicKey );

			ObjectBaseHash colServers = new ObjectBaseHash();
			ObjectServer   oServer    = null;

			string strSQL = "";

			switch ( nodeType )
			{
				case NodeType.AppProfile:
					strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ApplicationProfileServer"];
					break;
				case NodeType.DrvProfile:
					strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["DriverProfileServer"];
					break;
				case NodeType.MacType:
					strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["MachineTypeServer"];
					break;
			}

			// replace the Domain-Variable
			strSQL = strSQL.Replace( "@Ident_Domain", isql.FormatValue(Ident_Domain, ValType.String, true) );

			// replace UID_Profile
			strSQL = strSQL.Replace( "@UID_Profile", isql.FormatValue(UID_Profile, ValType.String, true) );

			// and now do it...
			using ( IDataReader rData = new CachedDataReader( cSQL.SqlExecute(strSQL) ) )
			{
				while ( rData.Read() )
				{
					// create a server-object
					oServer = new ObjectServer( rData );

					// and add to our Hash
					colServers.Add( oServer, "UID_ApplicationServer" );
				}
			}

			return colServers;
		}


		private void _InsertServerInTree( TreeListNode tlnParent, ObjectBaseHash colServer )
		{
			TreeListNode tlnServer;

			string UID_ParentServer;

			if (tlnParent != null)
			{
				NodeData nd = tlnParent.Tag as NodeData;
				UID_ParentServer = nd.Data1;
			}
			else
				UID_ParentServer = "";

			// loop for each serverobject
			foreach ( ObjectServer oServer in colServer )
			{
				if (oServer.GetData( "uid_parentapplicationserver" ) == UID_ParentServer)
				{
					if ( tlnParent != null )
						tlnServer = tlnParent.Nodes.Add(oServer.GetData("displaytext"), 0);	// insert as childs
					else
						tlnServer = tlcServer.Nodes.Add(oServer.GetData("displaytext"), 0);	// insert as root in control

					tlnServer.Tag = new NodeData( NodeType.Server, oServer.GetData("uid_applicationserver"), "" );

					tlnServer.SubItems.Add( oServer.GetData("chgnr") );
					tlnServer.SubItems.Add( oServer.GetData("state_p") );
					tlnServer.SubItems.Add( oServer.GetData("state_s") );
					tlnServer.SubItems.Add( oServer.GetData("changed") );
					tlnServer.SubItems.Add( "" );

					// call for all childs
					_InsertServerInTree( tlnServer, colServer );

					// assign the pictureindex
					tlnServer.ImageIndex = _GetPictureIndex( tlnServer );

					// open this Node
					tlnServer.Expand(false);

				}
			}
		}

		private int _GetPictureIndex( TreeListNode tlnServer )
		{
			string lChgNrIst;
			string lChgNrSoll = "0";
			bool   bReady = false;
			string strStateP;
			string strStateS;

			DateTime  dUpdate = new DateTime(0);
			bool   bJobs  = false;
			bool   bChgNr = false;

			// chgnr soll
			if ( tlnServer.ParentNode == null )
				lChgNrSoll = tlcProfile.SelectedNode.SubItems[0].Caption;
			else
				lChgNrSoll = tlnServer.ParentNode.SubItems[0].Caption;

			// chgnr is
			if ( tlnServer.SubItems[1].Caption.Length > 0 )
				lChgNrIst = tlnServer.SubItems[0].Caption;
			else
				lChgNrIst = "<unknown>";

			strStateP = tlnServer.SubItems[1].Caption;
			strStateS = tlnServer.SubItems[2].Caption;

			// OfflineCopy
			if (string.Equals(strStateS, "offlinecopy", StringComparison.OrdinalIgnoreCase))
				return 4;

			// OnlineCopy
			if (string.Equals(strStateS, "onlinecopy", StringComparison.OrdinalIgnoreCase))
				return 3;

			// is changeNumber equal ?
			bChgNr = lChgNrSoll == lChgNrIst;

			// isReady ???
			bReady = string.Equals( strStateP, "ready", StringComparison.OrdinalIgnoreCase);

			// get the date
			if ( tlnServer.SubItems[3].Caption.Length > 0 )
				dUpdate = Convert.ToDateTime(tlnServer.SubItems[3].Caption);

			// exists Jobs
			if (( tlnServer.SubItems.Count > 3) && (tlnServer.SubItems[4].Caption.Length > 0 ))
				bJobs = Convert.ToBoolean(tlnServer.SubItems[4].Caption);


			if (bReady && bChgNr && ! bJobs)
				return 0;	// green

			if (dUpdate.Ticks != 0)
			{
				TimeSpan ts = clsMain.Instance.CurrentConnection.Connection.LocalNow.Subtract(dUpdate);

				if ( (!bReady) && ( ts.TotalHours > clsMain.Instance.TimeOut ) && bJobs)
					return 1;
			}

			if ((!bReady) && bJobs)
				return 1;

			if ((!bReady || !bChgNr) && (!bJobs))
				return 2;

			// everything are unknown states
			return 5;
		}

		#endregion

		#region FormEvents

		/*
		private void mnuPopup_Copy_Click(object sender, System.EventArgs e)
		{
			if (tlcServer.SelectedItems.Count == 1)
			{
				NodeData ndp = m_tlnProfile.Tag as NodeData;
				NodeData nds = tlcServer.SelectedItems[0].Tag as NodeData;

				// update startdate
				tlcServer.SelectedItems[0].SubItems[3].Text = clsMain.Instance.CurrentConnection.Connection.LocalNow.ToString();
				tlcServer.SelectedItems[0].SubItems[2].Text = "False";

				// start servercopy
				JobQueueCheck.RefreshProfileCopy( ndp.Type, nds.Data1, ndp.Data2, tlcProfile.SelectedItems[0].SubItems[1].Text );

				// refresh JobQueueState
				_InitializeJobQueueThread();
			}
		}
		*/

		#endregion

		#region TreeEvents

		private void tlcProfile_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
		{
			switch ( e.KeyCode )
			{
				case Keys.F5:
					_InsertDomainRootNode();
					break;
			}
		}

		private void tlcServer_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
		{
			switch ( e.KeyCode )
			{
				case Keys.F5:
					_DisplayServerForProfile( tlcProfile.SelectedNode );
					break;
			}
		}

		#endregion

		#region JobQueueCheck

		private void _InitializeJobQueueThread()
		{
			if (m_JobQueueThread != null)
				_ReleaseJobQueueThread();

			m_JobQueueThread = new Thread( new ThreadStart(	_ThreadFunction ) );

			m_JobQueueThread.Start();
		}

		private void _ReleaseJobQueueThread()
		{
			if (m_JobQueueThread != null)
			{
				if (m_JobQueueThread.IsAlive)
					m_JobQueueThread.Join();

				m_JobQueueThread = null;
			}
		}

		private void _ThreadFunction()
		{
			try
			{
				_CheckForNodes( tlcServer.Nodes );
			}
			catch (Exception ex )
			{
				// do nothing because its our stupid thread
				Debug.WriteLine( ViException.ErrorString(ex));
			}
		}

		private void _CheckForNodes( TreeListNodeCollection colItems )
		{
			bool bExistsJobs;

			foreach ( TreeListNode tlnServer in colItems )
			{
				NodeData ndp = m_tlnProfile.Tag as NodeData;
				NodeData nds = tlnServer.Tag as NodeData;

				bExistsJobs = JobQueueCheck.ExistsCopyJobs( ndp.Type, nds.Data1, ndp.Data2 );

				tlnServer.SubItems[4].Caption = bExistsJobs.ToString();

				tlnServer.ImageIndex = _GetPictureIndex( tlnServer );

				// call recursiv
				_CheckForNodes( tlnServer.Nodes );
			}

			tlcServer.Invalidate();
		}


		#endregion

		private void _SaveFormSettings()
		{
			IConfigData	conf = AppData.Instance.Config( "frmProfileOnServer", false);

			// save the window size and position
			conf.Put( "Splitter",   panelProfile.Width.ToString() );

			conf.Put( "columnDomain",  tlcProfile.Columns[0].Width.ToString() );
			conf.Put( "columnVersion", tlcProfile.Columns[1].Width.ToString() );

			conf.Put( "columnServer",  tlcServer.Columns[0].Width.ToString() );
			conf.Put( "columnIst",     tlcServer.Columns[1].Width.ToString() );
			conf.Put( "columnStateP",  tlcServer.Columns[2].Width.ToString() );
			conf.Put( "columnStateS",  tlcServer.Columns[2].Width.ToString() );
			conf.Put( "columnChanged", tlcServer.Columns[3].Width.ToString() );
			conf.Put( "columnCopyJob", tlcServer.Columns[4].Width.ToString() );
		}

		private void _LoadFormSettings()
		{
			IConfigData	conf = AppData.Instance.Config( "frmProfileOnServer", false);

			// restore position
			if ( conf.Get("Splitter").Length > 0)
				panelProfile.Width = Convert.ToInt32(conf.Get("Splitter"));

			if ( conf.Get("columnDomain").Length > 0)
				tlcProfile.Columns[0].Width = Convert.ToInt32(conf.Get("columnDomain"));

			if ( conf.Get("columnVersion").Length > 0)
				tlcProfile.Columns[1].Width = Convert.ToInt32(conf.Get("columnVersion"));


			if ( conf.Get("columnServer").Length > 0)
				tlcServer.Columns[0].Width = Convert.ToInt32(conf.Get("columnServer"));

			if ( conf.Get("columnIst").Length > 0)
				tlcServer.Columns[1].Width = Convert.ToInt32(conf.Get("columnIst"));

			if ( conf.Get("columnStateP").Length > 0)
				tlcServer.Columns[2].Width = Convert.ToInt32(conf.Get("columnStateP"));

			if ( conf.Get("columnStateS").Length > 0)
				tlcServer.Columns[3].Width = Convert.ToInt32(conf.Get("columnStateS"));

			if ( conf.Get("columnChanged").Length > 0)
				tlcServer.Columns[4].Width = Convert.ToInt32(conf.Get("columnChanged"));

			if ( conf.Get("columnCopyJob").Length > 0)
				tlcServer.Columns[5].Width = Convert.ToInt32(conf.Get("columnCopyJob"));

		}

		private void tlcProfile_SelectedNodeChanged(object sender, VI.Controls.TreeListEventArgs args)
		{
			_DisplayServerForProfile( args.Node );
		}

		private void tlcProfile_NodeExpanding(object sender, VI.Controls.TreeListEventArgs args)
		{
			NodeData nd = args.Node.Tag as NodeData;

			switch ( nd.Type )
			{
				case NodeType.AppProfiles:
				case NodeType.DrvProfiles:
				case NodeType.MacTypes:
					_InsertProfiles( nd.Type, args.Node );
					break;
			}
		}

		private void mnuPopup_Copy_Click(object sender, System.EventArgs e)
		{
			if (tlcServer.SelectedNode != null)
			{
				NodeData ndp = tlcProfile.SelectedNode.Tag as NodeData;
				NodeData nds = tlcServer.SelectedNode.Tag as NodeData;

				// update startdate
				tlcServer.SelectedNode.SubItems[2].Caption = clsMain.Instance.CurrentConnection.Connection.LocalNow.ToString();
				tlcServer.SelectedNode.SubItems[1].Caption = "False";

				// start servercopy
				JobQueueCheck.RefreshProfileCopy( ndp.Type, nds.Data1, ndp.Data2, tlcServer.SelectedNode.SubItems[0].Caption );

				// refresh JobQueueState
				_InitializeJobQueueThread();
			}
		}

		private void cmPopup_Popup(object sender, System.EventArgs e)
		{
			mnuPopup_Copy.Enabled = false;

			// enable only for PAS
			if (tlcServer.SelectedNode != null)
			{
				if (tlcServer.SelectedNode.ParentNode != null)
				{
					mnuPopup_Copy.Enabled = true;
				}
			}

		}

		private void clsMain_ConnectionChanged(object sender, EventArgs e)
		{
			if ( clsMain.Instance.CurrentConnection != null)
				_InsertDomainRootNode();
		}
	}
}
