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
using System.Collections.Generic;
using System.Windows.Forms;
using System.Data;
using System.Diagnostics;
using System.Threading;

using VI.Base;
using VI.DB;
using VI.Controls;
using VI.CommonDialogs;


namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Summary description for frmJobChains.
	/// </summary>
	public class DCServerHasProfile : UserControl
	{

		private System.Windows.Forms.ColumnHeader columnHeader1;
		private System.Windows.Forms.ContextMenu cmPopup;
		private System.ComponentModel.IContainer components;
		private System.Windows.Forms.Panel panelLeft;
		private System.Windows.Forms.Splitter splitter1;
		private System.Windows.Forms.ImageList imglTab;
		private System.Windows.Forms.Panel panelRight;
		private System.Windows.Forms.ImageList imglServer;

		private TreeListNode m_tlnServer = null;
		private System.Windows.Forms.ImageList imglProfile;
		private System.Windows.Forms.MenuItem mnuPopup_Copy;
		private VI.Controls.TreeListControl tlcServer;
		private VI.Controls.TreeListControl tlcProfile;
		private System.Windows.Forms.Panel panelProfile;
		private System.Windows.Forms.ToolBarButton tbbApplicationProfile;
		private System.Windows.Forms.ToolBarButton tbbDriverProfile;
		private System.Windows.Forms.ToolBarButton tbbMachineType;
		private System.Windows.Forms.ToolBar tbProfileType;
		private System.Windows.Forms.MenuItem mnuPopup_CL2FDS;		// the currently selected server
		private Thread m_JobQueueThread = null;
		private ISingleDbObject m_dbCentralLibrary = null;

		public DCServerHasProfile()
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
			clsMain.Instance.ConnectionChanged += new EventHandler(clsMain_ConnectionChanged);

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


		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.components = new System.ComponentModel.Container();
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(DCServerHasProfile));
			this.columnHeader1 = new System.Windows.Forms.ColumnHeader();
			this.cmPopup = new System.Windows.Forms.ContextMenu();
			this.mnuPopup_Copy = new System.Windows.Forms.MenuItem();
			this.mnuPopup_CL2FDS = new System.Windows.Forms.MenuItem();
			this.imglTab = new System.Windows.Forms.ImageList(this.components);
			this.panelLeft = new System.Windows.Forms.Panel();
			this.tlcServer = new VI.Controls.TreeListControl();
			this.imglServer = new System.Windows.Forms.ImageList(this.components);
			this.splitter1 = new System.Windows.Forms.Splitter();
			this.panelRight = new System.Windows.Forms.Panel();
			this.tbProfileType = new System.Windows.Forms.ToolBar();
			this.tbbApplicationProfile = new System.Windows.Forms.ToolBarButton();
			this.tbbDriverProfile = new System.Windows.Forms.ToolBarButton();
			this.tbbMachineType = new System.Windows.Forms.ToolBarButton();
			this.panelProfile = new System.Windows.Forms.Panel();
			this.tlcProfile = new VI.Controls.TreeListControl();
			this.imglProfile = new System.Windows.Forms.ImageList(this.components);
			this.panelLeft.SuspendLayout();
			this.panelRight.SuspendLayout();
			this.panelProfile.SuspendLayout();
			this.SuspendLayout();
			//
			// columnHeader1
			//
			this.columnHeader1.Width = 180;
			//
			// cmPopup
			//
			this.cmPopup.MenuItems.AddRange(new System.Windows.Forms.MenuItem[]
			{
				this.mnuPopup_Copy,
				this.mnuPopup_CL2FDS
			});
			this.cmPopup.Popup += new System.EventHandler(this.cmPopup_Popup);
			//
			// mnuPopup_Copy
			//
			this.mnuPopup_Copy.Index = 0;
			this.mnuPopup_Copy.Text = "~Copy";
			this.mnuPopup_Copy.Click += new System.EventHandler(this.mnuPopup_Copy_Click);
			//
			// mnuPopup_CL2FDS
			//
			this.mnuPopup_CL2FDS.Index = 1;
			this.mnuPopup_CL2FDS.Text = "~CL2FDS";
			this.mnuPopup_CL2FDS.Click += new System.EventHandler(this.mnuPopup_CL2FDS_Click);
			//
			// imglTab
			//
			this.imglTab.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imglTab.ImageStream")));
			this.imglTab.TransparentColor = System.Drawing.Color.Transparent;
			this.imglTab.Images.SetKeyName(0, "");
			this.imglTab.Images.SetKeyName(1, "");
			this.imglTab.Images.SetKeyName(2, "");
			//
			// panelLeft
			//
			this.panelLeft.BackColor = System.Drawing.SystemColors.ControlDark;
			this.panelLeft.Controls.Add(this.tlcServer);
			this.panelLeft.Dock = System.Windows.Forms.DockStyle.Left;
			this.panelLeft.Location = new System.Drawing.Point(0, 0);
			this.panelLeft.Name = "panelLeft";
			this.panelLeft.Padding = new System.Windows.Forms.Padding(1);
			this.panelLeft.Size = new System.Drawing.Size(200, 422);
			this.panelLeft.TabIndex = 0;
			//
			// tlcServer
			//
			this.tlcServer.BackColor = System.Drawing.SystemColors.Window;
			this.tlcServer.Dock = System.Windows.Forms.DockStyle.Fill;
			this.tlcServer.HeaderFont = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.tlcServer.HideSelection = false;
			this.tlcServer.ImageList = this.imglServer;
			this.tlcServer.Location = new System.Drawing.Point(1, 1);
			this.tlcServer.Margin = new System.Windows.Forms.Padding(0);
			this.tlcServer.Name = "tlcServer";
			this.tlcServer.ShowRootLines = false;
			this.tlcServer.Size = new System.Drawing.Size(198, 420);
			this.tlcServer.SubTextColor = System.Drawing.Color.Blue;
			this.tlcServer.TabIndex = 1;
			this.tlcServer.Text = "treeListControl1";
			this.tlcServer.SelectedNodeChanged += new VI.Controls.TreeListEventHandler(this.tlcServer_SelectedNodeChanged);
			this.tlcServer.KeyUp += new System.Windows.Forms.KeyEventHandler(this.tlcServer_KeyUp);
			this.tlcServer.NodeExpanding += new VI.Controls.TreeListEventHandler(this.tlcServer_NodeExpanding);
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
			this.imglServer.Images.SetKeyName(6, "");
			this.imglServer.Images.SetKeyName(7, "");
			this.imglServer.Images.SetKeyName(8, "");
			this.imglServer.Images.SetKeyName(9, "");
			//
			// splitter1
			//
			this.splitter1.Location = new System.Drawing.Point(200, 0);
			this.splitter1.Name = "splitter1";
			this.splitter1.Size = new System.Drawing.Size(4, 422);
			this.splitter1.TabIndex = 1;
			this.splitter1.TabStop = false;
			//
			// panelRight
			//
			this.panelRight.BackColor = System.Drawing.SystemColors.Control;
			this.panelRight.Controls.Add(this.tbProfileType);
			this.panelRight.Controls.Add(this.panelProfile);
			this.panelRight.Dock = System.Windows.Forms.DockStyle.Fill;
			this.panelRight.Location = new System.Drawing.Point(204, 0);
			this.panelRight.Name = "panelRight";
			this.panelRight.Size = new System.Drawing.Size(524, 422);
			this.panelRight.TabIndex = 2;
			//
			// tbProfileType
			//
			this.tbProfileType.Appearance = System.Windows.Forms.ToolBarAppearance.Flat;
			this.tbProfileType.Buttons.AddRange(new System.Windows.Forms.ToolBarButton[]
			{
				this.tbbApplicationProfile,
				this.tbbDriverProfile,
				this.tbbMachineType
			});
			this.tbProfileType.DropDownArrows = true;
			this.tbProfileType.ImageList = this.imglTab;
			this.tbProfileType.Location = new System.Drawing.Point(0, 0);
			this.tbProfileType.Name = "tbProfileType";
			this.tbProfileType.ShowToolTips = true;
			this.tbProfileType.Size = new System.Drawing.Size(524, 28);
			this.tbProfileType.TabIndex = 4;
			this.tbProfileType.TextAlign = System.Windows.Forms.ToolBarTextAlign.Right;
			this.tbProfileType.ButtonClick += new System.Windows.Forms.ToolBarButtonClickEventHandler(this.tbProfileType_ButtonClick);
			//
			// tbbApplicationProfile
			//
			this.tbbApplicationProfile.ImageIndex = 0;
			this.tbbApplicationProfile.Name = "tbbApplicationProfile";
			this.tbbApplicationProfile.Pushed = true;
			this.tbbApplicationProfile.Style = System.Windows.Forms.ToolBarButtonStyle.ToggleButton;
			this.tbbApplicationProfile.Text = "~ApplicationProfile";
			//
			// tbbDriverProfile
			//
			this.tbbDriverProfile.ImageIndex = 1;
			this.tbbDriverProfile.Name = "tbbDriverProfile";
			this.tbbDriverProfile.Style = System.Windows.Forms.ToolBarButtonStyle.ToggleButton;
			this.tbbDriverProfile.Text = "~DriverProfile";
			//
			// tbbMachineType
			//
			this.tbbMachineType.ImageIndex = 2;
			this.tbbMachineType.Name = "tbbMachineType";
			this.tbbMachineType.Style = System.Windows.Forms.ToolBarButtonStyle.ToggleButton;
			this.tbbMachineType.Text = "~MachineType";
			//
			// panelProfile
			//
			this.panelProfile.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
										| System.Windows.Forms.AnchorStyles.Left)
										| System.Windows.Forms.AnchorStyles.Right)));
			this.panelProfile.BackColor = System.Drawing.SystemColors.ControlDark;
			this.panelProfile.Controls.Add(this.tlcProfile);
			this.panelProfile.Location = new System.Drawing.Point(0, 32);
			this.panelProfile.Name = "panelProfile";
			this.panelProfile.Padding = new System.Windows.Forms.Padding(1);
			this.panelProfile.Size = new System.Drawing.Size(524, 392);
			this.panelProfile.TabIndex = 3;
			//
			// tlcProfile
			//
			this.tlcProfile.BackColor = System.Drawing.SystemColors.Window;
			this.tlcProfile.ContextMenu = this.cmPopup;
			this.tlcProfile.Dock = System.Windows.Forms.DockStyle.Fill;
			this.tlcProfile.HeaderFont = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.tlcProfile.ImageList = this.imglProfile;
			this.tlcProfile.Location = new System.Drawing.Point(1, 1);
			this.tlcProfile.Margin = new System.Windows.Forms.Padding(0);
			this.tlcProfile.Name = "tlcProfile";
			this.tlcProfile.ShowRootLines = false;
			this.tlcProfile.Size = new System.Drawing.Size(522, 390);
			this.tlcProfile.SubTextColor = System.Drawing.Color.Blue;
			this.tlcProfile.TabIndex = 2;
			this.tlcProfile.Text = "treeListControl1";
			this.tlcProfile.KeyUp += new System.Windows.Forms.KeyEventHandler(this.tlcProfile_KeyUp);
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
			//
			// DCServerHasProfile
			//
			this.Controls.Add(this.panelRight);
			this.Controls.Add(this.splitter1);
			this.Controls.Add(this.panelLeft);
			this.Name = "DCServerHasProfile";
			this.Size = new System.Drawing.Size(728, 422);
			this.panelLeft.ResumeLayout(false);
			this.panelRight.ResumeLayout(false);
			this.panelRight.PerformLayout();
			this.panelProfile.ResumeLayout(false);
			this.ResumeLayout(false);

		}
		#endregion

		#region FormEvents

		private void tabProfileType_SelectedIndexChanged(object sender, System.EventArgs e)
		{

		}

		/// <summary>
		/// Translate all languagedepending strings
		/// </summary>
		private void _TranslateForm()
		{
			Text = LanguageManager.Instance.GetString( "frmServerHasProfile_Caption" );

			mnuPopup_Copy.Text = LanguageManager.Instance.GetString( "frmServerHasProfile_mnuCopy" );
			mnuPopup_CL2FDS.Text = LanguageManager.Instance.GetString( "frmServerHasProfile_mnuCL2FDS" );

			tbbApplicationProfile.Text = LanguageManager.Instance.GetString( "frmServerHasProfile_tabAppProfile" );
			tbbDriverProfile.Text = LanguageManager.Instance.GetString( "frmServerHasProfile_tabDrvProfile" );
			tbbMachineType.Text = LanguageManager.Instance.GetString( "frmServerHasProfile_tabMacType" );

			tlcServer.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmServerHasProfile_columnServer" ), 60 ) );

			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmServerHasProfile_columnProfile" ), 160 ) );
			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmServerHasProfile_columnIst" ), 60 ) );
			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmServerHasProfile_columnSoll" ), 60 ) );
			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmServerHasProfile_columnStateP" ), 60 ) );
			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmServerHasProfile_columnStateS" ), 60 ) );
			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmServerHasProfile_columnChanged" ), 60 ) );
			tlcProfile.Columns.Add( new TreeListColumn( LanguageManager.Instance.GetString( "frmServerHasProfile_columnCopyJob" ), 60 ) );
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
				tlcServer.BeginUpdate();

				// remove all old items
				tlcServer.Nodes.Clear();

				// create a new rootnode
				tlnRoot = tlcServer.Nodes.Add( LanguageManager.Instance["frmServerHasProfile_DomainRoot"], 0);
				tlnRoot.Tag = new NodeData( NodeType.Root, "", "" );

				// appand the JobChains
				_InsertDomains( tlnRoot, "" );

				// expand our rootnode
				tlnRoot.Expand(false);

				tlcServer.SelectedNode = tlnRoot;

			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
			}
			finally
			{
				// end treeupdate
				tlcServer.EndUpdate();

				Cursor.Current = Cursors.Default;
			}
		}

		private void _InsertDomains(TreeListNode tlnParent, string identParentDomain)
		{
			IColDbObject  dbcolDomains = null;
			ISqlFormatter isql = clsMain.Instance.CurrentConnection.Connection.SqlFormatter;
			TreeListNode tlnDomain;

			try
			{
				Cursor.Current = Cursors.WaitCursor;

				// create the collection
				dbcolDomains = clsMain.Instance.CurrentConnection.Connection.CreateCol("SDLDomain");

				// assign the where-clause
				if (String.IsNullOrEmpty(identParentDomain))
					dbcolDomains.Prototype.WhereClause = isql.Comparison("UID_SDLDomainParent", "", ValType.String);
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
					tlnDomain = tlnParent.Nodes.Add( colElem.Display, 1);
					tlnDomain.Tag = new NodeData( NodeType.Domain, colElem.GetValue("Ident_Domain"), "" );

					tlnDomain.ShowExpansionIndicator = true;
				}

			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
			}
		}

		private ObjectBaseHash _GetServerOfDomin( string parentDomain )
		{
			ISqlFormatter isql = clsMain.Instance.CurrentConnection.Connection.SqlFormatter;
			SqlExecutor   cSQL = clsMain.Instance.CurrentConnection.Connection.CreateSqlExecutor( clsMain.Instance.CurrentConnection.PublicKey );
			string        strSQL;

			ObjectBaseHash colServers = new ObjectBaseHash();
			ObjectServer2 objServer;

			try
			{
				// get the gigantic SQL-Statement
				strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ApplicationServer"];

				// replace the Domain-Variable
				strSQL = strSQL.Replace( "@Ident_DomainRD", isql.FormatValue(parentDomain, ValType.String) );

				using ( IDataReader rData = new CachedDataReader( cSQL.SqlExecute(strSQL) ) )
				{
					while ( rData.Read() )
					{
						// create a new Serverobject
						objServer = new ObjectServer2(rData);

						// appand to our list
						colServers.Add( objServer, "UID_ApplicationServer" );
					}
				}
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
			}

			return colServers;
		}

		private void _InsertServerInTree( TreeListNode tlnParent, ObjectBaseHash colServers, string UID_ParentServer, string Ident_DomainRD )
		{
			TreeListNode tlnServer;

			foreach ( ObjectServer2 pServer in colServers )
			{
				if (pServer.GetData("UID_ParentApplicationServer").ToUpperInvariant() == UID_ParentServer)
				{
					tlnServer = tlnParent.Nodes.Add( pServer.GetData("Ident_Applicationserver"), pServer.IconIndex);
					tlnServer.Tag = new NodeData( NodeType.Server, pServer.GetData("UID_ApplicationServer"), Ident_DomainRD );

					// call recursiv
					_InsertServerInTree( tlnServer, colServers, pServer.GetData("UID_ApplicationServer").ToUpperInvariant(), Ident_DomainRD );

				}
			}
		}

		private void _ExpandDomain( TreeListNode tlnParent )
		{
			NodeData nd = tlnParent.Tag as NodeData;
			ObjectBaseHash colServers;

			try
			{
				Cursor.Current = Cursors.WaitCursor;

				tlcServer.BeginUpdate();

				// Remove all old Childnodes
				tlnParent.Nodes.Clear();

				// get the collection of servers in domain
				colServers = _GetServerOfDomin( nd.Data1 );

				// insert in TreeView
				_InsertServerInTree( tlnParent, colServers, "", nd.Data1 );

				// Insert the SubDomains
				_InsertDomains( tlnParent, nd.Data1 );

				if (tlnParent.Nodes.Count == 0)
					tlnParent.ShowExpansionIndicator = false;
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
			}
			finally
			{
				tlcServer.EndUpdate();

				Cursor.Current = Cursors.Default;
			}

		}


		#endregion


		#region FillProfiles

		private void _DisplayProfilesForServer( TreeListNode tlnServer, int iType )
		{
			try
			{
				Cursor.Current = Cursors.WaitCursor;

				// begin update
				tlcProfile.BeginUpdate();

				// remove all old items
				tlcProfile.Nodes.Clear();

				// toggle Buttons
				tbbApplicationProfile.Pushed = iType == 0;
				tbbDriverProfile.Pushed = iType == 1;
				tbbMachineType.Pushed = iType == 2;

				// assign to membervariable
				m_tlnServer = tlnServer;

				// a server is selected ???
				if ( tlnServer != null )
				{
					NodeData nd = tlnServer.Tag as NodeData;

					if ( nd.Type == NodeType.Server )
					{
						switch ( iType )
						{
							case 0:
								_InsertProfiles( NodeType.AppProfile, nd.Data2, nd.Data1 );
								break;
							case 1:
								_InsertProfiles( NodeType.DrvProfile, nd.Data2, nd.Data1 );
								break;
							case 2:
								_InsertProfiles( NodeType.MacType, nd.Data2, nd.Data1 );
								break;
						}

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
				// end treeupdate
				tlcProfile.EndUpdate();

				Cursor.Current = Cursors.Default;
			}
		}

		private void _InsertProfiles( NodeType nodeType, string Ident_DomainRD, string UID_ApplicationServer )
		{
			ISqlFormatter isql = clsMain.Instance.CurrentConnection.Connection.SqlFormatter;
			SqlExecutor   cSQL = clsMain.Instance.CurrentConnection.Connection.CreateSqlExecutor( clsMain.Instance.CurrentConnection.PublicKey );
			string        strSQL = "";
			string        strSQLEO = "";

			TreeListNode tlnProfile;

			try
			{
				// SQL depents on ProfileType
				switch ( nodeType )
				{
					case NodeType.AppProfile:
						strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ServerAppProfile"];
						strSQLEO = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ServerAppProfileErrorsOnly"];
						break;
					case NodeType.DrvProfile:
						strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ServerDrvProfile"];
						strSQLEO = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ServerDrvProfileErrorsOnly"];
						break;
					case NodeType.MacType:
						strSQL = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ServerMacType"];
						strSQLEO = clsMain.Instance.CurrentConnection.Connection.SqlStrings["ServerMacTypeErrorsOnly"];
						break;
				}


				// replace the Variables
				if ( clsMain.Instance.ErrorOnly )
					strSQL = strSQL.Replace( "@ErrorsOnly", strSQLEO );  // insert the ErrorOnly part
				else
					strSQL = strSQL.Replace( "@ErrorsOnly", "" );		 // remove the ErrorOnly part

				strSQL = strSQL.Replace( "@Ident_DomainRD", isql.FormatValue(Ident_DomainRD, ValType.String) );
				strSQL = strSQL.Replace( "@UID_ApplicationServer", isql.FormatValue(UID_ApplicationServer, ValType.String) );

				using ( IDataReader rData = new CachedDataReader( cSQL.SqlExecute(strSQL) ) )
				{
					while ( rData.Read() )
					{
						// create a new Node
						tlnProfile = tlcProfile.Nodes.Add( rData.GetString(1), 0 );
						tlnProfile.Tag = new NodeData( nodeType, rData.GetString(0), "");

						tlnProfile.SubItems.Add( rData.GetInt32(2).ToString() );		// Nr Ist
						tlnProfile.SubItems.Add( rData.GetInt32(3).ToString() );		// Nr Soll
						tlnProfile.SubItems.Add( rData.GetString(4).ToString() );       // State P
						tlnProfile.SubItems.Add( rData.GetString(5).ToString() );		// State S
						tlnProfile.SubItems.Add( rData.GetDateTime(6).ToString() );		// XDateUpdated
						tlnProfile.SubItems.Add( "" );
					}
				}
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this.ParentForm, ex );
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
			bool bExistsJobs;

			try
			{
				List<TreeListNode> lNodes = new List<TreeListNode> (tlcProfile.Nodes.Count);

				lock (tlcProfile.Nodes.SyncRoot)
				{
					foreach (TreeListNode tlnProfile in tlcProfile.Nodes)
					{
						lNodes.Add(tlnProfile);
					}
				}

				foreach (TreeListNode tlnProfile in lNodes)
				{
					NodeData nds = m_tlnServer.Tag as NodeData;
					NodeData ndp = tlnProfile.Tag as NodeData;

					bExistsJobs = JobQueueCheck.ExistsCopyJobs( ndp.Type, nds.Data1, ndp.Data1 );

					tlnProfile.SubItems[5].Caption = bExistsJobs.ToString();

					tlnProfile.ImageIndex = _GetPictureIndex( tlnProfile );
				}

				tlcProfile.Invalidate();
			}
			catch (Exception ex )
			{
				// do nothing because its our stupid thread
				Debug.WriteLine( ViException.ErrorString(ex));
			}
		}

		private static int _GetPictureIndex(TreeListNode tlnProfile)
		{
			string lChgNrSoll;
			string lChgNrIst;
			string strStateP;
			string strStateS;
			bool   bReady;
			DateTime dUpdate;
			bool   bJobs;
			bool   bChgNr;

			// get the parameter
			lChgNrIst = tlnProfile.SubItems[0].Caption;
			lChgNrSoll = tlnProfile.SubItems[1].Caption;
			strStateP = tlnProfile.SubItems[2].Caption;
			strStateS = tlnProfile.SubItems[3].Caption;
			dUpdate = Convert.ToDateTime(tlnProfile.SubItems[4].Caption);
			bJobs = Convert.ToBoolean(tlnProfile.SubItems[5].Caption);

			// OfflineCopy
			if (string.Equals(strStateS, "OfflineCopy", StringComparison.OrdinalIgnoreCase))
				return 4;

			// OnlineCopy
			if (string.Equals(strStateS, "OnlineCopy", StringComparison.OrdinalIgnoreCase))
				return 3;

			// is changeNumber equal ?
			bChgNr = lChgNrSoll == lChgNrIst;
			bReady = string.Equals(strStateP, "Ready", StringComparison.OrdinalIgnoreCase);

			if (bReady && bChgNr && (! bJobs))
				return 0;		// green = ok

			if (dUpdate.Ticks != 0)
			{
				TimeSpan ts = clsMain.Instance.CurrentConnection.Connection.LocalNow - dUpdate;

				if ( (! bReady) && ( ts.TotalHours > clsMain.Instance.TimeOut) && bJobs)
					return 1;  // Timeout Red-Yellow
			}

			if ((! bReady) && bJobs)
				return 1;		// Jobs Running = Yellow

			if ((! bReady || !bChgNr) && (! bJobs) )
				return 2;		// NotReady but no jobs = Red

			return 5; // unknown state
		}


		#endregion

		private void cmPopup_Popup(object sender, System.EventArgs e)
		{
			// enable only for PAS-Server
			if ( m_tlnServer != null && tlcProfile.SelectedNode != null)
			{
				NodeData nd = m_tlnServer.ParentNode.Tag as NodeData;
				bool bServer = nd.Type == NodeType.Server;
				bool bCL = m_dbCentralLibrary != null;

				mnuPopup_Copy.Enabled = bServer;

				mnuPopup_CL2FDS.Enabled = (nd.Type == NodeType.Domain) && bCL && (m_tlnServer.Tag as NodeData).Data1 != m_dbCentralLibrary.GetValue("UID_ApplicationServer").String;
			}
			else
			{
				mnuPopup_Copy.Enabled = false;
				mnuPopup_CL2FDS.Enabled = false;
			}
		}

		private void mnuPopup_Copy_Click(object sender, System.EventArgs e)
		{
			if (tlcProfile.SelectedNode != null)
			{
				NodeData ndp = tlcProfile.SelectedNode.Tag as NodeData;
				NodeData nds = m_tlnServer.Tag as NodeData;

				// update startdate
				tlcProfile.SelectedNode.SubItems[3].Caption = clsMain.Instance.CurrentConnection.Connection.LocalNow.ToString();
				tlcProfile.SelectedNode.SubItems[2].Caption = "False";

				// start servercopy
				JobQueueCheck.RefreshProfileCopy( ndp.Type, nds.Data1, ndp.Data1, tlcProfile.SelectedNode.SubItems[1].Caption );

				// refresh JobQueueState
				_InitializeJobQueueThread();
			}
		}

		private void mnuPopup_CL2FDS_Click(object sender, System.EventArgs e)
		{
			if (tlcProfile.SelectedNode != null)
			{
				NodeData ndp = tlcProfile.SelectedNode.Tag as NodeData;
				NodeData nds = m_tlnServer.Tag as NodeData;

				// update startdate
				tlcProfile.SelectedNode.SubItems[3].Caption = clsMain.Instance.CurrentConnection.Connection.LocalNow.ToString();
				tlcProfile.SelectedNode.SubItems[2].Caption = "False";

				// start copy from CL
				JobQueueCheck.RefreshProfileCL2FDS( ndp.Type, ndp.Data1, nds.Data1, nds.Data2, m_dbCentralLibrary );

				// refresh JobQueueState
				_InitializeJobQueueThread();
			}
		}

		private void _SaveFormSettings()
		{
			IConfigData	conf = AppData.Instance.Config( "frmServerHasProfile", false);

			// save the window size and position
			conf.Put( "Splitter",   panelLeft.Width.ToString() );
			conf.Put( "columnServer", tlcServer.Columns[0].Width.ToString() );

			conf.Put( "columnProfile", tlcProfile.Columns[0].Width.ToString() );
			conf.Put( "columnIst",     tlcProfile.Columns[1].Width.ToString() );
			conf.Put( "columnSoll",    tlcProfile.Columns[2].Width.ToString() );
			conf.Put( "columnStateP",  tlcProfile.Columns[3].Width.ToString() );
			conf.Put( "columnStateS",  tlcProfile.Columns[4].Width.ToString() );
			conf.Put( "columnChanged", tlcProfile.Columns[5].Width.ToString() );
			conf.Put( "columnCopyJob", tlcProfile.Columns[6].Width.ToString() );
		}

		private void _LoadFormSettings()
		{
			IConfigData	conf = AppData.Instance.Config( "frmServerHasProfile", false);

			// restore position
			if ( conf.Get("Splitter").Length > 0)
				panelLeft.Width = Convert.ToInt32(conf.Get("Splitter"));

			if ( conf.Get("columnServer").Length > 0)
				tlcServer.Columns[0].Width = Convert.ToInt32(conf.Get("columnServer"));

			if ( conf.Get("columnProfile").Length > 0)
				tlcProfile.Columns[0].Width = Convert.ToInt32(conf.Get("columnProfile"));

			if ( conf.Get("columnIst").Length > 0)
				tlcProfile.Columns[1].Width = Convert.ToInt32(conf.Get("columnIst"));

			if ( conf.Get("columnSoll").Length > 0)
				tlcProfile.Columns[2].Width = Convert.ToInt32(conf.Get("columnSoll"));

			if ( conf.Get("columnStateP").Length > 0)
				tlcProfile.Columns[3].Width = Convert.ToInt32(conf.Get("columnStateP"));

			if ( conf.Get("columnStateS").Length > 0)
				tlcProfile.Columns[4].Width = Convert.ToInt32(conf.Get("columnStateS"));

			if ( conf.Get("columnChanged").Length > 0)
				tlcProfile.Columns[5].Width = Convert.ToInt32(conf.Get("columnChanged"));

			if ( conf.Get("columnCopyJob").Length > 0)
				tlcProfile.Columns[6].Width = Convert.ToInt32(conf.Get("columnCopyJob"));

		}

		private void tlcServer_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
		{
			switch ( e.KeyCode )
			{
				case Keys.F5:
					_InsertDomainRootNode();
					break;
			}
		}

		private void tlcServer_SelectedNodeChanged(object sender, VI.Controls.TreeListEventArgs args)
		{
			int iIndex = 0;

			if ( tbbDriverProfile.Pushed ) iIndex = 1;

			if ( tbbMachineType.Pushed )   iIndex = 2;

			_DisplayProfilesForServer( args.Node, iIndex );
		}

		private void tlcServer_NodeExpanding(object sender, VI.Controls.TreeListEventArgs args)
		{
			NodeData nd = args.Node.Tag as NodeData;

			switch ( nd.Type )
			{
				case NodeType.Domain:
					_ExpandDomain( args.Node );
					break;
			}
		}


		private void tlcProfile_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
		{
			switch ( e.KeyCode )
			{
				case Keys.F5:
					int iIndex = 0;

					if ( tbbDriverProfile.Pushed ) iIndex = 1;

					if ( tbbMachineType.Pushed )   iIndex = 2;

					_DisplayProfilesForServer( tlcServer.SelectedNode, iIndex );
					break;
			}
		}

		private void tbProfileType_ButtonClick(object sender, System.Windows.Forms.ToolBarButtonClickEventArgs e)
		{
			_DisplayProfilesForServer( m_tlnServer, e.Button.ImageIndex );
		}

		private void clsMain_ConnectionChanged(object sender, EventArgs e)
		{
			if ( clsMain.Instance.CurrentConnection != null )
			{
				_GetCentralLibrary();

				_InsertDomainRootNode();

				tbbMachineType.Visible = ! clsMain.Instance.CurrentConnection.Connection.Tables["MachineType"].IsDeactivated;
			}
		}


		private void _GetCentralLibrary()
		{
			ISqlFormatter fSQL = clsMain.Instance.CurrentConnection.Connection.SqlFormatter;
			IColDbObject colApplicationServer = clsMain.Instance.CurrentConnection.Connection.CreateCol("ApplicationServer");

			colApplicationServer.Prototype.WhereClause = fSQL.Comparison( "IsCentralLibrary", true, ValType.Bool );

			colApplicationServer.Load();

			if ( colApplicationServer.Count > 0 )
				m_dbCentralLibrary = colApplicationServer[0].Create();
			else
				m_dbCentralLibrary = null;
		}

	}
}
