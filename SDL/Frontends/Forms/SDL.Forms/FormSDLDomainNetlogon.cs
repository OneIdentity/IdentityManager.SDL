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
using System.IO;
using System.Windows.Forms;

using VI.DB;
using VI.DB.JobGeneration;
using VI.FormTools;
using VI.FormCustomizers;
using VI.FormBase.Tasks;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmWindowsNTDomaeneNetlogon
	/// </summary>

	public class FormSDLDomainNetlogon : VI.FormTools.BaseCustomizer
	{

		/// <summary>
		/// Defaultkonstruktor der Klasse FrmWindowsNTDomaeneNetlogon.
		/// </summary>
		public FormSDLDomainNetlogon()
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

				m_OpenFileDialog                   = (System.Windows.Forms.OpenFileDialog) Form.Components["OpenFileDialog"];
				m_SaveFileDialog                   = (System.Windows.Forms.SaveFileDialog) Form.Components["SaveFileDialog"];
				m_SyntaxEdit                       = (VI.Controls.Interfaces.IDBSyntaxEdit) Form.Controls["SyntaxEdit"];
				m_ButtonSave                       = (VI.Controls.Interfaces.IButton) Form.Controls["ButtonSave"];
				m_ButtonOpen                       = (VI.Controls.Interfaces.IButton) Form.Controls["ButtonOpen"];
				m_ButtonNew                        = (VI.Controls.Interfaces.IButton) Form.Controls["ButtonNew"];
				m_EditFileName                     = (VI.Controls.Interfaces.IEdit) Form.Controls["EditFileName"];
				m_EditPath                         = (VI.Controls.Interfaces.IEdit) Form.Controls["EditPath"];
				m_HorizFormBar                     = (VI.Controls.Interfaces.IHorizFormBar) Form.Controls["HorizFormBar"];
				m_MainPanel                        = (VI.Controls.Interfaces.IVIPanel) Form.Controls["MainPanel"];
				m_StockImageComponent              = (VI.ImageLibrary.StockImageComponent) Form.Components["StockImageComponent"];
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
				// TODO
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
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929000, ex), this);
			}
		}


		#endregion


		private void FormMethod_Release()
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				if (m_IsChanged)
				{
					DialogResult result = FormTool.ShowQuestion("SDL_FormSDLDomainNetlogon_Question_SaveChanges", MessageBoxButtons.YesNoCancel);

					if (result == DialogResult.Cancel) return;

					if (result == DialogResult.Yes) Save();
				}

				JobGen.Generate(dbobject, "CopyNETLOGONFromTASToFDS");
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		private void Save()
		{
			string filename = m_EditFileName.Text;

			if (!File.Exists(filename))
			{
				if (m_SaveFileDialog.ShowDialog() != DialogResult.OK) return;

				filename = m_EditFileName.Text = m_SaveFileDialog.FileName;
			}

			using (StreamWriter writer = new StreamWriter(File.Create(filename)))
			{
				writer.WriteLine(m_SyntaxEdit.Text);
			}

			m_IsChanged = false;
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

				// TODO Whereklauseln setzen
			}
			finally
			{
			}
		}

		
		/// <summary>
		///	Form load event.
		/// </summary>
		private void FrmWindowsNTDomäneNetlogon_OnLoad(object sender, EventArgs e)
		{
			try
			{
			
				m_IsChanged = false;

				using (new VI.FormBase.UpdateHelper(Tasks))
				{
					Task task = Tasks["Release"];
					task.Caption = "SDL_FormSDLDomainNetlogon_Task_Share";
					task.Enabled = true;
					task.Visible = true;
					task.IsGuiTask = false;
					task.IsModal = false;
					task.TaskMethod = new TaskMethod(FormMethod_Release);
				}
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
		private void FrmWindowsNTDomäneNetlogon_OnSizeChanged(object sender, EventArgs e)
		{
			try
			{
			
				FormTool.MaximizeControl(m_SyntaxEdit);
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
		private void FrmWindowsNTDomäneNetlogon_OnUnload(object sender, EventArgs e)
		{
			try
			{
			
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
				
				if (m_MainActivator.DbObject == null)
					return;

				string	path = "";

				ISingleDbObject domain = m_MainActivator.DbObject;

				if (domain != null)
				{
					ISingleDbObject tas = domain.GetFK("UID_ServerTAS").Create();

					if (tas != null && FormTool.CanSee(tas, "Ident_Server") && FormTool.CanSee(domain, "NetLogonOnTAS"))
					{
						path = @"\\" + tas.GetValue("Ident_Server") + @"\" + domain.GetValue("NetLogonOnTAS") + @"\";

						if (!Directory.Exists(path))
							FormTool.ShowMessage("Der Pfad: " + path + " konnte nicht gefunden werden" + Environment.NewLine +  "oder keine Verbindung zum Netzlaufwerk vorhanden.");
					}
				}

				m_EditPath.Text =
					m_SaveFileDialog.InitialDirectory =
						m_OpenFileDialog.InitialDirectory = (path == "" || !Directory.Exists(path)) ?
								@"C:\" : path;
			}
			catch (Exception ex)
			{
				HandleException(ex);
			}
		}


		private void ButtonNew_Click(object sender, System.EventArgs e)
		{
			try
			{
				if (m_SaveFileDialog.ShowDialog() != DialogResult.OK) return;

				m_EditFileName.Text = m_SaveFileDialog.FileName;
				using (Stream s = File.Create(m_SaveFileDialog.FileName)) {}

				m_SyntaxEdit.Text = "";
				m_IsChanged = false;

			}
			catch (Exception ex)
			{
				HandleException(ex);
			}
		}

		private void ButtonOpen_Click(object sender, System.EventArgs e)
		{
			try
			{
				if (m_OpenFileDialog.ShowDialog() != DialogResult.OK) return;

				m_EditFileName.Text = m_OpenFileDialog.FileName;

				using (StreamReader reader = new StreamReader(File.OpenRead(m_OpenFileDialog.FileName)))
				{
					m_SyntaxEdit.Text = reader.ReadToEnd();
				}
				m_IsChanged = false;
			}
			catch (Exception ex)
			{
				HandleException(ex);
			}
		}

		private void ButtonSave_Click(object sender, System.EventArgs e)
		{
			try
			{
				Save();
			}
			catch (Exception ex)
			{
				HandleException(ex);
			}
		}

		private void SyntaxEdit_TextChanged(object sender, System.EventArgs e)
		{
			try
			{
				m_IsChanged = true;
			}
			catch (Exception ex)
			{
				HandleException(ex);
			}
		}


		private bool m_IsChanged = false;

		#region Component declaration (Do not remove or rename this region!)

		private System.Windows.Forms.OpenFileDialog m_OpenFileDialog = null;
		private System.Windows.Forms.SaveFileDialog m_SaveFileDialog = null;
		private VI.Controls.Interfaces.IDBSyntaxEdit m_SyntaxEdit = null;
		private VI.Controls.Interfaces.IButton   m_ButtonSave = null;
		private VI.Controls.Interfaces.IButton   m_ButtonOpen = null;
		private VI.Controls.Interfaces.IButton   m_ButtonNew = null;
		private VI.Controls.Interfaces.IEdit     m_EditFileName = null;
		private VI.Controls.Interfaces.IEdit     m_EditPath = null;
		private VI.Controls.Interfaces.IHorizFormBar m_HorizFormBar = null;
		private VI.Controls.Interfaces.IVIPanel  m_MainPanel = null;
		private VI.ImageLibrary.StockImageComponent m_StockImageComponent = null;
		private VI.Controls.ActivatorComponent   m_MainActivator = null;

		#endregion Component declaration

	}
}

