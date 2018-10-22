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
using System.IO;
using System.Windows.Forms;

using VI.DB;
using VI.Base;
using VI.FormTools;
using VI.FormBase.Tasks;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmSoftwareAppProfileStammdaten
	/// </summary>

#if DEBUG
	public class FormApplicationProfileMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormApplicationProfileMasterData : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmSoftwareAppProfileStammdaten.
		/// </summary>
		public FormApplicationProfileMasterData()
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

				m_CheckBoxRemoveHKeyCurrentUser    = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxRemoveHKeyCurrentUser"];
				m_cmdOrderNumber                   = (VI.Controls.Interfaces.IButton) Form.Controls["cmdOrderNumber"];
				m_Command1                         = (VI.Controls.Interfaces.IDateButton) Form.Controls["Command1"];
				m_Command2                         = (VI.Controls.Interfaces.IDateButton) Form.Controls["Command2"];
				m_CustomTab1                       = (VI.Controls.Interfaces.ITabControl) Form.Controls["CustomTab1"];
				m_EditChgCL                        = (VI.Controls.Interfaces.IEdit) Form.Controls["EditChgCL"];
				m_EditChgNumber                    = (VI.Controls.Interfaces.IEdit) Form.Controls["EditChgNumber"];
				m_EditChgTest                      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditChgTest"];
				m_EditDefDriveTarget               = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDefDriveTarget"];
				m_EditDescription                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDescription"];
				m_EditDisplayName                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDisplayName"];
				m_EditHashValueFDS                 = (VI.Controls.Interfaces.IEdit) Form.Controls["EditHashValueFDS"];
				m_EditHashValueTAS                 = (VI.Controls.Interfaces.IEdit) Form.Controls["EditHashValueTAS"];
				m_EditMemoryUsage                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditMemoryUsage"];
				m_EditOrderNumber                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditOrderNumber"];
				m_EditPackagePath                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditPackagePath"];
				m_EditProfileCreator               = (VI.Controls.Interfaces.IEdit) Form.Controls["EditProfileCreator"];
				m_EditProfileDate                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditProfileDate"];
				m_EditProfileModDate               = (VI.Controls.Interfaces.IEdit) Form.Controls["EditProfileModDate"];
				m_EditProfileModifier              = (VI.Controls.Interfaces.IEdit) Form.Controls["EditProfileModifier"];
				m_EditServerDrive                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditServerDrive"];
				m_EditSubPath                      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditSubPath"];
				m_MainActivator                    = (VI.Controls.ActivatorComponent) Form.Components["MainActivator"];
				m_MainPanel                        = (VI.Controls.Interfaces.IVIPanel) Form.Controls["MainPanel"];
				m_TabPage_00                       = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPage_00"];
				m_TabPage_01                       = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPage_01"];
				m_TextComboBoxCachingBehavior      = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCachingBehavior"];
				m_TextComboBoxOSMode               = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxOSMode"];
				m_TextComboBoxProfileType          = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxProfileType"];
				m_TreeComboBoxUIDApplication       = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDApplication"];
				m_TreeComboBoxUIDInstallationType  = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDInstallationType"];
				m_TreeComboBoxUIDOS                = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDOS"];
				m_TreeComboBoxUIDSDLDomainRD       = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDSDLDomainRD"];
				m_TreeComboBoxUIDSDLDomainRDOwner  = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDSDLDomainRDOwner"];

				#endregion Component definition

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
				// Aufräumarbeiten
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
				m_EditDescription.Focus();
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929002, ex), this);
			}
		}

		#endregion

		protected override void OnFormLoad()
		{

			m_TabPage_00.Caption = "SDL_FormCommon_General";
			m_TabPage_01.Caption = "SDL_FormApplicationProfileMasterData_TabPage_Supportstaff";

			m_CheckBoxRemoveHKeyCurrentUser.EnabledByUser = false;

			using (new VI.FormBase.UpdateHelper(Tasks))
			{
				Task task = Tasks["EnableSubPath"];
				task.Caption = "SDL_FormApplicationProfileMasterData_Task_EnableSubPath";
				task.Enabled = true;
				task.Visible = false;
				task.StockImage = VI.ImageLibrary.StockImage.Edit;
				task.TaskMethod = FormTask_EnableSubPath;

				task = Tasks["ProfileEdit"];
				task.Caption = "SDL_FormApplicationProfileMasterData_Task_EditApplicationProfile";
				task.Enabled = true;
				task.Visible = AppData.Instance.AppType == AppType.Gui;
				task.StockImage = VI.ImageLibrary.StockImage.Edit;
				task.TaskMethod = FormMethod_ProfileEdit;

				task = Tasks["SyncProfile"];
				task.Caption = "SDL_FormApplicationProfileMasterData_Task_SynchronizeApplicationProfile";
				task.Enabled = true;
				task.Visible = true;
				task.TaskMethod = FormMethod_SyncProfile;
			}
		}


		/// <summary>
		/// FormMethode ProfileEdit
		/// </summary>
		public void FormMethod_ProfileEdit()
		{
			try
			{
				ISingleDbObject dom = null;
				ISingleDbObject app = null;

				// Daten holen und prüfen
				ISingleDbObject profile = m_MainActivator.DbObject;

				if (profile == null)
                    return;

				if (profile["UID_SDLDomainRD"].New.String.Length > 0)
				{
					dom = profile.GetFK("UID_SDLDomainRD").Create();

					if (dom != null)
						app = profile.GetFK("UID_Application").Create();
				}

				string strReturn;

				if (ProfileTool.GetProfilePathOnTas(profile, out strReturn))
				{
					m_MProfilePathOnTAS = strReturn;
					ProfileTool.ReadFileFromProfile(Path.Combine(m_MProfilePathOnTAS, "profile.vii"), out strReturn);
				}
				else
				{
					FormTool.ShowError(strReturn);
					return;
				}

				if (profile.IsChanged) { profile.Save(); profile.Load(); }

				if (ProfileTool.StarteProfileEditor(profile, dom, app))
				{
					// liefert true, wenn sich die profile.vii geändert hat
					// profile edit schreibt profile.vii - damit ist sync möglich
					if (ProfileTool.SyncWithProfileVii(profile, Path.Combine(m_MProfilePathOnTAS, "profile.vii")))
					{
						// unbedingt speichern, da sonst die JobKette auf einem alten Profilstand generiert wird.
						if (profile.IsChanged) { profile.Save(); profile.Load(); }

						profile.Custom.CallMethod("WriteVIIFiles");

						// Profile neu laden, da von WriteVIIFiles (Jobkette) geändert
						//DbObjectKey key = new DbObjectKey(profile);
						//profile.Clear();
						//key.FillObject(profile);
						//profile.Load();

						// das muss sein, da FillObject beim Setzen des PKs ein COlumnChanged auslöst, bei allen anderen
						// Spalten nicht, deshalb stimmt die Sheet Bestimmung nicht mehr und das Form heist AppProfile-Objekt ohne Anzeigename.
						Document.Reload();
					}
				}

			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(
					new FormCustomizerException(929001, ex, GetString("SDL_FormApplicationProfileMasterData_Task_EditApplicationProfile").Replace("&", "")), this);
			}
		}

		/// <summary>
		/// FormMethode SyncProfile
		/// </summary>
		public void FormMethod_SyncProfile()
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject profile = m_MainActivator.DbObject;

				if (profile == null) return;

				bool SyncProfilesPossible;

              
                string strReturn;

				if (ProfileTool.GetProfilePathOnTas(profile, out strReturn))
				{
					m_MProfilePathOnTAS = strReturn;

					if (ProfileTool.ReadFileFromProfile(Path.Combine(m_MProfilePathOnTAS, "profile.vii"), out strReturn))
					{
						SyncProfilesPossible = true;
					}
					else
					{
						FormTool.ShowError("VIP7_SyncAppProfile_ErrNoProfileVII");
						return;
					}
				}
				else
				{
					FormTool.ShowError(strReturn);
					return;
				}

				if (profile.IsChanged) { profile.Save(); profile.Load(); }

				//if (SyncProfilesPossible)
					ProfileTool.SyncWithProfileVii(profile, Path.Combine(m_MProfilePathOnTAS, "profile.vii"));

				if (profile.IsChanged) { profile.Save(); profile.Load(); }

				if (FormTool.MainForm != null)
					FormTool.MainForm.BringToFront();
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(
					new FormCustomizerException(929001, ex, GetString("SDL_FormApplicationProfileMasterData_Task_SynchronizeApplicationProfile").Replace("&", "")), this);
			}
		}


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

				m_TreeComboBoxUIDApplication.WhereClause = SqlFormatter.Comparison("IsProfileApplication", true, ValType.Bool);
			}
			finally
			{
			}
		}

		/// <summary>
		/// Wird aufgerufen, bevor das Objekt gespeichert wird.
		/// </summary>
		private void MainActivator_OnSaving(object sender, System.EventArgs e)
		{
			try
			{
				if (m_EditServerDrive.Text.Trim() == "")
					m_EditPackagePath.Text = "";
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
		private void CmdOrderNumber_OnClick(object sender, System.EventArgs e)
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null || !FormTool.CanSee(dbobject, "UID_SDLDomainRD", "UID_Profile", "OrderNumber", "UID_OS")) return;

				using (SortOrderPackDialog dlg = new SortOrderPackDialog(Connection, ProfileType.Application))
				{
					dlg.UidSDLDomainRD = dbobject["UID_SDLDomainRD"].New.String;
					dlg.UidProfile = dbobject["UID_Profile"].New.String;
					dlg.OrderNumber = dbobject["OrderNumber"].New.Double;
					dlg.UidOs = dbobject["UID_OS"].New.String;

					if (dlg.ShowDialog() != DialogResult.OK) return;

					FormTool.SetValueSafe(dbobject, "OrderNumber", dlg.OrderNumber);
				}
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		/// <summary>
		/// FormMethode EnableSubPath
		/// </summary>
		public void FormTask_EnableSubPath()
		{
			try
			{
				if (FormTool.ShowQuestion("SDL_FormApplicationProfileMasterData_Question_EnableSubPath", MessageBoxButtons.YesNo) != DialogResult.Yes)
					return;

				m_EditSubPath.EnabledByUser = true;
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(
					new FormCustomizerException(929001, ex, GetString("SDL_FormApplicationProfileMasterData_Task_EnableSubPath").Replace("&", "")), this);
			}
		}


		/// <summary>
		///
		/// </summary>
		private void MainActivator_OnActivated(object sender, System.EventArgs e)
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				if (FormTool.CanSee(dbobject, "ChgNumber", "ChgTest") && dbobject["ChgNumber"].New.Int == 0 && dbobject["ChgTest"].New.Int == 0)
				{
					m_EditChgTest.EnabledByUser = true;
					m_EditSubPath.EnabledByUser = true;
					Tasks["EnableSubPath"].Visible = false;
				}
				else
				{
					m_EditChgTest.EnabledByUser = false;
					m_EditSubPath.EnabledByUser = false;
					Tasks["EnableSubPath"].Visible = true;
				}

                m_EditPackagePath.Caption = "SDL_FormApplicationProfileMasterData_PackagePath";

				m_CheckBoxRemoveHKeyCurrentUser.EnabledByUser = !dbobject.IsLoaded;
				m_TextComboBoxCachingBehavior.EnabledByUser = !dbobject.IsLoaded;
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
		private void MainActivator_OnSaved(object sender, System.EventArgs e)
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				m_TextComboBoxCachingBehavior.EnabledByUser = m_CheckBoxRemoveHKeyCurrentUser.EnabledByUser = false;
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
		private void EditServerDrive_OnTextChanged(object sender, System.EventArgs e)
		{
			try
			{
				m_EditPackagePath.VisibleByUser = m_EditServerDrive.Text.Trim() != "";
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		private string m_MProfilePathOnTAS = "";

		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent   m_MainActivator = null;
		private VI.Controls.Interfaces.IButton   m_cmdOrderNumber = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxRemoveHKeyCurrentUser = null;
		private VI.Controls.Interfaces.IDateButton m_Command1 = null;
		private VI.Controls.Interfaces.IDateButton m_Command2 = null;
		private VI.Controls.Interfaces.IEdit     m_EditChgCL = null;
		private VI.Controls.Interfaces.IEdit     m_EditChgNumber = null;
		private VI.Controls.Interfaces.IEdit     m_EditChgTest = null;
		private VI.Controls.Interfaces.IEdit     m_EditDefDriveTarget = null;
		private VI.Controls.Interfaces.IEdit     m_EditDescription = null;
		private VI.Controls.Interfaces.IEdit     m_EditDisplayName = null;
		private VI.Controls.Interfaces.IEdit     m_EditHashValueFDS = null;
		private VI.Controls.Interfaces.IEdit     m_EditHashValueTAS = null;
		private VI.Controls.Interfaces.IEdit     m_EditMemoryUsage = null;
		private VI.Controls.Interfaces.IEdit     m_EditOrderNumber = null;
		private VI.Controls.Interfaces.IEdit     m_EditPackagePath = null;
		private VI.Controls.Interfaces.IEdit     m_EditProfileCreator = null;
		private VI.Controls.Interfaces.IEdit     m_EditProfileDate = null;
		private VI.Controls.Interfaces.IEdit     m_EditProfileModDate = null;
		private VI.Controls.Interfaces.IEdit     m_EditProfileModifier = null;
		private VI.Controls.Interfaces.IEdit     m_EditServerDrive = null;
		private VI.Controls.Interfaces.IEdit     m_EditSubPath = null;
		private VI.Controls.Interfaces.ITabControl m_CustomTab1 = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPage_00 = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPage_01 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCachingBehavior = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxOSMode = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxProfileType = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDApplication = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDInstallationType = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDOS = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDSDLDomainRD = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDSDLDomainRDOwner = null;
		private VI.Controls.Interfaces.IVIPanel  m_MainPanel = null;

		#endregion Component declaration

	}
}