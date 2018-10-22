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
using System.IO;

using VI.Base;
using VI.DB;
using VI.FormBase.Help;
using VI.CommonDialogs;

namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Summary description for frmApp.
	/// </summary>
	public class frmMain : System.Windows.Forms.Form
	{
		private VI.Controls.StatusBarConnection statusBar;
		private System.ComponentModel.IContainer components;
		private System.Windows.Forms.Timer timerMenu;
		private TD.SandDock.SandDockManager sdManager;
		private TD.SandBar.SandBarManager sbManager;
		private TD.SandBar.ToolBarContainer leftSandBarDock;
		private TD.SandBar.ToolBarContainer rightSandBarDock;
		private TD.SandBar.ToolBarContainer bottomSandBarDock;
		private TD.SandBar.ToolBarContainer topSandBarDock;
		private TD.SandBar.MenuBar menuBar;
		private TD.SandBar.MenuBarItem mnuWindows;
		private TD.SandBar.MenuButtonItem mnuWindows_ProfileOnServer;
		private TD.SandBar.MenuButtonItem mnuWindows_ServerHasProfile;
		private TD.SandBar.ToolBar toolBar;
		private TD.SandBar.MenuBarItem mnuConnection;
		private TD.SandBar.MenuButtonItem mnuConnection_New;
		private TD.SandBar.MenuButtonItem mnuConnection_Close;
		private TD.SandBar.MenuButtonItem mnuConnection_Setup;
		private TD.SandBar.MenuButtonItem mnuConnection_Exit;
		private VI.FormBase.TranslatorComponent Translator;
		private VI.ImageLibrary.StockImageComponent stockImages;
		private TD.SandBar.ButtonItem tbbConnection_New;
		private TD.SandBar.ButtonItem tbbConnection_Close;
		private TD.SandBar.ButtonItem tbbProfileOnServer;
		private TD.SandBar.ButtonItem tbbServerHasProfile;
		private TD.SandBar.MenuBarItem mnuHelp;
		private TD.SandBar.MenuButtonItem mnuHelp_ReplicationInfo;
		private VI.Tools.ReplicationInfo.DCProfileOnServer dcProfileOnServer;
		private VI.Tools.ReplicationInfo.DCServerHasProfile dcServerHasProfile;
		private VI.Tools.ReplicationInfo.DCFDSProfileOnServer dcFDSProfileOnServer;
		private TD.SandDock.DocumentContainer docEdit;
		private TD.SandDock.TabbedDocument frmProfileOnServer;
		private TD.SandDock.TabbedDocument frmServerHasProfile;
		private TD.SandBar.MenuButtonItem mnuConnection_ChangePassword;
		private TD.SandBar.MenuButtonItem menuWindows_DefaultLayout;
		private TD.SandDock.TabbedDocument frmFDSProfileOnServer;

		private TD.SandBar.MenuButtonItem mnuWindows_FDSProfileOnServer;
		private TD.SandBar.MenuButtonItem mnuHelp_Info;

		public frmMain()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			LanguageManager.Instance.Add( new VIIStringProvider(GetType().Assembly, "VI.Tools.ReplicationInfo.Resources.ReplicationInfo.vii"));

			// load the configuration
			clsMain.Instance.Load();

			clsMain.Instance.ConnectionChanged += new EventHandler(clsMain_ConnectionChanged);

			_TranslateForm();
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

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.components = new System.ComponentModel.Container();
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMain));
			this.statusBar = new VI.Controls.StatusBarConnection();
			this.timerMenu = new System.Windows.Forms.Timer(this.components);
			this.sdManager = new TD.SandDock.SandDockManager();
			this.sbManager = new TD.SandBar.SandBarManager(this.components);
			this.bottomSandBarDock = new TD.SandBar.ToolBarContainer();
			this.leftSandBarDock = new TD.SandBar.ToolBarContainer();
			this.rightSandBarDock = new TD.SandBar.ToolBarContainer();
			this.topSandBarDock = new TD.SandBar.ToolBarContainer();
			this.menuBar = new TD.SandBar.MenuBar();
			this.mnuConnection = new TD.SandBar.MenuBarItem();
			this.mnuConnection_New = new TD.SandBar.MenuButtonItem();
			this.mnuConnection_Close = new TD.SandBar.MenuButtonItem();
			this.mnuConnection_ChangePassword = new TD.SandBar.MenuButtonItem();
			this.mnuConnection_Setup = new TD.SandBar.MenuButtonItem();
			this.mnuConnection_Exit = new TD.SandBar.MenuButtonItem();
			this.mnuWindows = new TD.SandBar.MenuBarItem();
			this.mnuWindows_ProfileOnServer = new TD.SandBar.MenuButtonItem();
			this.mnuWindows_ServerHasProfile = new TD.SandBar.MenuButtonItem();
			this.mnuWindows_FDSProfileOnServer = new TD.SandBar.MenuButtonItem();
			this.menuWindows_DefaultLayout = new TD.SandBar.MenuButtonItem();
			this.mnuHelp = new TD.SandBar.MenuBarItem();
			this.mnuHelp_ReplicationInfo = new TD.SandBar.MenuButtonItem();
			this.mnuHelp_Info = new TD.SandBar.MenuButtonItem();
			this.toolBar = new TD.SandBar.ToolBar();
			this.tbbConnection_New = new TD.SandBar.ButtonItem();
			this.tbbConnection_Close = new TD.SandBar.ButtonItem();
			this.tbbProfileOnServer = new TD.SandBar.ButtonItem();
			this.tbbServerHasProfile = new TD.SandBar.ButtonItem();
			this.Translator = new VI.FormBase.TranslatorComponent();
			this.stockImages = new VI.ImageLibrary.StockImageComponent();
			this.docEdit = new TD.SandDock.DocumentContainer();
			this.frmProfileOnServer = new TD.SandDock.TabbedDocument();
			this.dcProfileOnServer = new VI.Tools.ReplicationInfo.DCProfileOnServer();
			this.frmServerHasProfile = new TD.SandDock.TabbedDocument();
			this.dcServerHasProfile = new VI.Tools.ReplicationInfo.DCServerHasProfile();
			this.frmFDSProfileOnServer = new TD.SandDock.TabbedDocument();
			this.dcFDSProfileOnServer = new VI.Tools.ReplicationInfo.DCFDSProfileOnServer();
			this.topSandBarDock.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.Translator)).BeginInit();
			this.docEdit.SuspendLayout();
			this.frmProfileOnServer.SuspendLayout();
			this.frmServerHasProfile.SuspendLayout();
			this.frmFDSProfileOnServer.SuspendLayout();
			this.SuspendLayout();
			//
			// statusBar
			//
			this.statusBar.BackColor = System.Drawing.SystemColors.Control;
			this.statusBar.Dock = System.Windows.Forms.DockStyle.Bottom;
			this.statusBar.Location = new System.Drawing.Point(0, 458);
			this.statusBar.Name = "statusBar";
			this.statusBar.ShowPanels = true;
			this.statusBar.Size = new System.Drawing.Size(736, 20);
			this.statusBar.TabIndex = 1;
			this.Translator.SetTextProperty(this.statusBar, null);
			//
			// timerMenu
			//
			this.timerMenu.Enabled = true;
			this.timerMenu.Interval = 200;
			this.timerMenu.Tick += new System.EventHandler(this.timerMenu_Tick);
			//
			// sdManager
			//
			this.sdManager.DockSystemContainer = this;
			this.sdManager.OwnerForm = this;
			this.sdManager.SerializeTabbedDocuments = true;
			//
			// sbManager
			//
			this.sbManager.OwnerForm = this;
			//
			// bottomSandBarDock
			//
			this.bottomSandBarDock.Dock = System.Windows.Forms.DockStyle.Bottom;
			this.bottomSandBarDock.Guid = new System.Guid("e72a7607-d7e3-47b3-b7f1-89108fd65798");
			this.bottomSandBarDock.Location = new System.Drawing.Point(0, 478);
			this.bottomSandBarDock.Manager = this.sbManager;
			this.bottomSandBarDock.Name = "bottomSandBarDock";
			this.bottomSandBarDock.Size = new System.Drawing.Size(736, 0);
			this.bottomSandBarDock.TabIndex = 16;
			this.Translator.SetTextProperty(this.bottomSandBarDock, null);
			//
			// leftSandBarDock
			//
			this.leftSandBarDock.Dock = System.Windows.Forms.DockStyle.Left;
			this.leftSandBarDock.Guid = new System.Guid("25105e1c-7421-4a89-b7b8-c3da9f7bb509");
			this.leftSandBarDock.Location = new System.Drawing.Point(0, 49);
			this.leftSandBarDock.Manager = this.sbManager;
			this.leftSandBarDock.Name = "leftSandBarDock";
			this.leftSandBarDock.Size = new System.Drawing.Size(0, 429);
			this.leftSandBarDock.TabIndex = 14;
			this.Translator.SetTextProperty(this.leftSandBarDock, null);
			//
			// rightSandBarDock
			//
			this.rightSandBarDock.Dock = System.Windows.Forms.DockStyle.Right;
			this.rightSandBarDock.Guid = new System.Guid("fa0a80f2-2045-4bf0-96ba-69eedd96a28c");
			this.rightSandBarDock.Location = new System.Drawing.Point(736, 49);
			this.rightSandBarDock.Manager = this.sbManager;
			this.rightSandBarDock.Name = "rightSandBarDock";
			this.rightSandBarDock.Size = new System.Drawing.Size(0, 429);
			this.rightSandBarDock.TabIndex = 15;
			this.Translator.SetTextProperty(this.rightSandBarDock, null);
			//
			// topSandBarDock
			//
			this.topSandBarDock.Controls.Add(this.menuBar);
			this.topSandBarDock.Controls.Add(this.toolBar);
			this.topSandBarDock.Dock = System.Windows.Forms.DockStyle.Top;
			this.topSandBarDock.Guid = new System.Guid("e85dc19a-44ea-4d40-bae1-0e898a265689");
			this.topSandBarDock.Location = new System.Drawing.Point(0, 0);
			this.topSandBarDock.Manager = this.sbManager;
			this.topSandBarDock.Name = "topSandBarDock";
			this.topSandBarDock.Size = new System.Drawing.Size(736, 49);
			this.topSandBarDock.TabIndex = 17;
			this.Translator.SetTextProperty(this.topSandBarDock, null);
			//
			// menuBar
			//
			this.menuBar.Guid = new System.Guid("f8a868a5-addc-42ba-907c-8e2d7b4af3d2");
			this.menuBar.Items.AddRange(new TD.SandBar.ToolbarItemBase[]
			{
				this.mnuConnection,
				this.mnuWindows,
				this.mnuHelp
			});
			this.menuBar.Location = new System.Drawing.Point(2, 0);
			this.menuBar.Name = "menuBar";
			this.menuBar.OwnerForm = this;
			this.menuBar.Size = new System.Drawing.Size(734, 23);
			this.menuBar.TabIndex = 0;
			this.Translator.SetTextProperty(this.menuBar, null);
			//
			// mnuConnection
			//
			this.mnuConnection.Items.AddRange(new TD.SandBar.ToolbarItemBase[]
			{
				this.mnuConnection_New,
				this.mnuConnection_Close,
				this.mnuConnection_ChangePassword,
				this.mnuConnection_Setup,
				this.mnuConnection_Exit
			});
			this.mnuConnection.Text = "frmMain_mnuConnection";
			this.Translator.SetTextProperty(this.mnuConnection, "Text");
			//
			// mnuConnection_New
			//
			this.mnuConnection_New.Shortcut = System.Windows.Forms.Shortcut.CtrlShiftN;
			this.stockImages.SetStockImage(this.mnuConnection_New, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.OpenConnection, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.mnuConnection_New.Text = "frmMain_mnuConnection_New";
			this.Translator.SetTextProperty(this.mnuConnection_New, "Text");
			this.mnuConnection_New.Activate += new System.EventHandler(this.mnuFile_NewConn_Click);
			//
			// mnuConnection_Close
			//
			this.stockImages.SetStockImage(this.mnuConnection_Close, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.CloseConnection, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.mnuConnection_Close.Text = "frmMain_mnuConnection_Close";
			this.Translator.SetTextProperty(this.mnuConnection_Close, "Text");
			this.mnuConnection_Close.Activate += new System.EventHandler(this.mnuFile_CloseConn_Click);
			//
			// mnuConnection_ChangePassword
			//
			this.mnuConnection_ChangePassword.BeginGroup = true;
			this.stockImages.SetStockImage(this.mnuConnection_ChangePassword, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.ChangePassword, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.mnuConnection_ChangePassword.Text = "frmMain_mnuConnection_ChangePassword";
			this.Translator.SetTextProperty(this.mnuConnection_ChangePassword, "Text");
			this.mnuConnection_ChangePassword.Activate += new System.EventHandler(this.mnuConnection_ChangePassword_Activate);
			//
			// mnuConnection_Setup
			//
			this.stockImages.SetStockImage(this.mnuConnection_Setup, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.Options, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.mnuConnection_Setup.Text = "frmMain_mnuConnection_Setup";
			this.Translator.SetTextProperty(this.mnuConnection_Setup, "Text");
			this.mnuConnection_Setup.Activate += new System.EventHandler(this.mnuFile_Setup_Click);
			//
			// mnuConnection_Exit
			//
			this.mnuConnection_Exit.BeginGroup = true;
			this.mnuConnection_Exit.Shortcut = System.Windows.Forms.Shortcut.AltF4;
			this.stockImages.SetStockImage(this.mnuConnection_Exit, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.Exit, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.mnuConnection_Exit.Text = "frmMain_mnuConnection_Exit";
			this.Translator.SetTextProperty(this.mnuConnection_Exit, "Text");
			this.mnuConnection_Exit.Activate += new System.EventHandler(this.mnuFile_End_Click);
			//
			// mnuWindows
			//
			this.mnuWindows.Items.AddRange(new TD.SandBar.ToolbarItemBase[]
			{
				this.mnuWindows_ProfileOnServer,
				this.mnuWindows_ServerHasProfile,
				this.mnuWindows_FDSProfileOnServer,
				this.menuWindows_DefaultLayout
			});
			this.mnuWindows.Text = "frmMain_mnuWindows";
			this.Translator.SetTextProperty(this.mnuWindows, "Text");
			//
			// mnuWindows_ProfileOnServer
			//
			this.mnuWindows_ProfileOnServer.Image = ((System.Drawing.Image)(resources.GetObject("mnuWindows_ProfileOnServer.Image")));
			this.mnuWindows_ProfileOnServer.Text = "frmMain_mnuWindows_ProfileOnServer";
			this.Translator.SetTextProperty(this.mnuWindows_ProfileOnServer, "Text");
			this.mnuWindows_ProfileOnServer.Activate += new System.EventHandler(this.mnuWindows_ProfileOnServer_Activate);
			//
			// mnuWindows_ServerHasProfile
			//
			this.mnuWindows_ServerHasProfile.Image = ((System.Drawing.Image)(resources.GetObject("mnuWindows_ServerHasProfile.Image")));
			this.mnuWindows_ServerHasProfile.Text = "frmMain_mnuWindows_ServerHasProfile";
			this.Translator.SetTextProperty(this.mnuWindows_ServerHasProfile, "Text");
			this.mnuWindows_ServerHasProfile.Activate += new System.EventHandler(this.mnuWindows_ServerHasProfile_Activate);
			//
			// mnuWindows_FDSProfileOnServer
			//
			this.stockImages.SetStockImage(this.mnuWindows_FDSProfileOnServer, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.WebUpload, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.mnuWindows_FDSProfileOnServer.Text = "mnuWindows_FDSProfileOnServer";
			this.Translator.SetTextProperty(this.mnuWindows_FDSProfileOnServer, "Text");
			this.mnuWindows_FDSProfileOnServer.Activate += new System.EventHandler(this.mnuWindows_FDSProfileOnServer_Activate);
			//
			// menuWindows_DefaultLayout
			//
			this.menuWindows_DefaultLayout.BeginGroup = true;
			this.stockImages.SetStockImage(this.menuWindows_DefaultLayout, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.CascadeWindows, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.menuWindows_DefaultLayout.Text = "frmMain_menuWindows_DefaultLayout";
			this.Translator.SetTextProperty(this.menuWindows_DefaultLayout, "Text");
			this.menuWindows_DefaultLayout.Activate += new System.EventHandler(this.menuWindows_DefaultLayout_Activate);
			//
			// mnuHelp
			//
			this.mnuHelp.Items.AddRange(new TD.SandBar.ToolbarItemBase[]
			{
				this.mnuHelp_ReplicationInfo,
				this.mnuHelp_Info
			});
			this.mnuHelp.Text = "frmMain_mnuHelp";
			this.Translator.SetTextProperty(this.mnuHelp, "Text");
			//
			// mnuHelp_ReplicationInfo
			//
			this.mnuHelp_ReplicationInfo.Icon = ((System.Drawing.Icon)(resources.GetObject("mnuHelp_ReplicationInfo.Icon")));
			this.mnuHelp_ReplicationInfo.Text = "frmMain_mnuHelp_ReplicationInfo";
			this.Translator.SetTextProperty(this.mnuHelp_ReplicationInfo, "Text");
			this.mnuHelp_ReplicationInfo.Activate += new System.EventHandler(this.mnuInfo_ReplicationInfo_Activate);
			//
			// mnuHelp_Info
			//
			this.mnuHelp_Info.Text = "frmMain_mnuHelp_Info";
			this.Translator.SetTextProperty(this.mnuHelp_Info, "Text");
			this.mnuHelp_Info.Activate += new System.EventHandler(this.mnuHelp_Info_Activate);
			//
			// toolBar
			//
			this.toolBar.DockLine = 1;
			this.toolBar.DrawActionsButton = false;
			this.toolBar.Guid = new System.Guid("d8f479c4-9b4a-45e9-a5e8-fa8a513204d0");
			this.toolBar.Items.AddRange(new TD.SandBar.ToolbarItemBase[]
			{
				this.tbbConnection_New,
				this.tbbConnection_Close,
				this.tbbProfileOnServer,
				this.tbbServerHasProfile
			});
			this.toolBar.Location = new System.Drawing.Point(2, 23);
			this.toolBar.Name = "toolBar";
			this.toolBar.Size = new System.Drawing.Size(734, 26);
			this.toolBar.Stretch = true;
			this.toolBar.TabIndex = 1;
			this.toolBar.TextAlign = TD.SandBar.ToolBarTextAlign.Underneath;
			this.Translator.SetTextProperty(this.toolBar, null);
			//
			// tbbConnection_New
			//
			this.tbbConnection_New.BuddyMenu = this.mnuConnection_New;
			this.tbbConnection_New.ImageIndex = 0;
			this.stockImages.SetStockImage(this.tbbConnection_New, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.OpenConnection, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.Translator.SetTextProperty(this.tbbConnection_New, "ToolTipText");
			this.tbbConnection_New.ToolTipText = "frmMain_tbbConnection_New";
			this.tbbConnection_New.Activate += new System.EventHandler(this.mnuFile_NewConn_Click);
			//
			// tbbConnection_Close
			//
			this.tbbConnection_Close.BuddyMenu = this.mnuConnection_Close;
			this.tbbConnection_Close.ImageIndex = 1;
			this.stockImages.SetStockImage(this.tbbConnection_Close, new VI.ImageLibrary.StockImageDefinition("Image", VI.ImageLibrary.StockImage.CloseConnection, VI.ImageLibrary.ImageSize.Small, VI.ImageLibrary.ImageState.Normal));
			this.Translator.SetTextProperty(this.tbbConnection_Close, "ToolTipText");
			this.tbbConnection_Close.ToolTipText = "frmMain_tbbConnection_Close";
			this.tbbConnection_Close.Activate += new System.EventHandler(this.mnuFile_CloseConn_Click);
			//
			// tbbProfileOnServer
			//
			this.tbbProfileOnServer.BeginGroup = true;
			this.tbbProfileOnServer.BuddyMenu = this.mnuWindows_ProfileOnServer;
			this.tbbProfileOnServer.Image = ((System.Drawing.Image)(resources.GetObject("tbbProfileOnServer.Image")));
			this.tbbProfileOnServer.ImageIndex = 2;
			this.Translator.SetTextProperty(this.tbbProfileOnServer, "ToolTipText");
			this.tbbProfileOnServer.ToolTipText = "frmMain_tbbProfileOnServer";
			this.tbbProfileOnServer.Activate += new System.EventHandler(this.mnuWindows_ProfileOnServer_Activate);
			//
			// tbbServerHasProfile
			//
			this.tbbServerHasProfile.BuddyMenu = this.mnuWindows_ServerHasProfile;
			this.tbbServerHasProfile.Image = ((System.Drawing.Image)(resources.GetObject("tbbServerHasProfile.Image")));
			this.tbbServerHasProfile.ImageIndex = 3;
			this.Translator.SetTextProperty(this.tbbServerHasProfile, "ToolTipText");
			this.tbbServerHasProfile.ToolTipText = "frmMain_tbbServerHasProfile";
			this.tbbServerHasProfile.Activate += new System.EventHandler(this.mnuWindows_ServerHasProfile_Activate);
			//
			// stockImages
			//
			this.stockImages.DefaultImageProperty = null;
			this.Translator.SetTextProperty(this.stockImages, null);
			//
			// docEdit
			//
			this.docEdit.Controls.Add(this.frmProfileOnServer);
			this.docEdit.Controls.Add(this.frmServerHasProfile);
			this.docEdit.Controls.Add(this.frmFDSProfileOnServer);
			this.docEdit.LayoutSystem = new TD.SandDock.SplitLayoutSystem(734, 407, System.Windows.Forms.Orientation.Horizontal, new TD.SandDock.LayoutSystemBase[]
			{
				((TD.SandDock.LayoutSystemBase)(new TD.SandDock.DocumentLayoutSystem(734, 407, new TD.SandDock.DockControl[] {
					((TD.SandDock.DockControl)(this.frmProfileOnServer)),
					((TD.SandDock.DockControl)(this.frmServerHasProfile)),
					((TD.SandDock.DockControl)(this.frmFDSProfileOnServer))
				}, this.frmFDSProfileOnServer)))
			});
			this.docEdit.Location = new System.Drawing.Point(0, 49);
			this.docEdit.Manager = this.sdManager;
			this.docEdit.Name = "docEdit";
			this.docEdit.Size = new System.Drawing.Size(736, 409);
			this.docEdit.TabIndex = 19;
			this.Translator.SetTextProperty(this.docEdit, null);
			//
			// frmProfileOnServer
			//
			this.frmProfileOnServer.CloseAction = TD.SandDock.DockControlCloseAction.HideOnly;
			this.frmProfileOnServer.Controls.Add(this.dcProfileOnServer);
			this.frmProfileOnServer.FloatingSize = new System.Drawing.Size(550, 400);
			this.frmProfileOnServer.Guid = new System.Guid("9cd54c27-1eab-444d-8ae5-82d0cfd7134d");
			this.frmProfileOnServer.Location = new System.Drawing.Point(1, 21);
			this.frmProfileOnServer.Name = "frmProfileOnServer";
			this.frmProfileOnServer.Size = new System.Drawing.Size(734, 387);
			this.frmProfileOnServer.TabIndex = 0;
			this.frmProfileOnServer.Text = "frmProfileOnServer_Caption";
			this.Translator.SetTextProperty(this.frmProfileOnServer, "Text");
			//
			// dcProfileOnServer
			//
			this.dcProfileOnServer.Dock = System.Windows.Forms.DockStyle.Fill;
			this.dcProfileOnServer.Location = new System.Drawing.Point(0, 0);
			this.dcProfileOnServer.Name = "dcProfileOnServer";
			this.dcProfileOnServer.Size = new System.Drawing.Size(734, 387);
			this.dcProfileOnServer.TabIndex = 0;
			this.Translator.SetTextProperty(this.dcProfileOnServer, null);
			//
			// frmServerHasProfile
			//
			this.frmServerHasProfile.CloseAction = TD.SandDock.DockControlCloseAction.HideOnly;
			this.frmServerHasProfile.Controls.Add(this.dcServerHasProfile);
			this.frmServerHasProfile.FloatingSize = new System.Drawing.Size(550, 400);
			this.frmServerHasProfile.Guid = new System.Guid("2188f443-0beb-4fe0-80de-725dd0dceb86");
			this.frmServerHasProfile.Location = new System.Drawing.Point(1, 21);
			this.frmServerHasProfile.Name = "frmServerHasProfile";
			this.frmServerHasProfile.Size = new System.Drawing.Size(734, 387);
			this.frmServerHasProfile.TabIndex = 1;
			this.frmServerHasProfile.Text = "frmServerHasProfile_Caption";
			this.Translator.SetTextProperty(this.frmServerHasProfile, "Text");
			//
			// dcServerHasProfile
			//
			this.dcServerHasProfile.Dock = System.Windows.Forms.DockStyle.Fill;
			this.dcServerHasProfile.Location = new System.Drawing.Point(0, 0);
			this.dcServerHasProfile.Name = "dcServerHasProfile";
			this.dcServerHasProfile.Size = new System.Drawing.Size(734, 387);
			this.dcServerHasProfile.TabIndex = 0;
			this.Translator.SetTextProperty(this.dcServerHasProfile, null);
			//
			// frmFDSProfileOnServer
			//
			this.frmFDSProfileOnServer.CloseAction = TD.SandDock.DockControlCloseAction.HideOnly;
			this.frmFDSProfileOnServer.Controls.Add(this.dcFDSProfileOnServer);
			this.frmFDSProfileOnServer.FloatingSize = new System.Drawing.Size(550, 400);
			this.frmFDSProfileOnServer.Guid = new System.Guid("e98424bd-713a-418d-83b7-78f5f9a3da6d");
			this.frmFDSProfileOnServer.Location = new System.Drawing.Point(1, 21);
			this.frmFDSProfileOnServer.Name = "frmFDSProfileOnServer";
			this.frmFDSProfileOnServer.Size = new System.Drawing.Size(734, 387);
			this.frmFDSProfileOnServer.TabIndex = 2;
			this.frmFDSProfileOnServer.Text = "frmFDSProfileOnServer_Caption";
			this.Translator.SetTextProperty(this.frmFDSProfileOnServer, "Text");
			//
			// dcFDSProfileOnServer
			//
			this.dcFDSProfileOnServer.Dock = System.Windows.Forms.DockStyle.Fill;
			this.dcFDSProfileOnServer.Location = new System.Drawing.Point(0, 0);
			this.dcFDSProfileOnServer.Name = "dcFDSProfileOnServer";
			this.dcFDSProfileOnServer.Size = new System.Drawing.Size(734, 387);
			this.dcFDSProfileOnServer.TabIndex = 0;
			this.Translator.SetTextProperty(this.dcFDSProfileOnServer, null);
			//
			// frmMain
			//
			this.ClientSize = new System.Drawing.Size(736, 478);
			this.Controls.Add(this.docEdit);
			this.Controls.Add(this.statusBar);
			this.Controls.Add(this.leftSandBarDock);
			this.Controls.Add(this.rightSandBarDock);
			this.Controls.Add(this.bottomSandBarDock);
			this.Controls.Add(this.topSandBarDock);
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.IsMdiContainer = true;
			this.MinimumSize = new System.Drawing.Size(320, 200);
			this.Name = "frmMain";
			this.Text = "~ReplicationInfo";
			this.Translator.SetTextProperty(this, null);
			this.Closing += new System.ComponentModel.CancelEventHandler(this.frmMain_Closing);
			this.Load += new System.EventHandler(this.frmMain_Load);
			this.topSandBarDock.ResumeLayout(false);
			((System.ComponentModel.ISupportInitialize)(this.Translator)).EndInit();
			this.docEdit.ResumeLayout(false);
			this.frmProfileOnServer.ResumeLayout(false);
			this.frmServerHasProfile.ResumeLayout(false);
			this.frmFDSProfileOnServer.ResumeLayout(false);
			this.ResumeLayout(false);

		}
		#endregion

		private void _HandleUnhandledExceptions(object sender, UnhandledExceptionEventArgs e)
		{
			ExceptionDialog.Show( this, e.ExceptionObject as Exception );
		}

		private void frmMain_Load(object sender, System.EventArgs e)
		{
			try
			{
				WindowState = FormWindowState.Normal;

				_LoadFormSettings();

				AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(_HandleUnhandledExceptions);

				_CreateConnection(true);
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this, ex );
			}
		}

		private void mnuFile_NewConn_Click(object sender, System.EventArgs e)
		{
			_CreateConnection( false );
		}

		private void mnuFile_CloseConn_Click(object sender, System.EventArgs e)
		{
			_ReleaseConnection();
		}

		private void mnuFile_End_Click(object sender, System.EventArgs e)
		{
			Close();
		}

		/// <summary>
		/// Translate all languagedepending strings
		/// </summary>
		private void _TranslateForm()
		{
			LanguageManager L = LanguageManager.Instance;

			AppData.Instance.AppDisplay = L["frmMain_Caption"];

			Text = L["frmMain_Caption"];
		}

		private void mnuFile_Setup_Click(object sender, System.EventArgs e)
		{
			frmSetup myfrmSetup = new frmSetup();

			myfrmSetup.ShowDialog( this );
		}

		private void mnuInfo_ReplicationInfo_Activate(object sender, System.EventArgs e)
		{
			HelpMgr.Instance.ShowHelp(@"Help\ReplicationInfo\General", true);
		}

		private void _RefreshMenus()
		{
			bool bCon = clsMain.Instance.CurrentConnection != null;

			mnuConnection_Close.Enabled = bCon;
			mnuConnection_ChangePassword.Enabled = bCon;

			mnuWindows.Visible = bCon;

			mnuWindows_ProfileOnServer.Enabled  = bCon;
			mnuWindows_ServerHasProfile.Enabled = bCon;

			mnuWindows_ProfileOnServer.Checked  = frmProfileOnServer.IsAccessible;
			mnuWindows_ServerHasProfile.Checked = frmServerHasProfile.IsAccessible;
			mnuWindows_FDSProfileOnServer.Checked = frmFDSProfileOnServer.IsAccessible;
		}

		private void _RefreshCaption()
		{
			string strCaption = LanguageManager.Instance.GetString( "frmMain_Caption" );

			if (clsMain.Instance.CurrentConnection == null)
				Text = String.Format( "{0} - {1}",
									  strCaption,
									  LanguageManager.Instance.GetString( "frmMain_NoConnection" ) );
			else
				Text = String.Format( "{0} - {1}@{2} ({3})",
									  strCaption,
									  clsMain.Instance.CurrentConnection.Connection.User.Display,
									  clsMain.Instance.CurrentConnection.Connection.Display,
									  clsMain.Instance.CurrentConnection.Connection.Database.Display );
		}

		private void frmMain_Closing(object sender, System.ComponentModel.CancelEventArgs e)
		{
			string configFile = Path.Combine(Path.GetDirectoryName(Application.ExecutablePath), "JobQueueInfo.config");

			_CloseAllDocuments();

			// save the configuration
			clsMain.Instance.Save();

			_SaveFormSettings();
		}


		private void toolBar_ButtonClick(object sender, System.Windows.Forms.ToolBarButtonClickEventArgs e)
		{
			switch ( (string) e.Button.Tag )
			{
				case "tbtnNewConnection":
					_CreateConnection( false );
					break;
				case "tbtnCloseConnection":
					_ReleaseConnection();
					break;

					/*

					case "tbtnProfileOnServer":
						if (frmProfileOnServer.IsHidden)
							frmProfileOnServer.Show(dockManager);
						else
							frmProfileOnServer.Hide();
						break;

					case "tbtnServerHasProfile":
						if ( frmServerHasProfile.IsHidden)
							 frmServerHasProfile.Show(dockManager);
						else
							frmServerHasProfile.Hide();
						break;
					*/
			}
		}

		private void _ReleaseConnection()
		{
			try
			{
				this._CloseAllDocuments();

				if ( clsMain.Instance.CurrentConnection != null )
				{
					clsMain.Instance.CurrentConnection.Connection.Dispose();
					clsMain.Instance.CurrentConnection = null;
				}
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this, ex );
			}
		}

		private bool _CloseAllDocuments( )
		{
			foreach ( TD.SandDock.DockControl dcEdit in sdManager.Documents )
			{
				dcEdit.Close();
			}

			return sdManager.Documents.GetLength(0) == 0;
		}

		private void _ShowAllDocuments()
		{
			frmFDSProfileOnServer.Manager = sdManager;
			frmFDSProfileOnServer.Open();

			frmProfileOnServer.Manager = sdManager;
			frmProfileOnServer.Open();

			frmServerHasProfile.Manager = sdManager;
			frmServerHasProfile.Open();
		}

		private void _CreateConnection( bool initial )
		{
			ConnectData	conn = null;

			// release the old connection
			_ReleaseConnection();

			try
			{
				ConnectionDialog dlg = new ConnectionDialog();

				dlg.NoAutoLogon = !initial;

				if ( dlg.ShowDialog(this) == DialogResult.OK )
				{
					BringToFront();

					// assign as current connection
					clsMain.Instance.CurrentConnection = dlg.ConnectData;

					_ShowAllDocuments();
				}
				else
				{
					if (initial)
						Close();
				}
			}
			catch ( VI.DB.ViLoginCancelException )
			{
				conn.Connection.Dispose();
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this, ex );
			}
		}

		private void timerMenu_Tick(object sender, System.EventArgs e)
		{
			_RefreshCaption();

			_RefreshMenus();
		}

		private void _SaveFormSettings()
		{
			IConfigData	conf = AppData.Instance.Config( "frmMain", false);

			VI.FormBase.Misc.ConfigDataHelper.SaveFormPosition( conf, this );
		}

		private void _LoadFormSettings()
		{
			IConfigData	conf = AppData.Instance.Config( "frmMain", false);

			VI.FormBase.Misc.ConfigDataHelper.LoadFormPosition( conf, this );
		}

		private void clsMain_ConnectionChanged(object sender, EventArgs e)
		{
			if ( clsMain.Instance.CurrentConnection != null)
			{
				statusBar.Session = clsMain.Instance.CurrentConnection.Connection.Session;

				_ShowAllDocuments();
			}
			else
			{
				_CloseAllDocuments();
				statusBar.Session = null;
			}
		}

		private static void _ChangeVisibilityDocument(TD.SandDock.DockControl frmControl)
		{
			if (frmControl.IsOpen)
			{
				frmControl.Close();
			}
			else
			{
				if ( ! frmControl.IsAccessible )
					frmControl.Open( );

				frmControl.Activate();
			}
		}

		private void mnuWindows_ServerHasProfile_Activate(object sender, System.EventArgs e)
		{
			_ChangeVisibilityDocument( frmServerHasProfile );
		}

		private void mnuWindows_ProfileOnServer_Activate(object sender, System.EventArgs e)
		{
			_ChangeVisibilityDocument( frmProfileOnServer );
		}

		private void mnuWindows_FDSProfileOnServer_Activate(object sender, EventArgs e)
		{
			_ChangeVisibilityDocument(frmFDSProfileOnServer);
		}

		private void mnuHelp_Info_Activate(object sender, System.EventArgs e)
		{
			using ( AboutDialog myfrmAbout = new AboutDialog(clsMain.Instance.CurrentConnection != null ? clsMain.Instance.CurrentConnection.Connection : null) )
			{
				myfrmAbout.ShowDialog( this );
			}
		}

		private void mnuConnection_ChangePassword_Activate(object sender, EventArgs e)
		{
			using (PasswordChangeDialog dlg = new PasswordChangeDialog())
			{
				dlg.Connection = clsMain.Instance.CurrentConnection.Connection;

				dlg.ShowDialog(this);
			}
		}

		private void menuWindows_DefaultLayout_Activate(object sender, EventArgs e)
		{
			frmProfileOnServer.Close();
			frmProfileOnServer.Manager = sdManager;
			frmProfileOnServer.Open();

			frmServerHasProfile.Close();
			frmServerHasProfile.Manager = sdManager;
			frmServerHasProfile.Open();

			frmFDSProfileOnServer.Close();
			frmFDSProfileOnServer.Manager = sdManager;
			frmFDSProfileOnServer.Open();

		}

	}

}
