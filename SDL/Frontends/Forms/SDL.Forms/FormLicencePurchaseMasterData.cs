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

using VI.DB;
using VI.Base;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmLicencePurchaseStammdaten
	/// </summary>

#if DEBUG
	public class FormLicencePurchaseMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormLicencePurchaseMasterData : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmLicencePurchaseStammdaten.
		/// </summary>
		public FormLicencePurchaseMasterData()
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

				m_CheckBoxAssetOwnerShip = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxAssetOwnerShip"];
				m_CheckBoxIsInactive = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsInactive"];
				m_CheckBoxIsLeasingAsset = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsLeasingAsset"];
				m_CommandSelectAssetActivate = (VI.Controls.Interfaces.IDateButton)Form.Controls["CommandSelectAssetActivate"];
				m_CommandSelectAssetDeActivate = (VI.Controls.Interfaces.IDateButton)Form.Controls["CommandSelectAssetDeActivate"];
				m_CommandSelectAssetInventory = (VI.Controls.Interfaces.IDateButton)Form.Controls["CommandSelectAssetInventory"];
				m_CommandSelectBuyDate = (VI.Controls.Interfaces.IDateButton)Form.Controls["CommandSelectBuyDate"];
				m_CommandSelectDeliveryDate = (VI.Controls.Interfaces.IDateButton)Form.Controls["CommandSelectDeliveryDate"];
				m_CommandSelectEndOfUse = (VI.Controls.Interfaces.IDateButton)Form.Controls["CommandSelectEndOfUse"];
				m_CommandSelectGuaranty = (VI.Controls.Interfaces.IDateButton)Form.Controls["CommandSelectGuaranty"];
				m_EditArticleCodeDealer = (VI.Controls.Interfaces.IEdit)Form.Controls["EditArticleCodeDealer"];
				m_EditArticleCodeManufacturer = (VI.Controls.Interfaces.IEdit)Form.Controls["EditArticleCodeManufacturer"];
				m_EditAssetActivate = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetActivate"];
				m_EditAssetAmortizationMonth = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetAmortizationMonth"];
				m_EditAssetDeActivate = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetDeActivate"];
				m_EditAssetDeliveryRemarks = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetDeliveryRemarks"];
				m_EditAssetIdent = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetIdent"];
				m_EditAssetInventory = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetInventory"];
				m_EditAssetInventoryText = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetInventoryText"];
				m_EditAssetNumber = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetNumber"];
				m_EditAssetReceiptNumber = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetReceiptNumber"];
				m_EditAssetValueCurrent = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetValueCurrent"];
				m_EditAssetValueNew = (VI.Controls.Interfaces.IEdit)Form.Controls["EditAssetValueNew"];
				m_EditBuyDate = (VI.Controls.Interfaces.IEdit)Form.Controls["EditBuyDate"];
				m_EditCountLicence = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicence"];
				m_EditCountLicenceRemaining = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicenceRemaining"];
				m_EditCurrency = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCurrency"];
				m_EditDeliveryDate = (VI.Controls.Interfaces.IEdit)Form.Controls["EditDeliveryDate"];
				m_EditDeliveryNumber = (VI.Controls.Interfaces.IEdit)Form.Controls["EditDeliveryNumber"];
				m_EditEndOfUse = (VI.Controls.Interfaces.IEdit)Form.Controls["EditEndOfUse"];
				m_EditGuaranty = (VI.Controls.Interfaces.IEdit)Form.Controls["EditGuaranty"];
				m_EditGuarantyMonths = (VI.Controls.Interfaces.IEdit)Form.Controls["EditGuarantyMonths"];
				m_EditGuarantyMonthsAdditional = (VI.Controls.Interfaces.IEdit)Form.Controls["EditGuarantyMonthsAdditional"];
				m_EditGuarantyNumber = (VI.Controls.Interfaces.IEdit)Form.Controls["EditGuarantyNumber"];
				m_EditOrderNumber = (VI.Controls.Interfaces.IEdit)Form.Controls["EditOrderNumber"];
				m_EditRentCharge = (VI.Controls.Interfaces.IEdit)Form.Controls["EditRentCharge"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_MultiValueEditSerialNumber = (VI.Controls.Interfaces.IMultiValueEdit)Form.Controls["MultiValueEditSerialNumber"];
				m_TabControl = (VI.Controls.Interfaces.ITabControl)Form.Controls["TabControl"];
				m_TabPageAsset = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPageAsset"];
				m_TabPageCommon = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPageCommon"];
				m_TabPageCustom = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPageCustom"];
				m_TabPageDelivery = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPageDelivery"];
				m_TextComboBoxCustomProperty01 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty01"];
				m_TextComboBoxCustomProperty02 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty02"];
				m_TextComboBoxCustomProperty03 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty03"];
				m_TextComboBoxCustomProperty04 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty04"];
				m_TextComboBoxCustomProperty05 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty05"];
				m_TextComboBoxCustomProperty06 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty06"];
				m_TextComboBoxCustomProperty07 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty07"];
				m_TextComboBoxCustomProperty08 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty08"];
				m_TextComboBoxCustomProperty09 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty09"];
				m_TextComboBoxCustomProperty10 = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxCustomProperty10"];
				m_TextComboBoxLicencePurchaseType = (VI.Controls.Interfaces.ITextComboBox)Form.Controls["TextComboBoxLicencePurchaseType"];
				m_TreeComboBoxIdentLicenceType = (VI.Controls.Interfaces.ITreeComboBox)Form.Controls["TreeComboBoxIdentLicenceType"];
				m_TreeComboBoxUIDFirmPartnerVendor = (VI.Controls.Interfaces.ITreeComboBox)Form.Controls["TreeComboBoxUIDFirmPartnerVendor"];
				m_TreeComboBoxUIDLicence = (VI.Controls.Interfaces.ITreeComboBox)Form.Controls["TreeComboBoxUIDLicence"];
				m_TreeComboBoxUIDOrgOwner = (VI.Controls.Interfaces.ITreeComboBox)Form.Controls["TreeComboBoxUIDOrgOwner"];

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
				// TODO Design den Alien-Controls zuweisen
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
				m_EditAssetIdent.Focus();
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
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;
				if (dbobject == null) return;

				m_TreeComboBoxUIDFirmPartnerVendor.WhereClause = SqlFormatter.Comparison("isvendor", true, ValType.Bool);
			}
			finally
			{
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxAssetOwnerShip = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsInactive = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsLeasingAsset = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectAssetActivate = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectAssetDeActivate = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectAssetInventory = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectBuyDate = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectDeliveryDate = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectEndOfUse = null;
		private VI.Controls.Interfaces.IDateButton m_CommandSelectGuaranty = null;
		private VI.Controls.Interfaces.IEdit m_EditArticleCodeDealer = null;
		private VI.Controls.Interfaces.IEdit m_EditArticleCodeManufacturer = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetActivate = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetAmortizationMonth = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetDeActivate = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetDeliveryRemarks = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetIdent = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetInventory = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetInventoryText = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetNumber = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetReceiptNumber = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetValueCurrent = null;
		private VI.Controls.Interfaces.IEdit m_EditAssetValueNew = null;
		private VI.Controls.Interfaces.IEdit m_EditBuyDate = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicence = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicenceRemaining = null;
		private VI.Controls.Interfaces.IEdit m_EditCurrency = null;
		private VI.Controls.Interfaces.IEdit m_EditDeliveryDate = null;
		private VI.Controls.Interfaces.IEdit m_EditDeliveryNumber = null;
		private VI.Controls.Interfaces.IEdit m_EditEndOfUse = null;
		private VI.Controls.Interfaces.IEdit m_EditGuaranty = null;
		private VI.Controls.Interfaces.IEdit m_EditGuarantyMonths = null;
		private VI.Controls.Interfaces.IEdit m_EditGuarantyMonthsAdditional = null;
		private VI.Controls.Interfaces.IEdit m_EditGuarantyNumber = null;
		private VI.Controls.Interfaces.IEdit m_EditOrderNumber = null;
		private VI.Controls.Interfaces.IEdit m_EditRentCharge = null;
		private VI.Controls.Interfaces.IMultiValueEdit m_MultiValueEditSerialNumber = null;
		private VI.Controls.Interfaces.ITabControl m_TabControl = null;
		private VI.Controls.Interfaces.ITabPage m_TabPageAsset = null;
		private VI.Controls.Interfaces.ITabPage m_TabPageCommon = null;
		private VI.Controls.Interfaces.ITabPage m_TabPageCustom = null;
		private VI.Controls.Interfaces.ITabPage m_TabPageDelivery = null;
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
		private VI.Controls.Interfaces.ITextComboBox m_TextComboBoxLicencePurchaseType = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxIdentLicenceType = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDFirmPartnerVendor = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDLicence = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDOrgOwner = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration

	}
}

