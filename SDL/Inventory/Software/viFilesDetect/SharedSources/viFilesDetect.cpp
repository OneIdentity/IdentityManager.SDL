// viFilesDetect.cpp : Defines the entry point for the application.
//

#include "..\SharedInclude\stdafx.h"
#include "..\SharedInclude\CviFileDetect.h"
#include "..\SharedInclude\viParamList.h"
#include "..\SharedInclude\viDialogMain.h"
#include "..\SharedInclude\viHelper.h"

#include <comdef.h>
#include <stdio.h>

BOOL ProcessCMDLine( CviFileDetect * pFileDetect, LPCSTR lpCmdLine );
BOOL ExpandFilterLists( CviParamList * pParamList );
LPTSTR ProcessFilterFromFile(LPCTSTR strFileName);
BOOL ShowParameterErrors( void );
BOOL DumpParameterErrors( void );

#ifdef _WINDOWS

	int APIENTRY WinMain(HINSTANCE hInstance,
						 HINSTANCE hPrevInstance,
						 LPSTR     lpCmdLine,
						 int       nCmdShow)
	{
 		CviFileDetect cFileDetect;

		g_cMsgColl.m_hInstance = hInstance;

		if ( g_cDialogMain.Create() )
		{
			//cDialogMain.Show();
		}

		if ( ProcessCMDLine( &cFileDetect, lpCmdLine ) )
		{
			if ( ! cFileDetect.Run() )
			{
				if ( cFileDetect.GetQuiet() )
					DumpParameterErrors();
				else
					ShowParameterErrors();
			}
		}
		else
		{
			if ( cFileDetect.GetQuiet() )
					DumpParameterErrors();
				else
					ShowParameterErrors();
		}
		
		return 0;
	}
#else

	int main(int argc, char* argv[])
	{
	 	CviFileDetect cFileDetect;
		CviString     cstrCmdLine;
		INT           iPos;

		g_cMsgColl.m_hInstance = GetModuleHandle( NULL );

		cstrCmdLine = GetCommandLine();
		
		iPos = cstrCmdLine.Find(" ", 0);

		if (iPos>-1)
		{
			cstrCmdLine.Delete(0, iPos + 1);
		}
		else
		{
			cstrCmdLine = "";
		}

		if ( g_cDialogMain.Create() )
		{
			//cDialogMain.Show();
		} 

		if ( ProcessCMDLine( &cFileDetect, cstrCmdLine.operator LPCTSTR() ) )
		{
			if ( ! cFileDetect.Run() )
			{
				DumpParameterErrors();
			}
		}
		else
		{
			DumpParameterErrors();
		}
		return 0;
	}
#endif

BOOL ProcessCMDLine( CviFileDetect * pFileDetect, LPCSTR lpCmdLine )
{
	BOOL         bRetVal;
	CviParamList cParamList;	
	LPCTSTR		 strParam;
	CviString	 cMsg;

	UFM_TRY
	{
		// parse the commandline
		bRetVal = cParamList.ProcessCMDLine(lpCmdLine);

		if (! bRetVal)
			UFM_LEAVE;

		if ( cParamList.GetCount() == 0 )
		{
			g_cMsgColl.Add(110, g_cMsgColl.GetResourceString( IDS_STRING_DE_110 ) );
			bRetVal = FALSE;
			UFM_LEAVE;
		}

		strParam = cParamList.GetIndex(0)->operator LPCTSTR();

		if ( strParam[0] == '/' )
		{
			g_cMsgColl.Add(110, g_cMsgColl.GetResourceString( IDS_STRING_DE_110 ) );
			bRetVal = FALSE;
			UFM_LEAVE;
		}

		// Quiet
		strParam = cParamList.GetParamData( _T("/Quiet"));

		if (strParam)
		{
			pFileDetect->SetQuiet( TRUE );
		}
		else
		{
			pFileDetect->SetQuiet( FALSE );
		}
		
		cParamList.RemoveParameter( _T("/Quiet") );

		// expand the filterlist
		bRetVal = ExpandFilterLists( &cParamList );

		if (! bRetVal)
			UFM_LEAVE;

		cParamList.DumpCollection();

		// now handle the parameters

		// FileName
		strParam = cParamList.GetIndex(0)->operator LPCTSTR();

		if (strParam)
			bRetVal = pFileDetect->OutFileName( strParam );
		else
			bRetVal = FALSE;
		
		if (! bRetVal)
			UFM_LEAVE;

		cParamList.RemoveParameter(0UL);


		// Drives
		strParam = cParamList.GetParamData( _T("/Drive:") );

		if (strParam)
			bRetVal = pFileDetect->Drives( strParam );
		else
			bRetVal = pFileDetect->Drives( _T("*") );
		
		if (! bRetVal)
			UFM_LEAVE;

		cParamList.RemoveParameter( _T("/Drive:") );


		// BaseDir
		strParam = cParamList.GetParamData( _T("/BaseDir:") );

		if (strParam)
			bRetVal = pFileDetect->SetBaseDirectory( strParam );

		if (! bRetVal)
			UFM_LEAVE;

		cParamList.RemoveParameter( _T("/BaseDir:") );



		// Files
		strParam = cParamList.GetParamData( _T("/Files:"));

		if (strParam)
			bRetVal = pFileDetect->SetFiles( strParam );
		else
			bRetVal = pFileDetect->SetFiles( _T("+*.exe|+*.com") );
		
		if (! bRetVal)
			UFM_LEAVE;

		cParamList.RemoveParameter( _T("/Files:") );


		// Dirs
		strParam = cParamList.GetParamData( _T("/Dirs:"));

		if (strParam)
			bRetVal = pFileDetect->SetDirectories( strParam );
		else
			bRetVal = pFileDetect->SetDirectories( _T("+*") );
		
		if (! bRetVal)
			UFM_LEAVE;

		cParamList.RemoveParameter( _T("/Dirs:") );

		// Get ( with data to determine )
		strParam = cParamList.GetParamData( _T("/Get:"));

		if (strParam)
			bRetVal = pFileDetect->GetData( strParam );
		else
			bRetVal = pFileDetect->GetData( _T("NRIB") );
		
		if (! bRetVal)
			UFM_LEAVE;

		cParamList.RemoveParameter( _T("/Get:") );


		// Priority ( with data to determine )
		strParam = cParamList.GetParamData( _T("/P:"));

		if (strParam)
			bRetVal = pFileDetect->Priority( strParam );
		
		if (! bRetVal)
			UFM_LEAVE;

		cParamList.RemoveParameter( _T("/P:") );

		// EXE
		strParam = cParamList.GetParamData( _T("/Exe"));

		if (strParam)
		{
			pFileDetect->ExecutableOnly( TRUE );
		}
		else
		{
			pFileDetect->ExecutableOnly( FALSE );
		}
		
		if (! bRetVal)
			UFM_LEAVE;

		cParamList.RemoveParameter( _T("/Exe") );

		
		// -------- all parameters processed -----------

		// process unknown parameters
		while( cParamList.GetCount() > 0 )
		{
			// format the message
			cMsg.Format(g_cMsgColl.GetResourceString( IDS_STRING_DE_108 ),  cParamList.GetIndex(0)->operator LPCTSTR() );

			// Add to viMessageCollection
			g_cMsgColl.Add(108, cMsg.operator LPCTSTR() );

			// remove this from Parameterlist
			cParamList.RemoveParameter(0UL);

			bRetVal = FALSE;
		}
	}
	UFM_FINALLY
	{
		
	}
	
	return bRetVal;
}


