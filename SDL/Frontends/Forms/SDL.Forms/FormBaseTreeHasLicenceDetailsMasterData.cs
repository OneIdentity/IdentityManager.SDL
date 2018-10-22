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

using VI.FormBase;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// FrmBaseTreeHasLicenceDetailsStammdaten
	/// </summary>
#if DEBUG
	public class FormBaseTreeHasLicenceDetailsMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormBaseTreeHasLicenceDetailsMasterData : VI.FormTools.BaseCustomizer
#endif
	{


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

				m_EditCountLicMacDirectActual = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicMacDirectActual"];
				m_EditCountLicMacDirectTarget = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicMacDirectTarget"];
				m_EditCountLicMacIndirectActual = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicMacIndirectActual"];
				m_EditCountLicMacIndirectTarget = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicMacIndirectTarget"];
				m_EditCountLicMacPossActual = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicMacPossActual"];
				m_EditCountLicMacPossTarget = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicMacPossTarget"];
				m_EditCountLicMacReal = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicMacReal"];
				m_EditCountLicUserActual = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicUserActual"];
				m_EditCountLicUserTarget = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLicUserTarget"];
				m_EditCountLimit = (VI.Controls.Interfaces.IEdit)Form.Controls["EditCountLimit"];
				m_FormHeader = (VI.Controls.Interfaces.IHorizFormBar)Form.Controls["FormHeader"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_TreeComboBoxBaseObject = (VI.Controls.Interfaces.ITreeComboBox)Form.Controls["TreeComboBoxBaseObject"];
				m_TreeComboBoxUIDLicence = (VI.Controls.Interfaces.ITreeComboBox)Form.Controls["TreeComboBoxUIDLicence"];

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
				m_TreeComboBoxBaseObject.Focus();
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
			try
			{
				// Aktivierung mit <null> verhindern
				if (m_MainActivator.DbObject == null) return;

				// TODO Whereklauseln setzen
			}
			finally
			{
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicMacDirectActual = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicMacDirectTarget = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicMacIndirectActual = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicMacIndirectTarget = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicMacPossActual = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicMacPossTarget = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicMacReal = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicUserActual = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLicUserTarget = null;
		private VI.Controls.Interfaces.IEdit m_EditCountLimit = null;
		private VI.Controls.Interfaces.IHorizFormBar m_FormHeader = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxBaseObject = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDLicence = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration

	}
}

