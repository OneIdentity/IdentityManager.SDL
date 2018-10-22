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
using System.Xml;
using System.ComponentModel;
using System.Windows.Forms;

namespace IniConfigurator
{
	/// <summary>
	/// Die Form, auf der sich alles abspielt und die fast nichts kann...
	///
	/// im app.Config-File gibt es zwei relevante Parameter:
	/// IniFileName und MaskFileName. Ist Ersterer angegeben, so wird die Datei bei Laden der Applikation geöffnet.
	/// Letzterer ist mandatory. Die angegebene Datei konfiguriert diese Applikation
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
		private System.Windows.Forms.PropertyGrid propertyGrid1;
		private System.Windows.Forms.MainMenu mainMenu;
		private System.Windows.Forms.MenuItem miFile;
		private System.Windows.Forms.MenuItem miFileOpen;
		private System.Windows.Forms.MenuItem miFileSave;
		private System.Windows.Forms.MenuItem miExit;
		private IContainer components;
		private FileAccessComponent openDocument;
		private System.Windows.Forms.MenuItem miFileNew;
		private System.Windows.Forms.MenuItem menuItem1;
		private System.Windows.Forms.MenuItem menuItem2;
		private System.Windows.Forms.MenuItem miFileSaveAs;
		private System.Windows.Forms.MenuItem menuItem3;
		private System.Windows.Forms.MenuItem miAbout;
		private System.Windows.Forms.MenuItem miOptions;
		private System.Windows.Forms.MenuItem miSaveDefaults;
		private XmlDocument configXml;

		private bool SaveDefaults { get { return( this.miSaveDefaults.Checked ); } }

		public Form1()
		{
			InitializeComponent();
		}

