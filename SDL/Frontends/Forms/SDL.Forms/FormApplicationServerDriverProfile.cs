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
using System.Collections.Generic;
using System.Data;
using System.Drawing;

using VI.DB;
using VI.Base;
using VI.Controls;
using VI.DB.DataAccess;
using VI.DB.Entities;
using VI.DB.Sync;
using VI.FormTools;
using VI.FormBase;
using VI.FormCustomizers;
using VI.ImageLibrary;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// frmKonfigApplikationsserverTreiberprofile
	/// </summary>

#if DEBUG
	public class FormApplicationServerDriverProfile : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormApplicationServerDriverProfile : VI.FormTools.BaseCustomizer
#endif
	{
		private ITreeListProxy m_Proxy;


		/// <summary>
		/// Defaultkonstruktor der Klasse FrmKonfigApplikationsserverTreiberprofile.
		/// </summary>
		public FormApplicationServerDriverProfile()
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

				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_TreeList = (VI.Controls.Interfaces.ITreeListControl)Form.Controls["TreeList"];

				#endregion Component definition

				m_Proxy = m_TreeList.Proxy;

				m_Proxy.AddColumn("~DisplayName", 300);
				m_Proxy.AddColumn("~ProfileStateProduction", 130);
				m_Proxy.AddColumn("~ProfileStateShadow", 130);
				m_Proxy.AddColumn("~ChgNumber", 100);

				m_TreeList.ImageList = ImagelistHandler.StockImageListSmall;

				if (AppData.Instance.AppType == AppType.Web)
				{
					CommonTools.SetProperty(m_TreeList, "AlternateNodeBackground", true);
					CommonTools.SetProperty(m_TreeList, "AutoSize", true);
					CommonTools.SetProperty(m_TreeList, "ShowNodeImages", false);
				}

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
				Color c = VI.Controls.Design.DesignClass.MixColor(ControlDesign.CaptionBackColor, ControlDesign.BackColor, 0.5f);
				m_Proxy.Columns[1].BackColor = c;
				m_Proxy.Columns[3].BackColor = c;

				m_TreeList.BackColor = ControlDesign.BackColor;
			}
			catch (Exception ex)
			{
				// Fehler melden
				ExceptionMgr.Instance.HandleException(new FormCustomizerException(929000, ex), this);
			}
		}

		#endregion


		protected override void OnFormSizeChanged()
		{
			FormTool.MaximizeControl(m_TreeList);
			FormTool.MaximizeControlWidth(m_TreeList, 20);
		}


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
				// Spaltenköpfe übersetzen
				m_Proxy.Columns[0].Caption = Connection.Tables["DriverProfile"]["DisplayName"].Display;
				m_Proxy.Columns[1].Caption = Connection.Tables["AppServerGotDriverProfile"]["ProfileStateProduction"].Display;
				m_Proxy.Columns[2].Caption = Connection.Tables["AppServerGotDriverProfile"]["ProfileStateShadow"].Display;
				m_Proxy.Columns[3].Caption = Connection.Tables["AppServerGotDriverProfile"]["ChgNumber"].Display;

				// Liste laden
				_LoadList();
			}
			finally
			{
			}
		}


		private void _LoadList()
		{

			const int ConstDisplayName = 0;
			const int ConstProfileStateProduction = 1;
			const int ConstProfileStateShadow = 2;
			const int ConstChgNumber = 3;

			using (new UpdateHelper(m_TreeList))
			{
				m_Proxy.Clear();

				// Daten holen und prüfen
				ISingleDbObject dbobject = m_MainActivator.DbObject;

				if (dbobject == null) return;

                var runner = Session.Resolve<IStatementRunner>();
                using (IDataReader reader = new CachedDataReader(runner.SqlExecute("SDL-FormAppServerDriverProfile", new List<QueryParameter>()
                    {
                        new QueryParameter("UID_ApplicationServer", ValType.String, FormTool.GetValueSafe(dbobject, "UID_ApplicationServer", ""))
                    })))
                {
                    while (reader.Read())
					{
						ITreeListNode node = m_Proxy.AddNode(reader.GetString(ConstDisplayName), (int)StockImage.DriverProfile);
						m_Proxy.AddItem(node, reader.GetString(ConstProfileStateProduction));
						m_Proxy.AddItem(node, reader.GetString(ConstProfileStateShadow));
						m_Proxy.AddItem(node, reader.GetString(ConstChgNumber));
					}
				}
			}
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.ITreeListControl m_TreeList = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration

	}
}

