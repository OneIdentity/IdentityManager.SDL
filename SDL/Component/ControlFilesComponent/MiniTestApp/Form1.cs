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
using System.Data;

using VI.JobService.JobComponents;

namespace MiniTestApp
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
		private System.Windows.Forms.Button btnWriteSectionWithCommit;
		private System.Windows.Forms.Button btnWriteSectionWithRollback;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public Form1()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
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
			this.btnWriteSectionWithCommit = new System.Windows.Forms.Button();
			this.btnWriteSectionWithRollback = new System.Windows.Forms.Button();
			this.SuspendLayout();
			// 
			// btnWriteSectionWithCommit
			// 
			this.btnWriteSectionWithCommit.Location = new System.Drawing.Point(32, 28);
			this.btnWriteSectionWithCommit.Name = "btnWriteSectionWithCommit";
			this.btnWriteSectionWithCommit.Size = new System.Drawing.Size(88, 40);
			this.btnWriteSectionWithCommit.TabIndex = 1;
			this.btnWriteSectionWithCommit.Text = "Write section with &commit";
			this.btnWriteSectionWithCommit.Click += new System.EventHandler(this.button1_Click);
			// 
			// btnWriteSectionWithRollback
			// 
			this.btnWriteSectionWithRollback.Location = new System.Drawing.Point(152, 28);
			this.btnWriteSectionWithRollback.Name = "btnWriteSectionWithRollback";
			this.btnWriteSectionWithRollback.Size = new System.Drawing.Size(88, 40);
			this.btnWriteSectionWithRollback.TabIndex = 2;
			this.btnWriteSectionWithRollback.Text = "Write section with &rollback";
			// 
			// Form1
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(272, 98);
			this.Controls.Add(this.btnWriteSectionWithRollback);
			this.Controls.Add(this.btnWriteSectionWithCommit);
			this.Name = "Form1";
			this.Text = "Form1";
			this.ResumeLayout(false);

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new Form1());
		}

		private void button1_Click(object sender, System.EventArgs e)
		{
			FileTransaction myFileTransaction = new FileTransaction("C:\\Temp\\Path.vii", "TEST");

			myFileTransaction.BeginSection(true);

			myFileTransaction.WriteKey("Key001", "MasterValue001");
			myFileTransaction.WriteKey("Key003", "MasterValue003");
			myFileTransaction.WriteKey("Key005", "Value005");

			myFileTransaction.Commit();
		}
	}
}
