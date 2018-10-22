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
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;

using VI.Base;

namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Summary description for frmDBSystem.
	/// </summary>
	public class frmDBSystem : System.Windows.Forms.Form
	{
		private System.Windows.Forms.Button btnCancel;
		private System.Windows.Forms.Button btnOk;
		private System.Windows.Forms.GroupBox groupBox1;
		private System.Windows.Forms.RadioButton rbtnMSSQL;
		private System.Windows.Forms.RadioButton rbtnOracle;
		private System.Windows.Forms.ImageList imglDBSystems;
		private System.ComponentModel.IContainer components;

		public frmDBSystem()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			_TranslateForm();
		}

		public static string ShowDBDialog()
		{
			frmDBSystem frmDlg = new frmDBSystem();
			string strReturn = "";
			
			DialogResult drDlg = frmDlg.ShowDialog();

			if ( drDlg == DialogResult.OK )
			{
				if ( frmDlg.rbtnMSSQL.Checked )
					strReturn = "VI.DB.ViSqlFactory, VI.DB";
				else
					strReturn = "VI.DB.Oracle.ViOracleFactory, VI.DB.Oracle";
			}

			return strReturn;
		}



		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if(components != null)
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
			System.Resources.ResourceManager resources = new System.Resources.ResourceManager(typeof(frmDBSystem));
			this.btnCancel = new System.Windows.Forms.Button();
			this.btnOk = new System.Windows.Forms.Button();
			this.groupBox1 = new System.Windows.Forms.GroupBox();
			this.rbtnMSSQL = new System.Windows.Forms.RadioButton();
			this.rbtnOracle = new System.Windows.Forms.RadioButton();
			this.imglDBSystems = new System.Windows.Forms.ImageList(this.components);
			this.SuspendLayout();
			// 
			// btnCancel
			// 
			this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnCancel.Location = new System.Drawing.Point(168, 72);
			this.btnCancel.Name = "btnCancel";
			this.btnCancel.Size = new System.Drawing.Size(80, 24);
			this.btnCancel.TabIndex = 3;
			this.btnCancel.Text = "~Cancel";
			// 
			// btnOk
			// 
			this.btnOk.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.btnOk.DialogResult = System.Windows.Forms.DialogResult.OK;
			this.btnOk.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnOk.Location = new System.Drawing.Point(72, 72);
			this.btnOk.Name = "btnOk";
			this.btnOk.Size = new System.Drawing.Size(88, 24);
			this.btnOk.TabIndex = 2;
			this.btnOk.Text = "~Ok";
			// 
			// groupBox1
			// 
			this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.groupBox1.Location = new System.Drawing.Point(0, 56);
			this.groupBox1.Name = "groupBox1";
			this.groupBox1.Size = new System.Drawing.Size(256, 8);
			this.groupBox1.TabIndex = 6;
			this.groupBox1.TabStop = false;
			// 
			// rbtnMSSQL
			// 
			this.rbtnMSSQL.Appearance = System.Windows.Forms.Appearance.Button;
			this.rbtnMSSQL.BackColor = System.Drawing.Color.White;
			this.rbtnMSSQL.Checked = true;
			this.rbtnMSSQL.ForeColor = System.Drawing.SystemColors.ControlText;
			this.rbtnMSSQL.ImageIndex = 0;
			this.rbtnMSSQL.ImageList = this.imglDBSystems;
			this.rbtnMSSQL.Location = new System.Drawing.Point(8, 8);
			this.rbtnMSSQL.Name = "rbtnMSSQL";
			this.rbtnMSSQL.Size = new System.Drawing.Size(112, 40);
			this.rbtnMSSQL.TabIndex = 0;
			this.rbtnMSSQL.TabStop = true;
			// 
			// rbtnOracle
			// 
			this.rbtnOracle.Appearance = System.Windows.Forms.Appearance.Button;
			this.rbtnOracle.BackColor = System.Drawing.Color.White;
			this.rbtnOracle.ImageIndex = 1;
			this.rbtnOracle.ImageList = this.imglDBSystems;
			this.rbtnOracle.Location = new System.Drawing.Point(128, 8);
			this.rbtnOracle.Name = "rbtnOracle";
			this.rbtnOracle.Size = new System.Drawing.Size(120, 40);
			this.rbtnOracle.TabIndex = 1;
			// 
			// imglDBSystems
			// 
			this.imglDBSystems.ImageSize = new System.Drawing.Size(100, 20);
			this.imglDBSystems.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imglDBSystems.ImageStream")));
			this.imglDBSystems.TransparentColor = System.Drawing.Color.Transparent;
			// 
			// frmDBSystem
			// 
			this.AcceptButton = this.btnOk;
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.CancelButton = this.btnCancel;
			this.ClientSize = new System.Drawing.Size(258, 104);
			this.ControlBox = false;
			this.Controls.Add(this.rbtnOracle);
			this.Controls.Add(this.rbtnMSSQL);
			this.Controls.Add(this.groupBox1);
			this.Controls.Add(this.btnOk);
			this.Controls.Add(this.btnCancel);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.Name = "frmDBSystem";
			this.ShowInTaskbar = false;
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
			this.Text = "~Select DBSystem";
			this.ResumeLayout(false);

		}
		#endregion

		private void _TranslateForm()
		{
			Text           = LanguageManager.Instance.GetString( "frmDBSystem_Caption" );
			btnOk.Text     = LanguageManager.Instance.GetString( "frmDBSystem_btnOk" );
			btnCancel.Text = LanguageManager.Instance.GetString( "frmDBSystem_btnCancel" );
		}

	}
}
