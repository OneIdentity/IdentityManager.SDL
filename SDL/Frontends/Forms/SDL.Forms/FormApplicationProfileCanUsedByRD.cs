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
using System.Data;
using System.Drawing;

using VI.DB;
using VI.Base;
using VI.Controls.Base;
using VI.FormTools;
using VI.FormCustomizers;

namespace SDL.Forms
{
	/// <summary>
	/// Dieser Customizer beinhaltet die Funktionalität des Formulars:
	/// FrmSoftwareAppProfileVerwendung
	/// </summary>

#if DEBUG
	public class FormApplicationProfileCanUsedByRD : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormApplicationProfileCanUsedByRD : VI.FormTools.BaseCustomizer
#endif
	{


		/// <summary>
		/// Defaultkonstruktor der Klasse FrmSoftwareAppProfileVerwendung.
		/// </summary>
		public FormApplicationProfileCanUsedByRD()
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

				m_HorizFormBar2 = (VI.Controls.Interfaces.IHorizFormBar)Form.Controls["HorizFormBar2"];
				m_lblHinweis = (VI.Controls.Interfaces.INetLabel)Form.Controls["lblHinweis"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_MemberRelation1 = (VI.Controls.Interfaces.ITwoMemberRelationControl)Form.Controls["MemberRelation1"];

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
				m_lblHinweis.BackColor = Color.Transparent;
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

				ISqlFormatter f = dbobject.Connection.SqlFormatter;

				string statement = string.Format("select UpdateWhereClause from DialogTableGroupRight where {0} and UID_DialogGroup in (select UID_DialogGroup from DialogUserInGroup where UID_DialogUser in (select UID_DialogUser from DialogUser where {1}))",
												 f.AndRelation(
													 f.Comparison("UID_DialogTable", "SDL-T-SDLDomain", ValType.String),
													 f.Comparison("CanEdit", true, ValType.Bool)
												 ),
												 f.Comparison("username", dbobject.Connection.User.Identifier, ValType.String));

				SqlExecutor exec = dbobject.Connection.CreateSqlExecutor((byte[])m_MainActivator.Variables[GenericPropertyDictionary.ConnectionPublicKey, null]);
				IDataReader datareader = null;

				using (datareader = exec.SqlExecute(statement))
				{
					statement = "select count(*) from SDLDOmain where " + SqlFormatter.UidComparison("UID_SDLDomain", dbobject["UID_SDLDomainRDOwner"].New.String);
					string wherest = "";

					while (datareader.Read())
					{
						string where = datareader.GetString(0).Trim();

						if (where == "")
						{
							wherest = "";
							break;
						}

						wherest = wherest.Length == 0 ? string.Format("({0})", where) :
								  string.Format("{0} or ({1})", wherest, where);
					}

					if (wherest != "") statement = statement + string.Format(" and ({0})", wherest);
				}

				object result = exec.SqlExecuteScalar(Connection.Variables.Replace(statement));

				if (result != null && Convert.ToInt32(result) > 0)
				{
					m_MemberRelation1.WhereClause = string.Format("(UID_SDLDomain in (select UID_SDLDomain from ApplicationServer) or {0}) and not (UID_SDLDomain in (select UID_SDLDomain from ApplicationServer Where {1}))",
													SqlFormatter.UidComparison("UID_ServerTAS", "",  CompareOperator.NotEqual),
													SqlFormatter.Comparison("IsCentralLibrary", true, ValType.Bool));
					m_lblHinweis.Visible = false;
				}
				else
				{
					m_MemberRelation1.WhereClause = string.Format("{0} = {1}", SqlFormatter.FormatValue(1, ValType.Int), SqlFormatter.FormatValue(2, ValType.Int));
					m_lblHinweis.Visible = true;
				}

			}
			finally
			{
			}
		}

		protected override void OnFormLoad()
		{
			m_lblHinweis.Visible = false;
			m_lblHinweis.Text = GetString("SDL_FormApplicationProfileCanUsedByRD_Message_NotTheOwner");
		}

		protected override void OnFormSizeChanged()
		{
			FormTool.MaximizeControl(m_MemberRelation1);
			m_lblHinweis.Width = m_MemberRelation1.Width;
		}


		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.IHorizFormBar m_HorizFormBar2 = null;
		private VI.Controls.Interfaces.INetLabel m_lblHinweis = null;
		private VI.Controls.Interfaces.ITwoMemberRelationControl m_MemberRelation1 = null;
		private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

		#endregion Component declaration

	}
}

