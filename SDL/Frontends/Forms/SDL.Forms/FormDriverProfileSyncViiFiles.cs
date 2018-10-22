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
using VI.FormTools;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmSyncDriverProfile
	/// </summary>
#if DEBUG
	public class FormDriverProfileSyncViiFiles : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormDriverProfileSyncViiFiles : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmSyncDriverProfile.
		/// </summary>
		public FormDriverProfileSyncViiFiles()
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

				m_EditAsLabel2                     = (VI.Controls.Interfaces.IEdit) Form.Controls["EditAsLabel2"];
				m_EditAsLabel3                     = (VI.Controls.Interfaces.IEdit) Form.Controls["EditAsLabel3"];
				m_EditAsLabel4                     = (VI.Controls.Interfaces.IEdit) Form.Controls["EditAsLabel4"];
				m_HorizFormBar1                    = (VI.Controls.Interfaces.IHorizFormBar) Form.Controls["HorizFormBar1"];
				m_MainPanel                        = (VI.Controls.Interfaces.IVIPanel) Form.Controls["MainPanel"];
				m_MainActivator                    = (VI.Controls.ActivatorComponent) Form.Components["MainActivator"];

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
			base.OnControlDesignChanged ();

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
			base.OnResetForm ();

			try
			{
				// TODO Initialisierungen durchführen
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

		/// <summary>
		///
		/// </summary>
		private void FrmSyncDriverProfile_OnLoad(object sender, EventArgs e)
		{
			try
			{
				m_EditAsLabel2.Text = "";
				m_EditAsLabel3.Text = "";
				m_EditAsLabel4.Text = "";
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
		private void MainActivator_OnActivated(object sender, System.EventArgs e)
		{
			try
			{
				m_EditAsLabel2.Text = "";
				m_EditAsLabel3.Text = "";
				m_EditAsLabel4.Text = "";

				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				string path = "";

				if (!ProfileTool.GetProfilePathOnTas(dbobject, out path)) return;

				m_EditAsLabel4.Text = path;

				string file = "";
				string error = "";

				if (ProfileTool.ReadFileFromProfile(System.IO.Path.Combine(path, "profiledescription.vii"), out file))
					m_EditAsLabel2.Text = file;
				else
					error = GetString("SDL_FormApplicationProfileSyncViiFiles_Message_ErrorNoProfileDescriptionVII") + Environment.NewLine;

				if (ProfileTool.ReadFileFromProfile(System.IO.Path.Combine(path, "profile.vii"), out file))
					m_EditAsLabel3.Text = file;
				else
					error += GetString("SDL_FormApplicationProfileSyncViiFiles_Message_ErrorNoProfileVII") + Environment.NewLine;

				if (error.Length > 0)
					FormTool.ShowError(error);
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.Interfaces.IEdit     m_EditAsLabel2 = null;
		private VI.Controls.Interfaces.IEdit     m_EditAsLabel3 = null;
		private VI.Controls.Interfaces.IEdit     m_EditAsLabel4 = null;
		private VI.Controls.Interfaces.IHorizFormBar m_HorizFormBar1 = null;
		private VI.Controls.Interfaces.IVIPanel  m_MainPanel = null;
		private VI.Controls.ActivatorComponent   m_MainActivator = null;

		#endregion Component declaration

	}
}

