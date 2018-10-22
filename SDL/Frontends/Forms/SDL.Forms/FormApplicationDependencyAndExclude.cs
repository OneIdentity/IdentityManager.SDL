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
using VI.Base;
using VI.FormTools;
using VI.FormCustomizers;

using VIC = VI.Controls;

namespace SDL.Forms
{
	/// <summary>
	///
	/// </summary>
#if DEBUG
	public class FormApplicationDependencyAndExclude : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormApplicationDependencyAndExclude : VI.FormTools.BaseCustomizer
#endif
	{
		/// <summary>
		/// Defaultkonstruktor der Klasse FrmApplicationDependsOnApp.
		/// </summary>
		public FormApplicationDependencyAndExclude()
		{ }

		#region Init & Done & Adaption & Designer stuff

		// In diese Region nichts einfügen, da diese vom Designer überschrieben wird.
		#region Component declaration (Do not remove or rename this region!)

		private VI.Controls.ActivatorComponent m_MainActivator = null;
		private VI.Controls.Interfaces.ITabControl m_TabControl = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage1 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage2 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage3 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage4 = null;
		private VI.Controls.Interfaces.ITabPage m_TabPage5 = null;
		private VI.Controls.Interfaces.ITwoMemberRelationControl m_MemberRelation1 = null;
		private VI.Controls.Interfaces.ITwoMemberRelationControl m_MemberRelation2 = null;
		private VI.Controls.Interfaces.ITwoMemberRelationControl m_MemberRelation3 = null;
		private VI.Controls.Interfaces.ITwoMemberRelationControl m_MemberRelationApplicationExcludeAppUIDApplication = null;
		private VI.Controls.Interfaces.ITwoMemberRelationControl m_MemberRelationApplicationExcludeDriverUIDApplication = null;
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

				m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
				m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];
				m_MemberRelation1 = (VI.Controls.Interfaces.ITwoMemberRelationControl)Form.Controls["MemberRelation1"];
				m_MemberRelation2 = (VI.Controls.Interfaces.ITwoMemberRelationControl)Form.Controls["MemberRelation2"];
				m_MemberRelation3 = (VI.Controls.Interfaces.ITwoMemberRelationControl)Form.Controls["MemberRelation3"];
				m_MemberRelationApplicationExcludeAppUIDApplication = (VI.Controls.Interfaces.ITwoMemberRelationControl)Form.Controls["MemberRelationApplicationExcludeAppUIDApplication"];
				m_MemberRelationApplicationExcludeDriverUIDApplication = (VI.Controls.Interfaces.ITwoMemberRelationControl)Form.Controls["MemberRelationApplicationExcludeDriverUIDApplication"];
				m_TabControl = (VI.Controls.Interfaces.ITabControl)Form.Controls["TabControl"];
				m_TabPage1 = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPage1"];
				m_TabPage2 = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPage2"];
				m_TabPage3 = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPage3"];
				m_TabPage4 = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPage4"];
				m_TabPage5 = (VI.Controls.Interfaces.ITabPage)Form.Controls["TabPage5"];

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
		/// Diese Methode wird immer nach der Generierung des Formulars aufgerufen, um eine
		/// formularspezifische Initialisierung durchzuführen. Das Formular ist zu diesem Zeitpunkt
		/// noch nicht aktiviert und besitzt keine Connection, SqlFormmater, ...
		/// </summary>
		protected override void OnFormLoad()
		{
			try
			{
				m_TabPage1.Caption = "SDL_FormApplicationDependencyAndExclude_TabPage_Parentapplications";
				m_TabPage2.Caption = "SDL_FormApplicationDependencyAndExclude_TabPage_Childapplications";
				m_TabPage3.Caption = "SDL_FormApplicationDependencyAndExclude_TabPage_Parentdrivers";
				m_TabPage4.Caption = "SDL_FormApplicationDependencyAndExclude_TabPage_Incompatibleapplications";
				m_TabPage5.Caption = "SDL_FormApplicationDependencyAndExclude_TabPage_Incompatibledrivers";
			}
			catch (Exception ex)
			{
				HandleException(ex);
			}
		}

		/// <summary>
		/// Wird aufgerufen, wenn sich die Größe des MainFrames geändert hat.
		/// </summary>
		protected override void OnFormSizeChanged()
		{
			try
			{
				FormTool.MaximizeControl(m_MemberRelation1);
				FormTool.MaximizeControl(m_MemberRelation2);
				FormTool.MaximizeControl(m_MemberRelation3);
				FormTool.MaximizeControl(m_MemberRelationApplicationExcludeAppUIDApplication);
				FormTool.MaximizeControl(m_MemberRelationApplicationExcludeDriverUIDApplication);
			}
			catch (Exception ex)
			{
				HandleException(ex);
			}
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

				// Inaktive dürfen nicht mehr zugeordnet werden
				m_MemberRelation1.WhereClause = string.Format("{0} or {1} in (select {2} from {4} where {3})",
												SqlFormatter.Comparison("IsInActive", false, ValType.Bool),
												SqlFormatter.FormatColumnname("UID_Application", true, ValType.String, FormatterOptions.None),
												SqlFormatter.FormatColumnname("UID_ApplicationParent", true, ValType.String, FormatterOptions.None),
												SqlFormatter.UidComparison("UID_ApplicationChild", FormTool.GetValueSafe(dbobject, "UID_Application", "")),
												"ApplicationDependsOnApp");

				m_MemberRelation2.WhereClause = string.Format("{0} or {1} in (select {2} from {4} where {3})",
												SqlFormatter.Comparison("IsInActive", false, ValType.Bool),
												SqlFormatter.FormatColumnname("UID_Application", true, ValType.String, FormatterOptions.None),
												SqlFormatter.FormatColumnname("UID_ApplicationChild", true, ValType.String, FormatterOptions.None),
												SqlFormatter.UidComparison("UID_ApplicationParent", FormTool.GetValueSafe(dbobject, "UID_Application", "")),
												"ApplicationDependsOnApp");

				m_MemberRelation3.WhereClause = string.Format("{0} or {1} in (select {2} from {4} where {3})",
												SqlFormatter.Comparison("IsInActive", false, ValType.Bool),
												SqlFormatter.FormatColumnname("UID_Driver", true, ValType.String, FormatterOptions.None),
												SqlFormatter.FormatColumnname("UID_DriverParent", true, ValType.String, FormatterOptions.None),
												SqlFormatter.UidComparison("UID_ApplicationChild", FormTool.GetValueSafe(dbobject, "UID_Application", "")),
												"ApplicationDependsOnDriver");

				m_MemberRelationApplicationExcludeAppUIDApplication.WhereClause =
					m_MemberRelationApplicationExcludeDriverUIDApplication.WhereClause = SqlFormatter.Comparison("IsInActive", false, ValType.Bool);
			}
			finally
			{
			}
		}

	}
}