		protected override void Dispose( bool disposing )
		{
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
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
			this.propertyGrid1 = new System.Windows.Forms.PropertyGrid();
			this.mainMenu = new System.Windows.Forms.MainMenu(this.components);
			this.miFile = new System.Windows.Forms.MenuItem();
			this.miFileNew = new System.Windows.Forms.MenuItem();
			this.miFileOpen = new System.Windows.Forms.MenuItem();
			this.menuItem2 = new System.Windows.Forms.MenuItem();
			this.miFileSave = new System.Windows.Forms.MenuItem();
			this.miFileSaveAs = new System.Windows.Forms.MenuItem();
			this.menuItem1 = new System.Windows.Forms.MenuItem();
			this.miExit = new System.Windows.Forms.MenuItem();
			this.miOptions = new System.Windows.Forms.MenuItem();
			this.miSaveDefaults = new System.Windows.Forms.MenuItem();
			this.menuItem3 = new System.Windows.Forms.MenuItem();
			this.miAbout = new System.Windows.Forms.MenuItem();
			this.SuspendLayout();
			//
			// propertyGrid1
			//
			this.propertyGrid1.Dock = System.Windows.Forms.DockStyle.Fill;
			this.propertyGrid1.LineColor = System.Drawing.SystemColors.ScrollBar;
			this.propertyGrid1.Location = new System.Drawing.Point(0, 0);
			this.propertyGrid1.Name = "propertyGrid1";
			this.propertyGrid1.Size = new System.Drawing.Size(576, 350);
			this.propertyGrid1.TabIndex = 0;
			this.propertyGrid1.ToolbarVisible = false;
			//
			// mainMenu
			//
			this.mainMenu.MenuItems.AddRange(new System.Windows.Forms.MenuItem[]
			{
				this.miFile,
				this.miOptions,
				this.menuItem3
			});
			//
			// miFile
			//
			this.miFile.Index = 0;
			this.miFile.MenuItems.AddRange(new System.Windows.Forms.MenuItem[]
			{
				this.miFileNew,
				this.miFileOpen,
				this.menuItem2,
				this.miFileSave,
				this.miFileSaveAs,
				this.menuItem1,
				this.miExit
			});
			this.miFile.Text = "&File";
			this.miFile.Popup += new System.EventHandler(this.miFile_Popup);
			//
			// miFileNew
			//
			this.miFileNew.Index = 0;
			this.miFileNew.Text = "&New";
			this.miFileNew.Click += new System.EventHandler(this.miFileNew_Click);
			//
			// miFileOpen
			//
			this.miFileOpen.Index = 1;
			this.miFileOpen.Text = "&Open";
			this.miFileOpen.Click += new System.EventHandler(this.miFileOpen_Click);
			//
			// menuItem2
			//
			this.menuItem2.Index = 2;
			this.menuItem2.Text = "-";
			//
			// miFileSave
			//
			this.miFileSave.Index = 3;
			this.miFileSave.Text = "&Save";
			this.miFileSave.Click += new System.EventHandler(this.miFileSave_Click);
			//
			// miFileSaveAs
			//
			this.miFileSaveAs.Index = 4;
			this.miFileSaveAs.Text = "Save &As";
			this.miFileSaveAs.Click += new System.EventHandler(this.miSaveAs_Click);
			//
			// menuItem1
			//
			this.menuItem1.Index = 5;
			this.menuItem1.Text = "-";
			//
			// miExit
			//
			this.miExit.Index = 6;
			this.miExit.Text = "E&xit";
			this.miExit.Click += new System.EventHandler(this.miExit_Click);
			//
			// miOptions
			//
			this.miOptions.Index = 1;
			this.miOptions.MenuItems.AddRange(new System.Windows.Forms.MenuItem[]
			{
				this.miSaveDefaults
			});
			this.miOptions.Text = "&Options";
			//
			// miSaveDefaults
			//
			this.miSaveDefaults.Index = 0;
			this.miSaveDefaults.Text = "&SaveDefaults";
			this.miSaveDefaults.Click += new System.EventHandler(this.miSaveDefaults_Click);
			//
			// menuItem3
			//
			this.menuItem3.Index = 2;
			this.menuItem3.MenuItems.AddRange(new System.Windows.Forms.MenuItem[]
			{
				this.miAbout
			});
			this.menuItem3.Text = "&?";
			//
			// miAbout
			//
			this.miAbout.Index = 0;
			this.miAbout.Text = "&About";
			this.miAbout.Click += new System.EventHandler(this.menuItem4_Click);
			//
			// Form1
			//
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(576, 350);
			this.Controls.Add(this.propertyGrid1);
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.Menu = this.mainMenu;
			this.Name = "Form1";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "Ini Editor";
			this.Load += new System.EventHandler(this.Form1_Load);
			this.ResumeLayout(false);

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main()
		{
			Application.EnableVisualStyles();
			Application.DoEvents();
			Application.Run(new Form1());
		}

		private void Form1_Load(object sender, System.EventArgs e)
		{
			string maskFileName = System.Configuration.ConfigurationSettings.AppSettings[ "MaskFileName" ];
			string iniFileName = System.Configuration.ConfigurationSettings.AppSettings[ "IniFileName" ];

			this.configXml = new XmlDocument();

			try
			{
				this.configXml.XmlResolver = null;
				this.configXml.Load( maskFileName );
				bool showVersion = this.configXml.DocumentElement.Attributes[ "ShowVersion" ].Value.Equals( "true" );
				string applicationCaption = null;

				if ( showVersion )
					applicationCaption = string.Format( "{0} V{1}", this.configXml.DocumentElement.Attributes[ "ConfiguratorCaption" ].Value, this.configXml.DocumentElement.Attributes[ "Version" ].Value );
				else
					applicationCaption = this.configXml.DocumentElement.Attributes[ "ConfiguratorCaption" ].Value;

				this.Text = applicationCaption;
			}
			catch
			{
				MessageBox.Show( "Error loading mask xml." );
			}

			if ( ( iniFileName != null ) && ( iniFileName.Length != 0 ) )
			{
				this.OpenFile( iniFileName );
			}
		}

		private void miExit_Click(object sender, System.EventArgs e)
		{
			this.Close();
		}

		private void OpenFile( string fileName )
		{
			try
			{
				this.openDocument = new FileAccessComponent( fileName, new DefaultValueProvider( this.configXml ) );
				ConfigClass c1 = new ConfigClass( this.openDocument, this.configXml.DocumentElement );
				this.propertyGrid1.SelectedObject = c1;
			}
			catch ( Exception ex )
			{
				MessageBox.Show( string.Format( "Error opening file {0}: {1}", fileName, ex.Message ), "Error", MessageBoxButtons.OK, MessageBoxIcon.Error );
			}
		}

		private void miFileOpen_Click(object sender, System.EventArgs e)
		{
			OpenFileDialog dlg = new OpenFileDialog();
			dlg.Filter = "Ini Files|*.ini";
			dlg.CheckFileExists = true;
			dlg.Multiselect = false;

			if ( dlg.ShowDialog() == DialogResult.OK )
			{
				this.OpenFile( dlg.FileName );
			}
		}

		private void miFile_Popup(object sender, System.EventArgs e)
		{
			this.miFileSave.Enabled = ( this.openDocument != null );
			this.miFileSaveAs.Enabled = this.miFileSave.Enabled;
		}

		private void miFileNew_Click(object sender, System.EventArgs e)
		{
			this.OpenFile( null );
		}

		private void miFileSave_Click(object sender, System.EventArgs e)
		{
			if ( this.openDocument.FileName == null )
			{
				SaveFileDialog dlg = new SaveFileDialog();
				dlg.Filter = "Ini Files|*.ini";

				if ( dlg.ShowDialog() == DialogResult.OK )
				{
					// Existierendes File muss gelöscht werden!
					if ( System.IO.File.Exists( dlg.FileName ) )
						System.IO.File.Delete( dlg.FileName );

					this.openDocument.SaveAs( dlg.FileName, this.SaveDefaults );
				}
			}
			else
				this.openDocument.Save( this.SaveDefaults );
		}

		private void miSaveAs_Click(object sender, System.EventArgs e)
		{
			SaveFileDialog dlg = new SaveFileDialog();
			dlg.Filter = "Ini Files|*.ini";

			if ( dlg.ShowDialog() == DialogResult.OK )
			{
				this.openDocument.SaveAs( dlg.FileName, this.SaveDefaults );
			}
		}

		private void menuItem4_Click(object sender, System.EventArgs e)
		{
			AboutBox dlg = new AboutBox();
			dlg.ShowDialog();
		}

		private void miSaveDefaults_Click(object sender, System.EventArgs e)
		{
			this.miSaveDefaults.Checked = !this.miSaveDefaults.Checked;
		}

	}
}
