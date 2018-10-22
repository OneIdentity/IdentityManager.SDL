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
using VI.FormTools;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmSoftwareDriverProfileOverview
	/// </summary>

#if DEBUG
	public class FormDriverProfileOverview : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormDriverProfileOverview : VI.FormTools.BaseCustomizer
#endif
	{


		/// <summary>
		/// Defaultkonstruktor der Klasse FrmSoftwareDriverProfileOverview.
		/// </summary>
		public FormDriverProfileOverview()
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

				m_HorizFormBar3 = (VI.Controls.Interfaces.IHorizFormBar)Form.Controls["HorizFormBar3"];
				m_Label1 = (VI.Controls.Interfaces.ICaptionLabel)Form.Controls["Label1"];
				m_ListViewProfiles = (VI.Controls.Interfaces.INetListView)Form.Controls["ListViewProfiles"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];

				#endregion Component definition

				m_ListViewProfiles.ListColumns.Clear();

				ColumnHeader colheader = new ColumnHeader();
				colheader.Text = GetString("SDL_FormDriverProfileOverview_Profiles");
				colheader.Width = 240;
				m_ListViewProfiles.ListColumns.Add(colheader);

				colheader = new ColumnHeader();
				colheader.Text = GetString("SDL_FormDriverProfileOverview_SortOrder");
				colheader.Width = 100;
				m_ListViewProfiles.ListColumns.Add(colheader);

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
				m_ListViewProfiles.BackColor = ControlDesign.BackColor;
				m_ListViewProfiles.ForeColor = ControlDesign.ControlForeColor;
				m_ListViewProfiles.Font = ControlDesign.ControlFont;
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929000, ex), this);
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

			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929002, ex), this);
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
			try
			{
				// Aktivierung mit <null> verhindern
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				m_ListViewProfiles.ListItems.Clear();

				if (!FormTool.CanSee(dbobject, "UID_SDLDomainRD", "DisplayName", "OrderNumber"))
                    return;

				string uidOS = dbobject.ObjectWalker["FK(UID_Driver).UID_OS"].String;

				IColDbObject profiles = Connection.CreateCol("DriverProfile");
				profiles.Prototype.WhereClause = SqlFormatter.AndRelation(
													 SqlFormatter.UidComparison("UID_SDLDomainRD", FormTool.GetValueSafe(dbobject, "UID_SDLDomainRD", "")),
													 string.Format("uid_driver in (select uid_driver from Driver where {0})",
															 SqlFormatter.UidComparison("UID_OS", uidOS)));

				profiles.Prototype.Columns["OrderNumber"].IsDisplayItem = true;
				profiles.Prototype.Columns["DisplayName"].IsDisplayItem = true;
				profiles.Prototype.OrderBy = "OrderNumber";

				profiles.Load();
				string uidprofile = FormTool.GetValueSafe(dbobject, "UID_Profile", "");

				foreach (IColElem profile in profiles)
				{
					ListViewItem item = new ListViewItem(new string[] { profile["DisplayName"].ToString(), profile["OrderNumber"].ToString() });
					item.ForeColor = string.Equals(uidprofile, profile["UID_Profile"].ToString(), StringComparison.OrdinalIgnoreCase) ? Color.Red : Color.Black;
					item.UseItemStyleForSubItems = true;

					m_ListViewProfiles.ListItems.Add(item);
				}

				// TODO Whereklauseln setzen
			}
			finally
			{
			}
		}

		protected override void OnFormSizeChanged()
		{
			FormTool.MaximizeControl(m_ListViewProfiles);
			FormTool.MaximizeControlWidth(m_ListViewProfiles, 10);
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.ICaptionLabel m_Label1 = null;
		private VI.Controls.Interfaces.IHorizFormBar m_HorizFormBar3 = null;
		private VI.Controls.Interfaces.INetListView m_ListViewProfiles = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration

	}
}

