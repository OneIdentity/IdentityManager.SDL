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

using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmLicenceTypeStammdaten
	/// </summary>

#if DEBUG
	public class FormLicenceTypeMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormLicenceTypeMasterData : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmLicenceTypeStammdaten.
		/// </summary>
		public FormLicenceTypeMasterData()
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

				m_CheckBoxIsConcurrentUse = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsConcurrentUse"];
				m_CheckBoxIsForFree = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsForFree"];
				m_CheckBoxIsLocalityBased = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsLocalityBased"];
				m_CheckBoxIsPerCompany = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsPerCompany"];
				m_CheckBoxIsPerMachine = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsPerMachine"];
				m_CheckBoxIsPerProcessor = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsPerProcessor"];
				m_CheckBoxIsPerUser = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsPerUser"];
				m_CheckBoxIsToPayOnce = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsToPayOnce"];
				m_CheckBoxIsToPayRecent = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckBoxIsToPayRecent"];
				m_EditDescription = (VI.Controls.Interfaces.IEdit)Form.Controls["EditDescription"];
				m_EditIdentLicenceType = (VI.Controls.Interfaces.IEdit)Form.Controls["EditIdentLicenceType"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_TabControl = (VI.Controls.Interfaces.ITabControl)Form.Controls["TabControl"];
				m_TabPageCommon = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPageCommon"];
				m_TabPageCustom = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPageCustom"];
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
				m_EditIdentLicenceType.Focus();
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
				// TODO Whereklauseln & CO hier initialisieren
			}
			finally
			{
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsConcurrentUse = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsForFree = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsLocalityBased = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsPerCompany = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsPerMachine = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsPerProcessor = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsPerUser = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsToPayOnce = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsToPayRecent = null;
		private VI.Controls.Interfaces.IEdit m_EditDescription = null;
		private VI.Controls.Interfaces.IEdit m_EditIdentLicenceType = null;
		private VI.Controls.Interfaces.ITabControl m_TabControl = null;
		private VI.Controls.Interfaces.ITabPage m_TabPageCommon = null;
		private VI.Controls.Interfaces.ITabPage m_TabPageCustom = null;
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
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration

	}
}

