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

using VI.Base;
using VI.DB;
using VI.FormCustomizers;
using VI.FormTools;

using VIC = VI.Controls;

namespace SDL.Forms
{
	/// <summary>
	///
	/// </summary>
#if DEBUG
	public class FormBaseTreeRelatedToBaseTree : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormBaseTreeRelatedToBaseTree : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmBaseTreeRelatedToBaseTree.
		/// </summary>
		public FormBaseTreeRelatedToBaseTree()
		{ }

		#region Init & Done & Adaption & Designer stuff

		// In diese Region nichts einfügen, da diese vom Designer überschrieben wird.
		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.IHorizFormBar m_FormHeader = null;
		private VI.Controls.Interfaces.ITwoMemberRelationControl m_MemberRelation1 = null;
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

				m_FormHeader = (VI.Controls.Interfaces.IHorizFormBar)Form.Controls["FormHeader"];
				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_MemberRelation1 = (VI.Controls.Interfaces.ITwoMemberRelationControl)Form.Controls["MemberRelation1"];

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
			// TODO Design den Alien-Controls zuweisen


			// Basis aufrufen
			base.OnControlDesignChanged();
		}


		// In diese Region nichts einfügen, da diese vom Designer überschrieben wird.
		#region WindowsFormDesigner component initialization (Do not remove or rename this region!)

		/// <summary>
		/// Dummy Methode für den FormDesigner.
		/// </summary>
		private void InitializeComponent()
		{ }

		#endregion WindowsFormDesigner component initialization


		/// <summary>
		/// Diese Methode wird immer nach der Generierung des Formulars aufgerufen, um eine
		/// formularspezifische Initialisierung durchzuführen. Das Formular ist zu diesem Zeitpunkt
		/// noch nicht aktiviert und besitzt keine Connection, SqlFormmater, ...
		/// </summary>
		protected override void OnFormLoad()
		{
			// TODO Captions setzen


			// Basis aufrufen
			base.OnFormLoad();
		}

		/// <summary>
		/// Wird aufgerufen, wenn sich die Größe des MainFrames geändert hat.
		/// </summary>
		protected override void OnFormSizeChanged()
		{
			try
			{
				FormTool.MaximizeControl(m_MemberRelation1);
			}
			catch (Exception ex)
			{
				HandleException(ex);
			}
		}

		#endregion

		/// <summary>
		/// Wird aufgerufen, bevor der MainActivator mit der Aktivierung beginnt.
		/// Hier sollten alle von einem DB-Objekt abhängige Initialisierungen
		/// durchgeführt werden. Das Formular besitzt zu diesem Zeitpunkt die Connection
		/// und alle davon abhängigen Komponenten (SqlFormatter, Preprocessor-Auswertung, ...)
		/// </summary>
		private void MainActivator_OnActivating(object sender, System.EventArgs e)
		{
			// Aktivierung mit <null> verhindern
			ISingleDbObject dbobject = m_MainActivator.DbObject;

			if (dbobject == null) return;

			try
			{
				string pkcol = "UID_" + dbobject.Tablename;

				// TODO Whereklauseln setzen
				m_MemberRelation1.WhereClause =
					SqlFormatter.Comparison(pkcol, dbobject[pkcol].New.String, ValType.String, CompareOperator.NotEqual);

				m_MemberRelation1.RootFilterMemberWhereClause = "";
				m_MemberRelation1.RootFilterWhereClause = "";
				m_MemberRelation1.RootFilterTableName = "";

				switch (dbobject.Tablename.ToLowerInvariant())
				{
					case "aerole":
						m_MemberRelation1.MNTableName = "AERoleRelatedToAERole";
						break;

					case "department":
						m_MemberRelation1.MNTableName = "DepartmentRelatedToDepartment";
						break;

					case "locality":
						m_MemberRelation1.MNTableName = "LocalityRelatedToLocality";
						break;

					case "org":
						m_MemberRelation1.MNTableName = "OrgRelatedToOrg";
						m_MemberRelation1.RootFilterTableName = "OrgRoot";
						m_MemberRelation1.RootFilterMemberWhereClause =
							SqlFormatter.UidComparison("UID_OrgRoot", "%UID_OrgRoot%");
						m_MemberRelation1.RootFilterWhereClause = "UID_OrgRoot in (select UID_OrgRoot from Org)";
						break;

					case "profitcenter":
						m_MemberRelation1.MNTableName = "ProfitCenterRelatedToProf";
						break;
				}

				m_MemberRelation1.MNBaseColumnName = pkcol;
			}
			finally
			{

			}
		}
	}
}