BOOL ExpandFilterLists( CviParamList * pParamList )
{
	LPCTSTR strParam;
	LPTSTR  strNewData;
	BOOL    bRetVal = TRUE;
	ULONG   iPos;

	strParam = pParamList->GetParamData( _T("/Files:") );

	if (strParam)
	{
		if (strParam[0] == _T('@'))
		{
			strParam++;

			strNewData = ProcessFilterFromFile( strParam );

			if (strNewData)
			{
				iPos = pParamList->FindParam( _T("/Files:") );

				if ( iPos != -1)
				{
					// set as new parameter
					*(pParamList->GetIndex(iPos)) = _T("/Files:");
					*(pParamList->GetIndex(iPos)) += strNewData;
				}

				UFM_FREE( strNewData );
			}
			else
			{
				bRetVal = FALSE;

			}
		}
	}
	
	strParam = pParamList->GetParamData( _T("/Dirs:") );

	if (strParam)
	{
		if (strParam[0] == _T('@'))
		{
			strParam++;

			strNewData = ProcessFilterFromFile( strParam );

			if (strNewData)
			{
				iPos = pParamList->FindParam( _T("/Dirs:") );

				if ( iPos != -1)
				{
					// set as new parameter
					*(pParamList->GetIndex(iPos)) = _T("/Dirs:");
					*(pParamList->GetIndex(iPos)) += strNewData;
				}

				UFM_FREE( strNewData );
			}
			else
			{
				bRetVal = FALSE;

			}
		}
	}

	return bRetVal;
}


/********************************************************************
 *
 * The returned String must be released with free()
 *
 \*******************************************************************/
LPTSTR ProcessFilterFromFile(LPCTSTR strFileName)
{
	FILE *pFile = NULL;
	TCHAR vBuffer[2048];
	CviString cString;
	CviString cStringWork;
	BOOL      bFirst = TRUE;
	LPTSTR    lpszReturn = NULL;

	pFile = fopen(strFileName, _T("r"));

	if (pFile)
	{
		// initialize the
		cString = _T("");

		while( fgets( vBuffer, 2048, pFile ) > NULL )
		{
			cStringWork = vBuffer;

			cStringWork.TrimLeft();
			cStringWork.TrimRight();

			if ( ! cStringWork.IsEmpty() )
			{
				if (bFirst)
				{
					bFirst = FALSE;
					cString += cStringWork;
				}
				else
				{
					cString += _T('|');
					cString += cStringWork;
				}
			}
		}

		fclose(pFile);

		lpszReturn  = _tcsdup( cString.operator LPCTSTR() );
	}
	else
	{
		CviString cstrError;
		cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_107 ), strFileName, GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );
		g_cMsgColl.Add( 107, cstrError.operator LPCTSTR() );
	}

	return lpszReturn;
}

BOOL ShowParameterErrors( )
{
	CviString cstrMsg;
	ULONG     iPos;

	if ( g_cMsgColl.Count() > 0)
	{
		cstrMsg = "";

		for (iPos=0; iPos<g_cMsgColl.Count(); iPos++)
		{
			cstrMsg += g_cMsgColl.Item(iPos)->MessageText();
			cstrMsg += _T("\n");
		}

		g_cMsgColl.Clear();

		::MessageBox(NULL, cstrMsg.operator LPCTSTR(), _T("viFilesDetect"), MB_OK);
	}
	
	return TRUE;
}

BOOL DumpParameterErrors( )
{
	CviString cstrMsg;
	ULONG     iPos;

	if ( g_cMsgColl.Count() > 0)
	{
		for (iPos=0; iPos<g_cMsgColl.Count(); iPos++)
		{
			puts( g_cMsgColl.Item(iPos)->MessageText() );
		}

		g_cMsgColl.Clear();
	}
	
	return TRUE;
}

