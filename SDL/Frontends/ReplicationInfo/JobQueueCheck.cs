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
using System.Windows.Forms;

using VI.Base;
using VI.DB;
using VI.DB.Scripting;
using VI.CommonDialogs;


namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Summary description for JobQueueCheck.
	/// </summary>
	public class JobQueueCheck
	{
		public JobQueueCheck()
		{
			//
			// TODO: Add constructor logic here
			//
		}

		public static bool ExistsCopyJobs( NodeType nodeType, string strUID_Server, string strUID_Profile )
		{
			ISingleDbObject dbObject;
			string strScript;
			bool bReturn = false;

			switch ( nodeType )
			{
				case NodeType.AppProfile:
					dbObject = clsMain.Instance.CurrentConnection.Connection.CreateSingle("ApplicationProfile");
					strScript = "VI_AE_ApplicationProfileCopyRunning";
					break;

				case NodeType.DrvProfile:
					dbObject = clsMain.Instance.CurrentConnection.Connection.CreateSingle("DriverProfile");
					strScript = "VI_AE_DriverProfileCopyRunning";
					break;

				case NodeType.MacType:
					dbObject = clsMain.Instance.CurrentConnection.Connection.CreateSingle("MachineType");
					strScript = "VI_AE_MachineTypeCopyRunning";
					break;

				default:
					return false;
			}

			ScriptRunner scr = new ScriptRunner(
				clsMain.Instance.CurrentConnection.Connection.Scripts["scripts"],
				dbObject );

			// Script Exists ???
			if ( scr.Class.HasMethod(strScript) )
			{
				bReturn = new DbVal( scr.Eval(strScript, new object[] { strUID_Server, strUID_Profile } ) ).Bool;
			}
			else
				bReturn = false;	// No script, no check

			return bReturn;
		}

		public static void RefreshProfileCopy( NodeType nodeType, string UID_Server, string UID_Profile, string ChgNrSoll)
		{
			ISingleDbObject oSgP = null;

			try
			{
				// Change mouse cursor
				Cursor.Current = Cursors.WaitCursor;

				switch ( nodeType )
				{
					case NodeType.AppProfile:
						// create the object
						oSgP = clsMain.Instance.CurrentConnection.Connection.CreateSingle( "AppServerGotAppProfile" );

						// fill primary keys
						oSgP["UID_ApplicationServer"].NewValue = UID_Server;
						oSgP["UID_Profile"].NewValue = UID_Profile;
						break;

					case NodeType.DrvProfile:
						// create the object
						oSgP = clsMain.Instance.CurrentConnection.Connection.CreateSingle( "AppServerGotDriverProfile" );

						// fill primary keys
						oSgP["UID_ApplicationServer"].NewValue = UID_Server;
						oSgP["UID_Profile"].NewValue = UID_Profile;
						break;

					case NodeType.MacType:
						// create the object
						oSgP = clsMain.Instance.CurrentConnection.Connection.CreateSingle( "AppServerGotMactypeInfo" );

						// fill primary keys
						oSgP["UID_ApplicationServer"].NewValue = UID_Server;
						oSgP["UID_MachineType"].NewValue = UID_Profile;
						break;

					default:

						throw new Exception( "Invalid nodeType " + nodeType.ToString() + " for _RefreshProfileCopy.");

				}

				// try to load
				oSgP.Load();

				// Change properties required for Update
				oSgP.PutValue("ProfileStateProduction", "EMPTY" );

				// Reverse the ChgNumber for MAC-Types
				if  ( nodeType == NodeType.MacType )
				{
					if (oSgP.GetValue("ChgNumber").Int > 0)
					{
						oSgP.PutValue("ChgNumber", - oSgP.GetValue("ChgNumber").Int );
					}
				}

				// now save the object
				oSgP.Save();


				// and now fire the event
				VI.DB.JobGeneration.JobGen.Generate( oSgP, "Copy2PAS" );
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( null, ex );
			}
			finally
			{
				Cursor.Current = Cursors.Default;
			}
		}



		public static void RefreshProfileCL2FDS( NodeType nodeType, string UID_Profile, string UID_Server, string Ident_Domain, IValueProvider vpCL)
		{
			IColDbObject colProfileCL;
			ISingleDbObject cProfileCL = null;
			ISingleDbObject oProfileFDS = null;

			ISqlFormatter fSQL = clsMain.Instance.CurrentConnection.Connection.SqlFormatter;

			try
			{
				// Change mousecursor
				Cursor.Current = Cursors.WaitCursor;

				switch ( nodeType )
				{
					case NodeType.AppProfile:
						// create the object
						oProfileFDS = clsMain.Instance.CurrentConnection.Connection.CreateSingle( "ApplicationProfile" );

						// fill primarykeys
						oProfileFDS["UID_Profile"].NewValue = UID_Profile;
						oProfileFDS.Load();

						// create the object
						colProfileCL = clsMain.Instance.CurrentConnection.Connection.CreateCol( "ApplicationProfile" );
						colProfileCL.Prototype["UID_Application"].NewValue = oProfileFDS["UID_Application"].New.String;
						colProfileCL.Prototype["Ident_OS"].NewValue = oProfileFDS["Ident_OS"].New.String;
						colProfileCL.Prototype["Ident_InstType"].NewValue = oProfileFDS["Ident_InstType"].New.String;
						colProfileCL.Prototype["Ident_DomainRD"].NewValue = vpCL.GetValue("Ident_Domain").String;

						break;

					case NodeType.DrvProfile:
						// create the object
						oProfileFDS = clsMain.Instance.CurrentConnection.Connection.CreateSingle( "DriverProfile" );

						// fill primarykeys
						oProfileFDS["UID_Profile"].NewValue = UID_Profile;
						oProfileFDS.Load();

						// create the object
						colProfileCL = clsMain.Instance.CurrentConnection.Connection.CreateCol( "DriverProfile" );
						colProfileCL.Prototype["UID_Driver"].NewValue = oProfileFDS["UID_Driver"].New.String;
						colProfileCL.Prototype["Ident_DomainRD"].NewValue = vpCL.GetValue("Ident_Domain").String;

						break;

					case NodeType.MacType:
						// create the object
						oProfileFDS = clsMain.Instance.CurrentConnection.Connection.CreateSingle( "MachineType" );

						// fill primarykeys
						oProfileFDS["UID_MachineType"].NewValue = UID_Profile;
						oProfileFDS.Load();

						// create the object
						colProfileCL = clsMain.Instance.CurrentConnection.Connection.CreateCol( "MachineType" );
						colProfileCL.Prototype["Ident_MachineType"].NewValue = oProfileFDS["Ident_MachineType"].New.String;
						colProfileCL.Prototype["Ident_DomainMachineType"].NewValue = vpCL.GetValue("Ident_Domain").String;

						break;

					default:
						throw new Exception( "Invalid nodeType " + nodeType.ToString() + " for _RefreshProfileCopy.");
				}

				// Source Coll Laden
				colProfileCL.Load();

				if ( colProfileCL.Count > 0 )
				{
					cProfileCL = colProfileCL[0].Create();

					if (nodeType == NodeType.MacType)
					{
						cProfileCL.PutValue("MakeFullCopy", true);
						cProfileCL.Custom.CallMethod("SvrCopy", "COPYCL2FDS", "", "", clsMain.Instance.CurrentConnection.Connection.LocalNow, Ident_Domain);
					}
					else
					{
						cProfileCL.Custom.CallMethod("SvrCopy", "COPYCL2FDS", "", "", clsMain.Instance.CurrentConnection.Connection.LocalNow, Ident_Domain, false);
					}
				}
			}
			catch ( Exception ex )
			{
				ExceptionDialog.Show( null, ex );
			}
			finally
			{
				Cursor.Current = Cursors.Default;
			}
		}
	}
}
