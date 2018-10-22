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



// ReSharper disable RedundantNameQualifier
// ReSharper disable RedundantDefaultMemberInitializer
// ReSharper disable NotAccessedField.Local
// ReSharper disable UnusedMember.Local
// ReSharper disable UnusedParameter.Local
// ReSharper disable EmptyConstructor								


using System;
using VI.DB;
using VI.Base;
using VI.FormBase;
using VI.FormTools;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmKonfigApplikationsserverStammdaten
	/// </summary>

#if DEBUG
	public class FormApplicationServerMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormApplicationServerMasterData : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmKonfigApplikationsserverStammdaten.
		/// </summary>
		public FormApplicationServerMasterData()
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

				m_CheckBoxIsCentralLibrary         = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxIsCentralLibrary"];
				m_CheckboxUseAllwaysLimit          = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckboxUseAllwaysLimit"];
				m_CheckboxUseShadowFolder          = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckboxUseShadowFolder"];
				m_EditFullPath                     = (VI.Controls.Interfaces.IEdit) Form.Controls["EditFullPath"];
				m_EditIdentApplicationServer       = (VI.Controls.Interfaces.IEdit) Form.Controls["EditIdentApplicationServer"];
				m_EditOnLineLimit                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditOnLineLimit"];
				m_HorizFormBar                     = (VI.Controls.Interfaces.IHorizFormBar) Form.Controls["HorizFormBar"];
				m_MainActivator                    = (VI.Controls.ActivatorComponent) Form.Components["MainActivator"];
				m_MainPanel                        = (VI.Controls.Interfaces.IVIPanel) Form.Controls["MainPanel"];
				m_TreeComboBoxUIDApplicationServerRedirect = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDApplicationServerRedirect"];
				m_TreeComboBoxUIDParentApplicationServer = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDParentApplicationServer"];
				m_TreeComboBoxUIDSDLDomain         = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDSDLDomain"];
				m_TreeComboBoxUIDServer            = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDServer"];

				#endregion Component definition

				// Design der Alien-Controls anpassen
				OnControlDesignChanged();
			}
			catch (Exception ex)
			{
				// Fehler melden
				throw new VI.FormCustomizers.FormCustomizerException(874825, ex, ToString());
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
				// Aufräumarbeiten
			}
			catch (Exception ex)
			{
				// Fehler melden
				throw new VI.FormCustomizers.FormCustomizerException(874826, ex, ToString());
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
				// Design den Alien-Controls zuweisen
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(new VI.FormCustomizers.FormCustomizerException(929000, ex), this);
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
				m_EditIdentApplicationServer.Focus();
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(new VI.FormCustomizers.FormCustomizerException(929002, ex), this);
			}
		}

		#endregion


		#region WindowsFormDesigner component initialization (Do not remove or rename this region!)

		/// <summary>
		/// Dummy Methode für den FormDesigner.
		/// </summary>
		private void InitializeComponent()
		{}

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
				if (m_MainActivator.DbObject == null) return;

				// Whereklauseln setzen
			}
			finally
			{
			}
		}

		protected override void OnFormLoad()
		{
			m_HorizFormBar.Caption = "SDL_FormCommon_MasterData";
			m_TreeComboBoxUIDParentApplicationServer.RootNodeCaption = "SDL_FormApplicationServerMasterData_ApplicationServer";
		}


		/// <summary>
		///
		/// </summary>
		private void MainActivator_OnActivated(object sender, System.EventArgs e)
		{
			try
			{
				m_BInitialised = true;

				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject != null)
				{
					var SDLDomaiDef = FormTool.GetValueSafe(dbobject, "UID_SDLDomain", "") != "";

					m_TreeComboBoxUIDSDLDomain.EnabledByUser = !SDLDomaiDef;

					if (SDLDomaiDef)
					{
						m_TreeComboBoxUIDParentApplicationServer.WhereClause = !FormTool.CanSee(dbobject, "UID_ApplicationServer") ? "1=2" :
						    // ReSharper disable once UseStringInterpolation
						    string.Format("{0} and not {1}",
						        SqlFormatter.UidComparison("UID_SDLDomain", dbobject["UID_SDLDomain"].New.String),
						        SqlFormatter.InClause("UID_ApplicationServer", ValType.String, FormTool.GetChildUuids(Connection,
						            "Applicationserver", "UID_Applicationserver",
						            dbobject["UID_ApplicationServer"].New.String, "UID_ParentApplicationserver")));
					}
					else m_TreeComboBoxUIDParentApplicationServer.WhereClause = SqlFormatter.EmptyClause("UID_SDLDomain", ValType.String);

				}


				if (m_EditIdentApplicationServer.Enabled && m_EditIdentApplicationServer.Visible) m_EditIdentApplicationServer.Select();
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		/// <summary>
		///
		/// </summary>
		private void TreeComboBox3_OnSelectionChangeCommitted(object sender, System.EventArgs e)
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null || !m_BInitialised || FormTool.GetValueSafe(dbobject, "UID_SDLDomain", "") == "")
                    return;

				// das reicht völlig aus
				dbobject.GetFK("UID_ParentApplicationServer").SetParent(null);

			    m_TreeComboBoxUIDParentApplicationServer.WhereClause =
			        !FormTool.CanSee(dbobject, "UID_ApplicationServer", "UID_SDLDomain")
			            ? "1=2"
			            :
			            // ReSharper disable once UseStringInterpolation
			            string.Format("{0} and not {1}",
			                SqlFormatter.UidComparison("UID_SDLDomain", dbobject["UID_SDLDomain"].New.String),
			                SqlFormatter.InClause("UID_Applicationserver", ValType.String, FormTool.GetChildUuids(Connection,
			                    "Applicationserver", "UID_Applicationserver",
			                    dbobject["UID_ApplicationServer"].New.String, "UID_ParentApplicationserver")));
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		private bool m_BInitialised = false;

		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent   m_MainActivator = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsCentralLibrary = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckboxUseAllwaysLimit = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckboxUseShadowFolder = null;
		private VI.Controls.Interfaces.IEdit     m_EditFullPath = null;
		private VI.Controls.Interfaces.IEdit     m_EditIdentApplicationServer = null;
		private VI.Controls.Interfaces.IEdit     m_EditOnLineLimit = null;
		private VI.Controls.Interfaces.IHorizFormBar m_HorizFormBar = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDApplicationServerRedirect = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDParentApplicationServer = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDSDLDomain = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDServer = null;
		private VI.Controls.Interfaces.IVIPanel  m_MainPanel = null;

		#endregion Component declaration

	}
}


