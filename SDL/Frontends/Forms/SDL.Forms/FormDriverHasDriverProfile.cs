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
using VI.FormTools;
using VI.FormBase;
using VI.FormBase.Tasks;
using VI.ImageLibrary;
using VI.FormCustomizers;

namespace SDL.Forms
{
    /// <summary>
    /// Dieser Customizer beinhaltet die Funktionalität des Formulars:
    /// frmSoftwareTreiberProfile
    /// </summary>
#if DEBUG
    public class FormDriverHasDriverProfile : VI.FormTools.BaseCustomizerDesignSupport
#else
	public class FormDriverHasDriverProfile : VI.FormTools.BaseCustomizer
#endif
    {
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

                m_ChildRelation1 = (VI.Controls.Interfaces.ITwoChildRelationControl)Form.Controls["ChildRelation1"];
                m_HorizFormBar2 = (VI.Controls.Interfaces.IHorizFormBar)Form.Controls["HorizFormBar2"];
                m_MainActivator = (VI.Controls.ActivatorComponent)Form.Components["MainActivator"];
                m_MainPanel = (VI.Controls.Interfaces.IVIPanel)Form.Controls["MainPanel"];

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
            }
            catch (Exception ex)
            {
                // Fehler melden
                ExceptionMgr.Instance.HandleException(new FormCustomizerException(929000, ex), this);
            }
        }

        #endregion


        /// <summary>
        /// FormMethode NewProfile
        /// </summar>
        public void FormTask_NewProfile()
        {
            try
            {
                // Daten holen und prüfen
                ISingleDbObject dbobject = m_MainActivator.DbObject;

                if (dbobject == null) return;

                ISingleDbObject profile = Connection.CreateSingle("DriverProfile");

                profile.GetFK("UID_Driver").Parent = m_MainActivator.DbObject;

                NavigateTo(profile);
            }
            catch (Exception ex)
            {
                // Fehler melden
                ExceptionMgr.Instance.HandleException(
                    new FormCustomizerException(929001, ex, GetString("SDL_FormApplicationHasApplicationProfile_Task_LinkNewProfile").Replace("&", "")), this);
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

                // TODO Whereklauseln setzen
            }
            finally
            {
            }
        }


        protected override void OnFormLoad()
        {
            using (new UpdateHelper(Tasks))
            {
                Task task = Tasks["NewProfile"];
                task.Caption = "SDL_FormApplicationHasApplicationProfile_Task_LinkNewProfile";
                task.Enabled = true;
                task.StockImage = StockImage.DriverProfile;
                task.TaskMethod = FormTask_NewProfile;
            }
        }


        protected override void OnFormSizeChanged()
        {
            FormTool.StretchControl(m_ChildRelation1, ExtOrientation.Both, true);
        }


        #region Component declaration (Do not remove or rename this region!)

        private VI.Controls.ActivatorComponent m_MainActivator = null;
        private VI.Controls.Interfaces.IHorizFormBar m_HorizFormBar2 = null;
        private VI.Controls.Interfaces.ITwoChildRelationControl m_ChildRelation1 = null;
        private VI.Controls.Interfaces.IVIPanel m_MainPanel = null;

        #endregion Component declaration

    }
}



