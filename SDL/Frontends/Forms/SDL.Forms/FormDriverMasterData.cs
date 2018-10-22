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
using VI.DB.Entities;
using VI.DB.Sync;
using VI.FormTools;
using VI.FormBase;
using VI.FormBase.Tasks;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmSoftwareTreiberStammdaten
	/// </summary>

#if DEBUG
	public class FormDriverMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormDriverMasterData : VI.FormTools.BaseCustomizer
#endif
	{
		#region Init & Done

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

				m_ButtonDateFirstInstall2          = (VI.Controls.Interfaces.IDateButton) Form.Controls["ButtonDateFirstInstall2"];
				m_CheckBoxIsForITShop              = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxIsForITShop"];
				m_CheckBoxIsInActive               = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxIsInActive"];
				m_CheckBoxIsITShopOnly             = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxIsITShopOnly"];
				m_CheckBoxIsProfileApplication     = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxIsProfileApplication"];
				m_CustomTab1                       = (VI.Controls.Interfaces.ITabControl) Form.Controls["CustomTab1"];
				m_EditDateFirstInstall             = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDateFirstInstall"];
				m_EditDateStatusIndicatorChanged   = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDateStatusIndicatorChanged"];
				m_EditDescription                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDescription"];
				m_EditDocumentationURL             = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDocumentationURL"];
				m_EditDriverURL                    = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDriverURL"];
				m_EditIdentDriver                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditIdentDriver"];
				m_EditInternalProductName          = (VI.Controls.Interfaces.IEdit) Form.Controls["EditInternalProductName"];
				m_EditLicenceClerk                 = (VI.Controls.Interfaces.IEdit) Form.Controls["EditLicenceClerk"];
				m_EditLicencePrice                 = (VI.Controls.Interfaces.IEdit) Form.Controls["EditLicencePrice"];
				m_EditLicenceState                 = (VI.Controls.Interfaces.IEdit) Form.Controls["EditLicenceState"];
				m_EditSomeComments                 = (VI.Controls.Interfaces.IEdit) Form.Controls["EditSomeComments"];
				m_EditSortOrderForProfile          = (VI.Controls.Interfaces.IEdit) Form.Controls["EditSortOrderForProfile"];
				m_EditVersion                      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditVersion"];
				m_MainActivator                    = (VI.Controls.ActivatorComponent) Form.Components["MainActivator"];
				m_MainPanel                        = (VI.Controls.Interfaces.IVIPanel) Form.Controls["MainPanel"];
				m_MVPSupportedOperatingSystems     = (VI.Controls.Interfaces.IMultiValueEdit) Form.Controls["MVPSupportedOperatingSystems"];
				m_NewObjectButtonAccProduct        = (VI.Controls.Interfaces.INewObjectButton) Form.Controls["NewObjectButtonAccProduct"];
				m_NewObjectButtonSectionName       = (VI.Controls.Interfaces.INewObjectButton) Form.Controls["NewObjectButtonSectionName"];
				m_TabPage_00                       = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPage_00"];
				m_TabPage_01                       = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPage_01"];
				m_TabPage_03                       = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPage_03"];
				m_TabPageExtended                  = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPageExtended"];
				m_TextComboBoxAppAccessType        = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxAppAccessType"];
				m_TextComboBoxAppInstallationMode  = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxAppInstallationMode"];
				m_TextComboBoxAppPermitType        = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxAppPermitType"];
				m_TextComboBoxAppStatusIndicator   = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxAppStatusIndicator"];
				m_TextComboBoxAppUpdateCycle       = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxAppUpdateCycle"];
				m_TextComboBoxCustomProperty01     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty01"];
				m_TextComboBoxCustomProperty02     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty02"];
				m_TextComboBoxCustomProperty03     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty03"];
				m_TextComboBoxCustomProperty04     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty04"];
				m_TextComboBoxCustomProperty05     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty05"];
				m_TextComboBoxCustomProperty06     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty06"];
				m_TextComboBoxCustomProperty07     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty07"];
				m_TextComboBoxCustomProperty08     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty08"];
				m_TextComboBoxCustomProperty09     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty09"];
				m_TextComboBoxCustomProperty10     = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxCustomProperty10"];
				m_TreeComboBoxAccProduct           = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxAccProduct"];
				m_TreeComboBoxUIDApplicationType   = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDApplicationType"];
				m_TreeComboBoxUIDDialogCulture     = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDDialogCulture"];
				m_TreeComboBoxUIDOS                = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDOS"];
				m_TreeComboBoxUIDSectionName       = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDSectionName"];

				#endregion Component definition

				// Design der Alien-Controls anpassen
				OnControlDesignChanged();

			    m_NewObjectButtonSectionName.SetUpNewObjectAction = SetUpNewSectionNameObjectAction;
            }
			catch (Exception ex)
			{
				// Fehler melden
				throw new FormCustomizerException(874825, ex, ToString());
			}
		}

	    private void SetUpNewSectionNameObjectAction(ISingleDbObject targetDbObject)
	    {
	        FormTool.SetValueSafe(targetDbObject, "AppsNotDriver", true);

	        var sourceDbObject = m_MainActivator.DbObject;
	        if (sourceDbObject == null || Session == null)
	            return;

	        var prefix = Session.Config().GetConfigParm(@"Software\Driver\Section\Prefix") ?? "";
	        var identDriver = prefix + FormTool.GetValueSafe(sourceDbObject, "Ident_Driver", "");
	        var targetMaxLen = targetDbObject.GetEntity().Columns["Ident_SectionName"].MaxLen;
	        if (!string.IsNullOrEmpty(identDriver) && targetMaxLen > 0)
	            identDriver = identDriver.Substring(0, Math.Min(targetMaxLen, identDriver.Length)).Trim();

	        FormTool.SetValueSafe(targetDbObject, "Ident_SectionName", identDriver);
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
				// Design den Alien-Controls zuweisen
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
				m_EditIdentDriver.Focus();
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(new FormCustomizerException(929002, ex), this);
			}
		}

		#endregion

		/// <summary>
		/// FormMethode BrowseDocumentation
		/// </summary>
		public void FormTask_BrowseDocumentation()
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				// TabPage anzeigen
				m_CustomTab1.SelectedTab = m_TabPage_00;

				FormTool.ShowFile(m_EditDocumentationURL.Text);
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(
					new FormCustomizerException(929001, ex, GetString("SDL_FormDriverMasterData_Task_BrowseDocumentation").Replace("&", "")), this);
			}
		}


		/// <summary>
		/// FormMethode BrowseVendor
		/// </summary>
		public void FormTask_BrowseVendor()
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				// TabPage anzeigen
				m_CustomTab1.SelectedTab = m_TabPage_00;

				FormTool.ShowFile(m_EditDriverURL.Text);
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(
					new FormCustomizerException(929001, ex, GetString("SDL_FormDriverMasterData_Task_BrowseVendor").Replace("&", "")), this);
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

	        // Daten holen und prüfen
	        ISingleDbObject dbobject = m_MainActivator.DbObject;

	        if (dbobject == null) return;

	        m_TreeComboBoxUIDSectionName.WhereClause = SqlFormatter.Comparison("AppsNotDriver", true, ValType.Bool);
	    }


	    protected override void OnFormLoad()
		{
			m_TabPage_00.Caption = "SDL_FormCommon_General";
			m_TabPage_01.Caption = "SDL_FormDriverMasterData_TabPage_License";
			m_TabPageExtended.Caption = "SDL_FormDriverMasterData_TabPage_Extended";
			m_TabPage_03.Caption = "SDL_FormCommon_UserDefined";


			using (new UpdateHelper(Tasks))
			{
				Task task = Tasks["BrowseDocumentation"];
				task.Caption = "SDL_FormDriverMasterData_Task_BrowseDocumentation";
				task.Enabled = true;
				task.Visible = true;
				task.IsGuiTask = true;
				task.StockImage = VI.ImageLibrary.StockImage.WorldWideWeb;
				task.TaskMethod = FormTask_BrowseDocumentation;

				task = Tasks["BrowseVendor"];
				task.Caption = "SDL_FormDriverMasterData_Task_BrowseVendor";
				task.Enabled = true;
				task.Visible = true;
				task.IsGuiTask = true;
				task.StockImage = VI.ImageLibrary.StockImage.WorldWideWeb;
				task.TaskMethod = FormTask_BrowseVendor;
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent   m_MainActivator = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsForITShop = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsInActive = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsITShopOnly = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsProfileApplication = null;
		private VI.Controls.Interfaces.IDateButton m_ButtonDateFirstInstall2 = null;
		private VI.Controls.Interfaces.IEdit     m_EditDateFirstInstall = null;
		private VI.Controls.Interfaces.IEdit     m_EditDateStatusIndicatorChanged = null;
		private VI.Controls.Interfaces.IEdit     m_EditDescription = null;
		private VI.Controls.Interfaces.IEdit     m_EditDocumentationURL = null;
		private VI.Controls.Interfaces.IEdit     m_EditDriverURL = null;
		private VI.Controls.Interfaces.IEdit     m_EditIdentDriver = null;
		private VI.Controls.Interfaces.IEdit     m_EditInternalProductName = null;
		private VI.Controls.Interfaces.IEdit     m_EditLicenceClerk = null;
		private VI.Controls.Interfaces.IEdit     m_EditLicencePrice = null;
		private VI.Controls.Interfaces.IEdit     m_EditLicenceState = null;
		private VI.Controls.Interfaces.IEdit     m_EditSomeComments = null;
		private VI.Controls.Interfaces.IEdit     m_EditSortOrderForProfile = null;
		private VI.Controls.Interfaces.IEdit     m_EditVersion = null;
		private VI.Controls.Interfaces.IMultiValueEdit m_MVPSupportedOperatingSystems = null;
		private VI.Controls.Interfaces.INewObjectButton m_NewObjectButtonAccProduct = null;
		private VI.Controls.Interfaces.INewObjectButton m_NewObjectButtonSectionName = null;
		private VI.Controls.Interfaces.ITabControl m_CustomTab1 = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPage_00 = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPage_01 = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPage_03 = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPageExtended = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxAppAccessType = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxAppInstallationMode = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxAppPermitType = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxAppStatusIndicator = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxAppUpdateCycle = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty01 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty02 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty03 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty04 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty05 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty06 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty07 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty08 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty09 = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxCustomProperty10 = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxAccProduct = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDApplicationType = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDDialogCulture = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDOS = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDSectionName = null;
		private VI.Controls.Interfaces.IVIPanel  m_MainPanel = null;

        #endregion Component declaration

    }
}


