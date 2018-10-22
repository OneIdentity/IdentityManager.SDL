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
using System.Windows.Forms;

using VI.DB;
using VI.Base;
using VI.FormBase;
using VI.Controls;
using VI.FormBase.Collections;
using VI.FormTools;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmHardwareComputerInstallprotokolle
	/// </summary>

#if DEBUG
	public class FormHardwarePCClientlog : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormHardwarePCClientlog : VI.FormTools.BaseCustomizer
#endif
	{

		private int m_LastFindPos = -1;
		private string m_SearchPattern = "";
		private bool m_IgnoreCase = true;


		/// <summary>
		/// Defaultkonstruktor der Klasse FrmHardwareComputerInstallprotokolle.
		/// </summary>
		public FormHardwarePCClientlog()
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
				m_TabPage_02 = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPage_02"];
				m_TreeListApps = (VI.Controls.Interfaces.ITreeListControl)Form.Controls["TreeListApps"];
				m_TreeListDrivers = (VI.Controls.Interfaces.ITreeListControl)Form.Controls["TreeListDrivers"];

				#endregion Component definition

				m_TreeListApps.ShowRootLines = false;
				m_TreeListApps.ImageList = VI.ImageLibrary.ImagelistHandler.StockImageListSmall;
				CommonTools.SetProperty(m_TreeListApps, "AutoSize", true);
				CommonTools.SetProperty(m_TreeListApps, "MaxHeight", int.MaxValue);
				CommonTools.SetProperty(m_TreeListApps, "AlternateNodeBackground", true);
				CommonTools.SetProperty(m_TreeListApps, "ShowNodeImages", false);

				m_TreeListApps.Proxy.ColumnsSortable = true;

				ITreeListColumn col = m_TreeListApps.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_DisplayName", 250);
				col.Comparer = StringComparer.OrdinalIgnoreCase;
				col = m_TreeListApps.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_CurrentlyActive", 70);
				col.Comparer = StringComparer.OrdinalIgnoreCase;
				col = m_TreeListApps.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_InstallDate", 150);
				col.Comparer = new ComparableComparer();
				col = m_TreeListApps.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_UninstallDate", 150);
				col.Comparer = new ComparableComparer();
				col = m_TreeListApps.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_Audit", 70);
				col.Comparer = new ComparableComparer();
				col = m_TreeListApps.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_OperatingSystem", 100);
				col.Comparer = StringComparer.OrdinalIgnoreCase;
				col = m_TreeListApps.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_InstallType", 100);
				col.Comparer = StringComparer.OrdinalIgnoreCase;


				m_TreeListDrivers.ShowRootLines = false;
				m_TreeListDrivers.ImageList = VI.ImageLibrary.ImagelistHandler.StockImageListSmall;
				CommonTools.SetProperty(m_TreeListDrivers, "AutoSize", true);
				CommonTools.SetProperty(m_TreeListDrivers, "MaxHeight", int.MaxValue);
				CommonTools.SetProperty(m_TreeListDrivers, "AlternateNodeBackground", true);
				CommonTools.SetProperty(m_TreeListDrivers, "ShowNodeImages", false);

				m_TreeListDrivers.Proxy.ColumnsSortable = true;

				col = m_TreeListDrivers.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_DisplayName", 250);
				col.Comparer = StringComparer.OrdinalIgnoreCase;
				col = m_TreeListDrivers.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_CurrentlyActive", 70);
				col.Comparer = new ComparableComparer();
				col = m_TreeListDrivers.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_InstallDate", 150);
				col.Comparer = new ComparableComparer();
				col = m_TreeListDrivers.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_UninstallDate", 150);
				col.Comparer = new ComparableComparer();
				col = m_TreeListDrivers.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_Audit", 70);
				col.Comparer = new ComparableComparer();
				col = m_TreeListDrivers.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_OperatingSystem", 100);
				col.Comparer = StringComparer.OrdinalIgnoreCase;
				col = m_TreeListDrivers.Proxy.AddColumn("SDL_FormADSAccountAppsInfo_InstallType", 100);
				col.Comparer = StringComparer.OrdinalIgnoreCase;

				// Design der Alien-Controls anpassen
				OnControlDesignChanged();

				if (m_RichTextBox1 is RichTextBox)
				{
					(m_RichTextBox1 as RichTextBox).KeyDown += new KeyEventHandler(RichTextBox_KeyDown);
				}

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
				m_TreeListApps.BackColor = ControlDesign.BackColor;
				m_TreeListDrivers.BackColor = ControlDesign.BackColor;

				m_RichTextBox1.BackColor = ControlDesign.BackColor;
				m_RichTextBox1.ForeColor = ControlDesign.ControlForeColor;
				m_RichTextBox1.Font = ControlDesign.ControlFont;
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929000, ex), this);
			}
		}

		#endregion


		#region WindowsFormDesigner component initialization (Do not remove or rename this region!)

		/// <summary>
		/// Dummy method for FormDesigner.
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
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				_Load(m_TreeListApps, true);
				_Load(m_TreeListDrivers, false);
				_LoadActivatorCombo();
			}
			finally
			{
				m_RichTextBox1.Text = "";
				m_LastFindPos = -1;
				m_SearchPattern = "";
				m_IgnoreCase = true;
			}
		}


		private void _Load(VI.Controls.Interfaces.ITreeListControl treeList, bool loadApps)
		{
			ITreeListProxy proxy = treeList.Proxy;

			using (new UpdateHelper(treeList))
			{
				proxy.Clear();

				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				IColDbObject col = Connection.CreateCol("MachineAppsInfo");
				col.Prototype["displayname"].IsDisplayItem = true;
				col.Prototype["CurrentlyActive"].IsDisplayItem = true;
				col.Prototype["Installdate"].IsDisplayItem = true;
				col.Prototype["deinstalldate"].IsDisplayItem = true;
				col.Prototype["revision"].IsDisplayItem = true;
				col.Prototype["UID_OS"].IsDisplayItem = true;
				col.Prototype["UID_InstallationType"].IsDisplayItem = true;

				col.Prototype.WhereClause = SqlFormatter.AndRelation(!FormTool.CanSee(dbobject, "UID_HardWare") ? "1=2" :
											SqlFormatter.UidComparison("UID_Hardware", dbobject["UID_HardWare"].New.String),
											SqlFormatter.Comparison("AppsNotDriver", loadApps, ValType.Bool));
				col.Prototype.OrderBy = "Displayname, Installdate, DeInstallDate";
				col.Load(CollectionLoadType.ForeignDisplays);

				foreach (IColElem elem in col)
				{
					ITreeListNode node = proxy.AddNode(elem.GetDisplayValue("displayname"), (int)VI.ImageLibrary.StockImage.ApplicationProfile);
					ITreeListItemSmall item = proxy.CreateCheckBoxItem(elem.GetValue("CurrentlyActive").Bool);
					item.Enabled = false;
					proxy.AddItem(node, item);

					DateTime date = elem.GetValue("Installdate").Date;
					item = proxy.AddItem(node, DbVal.IsEmpty(date, ValType.Date) ? "" : date.ToString());
					item.Data = date;

					date = elem.GetValue("deinstalldate").Date;
					item = proxy.AddItem(node, DbVal.IsEmpty(date, ValType.Date) ? "" : date.ToString());
					item.Data = date;

					item = proxy.AddItem(node, elem["Revision"]);
					item.Data = elem.GetValue("Revision").Int;

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

				IColDbObject col = Connection.CreateCol("ClientLog");
				col.Prototype.WhereClause = SqlFormatter.UidComparison("UID_Hardware", dbobject["UID_HardWare"].New.String);
				col.Prototype.OrderBy = "InstallDate DESC";

				col.Load();

				foreach (IColElem elem in col)
				{
					m_ActivatorCombo.ComboItems.Add(elem);
				}
			}
		}

		protected override void OnFormLoad()
		{
			try
			{
				m_TabPage_00.Caption = "SDL_FormHardwarePCClientlog_TabPage_Applications";
				m_TabPage_01.Caption = "SDL_FormHardwarePCClientlog_TabPage_Driver";
				m_TabPage_02.Caption = "SDL_FormHardwarePCClientlog_TabPage_PCclient";

				m_ActivatorCombo.ComboItems.Clear();
				m_RichTextBox1.Text = "";
				m_RichTextBox1.Font = new Font("Courier New", 9.0F);

				m_LastFindPos = -1;
				m_SearchPattern = "";
				m_IgnoreCase = true;
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}

		protected override void OnFormSizeChanged()
		{
			FormTool.MaximizeControl(m_RichTextBox1);
			FormTool.MaximizeControl(m_TreeListDrivers);
			FormTool.MaximizeControl(m_TreeListApps);
			FormTool.MaximizeControlWidth(m_RichTextBox1, 10);
			FormTool.MaximizeControlWidth(m_TreeListDrivers, 10);
			FormTool.MaximizeControlWidth(m_TreeListApps, 10);
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

				m_LastFindPos = -1;
				m_SearchPattern = "";
				m_IgnoreCase = true;

			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(ex, this, 100);
			}
		}

		private void RichTextBox_KeyDown(object sender, KeyEventArgs e)
		{
			try
			{
				if (e.KeyCode == Keys.F && e.Modifiers == Keys.Control)
				{
					using (VI.Controls.Forms.SearchForm sf = new VI.Controls.Forms.SearchForm())
					{
						if (sf.ShowDialog(FormTool.MainForm) != DialogResult.OK)
							return;

						m_SearchPattern = sf.SearchPattern;
						m_IgnoreCase = sf.IgnoreCase;
						m_LastFindPos = (m_RichTextBox1 as RichTextBox).Find(m_SearchPattern, m_IgnoreCase ? RichTextBoxFinds.None : RichTextBoxFinds.MatchCase);

						if (m_LastFindPos >= 0)
							(m_RichTextBox1 as RichTextBox).Select(m_LastFindPos, m_SearchPattern.Length);
					}
				}
				else if (e.KeyCode == Keys.F3 && m_LastFindPos >= 0 && m_SearchPattern.Length > 0)
				{
					bool reverse = e.Modifiers == Keys.Shift;
					RichTextBoxFinds flags = (m_IgnoreCase ? RichTextBoxFinds.None : RichTextBoxFinds.MatchCase) | (reverse ? RichTextBoxFinds.Reverse : RichTextBoxFinds.None);
					int pos = (m_RichTextBox1 as RichTextBox).Find(m_SearchPattern, m_LastFindPos + 1, flags);

					if (pos >= 0)
					{
						m_LastFindPos = pos;
						(m_RichTextBox1 as RichTextBox).Select(m_LastFindPos, m_SearchPattern.Length);
					}
				}
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(ex, this, 100);
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.INetComboBox m_ActivatorCombo = null;
		private VI.Controls.Interfaces.INetRichTextBox m_RichTextBox1 = null;
		private VI.Controls.Interfaces.ITabControl m_CustomTab1 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage_00 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage_01 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage_02 = null;
		private VI.Controls.Interfaces.ITreeListControl m_TreeListApps = null;
		private VI.Controls.Interfaces.ITreeListControl m_TreeListDrivers = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration


	}
}

