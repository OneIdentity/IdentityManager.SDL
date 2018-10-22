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

using VI.Base;
using VI.CommonDialogs;

namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Form to configure the program
	/// </summary>
	public class frmSetup : System.Windows.Forms.Form
	{
		private System.Windows.Forms.ComboBox cbxLanguage;
		private System.Windows.Forms.Label lblLanguage;
		private System.Windows.Forms.Button btnOk;
		private System.Windows.Forms.Button btnCancel;
		private System.Windows.Forms.CheckBox chbxErrorOnly;
		private System.Windows.Forms.Label lblTimeout;
		private System.Windows.Forms.NumericUpDown udTimeOut;
		private System.Windows.Forms.Label lblHours;
		private System.Windows.Forms.Label lblDomainFilter;
		private System.Windows.Forms.GroupBox gbViewSettings;
		private VI.Controls.SyntaxEdit.SyntaxEdit sedtDomainFilter;
		private System.Windows.Forms.GroupBox gbLanguage;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public frmSetup()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			_TranslateForm();
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
			ActiproSoftware.SyntaxEditor.Document document1 = new ActiproSoftware.SyntaxEditor.Document();
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmSetup));
			this.cbxLanguage = new System.Windows.Forms.ComboBox();
			this.lblLanguage = new System.Windows.Forms.Label();
			this.btnOk = new System.Windows.Forms.Button();
			this.btnCancel = new System.Windows.Forms.Button();
			this.chbxErrorOnly = new System.Windows.Forms.CheckBox();
			this.lblTimeout = new System.Windows.Forms.Label();
			this.udTimeOut = new System.Windows.Forms.NumericUpDown();
			this.lblHours = new System.Windows.Forms.Label();
			this.lblDomainFilter = new System.Windows.Forms.Label();
			this.gbViewSettings = new System.Windows.Forms.GroupBox();
			this.sedtDomainFilter = new VI.Controls.SyntaxEdit.SyntaxEdit();
			this.gbLanguage = new System.Windows.Forms.GroupBox();
			((System.ComponentModel.ISupportInitialize)(this.udTimeOut)).BeginInit();
			this.gbViewSettings.SuspendLayout();
			this.gbLanguage.SuspendLayout();
			this.SuspendLayout();
			//
			// cbxLanguage
			//
			this.cbxLanguage.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			this.cbxLanguage.Items.AddRange(new object[]
			{
				"Deutsch",
				"English"
			});
			this.cbxLanguage.Location = new System.Drawing.Point(192, 24);
			this.cbxLanguage.Name = "cbxLanguage";
			this.cbxLanguage.Size = new System.Drawing.Size(192, 21);
			this.cbxLanguage.TabIndex = 0;
			//
			// lblLanguage
			//
			this.lblLanguage.Location = new System.Drawing.Point(8, 24);
			this.lblLanguage.Name = "lblLanguage";
			this.lblLanguage.Size = new System.Drawing.Size(176, 16);
			this.lblLanguage.TabIndex = 1;
			this.lblLanguage.Text = "~Language";
			this.lblLanguage.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			//
			// btnOk
			//
			this.btnOk.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.btnOk.DialogResult = System.Windows.Forms.DialogResult.OK;
			this.btnOk.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnOk.Location = new System.Drawing.Point(222, 294);
			this.btnOk.Name = "btnOk";
			this.btnOk.Size = new System.Drawing.Size(88, 24);
			this.btnOk.TabIndex = 5;
			this.btnOk.Text = "~Ok";
			this.btnOk.Click += new System.EventHandler(this.btnOk_Click);
			//
			// btnCancel
			//
			this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnCancel.Location = new System.Drawing.Point(318, 294);
			this.btnCancel.Name = "btnCancel";
			this.btnCancel.Size = new System.Drawing.Size(88, 24);
			this.btnCancel.TabIndex = 6;
			this.btnCancel.Text = "~Cancel";
			//
			// chbxErrorOnly
			//
			this.chbxErrorOnly.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
										 | System.Windows.Forms.AnchorStyles.Right)));
			this.chbxErrorOnly.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.chbxErrorOnly.Location = new System.Drawing.Point(192, 16);
			this.chbxErrorOnly.Name = "chbxErrorOnly";
			this.chbxErrorOnly.Size = new System.Drawing.Size(192, 32);
			this.chbxErrorOnly.TabIndex = 10;
			this.chbxErrorOnly.Text = "~Error only";
			//
			// lblTimeout
			//
			this.lblTimeout.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.lblTimeout.Location = new System.Drawing.Point(8, 64);
			this.lblTimeout.Name = "lblTimeout";
			this.lblTimeout.Size = new System.Drawing.Size(176, 27);
			this.lblTimeout.TabIndex = 11;
			this.lblTimeout.Text = "~TimeOut:";
			this.lblTimeout.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			//
			// udTimeOut
			//
			this.udTimeOut.Location = new System.Drawing.Point(192, 64);
			this.udTimeOut.Maximum = new decimal(new int[]
			{
				100000,
				0,
				0,
				0
			});
			this.udTimeOut.Minimum = new decimal(new int[]
			{
				1,
				0,
				0,
				0
			});
			this.udTimeOut.Name = "udTimeOut";
			this.udTimeOut.Size = new System.Drawing.Size(56, 20);
			this.udTimeOut.TabIndex = 12;
			this.udTimeOut.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
			this.udTimeOut.Value = new decimal(new int[]
			{
				24,
				0,
				0,
				0
			});
			//
			// lblHours
			//
			this.lblHours.Location = new System.Drawing.Point(256, 68);
			this.lblHours.Name = "lblHours";
			this.lblHours.Size = new System.Drawing.Size(128, 16);
			this.lblHours.TabIndex = 13;
			this.lblHours.Text = "~Hours";
			//
			// lblDomainFilter
			//
			this.lblDomainFilter.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.lblDomainFilter.Location = new System.Drawing.Point(8, 104);
			this.lblDomainFilter.Name = "lblDomainFilter";
			this.lblDomainFilter.Size = new System.Drawing.Size(176, 32);
			this.lblDomainFilter.TabIndex = 15;
			this.lblDomainFilter.Text = "~WhereClause for Domains";
			this.lblDomainFilter.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			//
			// gbViewSettings
			//
			this.gbViewSettings.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
										  | System.Windows.Forms.AnchorStyles.Left)
										  | System.Windows.Forms.AnchorStyles.Right)));
			this.gbViewSettings.Controls.Add(this.sedtDomainFilter);
			this.gbViewSettings.Controls.Add(this.lblDomainFilter);
			this.gbViewSettings.Controls.Add(this.chbxErrorOnly);
			this.gbViewSettings.Controls.Add(this.lblTimeout);
			this.gbViewSettings.Controls.Add(this.udTimeOut);
			this.gbViewSettings.Controls.Add(this.lblHours);
			this.gbViewSettings.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
			this.gbViewSettings.Location = new System.Drawing.Point(8, 72);
			this.gbViewSettings.Name = "gbViewSettings";
			this.gbViewSettings.Size = new System.Drawing.Size(398, 214);
			this.gbViewSettings.TabIndex = 16;
			this.gbViewSettings.TabStop = false;
			this.gbViewSettings.Text = "~ViewSettings";
			//
			// sedtDomainFilter
			//
			this.sedtDomainFilter.AcceptsTab = false;
			this.sedtDomainFilter.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
											| System.Windows.Forms.AnchorStyles.Left)
											| System.Windows.Forms.AnchorStyles.Right)));
			this.sedtDomainFilter.Document = document1;
			this.sedtDomainFilter.IndicatorMarginVisible = false;
			this.sedtDomainFilter.Language = VI.Controls.SyntaxEdit.SyntaxEditLanguages.SQL;
			this.sedtDomainFilter.Location = new System.Drawing.Point(192, 104);
			this.sedtDomainFilter.Name = "sedtDomainFilter";
			this.sedtDomainFilter.SelectionMarginWidth = 1;
			this.sedtDomainFilter.Size = new System.Drawing.Size(192, 96);
			this.sedtDomainFilter.SplitType = ActiproSoftware.SyntaxEditor.SyntaxEditorSplitType.None;
			this.sedtDomainFilter.TabIndex = 16;
			this.sedtDomainFilter.UseDisabledRenderingForReadOnlyMode = true;
			//
			// gbLanguage
			//
			this.gbLanguage.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
									  | System.Windows.Forms.AnchorStyles.Right)));
			this.gbLanguage.Controls.Add(this.lblLanguage);
			this.gbLanguage.Controls.Add(this.cbxLanguage);
			this.gbLanguage.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
			this.gbLanguage.Location = new System.Drawing.Point(8, 8);
			this.gbLanguage.Name = "gbLanguage";
			this.gbLanguage.Size = new System.Drawing.Size(398, 56);
			this.gbLanguage.TabIndex = 17;
			this.gbLanguage.TabStop = false;
			this.gbLanguage.Text = "~Language";
			//
			// frmSetup
			//
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.BackColor = System.Drawing.SystemColors.Control;
			this.ClientSize = new System.Drawing.Size(416, 326);
			this.Controls.Add(this.gbLanguage);
			this.Controls.Add(this.gbViewSettings);
			this.Controls.Add(this.btnCancel);
			this.Controls.Add(this.btnOk);
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.MinimumSize = new System.Drawing.Size(424, 360);
			this.Name = "frmSetup";
			this.ShowInTaskbar = false;
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
			this.Text = "~Configure ReplicationInfo";
			this.Load += new System.EventHandler(this.frmSetup_Load);
			((System.ComponentModel.ISupportInitialize)(this.udTimeOut)).EndInit();
			this.gbViewSettings.ResumeLayout(false);
			this.gbLanguage.ResumeLayout(false);
			this.ResumeLayout(false);

		}
		#endregion

		/// <summary>
		/// Translate all language depending strings
		/// </summary>
		private void _TranslateForm()
		{
			LanguageManager L = LanguageManager.Instance;

			Text = L["frmSetup_Caption"];

			gbLanguage.Text = L["frmSetup_gbLanguage"];
			lblLanguage.Text = L["frmSetup_lblLanguage"];
			lblDomainFilter.Text = L["frmSetup_lblDomainFilter"];

			gbViewSettings.Text = L["frmSetup_gbViewSetting"];
			chbxErrorOnly.Text = L["frmSetup_chbxErrorsOnly"];
			lblTimeout.Text  = L["frmSetup_lblTimeOut"];
			lblHours.Text    = L["frmSetup_lblHours"];

			btnOk.Text       = L["frmSetup_btnOk"];
			btnCancel.Text   = L["frmSetup_btnCancel"];
		}

		/// <summary>
		/// Read all settings from Configuration class and initialize the Controls
		/// </summary>
		private void _LoadSettings()
		{
			try
			{
				// Language
				if ( cbxLanguage.Items.Contains( LanguageManager.Instance.Language ) )
					cbxLanguage.SelectedItem = LanguageManager.Instance.Language;
				else
					cbxLanguage.SelectedIndex = 0;

				sedtDomainFilter.Document.Text  = clsMain.Instance.DomainFilter;

				// Errors only
				chbxErrorOnly.Checked = clsMain.Instance.ErrorOnly;

				// timeout
				udTimeOut.Value = clsMain.Instance.TimeOut;
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this, ex );
			}
		}

		/// <summary>
		/// Write the new settings back to our Configuration class
		/// </summary>
		private void _SaveSettings()
		{
			try
			{
				// Language
				LanguageManager.Instance.Language = cbxLanguage.SelectedItem.ToString();

				// Errors only
				clsMain.Instance.ErrorOnly = chbxErrorOnly.Checked;

				// TimeOut
				clsMain.Instance.TimeOut = Convert.ToInt32(udTimeOut.Value);

				// DomainFilter
				clsMain.Instance.DomainFilter = sedtDomainFilter.Document.Text;

			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( this, ex );
			}

		}

		private void frmSetup_Load(object sender, System.EventArgs e)
		{
			_LoadSettings();
		}

		private void btnOk_Click(object sender, System.EventArgs e)
		{
			_SaveSettings();
		}


	}
}
