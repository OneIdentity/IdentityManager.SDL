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
using System.Drawing;
using System.Windows.Forms;

using VI.DB;
using VI.Base;
using VI.Controls;
using VI.FormTools;
using VI.ImageLibrary;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmBaseTreeHasLicenceGrid
	/// </summary>
#if DEBUG
	public class FormDepartmentHasLicenseGrid : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormDepartmentHasLicenseGrid : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmBaseTreeHasLicenceGrid.
		/// </summary>
		static FormDepartmentHasLicenseGrid()
		{
			m_ImageList = new ImageList();
			m_ImageList.ColorDepth = ColorDepth.Depth32Bit;
			m_ImageList.ImageSize = new Size(16, 16);

			ImagelistHandler.AddFromImage(new Icon(typeof(FormDepartmentHasLicenseGrid).Assembly.GetManifestResourceStream("SDL.Forms.Resources.Lizenz.ico")),
										  m_ImageList);

		}

		/// <summary>
		/// Defaultkonstruktor der Klasse FrmBaseTreeHasLicenceGrid.
		/// </summary>
		public FormDepartmentHasLicenseGrid()
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

				m_DataStore = (VI.Controls.DataStoreComponent)Form.Components["DataStore"];
				m_FormHeader = (VI.Controls.Interfaces.IHorizFormBar)Form.Controls["FormHeader"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_TreeList = (VI.Controls.TreeListControl)Form.Controls["TreeList"];

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
				m_TreeList.BackColor = ControlDesign.BackColor;
				m_TreeList.ForeColor = ControlDesign.ControlForeColor;
				m_TreeList.Font = ControlDesign.ControlFont;

				foreach (TreeListColumn col in m_TreeList.Columns)
				{
					col.BackColor = ControlDesign.BackColor;
				}
			}
			catch (Exception ex)
			{
				// Fehler melden
				VI.FormBase.ExceptionMgr.Instance.HandleException(new FormCustomizerException(929000, ex), this);
			}
		}

		#endregion


		private void LoadData()
		{
			using (new VI.FormBase.UpdateHelper(m_TreeList))
			{
				m_TreeList.Nodes.Clear();

				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null || !dbobject.TableDef.CanSee) return;

				IColDbObject col = Connection.CreateCol(m_DataStore.String1);

				col.Prototype.WhereClause = SqlFormatter.Comparison(m_DataStore.String2, FormTool.GetValueSafe(dbobject, m_DataStore.String2, ""), ValType.String);
				col.Prototype.Columns["CountLicMacDirectTarget"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicMacIndirectTarget"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicUserTarget"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicMacPossTarget"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicMacDirectActual"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicMacDirectActual"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicMacIndirectActual"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicUserActual"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicMacPossActual"].IsDisplayItem = true;
				col.Prototype.Columns["CountLicMacReal"].IsDisplayItem = true;
				col.Prototype.Columns["CountLimit"].IsDisplayItem = true;
				col.Load();

				bool canedit = col.Prototype.Columns["CountLimit"].CanEdit;
				bool[] cansees = new bool[]
				{
					col.Prototype.Columns["UID_Licence"].CanSee,
					col.Prototype.Columns["CountLimit"].CanSee,
					col.Prototype.Columns["CountLicMacDirectActual"].CanSee,
					col.Prototype.Columns["CountLicMacDirectTarget"].CanSee,
					col.Prototype.Columns["CountLicMacIndirectActual"].CanSee,
					col.Prototype.Columns["CountLicMacIndirectTarget"].CanSee,
					col.Prototype.Columns["CountLicMacPossActual"].CanSee,
					col.Prototype.Columns["CountLicMacPossTarget"].CanSee,
					col.Prototype.Columns["CountLicMacReal"].CanSee,
					col.Prototype.Columns["CountLicUserActual"].CanSee,
					col.Prototype.Columns["CountLicUserTarget"].CanSee,
				};

				// und Grid füllen
				foreach (IColElem elem in col)
				{
					ISingleDbObject obj = elem.Create();

					ISingleDbObject identfk = obj.GetFK("UID_Licence").Create();
					string ident = identfk != null ? identfk["Ident_Licence"].New.String : "";

					TreeListNode node = m_TreeList.Nodes.Add(cansees[0] ? ident : "", 0);
					node.ForeColor = SystemColors.ControlDark;

					ITreeListItem subitem = canedit ? new TreeListItemTextBox(cansees[1] ? elem["CountLimit"].ToString() : "", 8) :
											new TreeListItem(cansees[1] ? elem["CountLimit"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = canedit ? SystemColors.ControlText : SystemColors.ControlDark;

					subitem = new TreeListItem(cansees[2] ? elem["CountLicMacReal"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;
					subitem = new TreeListItem(cansees[3] ? elem["CountLicUserActual"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;
					subitem = new TreeListItem(cansees[4] ? elem["CountLicUserTarget"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;
					subitem = new TreeListItem(cansees[5] ? elem["CountLicMacDirectActual"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;
					subitem = new TreeListItem(cansees[6] ? elem["CountLicMacDirectTarget"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;
					subitem = new TreeListItem(cansees[7] ? elem["CountLicMacIndirectActual"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;
					subitem = new TreeListItem(cansees[8] ? elem["CountLicMacIndirectTarget"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;
					subitem = new TreeListItem(cansees[9] ? elem["CountLicMacPossActual"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;
					subitem = new TreeListItem(cansees[10] ? elem["CountLicMacPossTarget"].ToString() : "");
					node.SubItems.Add(subitem);
					subitem.ForeColor = SystemColors.ControlDark;

					node.Tag = obj;
				}
			}
		}


		#region WindowsFormDesigner component initialization (Do not remove or rename this region!)

		/// <summary>
		/// Dummy method for FormDesigner.
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

			}
			finally
			{
			}
		}

		/// <summary>
		///
		/// </summary>
		private void MainActivator_OnActivated(object sender, System.EventArgs e)
		{
			try
			{
				// Aktivierung mit <null> verhindern
				if (m_MainActivator.DbObject == null) return;

				LoadData();
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
		private void MainActivator_OnDiscarded(object sender, System.EventArgs e)
		{
			try
			{
				foreach (TreeListNode node in m_TreeList.Nodes)
				{
					if (!node.SubItemsContentChanged) continue;

					ISingleDbObject dbobject = node.Tag as ISingleDbObject;

					node.SubItems[0].Data = FormTool.GetValueSafe(dbobject, "CountLimit", 0).ToString();
					node.SubItems[0].ForeColor = SystemColors.ControlText;
				}
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
			finally
			{
				m_TreeList.Invalidate();
			}
		}

		/// <summary>
		///
		/// </summary>
		private void FrmBaseTreeHasLicenceGrid_OnLoad(object sender, EventArgs e)
		{
			try
			{
				m_TreeList.ImageList = m_ImageList;

				using (new VI.FormBase.UpdateHelper(m_TreeList))
				{
					m_TreeList.Nodes.Clear();
					m_TreeList.Columns.Clear();

					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_License"), 120));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_CountLimit"), 40, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_MacReal"), 60, HorizontalAlignment.Center, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_UserActual"), 40, HorizontalAlignment.Center, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_UserTarget"), 40, HorizontalAlignment.Center, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_MacDirectActual"), 48, HorizontalAlignment.Center, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_MacDirectTarget"), 48, HorizontalAlignment.Center, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_MacIndirectActual"), 45, HorizontalAlignment.Center, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_MacIndirectTarget"), 45, HorizontalAlignment.Center, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_MacPossActual"), 63, HorizontalAlignment.Center, HorizontalAlignment.Center));
					m_TreeList.Columns.Add(new TreeListColumn(GetString("SDL_FormDepartmentHasLicenseGrid_MacPossTarget"), 63, HorizontalAlignment.Center, HorizontalAlignment.Center));

					// Farbe anpassen
					foreach (TreeListColumn col in m_TreeList.Columns)
					{
						col.BackColor = ControlDesign.BackColor;
					}

					m_TreeList.ShowGroups = true;

					m_TreeList.Columns[3].BeginGroup = true;
					m_TreeList.Columns[3].GroupCaption = GetString("SDL_FormCommon_User");
					m_TreeList.Columns[5].BeginGroup = true;
					m_TreeList.Columns[5].GroupCaption = GetString("SDL_FormDepartmentHasLicenseGrid_GroupOverWorkdesks");
					m_TreeList.Columns[7].BeginGroup = true;
					m_TreeList.Columns[7].GroupCaption = GetString("SDL_FormDepartmentHasLicenseGrid_GroupRegularPC");
					m_TreeList.Columns[9].BeginGroup = true;
					m_TreeList.Columns[9].GroupCaption = GetString("SDL_FormDepartmentHasLicenseGrid_GroupPossAssign");
				}
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}

		protected override void OnFormSizeChanged()
		{
			base.OnFormSizeChanged();

			FormTool.StretchControl(m_TreeList, VI.FormBase.ExtOrientation.Both, true);
		}


		/// <summary>
		///
		/// </summary>
		private void MainActivator_OnSaved(object sender, System.EventArgs e)
		{
			try
			{
				foreach (TreeListNode node in m_TreeList.Nodes)
				{
					if (!node.SubItemsContentChanged) continue;

					ISingleDbObject dbobject = node.Tag as ISingleDbObject;

					if (FormTool.SetValueSafe(dbobject, "CountLimit", int.Parse(node.SubItems[0].Data as string)))
					{
						node.SubItems[0].ForeColor = SystemColors.ControlText;
					}

					dbobject.Save();
					dbobject.Load();
				}
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
			finally
			{
				m_TreeList.Invalidate();
			}
		}

		/// <summary>
		///
		/// </summary>
		private void TreeList_OnSubItemContentChanging(object sender, TreeListEventArgs e)
		{
			try
			{
				string text = ((string)e.Data).Trim();

				// leere Einträge verhindern
				if (text == "")
				{
					e.Cancel = true;
					return;
				}

				// Änderung melden
				if (text != e.SubItem.Data as string)
				{
					try
					{
						e.SubItem.Data = int.Parse(text).ToString();
					}
					catch
					{
						e.Cancel = true;
						return;
					};

					e.SubItem.ForeColor = Color.Red;

					m_MainActivator.DataChanged("");
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
		private void TreeList_OnSort(object sender, TreeListEventArgs e)
		{
			try
			{
				e.Nodes.Sort(new TreeListNodeComparerCaption());
			}
			catch (Exception ex)
			{
				// Fehler melden
				HandleException(ex);
			}
		}


		/// <summary>
		/// Imagelist für die TreeList.
		/// </summary>
		private static ImageList m_ImageList = null;

		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.DataStoreComponent m_DataStore = null;
		private VI.Controls.Interfaces.IHorizFormBar m_FormHeader = null;
		private VI.Controls.TreeListControl m_TreeList = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration


	}
}


