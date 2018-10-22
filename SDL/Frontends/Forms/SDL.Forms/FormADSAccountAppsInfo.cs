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
using VI.DB;
using VI.FormBase;
using VI.Controls;
using VI.FormTools;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmADSAccountInstallationsprotokolle
	/// </summary>

#if DEBUG
	public class FormADSAccountAppsInfo : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormADSAccountAppsInfo : VI.FormTools.BaseCustomizer
#endif
	{


		/// <summary>
		/// Defaultkonstruktor der Klasse FrmADSAccountInstallationsprotokolle.
		/// </summary>
		public FormADSAccountAppsInfo()
		{

		}


		#region Init & Done & Customization

		/// <summary>
		/// Diese Methode wird während der Initialisierung des Customizers
		/// aufgerufen und ermöglicht eine vom Customizer abhängige Initialisierung.
		/// </summary>
		protected override void OnInit()
		{
			// Basis aufrufen, um den Event zu feuern
			base.OnInit();

			try
			{
				// Zuweisung der generierten Steuerelemente und Komponenten
				// zu ihren Instanzvariablen
				#region Component definition (Do not remove or rename this region!)

				m_ActivatorCombo = (VI.Controls.Interfaces.INetComboBox)Form.Controls["ActivatorCombo"];
				m_CustomTab1 = (VI.Controls.Interfaces.ITabControl)Form.Controls["CustomTab1"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_RichTextBox1 = (VI.Controls.Interfaces.INetRichTextBox)Form.Controls["RichTextBox1"];
				m_TabPage_00 = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPage_00"];
				m_TabPage_01 = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPage_01"];
				m_TreeListProtocols = (VI.Controls.Interfaces.ITreeListControl)Form.Controls["TreeListProtocols"];

				#endregion Component definition

				m_TreeListProtocols.ShowRootLines = false;
				m_TreeListProtocols.ImageList = VI.ImageLibrary.ImagelistHandler.StockImageListSmall;
				CommonTools.SetProperty(m_TreeListProtocols, "AutoSize", true);
				CommonTools.SetProperty(m_TreeListProtocols, "MaxHeight", int.MaxValue);
				CommonTools.SetProperty(m_TreeListProtocols, "AlternateNodeBackground", true);
				CommonTools.SetProperty(m_TreeListProtocols, "ShowNodeImages", false);

				m_TreeListProtocols.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_DisplayName", 250);
				m_TreeListProtocols.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_CurrentlyActive", 70);
				m_TreeListProtocols.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_InstallDate", 150);
				m_TreeListProtocols.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_UninstallDate", 150);
				m_TreeListProtocols.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_Audit", 70);
				m_TreeListProtocols.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_OperatingSystem", 100);
				m_TreeListProtocols.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_InstallType", 100);

				// Design der Alien-Controls anpassen
				OnControlDesignChanged();
			}
			catch (Exception ex)
			{
				// Fehler melden
				throw new FormCustomizerException(874825, ex, ToString());
			}
		}

		/// <summary>
		/// Diese Methode wird von der IDisposeable.Dispose()-Methode der
		/// Basisklasse aufgerufen.
		/// </summary>
		protected override void OnDispose()
		{
			// Basis aufrufen, um den Event zu feuern
			base.OnDispose();

			try
			{
				// TODO Aufräumarbeiten
			}
			catch (Exception ex)
			{
				// Fehler melden
				throw new FormCustomizerException(874826, ex, ToString());
			}
		}

		/// <summary>
		/// Wird aufgerufen, wenn das Design der Alien-Controls angepasst werden muss.
		/// </summary>
		protected override void OnControlDesignChanged()
		{
			base.OnControlDesignChanged();

			try
			{
				m_RichTextBox1.BackColor = ControlDesign.BackColor;

				m_TreeListProtocols.BackColor = ControlDesign.BackColor;
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(new FormCustomizerException(929000, ex), this);
			}
		}

		/// <summary>
		/// Wird aufgerufen, wenn das Formular in seinen Initialzustand zurückgesetzt
		/// werden muss. Im Gegensatz zu OnInit wird diese Methode mehrmals aufgerufen.
		/// </summary>
		protected override void OnResetForm()
		{
			base.OnResetForm();

			try
			{
				// TODO Initialisierungen durchführen
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(new FormCustomizerException(929002, ex), this);
			}
		}

		#endregion


		#region WindowsFormDesigner component initialization (Do not remove or rename this region!)

		/// <summary>
		/// Dummy Methode für den FormDesigner.
		/// </summary>
		private void InitializeComponent()
		{ }

		#endregion WindowsFormDesigner component initialization


		/// <summary>
		/// Wird aufgerufen, bevor der MainActivator aktiviert wird.
		/// Hier sollten alle von einem DB-Objekt abhängige Initialisierungen
		/// durchgeführt werden.
		/// </summary>
		private void MainActivator_OnActivating(object sender, System.EventArgs e)
		{
			// Daten holen und prüfen
			ISingleDbObject dbobject = m_MainActivator.DbObject;

			if (dbobject == null) return;

			m_RichTextBox1.Text = "";

			_LoadProtocols();
			_LoadActivatorCombo();
		}

		private void _LoadProtocols()
		{
			ITreeListProxy proxy = m_TreeListProtocols.Proxy;

			using (new UpdateHelper(m_TreeListProtocols))
			{
				proxy.Clear();

				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				IColDbObject col = Connection.CreateCol("ADSAccountAppsInfo");
				col.Prototype["displayname"].IsDisplayItem = true;
				col.Prototype["CurrentlyActive"].IsDisplayItem = true;
				col.Prototype["Installdate"].IsDisplayItem = true;
				col.Prototype["deinstalldate"].IsDisplayItem = true;
				col.Prototype["revision"].IsDisplayItem = true;
				col.Prototype["UID_OS"].IsDisplayItem = true;
				col.Prototype["UID_InstallationType"].IsDisplayItem = true;

				col.Prototype.WhereClause = !FormTool.CanSee(dbobject, "UID_ADSAccount") ? "1=2" :
											SqlFormatter.UidComparison("UID_ADSAccount", FormTool.GetValueSafe(dbobject, "UID_ADSAccount", ""));
				col.Prototype.OrderBy = "displayname";
				col.Load(CollectionLoadType.ForeignDisplays);

				foreach (IColElem elem in col)
				{
					ITreeListNode node = proxy.AddNode(elem.GetDisplayValue("displayname"), (int)VI.ImageLibrary.StockImage.ApplicationProfile);
					ITreeListItemSmall item = proxy.CreateCheckBoxItem(elem.GetValue("CurrentlyActive").Bool);
					item.Enabled = false;
					proxy.AddItem(node, item);
					proxy.AddItem(node, elem["Installdate"]);
					proxy.AddItem(node, elem["deinstalldate"]);
					proxy.AddItem(node, elem["Revision"]);
					proxy.AddItem(node, elem.GetDisplayValue("UID_OS"));
					proxy.AddItem(node, elem.GetDisplayValue("UID_InstallationType"));
				}
			}
		}

		private void _LoadActivatorCombo()
		{
			using (new UpdateHelper(m_ActivatorCombo))
			{
				m_ActivatorCombo.ComboItems.Clear();

				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				// das hat nur Sinn, wenn ich die UID_ADSAccount lesen darf
				if (FormTool.CanSee(dbobject, "UID_ADSAccount"))
				{
					IColDbObject col = Connection.CreateCol("ClientLog");
					col.Prototype.WhereClause = SqlFormatter.UidComparison("UID_ADSAccount", dbobject["UID_ADSAccount"].New.String);
					col.Prototype.OrderBy = "InstallDate DESC";

					col.Load();

					foreach (IColElem elem in col)
					{
						m_ActivatorCombo.ComboItems.Add(elem);
					}
				}
			}
		}


		protected override void OnFormLoad()
		{
			m_TabPage_00.Caption = "SDL_FormADSAccountAppsInfo_TabPage_Applications";
			m_TabPage_01.Caption = "SDL_FormADSAccountAppsInfo_TabPage_PCclient";

			m_ActivatorCombo.ComboItems.Clear();
			m_RichTextBox1.Font = new Font("Courier New", 9.0F);
		}

		protected override void OnFormSizeChanged()
		{
			FormTool.MaximizeControl(m_TreeListProtocols);
			FormTool.MaximizeControl(m_RichTextBox1);
			FormTool.MaximizeControlWidth(m_TreeListProtocols, 10);
			FormTool.MaximizeControlWidth(m_RichTextBox1, 10);
		}


		/// <summary>
		///
		/// </summary>
		private void ActivatorCombo_OnSelectionChangeCommitted(object sender, System.EventArgs e)
		{
			try
			{
				if (m_ActivatorCombo.SelectedItem == null) return;

				ISingleDbObject dbobject = (m_ActivatorCombo.SelectedItem as IColElem).Create();

				m_RichTextBox1.Text = FormTool.GetValueSafe(dbobject, "LogContent", "");
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(ex, this, 100);
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.INetComboBox m_ActivatorCombo = null;
		private VI.Controls.Interfaces.INetRichTextBox m_RichTextBox1 = null;
		private VI.Controls.Interfaces.ITabControl m_CustomTab1 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage_00 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage_01 = null;
		private VI.Controls.Interfaces.ITreeListControl m_TreeListProtocols = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration

	}
}

