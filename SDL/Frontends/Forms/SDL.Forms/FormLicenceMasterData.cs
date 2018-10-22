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
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmLicenceStammdaten
	/// </summary>

#if DEBUG
	public class FormLicenceMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormLicenceMasterData : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmLicenceStammdaten.
		/// </summary>
		public FormLicenceMasterData()
		{

		}


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

				m_CheckBoxIsInactive               = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxIsInactive"];
				m_CommandSelectLastDeliverDate     = (VI.Controls.Interfaces.IDateButton) Form.Controls["CommandSelectLastDeliverDate"];
				m_CommandSelectLastOfferDate       = (VI.Controls.Interfaces.IDateButton) Form.Controls["CommandSelectLastOfferDate"];
				m_CommandSelectValidFrom           = (VI.Controls.Interfaces.IDateButton) Form.Controls["CommandSelectValidFrom"];
				m_CommandSelectValidTo             = (VI.Controls.Interfaces.IDateButton) Form.Controls["CommandSelectValidTo"];
				m_EditArticleCode                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditArticleCode"];
				m_EditArticleCodeManufacturer      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditArticleCodeManufacturer"];
				m_EditCountLicMacDirectActual      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicMacDirectActual"];
				m_EditCountLicMacDirectTarget      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicMacDirectTarget"];
				m_EditCountLicMacIndirectActual    = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicMacIndirectActual"];
				m_EditCountLicMacIndirectTarget    = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicMacIndirectTarget"];
				m_EditCountLicMacPossActual        = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicMacPossActual"];
				m_EditCountLicMacPossTarget        = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicMacPossTarget"];
				m_EditCountLicMacReal              = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicMacReal"];
				m_EditCountLicUserActual           = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicUserActual"];
				m_EditCountLicUserTarget           = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLicUserTarget"];
				m_EditCountLimit                   = (VI.Controls.Interfaces.IEdit) Form.Controls["EditCountLimit"];
				m_EditDescription                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditDescription"];
				m_EditIdentLicence                 = (VI.Controls.Interfaces.IEdit) Form.Controls["EditIdentLicence"];
				m_EditLastDeliverDate              = (VI.Controls.Interfaces.IEdit) Form.Controls["EditLastDeliverDate"];
				m_EditLastDeliverPrice             = (VI.Controls.Interfaces.IEdit) Form.Controls["EditLastDeliverPrice"];
				m_EditLastOfferDate                = (VI.Controls.Interfaces.IEdit) Form.Controls["EditLastOfferDate"];
				m_EditLastOfferPrice               = (VI.Controls.Interfaces.IEdit) Form.Controls["EditLastOfferPrice"];
				m_EditLicenceNameManufacturer      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditLicenceNameManufacturer"];
				m_EditOrderQuantityMin             = (VI.Controls.Interfaces.IEdit) Form.Controls["EditOrderQuantityMin"];
				m_EditOrderUnit                    = (VI.Controls.Interfaces.IEdit) Form.Controls["EditOrderUnit"];
				m_EditValidFrom                    = (VI.Controls.Interfaces.IEdit) Form.Controls["EditValidFrom"];
				m_EditValidTo                      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditValidTo"];
				m_EditVersion                      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditVersion"];
				m_MainActivator                    = (VI.Controls.ActivatorComponent) Form.Components["MainActivator"];
				m_MainPanel                        = (VI.Controls.Interfaces.IVIPanel) Form.Controls["MainPanel"];
				m_TabControl                       = (VI.Controls.Interfaces.ITabControl) Form.Controls["TabControl"];
				m_TabPageAsset                     = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPageAsset"];
				m_TabPageCommon                    = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPageCommon"];
				m_TabPageCustom                    = (VI.Controls.Interfaces.ITabPage) Form.Controls["TabPageCustom"];
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
				m_TextComboBoxLicenceProductType   = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxLicenceProductType"];
				m_TextComboBoxLicenceStatusIndicator = (VI.Controls.Interfaces.ITextComboBox) Form.Controls["TextComboBoxLicenceStatusIndicator"];
				m_TreeComboBoxUIDApplicationType   = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDApplicationType"];
				m_TreeComboBoxUIDDialogCulture     = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDDialogCulture"];
				m_TreeComboBoxUIDFirmPartner       = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDFirmPartner"];
				m_TreeComboBoxUIDLicenceType       = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDLicenceType"];
				m_TreeComboBoxUIDOS                = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDOS"];

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
				// Design den Alien-Controls zuweisen
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
				m_EditIdentLicence.Focus();
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
		{}

		#endregion WindowsFormDesigner component initialization


		/// <summary>
		/// Wird aufgerufen, bevor der MainActivator aktiviert wird.
		/// Hier sollten alle von einem DB-Objekt abhängige Initialisierungen
		/// durchgeführt werden.
		/// </summary>
		private void MainActivator_OnActivating(object sender, System.EventArgs e)
		{
			//try
			//{
			//	//  Whereklauseln & CO hier initialisieren
			//}
			//finally
			//{
			//}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent   m_MainActivator = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsInactive = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectLastDeliverDate = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectLastOfferDate = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectValidFrom = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectValidTo = null;
		private VI.Controls.Interfaces.IEdit     m_EditArticleCode = null;
		private VI.Controls.Interfaces.IEdit     m_EditArticleCodeManufacturer = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicMacDirectActual = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicMacDirectTarget = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicMacIndirectActual = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicMacIndirectTarget = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicMacPossActual = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicMacPossTarget = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicMacReal = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicUserActual = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLicUserTarget = null;
		private VI.Controls.Interfaces.IEdit     m_EditCountLimit = null;
		private VI.Controls.Interfaces.IEdit     m_EditDescription = null;
		private VI.Controls.Interfaces.IEdit     m_EditIdentLicence = null;
		private VI.Controls.Interfaces.IEdit     m_EditLastDeliverDate = null;
		private VI.Controls.Interfaces.IEdit     m_EditLastDeliverPrice = null;
		private VI.Controls.Interfaces.IEdit     m_EditLastOfferDate = null;
		private VI.Controls.Interfaces.IEdit     m_EditLastOfferPrice = null;
		private VI.Controls.Interfaces.IEdit     m_EditLicenceNameManufacturer = null;
		private VI.Controls.Interfaces.IEdit     m_EditOrderQuantityMin = null;
		private VI.Controls.Interfaces.IEdit     m_EditOrderUnit = null;
		private VI.Controls.Interfaces.IEdit     m_EditValidFrom = null;
		private VI.Controls.Interfaces.IEdit     m_EditValidTo = null;
		private VI.Controls.Interfaces.IEdit     m_EditVersion = null;
		private VI.Controls.Interfaces.ITabControl m_TabControl = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPageAsset = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPageCommon = null;
		private VI.Controls.Interfaces.ITabPage  m_TabPageCustom = null;
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
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxLicenceProductType = null;
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxLicenceStatusIndicator = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDApplicationType = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDDialogCulture = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDFirmPartner = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDLicenceType = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDOS = null;
		private VI.Controls.Interfaces.IVIPanel  m_MainPanel = null;

		#endregion Component declaration

	}
}



