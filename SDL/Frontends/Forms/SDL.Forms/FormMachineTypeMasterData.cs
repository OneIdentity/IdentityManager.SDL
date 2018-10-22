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
	/// frmSoftwareMaschinentypenStammdaten
	/// </summary>

#if DEBUG
	public class FormMachineTypeMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormMachineTypeMasterData : VI.FormTools.BaseCustomizer
#endif
	{


		/// <summary>
		/// Defaultkonstruktor der Klasse FrmSoftwareMaschinentypenStammdaten.
		/// </summary>
		public FormMachineTypeMasterData()
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

				m_CheckBoxIsInActive               = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxIsInActive"];
				m_CheckBoxRemoteBoot               = (VI.Controls.Interfaces.ICheckBox) Form.Controls["CheckBoxRemoteBoot"];
				m_EditChgNumber                    = (VI.Controls.Interfaces.IEdit) Form.Controls["EditChgNumber"];
				m_EditGraphicCard                  = (VI.Controls.Interfaces.IEdit) Form.Controls["EditGraphicCard"];
				m_EditIdentMachineType             = (VI.Controls.Interfaces.IEdit) Form.Controls["EditIdentMachineType"];
				m_EditInfFileNT4                   = (VI.Controls.Interfaces.IEdit) Form.Controls["EditInfFileNT4"];
				m_EditInfFileNT5                   = (VI.Controls.Interfaces.IEdit) Form.Controls["EditInfFileNT5"];
				m_EditInfFileW95                   = (VI.Controls.Interfaces.IEdit) Form.Controls["EditInfFileW95"];
				m_EditNetcard                      = (VI.Controls.Interfaces.IEdit) Form.Controls["EditNetcard"];
				m_HorizFormBar1                    = (VI.Controls.Interfaces.IHorizFormBar) Form.Controls["HorizFormBar1"];
				m_MainActivator                    = (VI.Controls.ActivatorComponent) Form.Components["MainActivator"];
				m_MainPanel                        = (VI.Controls.Interfaces.IVIPanel) Form.Controls["MainPanel"];
				m_TreeComboBoxUIDSDLDomain         = (VI.Controls.Interfaces.ITreeComboBox) Form.Controls["TreeComboBoxUIDSDLDomain"];

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
				m_EditIdentMachineType.Focus();
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929002, ex), this);
			}
		}


		protected override void OnFormLoad()
		{
			m_HorizFormBar1.Caption = "SDL_FormCommon_MasterData";
			m_TreeComboBoxUIDSDLDomain.RootNodeCaption = "SDL_FormMachineTypeMasterData_Domains";
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
				//if (m_MainActivator.DbObject == null)
    //                return;

				// Whereklauseln setzen
			}
			finally
			{
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent   m_MainActivator = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxIsInActive = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckBoxRemoteBoot = null;
		private VI.Controls.Interfaces.IEdit     m_EditChgNumber = null;
		private VI.Controls.Interfaces.IEdit     m_EditGraphicCard = null;
		private VI.Controls.Interfaces.IEdit     m_EditIdentMachineType = null;
		private VI.Controls.Interfaces.IEdit     m_EditInfFileNT4 = null;
		private VI.Controls.Interfaces.IEdit     m_EditInfFileNT5 = null;
		private VI.Controls.Interfaces.IEdit     m_EditInfFileW95 = null;
		private VI.Controls.Interfaces.IEdit     m_EditNetcard = null;
		private VI.Controls.Interfaces.IHorizFormBar m_HorizFormBar1 = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDSDLDomain = null;
		private VI.Controls.Interfaces.IVIPanel  m_MainPanel = null;

		#endregion Component declaration

	}
}


