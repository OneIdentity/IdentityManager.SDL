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
using VI.FormBase;
using VI.FormBase.Tasks;
using VI.FormTools;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmSoftwareMaschinentypenAktion
	/// </summary>

#if DEBUG
	public class FormMachineTypeCopy : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormMachineTypeCopy : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmSoftwareMaschinentypenAktion.
		/// </summary>
		public FormMachineTypeCopy()
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

				m_Checkbox2                        = (VI.Controls.Interfaces.ICheckBox) Form.Controls["Checkbox2"];
				m_Combo1                           = (VI.Controls.Interfaces.INetComboBox) Form.Controls["Combo1"];
				m_Combo2                           = (VI.Controls.Interfaces.INetComboBox) Form.Controls["Combo2"];
				m_Command1                         = (VI.Controls.Interfaces.IButton) Form.Controls["Command1"];
				m_DateTimePicker1                  = (VI.Controls.Interfaces.INetDateTimePicker) Form.Controls["DateTimePicker1"];
				m_EditChgNumber                    = (VI.Controls.Interfaces.IEdit) Form.Controls["EditChgNumber"];
				m_EditIdentMachineType             = (VI.Controls.Interfaces.IEdit) Form.Controls["EditIdentMachineType"];
				m_HorizFormBar2                    = (VI.Controls.Interfaces.IHorizFormBar) Form.Controls["HorizFormBar2"];
				m_Label1                           = (VI.Controls.Interfaces.ICaptionLabel) Form.Controls["Label1"];
				m_Label2                           = (VI.Controls.Interfaces.ICaptionLabel) Form.Controls["Label2"];
				m_MainActivator                    = (VI.Controls.ActivatorComponent) Form.Components["MainActivator"];
				m_MainPanel                        = (VI.Controls.Interfaces.IVIPanel) Form.Controls["MainPanel"];
				m_Option1                          = (VI.Controls.Interfaces.IRadioButton) Form.Controls["Option1"];
				m_Option2                          = (VI.Controls.Interfaces.IRadioButton) Form.Controls["Option2"];
				m_ShrinkFrame3                     = (VI.Controls.Interfaces.IShrinkFrame) Form.Controls["ShrinkFrame3"];
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
				m_DateTimePicker1.BackColor = ControlDesign.ControlBackColor;
				m_DateTimePicker1.ForeColor = ControlDesign.ControlForeColor;
				m_DateTimePicker1.Font = ControlDesign.ControlFont;

				m_Combo1.BackColor = ControlDesign.ControlBackColor;
				m_Combo1.ForeColor = ControlDesign.ControlForeColor;
				m_Combo1.Font = ControlDesign.ControlFont;

				m_Combo2.BackColor = ControlDesign.ControlBackColor;
				m_Combo2.ForeColor = ControlDesign.ControlForeColor;
				m_Combo2.Font = ControlDesign.ControlFont;
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
				m_Clone = null;
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929002, ex), this);
			}
		}

		#endregion

		/// <summary>
		///
		/// </summary>
		private void Copy()
		{
			try
			{
				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null || dbobject.Custom == null) return;

				using (new VI.Controls.WaitCursor())
				{
					object starttime = DbVal.MinDate;

					if (m_Option2.Checked)
					{
					    starttime = DbVal.ToUniversalTime(m_DateTimePicker1.Value, TimeZoneInfo.Local);
                    }

					switch (m_Combo1.SelectedIndex)
					{
						case 0:
							dbobject.Custom.CallMethod("SvrCopy", "CopyFDS2CL", "", "", starttime, "");
							break;

						case 1:

							if (m_Combo2.SelectedIndex >= 0)
							{
								dbobject.Custom.CallMethod("SvrCopy", "CopyFDS_P2FDS_C", "",
														   m_ColAppServer[m_Combo2.SelectedIndex]["UID_Server"].ToString(), starttime, "");
								break;
							}
							else
							{
								FormTool.ShowMessage("SDL_FormApplicationProfileCopyAll_Message_ChildServer");
							}

							break;

						case 2:

							if (m_Combo2.SelectedIndex >= 0)
							{
								dbobject.Custom.CallMethod("SvrCopy", "CopyFDS_C2FDS_P", "",
														   m_ColAppServer[m_Combo2.SelectedIndex]["UID_Server"].ToString(), starttime, "");
								break;
							}
							else
							{
								FormTool.ShowMessage("SDL_FormApplicationProfileCopyAll_Message_ChildServer");
							}

							break;

						case 3:
							dbobject.Custom.CallMethod("SvrCopy", "CopyFDS2TAS", "", "", starttime, "");
							break;

						case 4:
							dbobject.Custom.CallMethod("SvrCopy", "CopyTAS2FDS", "", "", starttime, "");
							break;

						default:
							FormTool.ShowMessage("SDL_FormApplicationProfileCopyAll_Message_Action");
							break;
					}
				}
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		/// <summary>
		/// FormMethode Copy
		/// </summary>
		public void FormMethod_Copy()
		{
			try
			{
				Copy();
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(
					new FormCustomizerException(929001, ex, GetString("SDL_FormApplicationProfileCopyAll_Copy").Replace("&", "")), this);
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

				m_ShrinkFrame3.VisibleByUser = Connection.GetConfigParm(@"Software\SoftwareDistribution\Replication\ReplJobDelay") == "1";

				// mit einem Clone aktivieren, damit der Save-Button im Manager nie enabled wird
				if (m_Clone == null)
				{
					m_Clone = new DbObjectKey(m_MainActivator.DbObject).GetObject(Connection);
					m_MainActivator.DbObject = m_Clone;
				}
			}
			finally
			{
			}
		}

		/// <summary>
		///
		/// </summary>
		private void Combo1_OnSelectionChangeCommitted(object sender, System.EventArgs e)
		{
			try
			{

				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				m_Combo2.ComboItems.Clear();

				//				if (m_Combo1.SelectedIndex == 0) m_Combo2.Enabled = false;

				//				else

				if (m_Combo1.SelectedIndex == 1 || m_Combo1.SelectedIndex == 2)
				{
					m_ColAppServer = Connection.CreateCol("ApplicationServer");
					m_ColAppServer.Prototype.WhereClause = !FormTool.CanSee(dbobject, "UID_SDLDomain") ? "1=2" :
														   SqlFormatter.AndRelation(
																   SqlFormatter.UidComparison("UID_SDLDomain", dbobject["UID_SDLDomain"].New.String),
																   " not " + SqlFormatter.EmptyClause("UID_ParentApplicationServer", ValType.String));
					m_ColAppServer.Prototype.Columns["UID_Server"].IsDisplayItem = true;
					m_ColAppServer.Load();

					if (m_ColAppServer.Count > 0)
					{
						foreach (IColElem elem in m_ColAppServer)
						{
							m_Combo2.ComboItems.Add(elem);
						}

						//						m_Combo2.Enabled = true;
					}
					else
					{
						FormTool.ShowMessage("SDL_FormApplicationProfileCopyAll_Message_NoChildServerActionNotPossible");
						//						m_Combo2.Enabled = false;
					}
				}
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(ex, this, 100);
			}
		}


		/// <summary>
		///
		/// </summary>
		private void Command1_OnClick(object sender, System.EventArgs e)
		{
			try
			{
				//			    Kopieren
				Copy();
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
		private void DateTimePicker1_OnValueChanged(object sender, System.EventArgs e)
		{
			try
			{
				if (!_init)
				    m_Option2.Checked = true;
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		protected override void OnFormLoad()
		{
			m_Label1.Caption = "SDL_FormApplicationProfileCopyAll_ChildServer";
			m_Label2.Caption = "SDL_FormApplicationProfileCopyAll_Action";

			m_Option1.Caption = "SDL_FormApplicationProfileCopyAll_OptionNow";
			m_Option2.Caption = "SDL_FormApplicationProfileCopyAll_OptionAt";

			m_HorizFormBar2.Caption = "SDL_FormApplicationProfileCopyAll_Copy";

			m_Combo1.ComboItems.Clear();
			m_Combo1.ComboItems.Add(GetString("SDL_FormApplicationProfileCopyAll_FDSToCL"));
			m_Combo1.ComboItems.Add(GetString("SDL_FormApplicationProfileCopyAll_TroubleshootingFDSToPAS"));
			m_Combo1.ComboItems.Add(GetString("SDL_FormApplicationProfileCopyAll_TroubleshootingPASToFDS"));
			m_Combo1.ComboItems.Add(GetString("SDL_FormMachineTypeCopy_Task_CopyFDSToTAS"));
			m_Combo1.ComboItems.Add(GetString("SDL_FormMachineTypeCopy_Task_CopyTASToFDS"));
			m_Combo1.SelectedIndex = 0;

			m_Command1.Caption = GetString("SDL_FormApplicationProfileCopyAll_Copy");

		    _init = true;
            try
		    {
		        m_DateTimePicker1.Value = ThreadStore.Instance.LocalNow;
		        m_DateTimePicker1.MinDate = ThreadStore.Instance.LocalNow;

		    }
		    finally
		    {
		        _init = false;
		    }

			using (new UpdateHelper(Tasks))
			{
				Task task = Tasks["Copy"];
				task.Caption = "SDL_FormApplicationProfileCopyAll_Copy";
				task.Enabled = true;
				task.Visible = true;
				task.TaskMethod = new VI.FormBase.Tasks.TaskMethod(FormMethod_Copy);
			}
		}

		/// <summary>
		///
		/// </summary>
		private void MainActivator_OnActivated(object sender, System.EventArgs e)
		{
			try
			{

				// den Clone vernichten, wegen FormCache
				m_Clone = null;

				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

				m_StrDestinationDomain = m_MainActivator.Variables["CustomString", ""].ToString();

				// kopieren ohne Customizer ist nicht möglich
				m_Command1.Enabled = dbobject != null && dbobject.Custom != null;
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		private IColDbObject m_ColAppServer = null;
		private string m_StrDestinationDomain = "";
		private ISingleDbObject m_Clone = null;
	    private bool _init = false;

		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent   m_MainActivator = null;
		private VI.Controls.Interfaces.IButton   m_Command1 = null;
		private VI.Controls.Interfaces.ICaptionLabel m_Label1 = null;
		private VI.Controls.Interfaces.ICaptionLabel m_Label2 = null;
		private VI.Controls.Interfaces.ICheckBox m_Checkbox2 = null;
		private VI.Controls.Interfaces.IEdit     m_EditChgNumber = null;
		private VI.Controls.Interfaces.IEdit     m_EditIdentMachineType = null;
		private VI.Controls.Interfaces.IHorizFormBar m_HorizFormBar2 = null;
		private VI.Controls.Interfaces.INetComboBox m_Combo1 = null;
		private VI.Controls.Interfaces.INetComboBox m_Combo2 = null;
		private VI.Controls.Interfaces.INetDateTimePicker m_DateTimePicker1 = null;
		private VI.Controls.Interfaces.IRadioButton m_Option1 = null;
		private VI.Controls.Interfaces.IRadioButton m_Option2 = null;
		private VI.Controls.Interfaces.IShrinkFrame m_ShrinkFrame3 = null;
		private VI.Controls.Interfaces.ITreeComboBox m_TreeComboBoxUIDSDLDomain = null;
		private VI.Controls.Interfaces.IVIPanel  m_MainPanel = null;

		#endregion Component declaration

	}
}
