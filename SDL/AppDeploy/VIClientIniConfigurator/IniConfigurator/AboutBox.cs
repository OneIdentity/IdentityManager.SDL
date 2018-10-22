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


using System.Reflection;
using System.Windows.Forms;

namespace IniConfigurator
{
	public class AboutBox : System.Windows.Forms.Form
	{
		private System.Windows.Forms.Button OK;
		private System.Windows.Forms.Label lblCopyright;
		private System.Windows.Forms.Label lblProduct;
		private System.Windows.Forms.Label lblVersion;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public AboutBox()
		{
			InitializeComponent();
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
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
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(AboutBox));
			this.lblProduct = new System.Windows.Forms.Label();
			this.lblCopyright = new System.Windows.Forms.Label();
			this.OK = new System.Windows.Forms.Button();
			this.lblVersion = new System.Windows.Forms.Label();
			this.SuspendLayout();
			//
			// lblProduct
			//
			this.lblProduct.Location = new System.Drawing.Point(8, 8);
			this.lblProduct.Name = "lblProduct";
			this.lblProduct.Size = new System.Drawing.Size(392, 16);
			this.lblProduct.TabIndex = 0;
			this.lblProduct.Text = "<Product>";
			//
			// lblCopyright
			//
			this.lblCopyright.Location = new System.Drawing.Point(8, 56);
			this.lblCopyright.Name = "lblCopyright";
			this.lblCopyright.Size = new System.Drawing.Size(392, 16);
			this.lblCopyright.TabIndex = 1;
			this.lblCopyright.Text = "<copyright>";
			//
			// OK
			//
			this.OK.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.OK.Location = new System.Drawing.Point(8, 80);
			this.OK.Name = "OK";
			this.OK.Size = new System.Drawing.Size(120, 24);
			this.OK.TabIndex = 2;
			this.OK.Text = "OK";
			this.OK.Click += new System.EventHandler(this.OK_Click);
			//
			// lblVersion
			//
			this.lblVersion.Location = new System.Drawing.Point(8, 32);
			this.lblVersion.Name = "lblVersion";
			this.lblVersion.Size = new System.Drawing.Size(392, 16);
			this.lblVersion.TabIndex = 3;
			this.lblVersion.Text = "<Version>";
			//
			// AboutBox
			//
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(410, 111);
			this.Controls.Add(this.lblVersion);
			this.Controls.Add(this.OK);
			this.Controls.Add(this.lblCopyright);
			this.Controls.Add(this.lblProduct);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.Name = "AboutBox";
			this.ShowInTaskbar = false;
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "About";
			this.Load += new System.EventHandler(this.AboutBox_Load);
			this.ResumeLayout(false);

		}
		#endregion

		private void OK_Click(object sender, System.EventArgs e)
		{
			this.Close();
		}

		private void AboutBox_Load(object sender, System.EventArgs e)
		{
			AssemblyCopyrightAttribute crAttribute = (AssemblyCopyrightAttribute) AssemblyCopyrightAttribute.GetCustomAttribute(Assembly.GetExecutingAssembly(), typeof(AssemblyCopyrightAttribute));
			this.lblProduct.Text = Application.ProductName;
			this.lblVersion.Text = "Version: " + Application.ProductVersion;
			this.lblCopyright.Text = crAttribute.Copyright;
		}
	}
}
