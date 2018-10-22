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
using VI.FormCustomizers;

using VIC = VI.Controls;

namespace SDL.Forms
{
	/// <summary>
	///
	/// </summary>
#if DEBUG
	public class FormDriverDependsOnDriverMasterData : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormDriverDependsOnDriverMasterData : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmDriverDependsOnDriverDetailsStammdaten.
		/// </summary>
		public FormDriverDependsOnDriverMasterData()
		{ }

		#region Init & Done & Adaption & Designer stuff

		// In diese Region nichts einfügen, da diese vom Designer überschrieben wird.
		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.ICheckBox m_CheckboxIsPhysicalDependent = null;
		private VI.Controls.Interfaces.IHorizFormBar m_FormHeader = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUID_DriverChild = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUID_DriverParent = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration

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

				m_CheckboxIsPhysicalDependent = (VI.Controls.Interfaces.ICheckBox)Form.Controls["CheckboxIsPhysicalDependent"];
				m_FormHeader = (VI.Controls.Interfaces.IHorizFormBar)Form.Controls["FormHeader"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_TreeComboBoxUID_DriverChild = (VI.Controls.Interfaces.ITreeComboBox)Form.Controls["TreeComboBoxUID_DriverChild"];
				m_TreeComboBoxUID_DriverParent = (VI.Controls.Interfaces.ITreeComboBox)Form.Controls["TreeComboBoxUID_DriverParent"];

				#endregion Component definition

				// Design der Alien-Controls anpassen
				OnControlDesignChanged();
			}
			catch (Exception ex)
			{
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
				// TODO Initialisierungen durchführen
			}
			catch (Exception ex)
			{
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929002, ex), this);
			}
		}

		// In diese Region nichts einfügen, da diese vom Designer überschrieben wird.
		#region WindowsFormDesigner component initialization (Do not remove or rename this region!)

		/// <summary>
		/// Dummy Methode für den FormDesigner.
		/// </summary>
		private void InitializeComponent()
		{ }

		#endregion WindowsFormDesigner component initialization

		#endregion


		/// <summary>
		/// Dieser EventHandler wird immer nach der Generierung des Formulars aufgerufen, um eine
		/// formularspezifische Initialisierung durchzuführen. Das Formular ist zu diesem Zeitpunkt
		/// noch nicht Aktiviert und besitzt keine Connection, SqlFormmater, ...
		/// </summary>
		protected override void OnFormLoad()
		{
			// TODO Captions setzen

			// TODO Tasks definieren
			/*				using (new UpdateHelper(Tasks))
			                {
			                    Task task = Tasks["<TaskName>"];
			                    task.TaskMethod	= new TaskMethod(Task_<TaskName>);
			                    task.Caption = "VIM_CAPTION_TASK_<TaskName>";
			                    task.StockImage = StockImage...;
			                    task.Enabled = false;
			                }
			*/
		}


		/// <summary>
		/// Wird aufgerufen, bevor der MainActivator mit der Aktivierung beginnt.
		/// Hier sollten alle von einem DB-Objekt abhängige Initialisierungen
		/// durchgeführt werden. Das Formular besitzt zu diesem Zeitpunkt die Connection
		/// und alle davon abhängigen Komponenten (SqlFormatter, Preprocessor-Auswertung, ...)
		/// </summary>
		private void MainActivator_OnActivating(object sender, System.EventArgs e)
		{
			try
			{
				// Aktivierung mit <null> verhindern
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				// TODO Whereklauseln setzen
			}
			finally
			{
			}
		}
	}
}

