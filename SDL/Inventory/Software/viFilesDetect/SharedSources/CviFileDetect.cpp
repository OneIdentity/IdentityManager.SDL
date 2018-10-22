// CviFileDetect.cpp: implementation of the CviFileDetect class.
//
//////////////////////////////////////////////////////////////////////

#include "..\SharedInclude\stdafx.h"
#include "Lmcons.h"
#include "Shellapi.h"
#include "Windows.h"
#include "..\SharedInclude\viDialogMain.h"
#include "..\SharedInclude\viHelper.h"
#include "..\SharedInclude\viFileImprint.h"
#include "..\SharedInclude\CviFileDetect.h"

typedef struct LANGANDCODEPAGE {
  WORD wLanguage;
  WORD wCodePage;
} tLangNCodePage;


ACCEPTDIR(AcceptDir)
{
	g_cDialogMain.ShowText( strDirectory );
	DoEvents();
	return 0;
}

CCollection<CviFileInfo> g_test(1000,100,true);

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CviFileDetect::CviFileDetect()
{
	m_bWait           = FALSE;
	m_bQuiet          = FALSE;
	m_dwPriorityClass = IDLE_PRIORITY_CLASS;

	SetAcceptDirFunction( AcceptDir ); 

	IgnoreErrors(TRUE);
}

CviFileDetect::~CviFileDetect()
{
}
/*
BOOL CviFileDetect::Files( LPCTSTR strFiles )
{
	return m_cDirWalker.SetFiles( strFiles );
}

CviFilePatternCollection * CviFileDetect::Files()
{
	return NULL;
}

BOOL CviFileDetect::Dirs( LPCTSTR strDirs )
{
	return m_cDirWalker.SetDirectories( strDirs );
}

CviFilePatternCollection * CviFileDetect::Dirs()
{
	return NULL;
}
*/

BOOL CviFileDetect::OutFileName(LPCTSTR strOutFileName)
{
	CviString  cstrWork;

	// spezialhandling for dir-only names

	cstrWork = strOutFileName;

	if (cstrWork.GetLength() < 2)
		return FALSE;

	if (cstrWork[cstrWork.GetLength()-1] == _T('\\'))
	{
		// its a directory-only name.
		SYSTEMTIME sTime;
		CviString  cstrTime;
		TCHAR      vBuffer[MAX_COMPUTERNAME_LENGTH + 1];
		DWORD      dwLen = MAX_COMPUTERNAME_LENGTH + 1;
		
		// get some data
		GetLocalTime( &sTime );
		GetComputerName( vBuffer, &dwLen );

		// format the name
		cstrTime.Format(_T("%04d%02d%02d%02d%02d%02d%s.xml"), 
			sTime.wYear, sTime.wMonth, sTime.wDay,
			sTime.wHour, sTime.wMinute, sTime.wSecond, vBuffer );

		cstrWork += cstrTime;
	}
	
	// copy to membervariable
	m_cstrFileName = cstrWork;

	return TRUE;
}


LPCTSTR CviFileDetect::OutFileName( void )
{
	return m_cstrFileName.operator LPCTSTR();
}

BOOL CviFileDetect::Drives(LPCTSTR strDrives)
{
	// copy the string
	m_cstrDrives = strDrives;

	// make uppercase
	m_cstrDrives.MakeUpper();

	return TRUE;
}

BOOL CviFileDetect::GetData(LPCTSTR strGetData)
{
	m_cstrGetData = strGetData;

	m_cstrGetData.MakeUpper();

	return TRUE;
}

BOOL CviFileDetect::Wait(BOOL bWait)
{
	m_bWait = bWait;

	return TRUE;
}

VOID CviFileDetect::SetQuiet(BOOL bQuiet)
{
	m_bQuiet = bQuiet;
}

BOOL CviFileDetect::GetQuiet(void)
{
	return m_bQuiet;
}


BOOL CviFileDetect::Run()
{
	BOOL bRetVal;

	UFM_TRY
	{
		/* BugList 5135
		bRetVal = _CheckDestinationFile();
		if ( !bRetVal) UFM_LEAVE;
		*/

		// set priority-class
		SetPriorityClass( GetCurrentProcess(), m_dwPriorityClass );

		bRetVal = _SearchFiles();

		if ( !bRetVal) UFM_LEAVE;

		bRetVal = _DeterineData();

		if ( !bRetVal) UFM_LEAVE;

		bRetVal = m_cXMLFile.WriteToFile( m_cstrFileName.operator LPCTSTR() );
	}
	UFM_FINALLY
	{

	}

	return bRetVal;
}

BOOL CviFileDetect::IsLocalHardDisk(TCHAR cDrive)
{
	TCHAR vRoot[4];
	UINT  iType;

	vRoot[0] = cDrive;
	vRoot[1] = _T(':');
	vRoot[2] = _T('\\');
	vRoot[3] = _T('\0');

	iType = GetDriveType( vRoot );
  
	return (iType == DRIVE_FIXED);
}


BOOL CviFileDetect::_SearchFiles( )
{
	BOOL bRetVal = TRUE;
	TCHAR          cDL;	// DriveLetter;
	INT            iPos;

	// cleanup the filescollection
	m_cFilesColl.Clear();

	if ( GetBaseDirectory() && ( _tcslen(GetBaseDirectory() )>0 ) )
	{
		// search in directory

		bRetVal = CviDirWalker::Run( &m_cFilesColl );

		// copy the returned errors
		g_cMsgColl.Appand( & MessageCollection() );
	}
	else
	{
		// search on drive
		if ( m_cstrDrives == _T('*') )
		{
			// process all lokal drives
			for ( cDL=_T('A'); cDL<=_T('Z'); cDL++)
			{
				bRetVal = _SearchFilesOnDrive( &m_cFilesColl, cDL, FALSE );
			}
		}
		else
		{
			// process special files only
			for( iPos=0; iPos<m_cstrDrives.GetLength(); iPos++ )
			{
				cDL = m_cstrDrives[iPos];

				bRetVal = _SearchFilesOnDrive( &m_cFilesColl, cDL, TRUE );
			}
		
		}
	}
	return TRUE;
}

BOOL CviFileDetect::_SearchFilesOnDrive( CviFilesCollection  * pFilesColl, TCHAR cDriveLetter, BOOL bShowErrors )
{
	BOOL bRetVal = TRUE;
	TCHAR vRoot[4];

	bRetVal = IsLocalHardDisk(cDriveLetter);

	if (bRetVal)
	{
		// format the rootdir
		vRoot[0] = cDriveLetter;
		vRoot[1] = _T(':');
		vRoot[2] = _T('\\');
		vRoot[3] = _T('\0');

		// set the rootdir
		/* m_cDirWalker. */	SetBaseDirectory( vRoot );

		bRetVal = /*m_cDirWalker. */ CviDirWalker::Run( pFilesColl );

		// copy the returned errors
		g_cMsgColl.Appand( & /*m_cDirWalker. */ MessageCollection() );
	}
	else
	{
		if (bShowErrors)
		{
			CviString cstrError;

			cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_101 ), cDriveLetter);
			g_cMsgColl.Add(101, cstrError.operator LPCTSTR() );
			bRetVal = FALSE;
		}
	}

	return bRetVal;
}

BOOL CviFileDetect::_DeterineData()
{
	ULONG iPos;

	// cleanup the filelist
	m_cXMLFile.Clear();

	// add XML-FileHeader
	m_cXMLFile.Add(_T("<?xml version='1.0' encoding=\"UTF-16\"?>") );

	// add head of AppDetect-Section
	_XMLAddAppDetect();

	if ( m_cFilesColl.Count() == 0 )
	{
		g_cMsgColl.Add(114, g_cMsgColl.GetResourceString( IDS_STRING_DE_114 ), mpInfo);
	}
	else
	{
		// process every file
		for( iPos=0; iPos<m_cFilesColl.Count(); iPos++ )
		{
			__try
			{
				_XMLProcessFile( m_cFilesColl.Item(iPos) );
			}
			__except( EXCEPTION_EXECUTE_HANDLER ) 
			{
				TCHAR szBuffer[2048];
				_stprintf(szBuffer, g_cMsgColl.GetResourceString( IDS_STRING_DE_115 ), m_cFilesColl.Item(iPos)->FullName() );
				g_cMsgColl.Add(115, szBuffer, mpInfo );
			}

		}
	}

	_XMLAddErrorReport();

	// Add the tail of the AppDetect-Section
	m_cXMLFile.Add( _T("</AppDetect>") );

	return TRUE;
}


BOOL CviFileDetect::_XMLAddAppDetect()
{
	SYSTEMTIME sTime;
	TCHAR      vComputer[MAX_COMPUTERNAME_LENGTH + 1];
	DWORD      dwLenComputer = MAX_COMPUTERNAME_LENGTH + 1;
	TCHAR      vUser[UNLEN + 1];
	DWORD      dwLenUser = UNLEN + 1;
	CviString  cstrTime;
	CviString  cstrXMLLine;


	// get some data
	GetLocalTime( &sTime );
	GetComputerName( vComputer, &dwLenComputer );
	GetUserName( vUser, &dwLenUser );

	// format the time
	cstrTime.Format(_T("%04d%02d%02d%02d%02d%02d"), 
			sTime.wYear, sTime.wMonth, sTime.wDay,
			sTime.wHour, sTime.wMinute, sTime.wSecond );

	cstrXMLLine.Format(_T("<AppDetect ComputerName=\"%s\" UserName=\"%s\" ProcessTime=\"%s\">"),
							vComputer, vUser, cstrTime.operator LPCTSTR() );

	m_cXMLFile.Add( cstrXMLLine.operator LPCTSTR() );

	return TRUE;
}

BOOL CviFileDetect::_XMLAddErrorReport()
{
	ULONG iPos;
	CviString    cstrWork;
	CviMessage * pMessage;
	CviString    cstrType;

	// insert ErrorReport-section head
	m_cXMLFile.Add( _T("   <ErrorReport>") );

	// insert all errormessages
	for( iPos=0; iPos<g_cMsgColl.Count(); iPos++ )
	{
		pMessage= g_cMsgColl.Item(iPos);

		switch( pMessage->Priority() )
		{
		case mpInfo:    cstrType = g_cMsgColl.GetResourceString( IDS_STRING_DE_102 );    break;
		case mpWarning: cstrType = g_cMsgColl.GetResourceString( IDS_STRING_DE_103 ); break;
		case mpError:   cstrType = g_cMsgColl.GetResourceString( IDS_STRING_DE_104 );   break;
		default:        cstrType = g_cMsgColl.GetResourceString( IDS_STRING_DE_105 );
		}

		cstrWork.Format(_T("      <Message Type=\"%s\" Number=\"%d\" Text=\"%s\"/>"), 
			cstrType.operator LPCTSTR(), pMessage->Number(), pMessage->MessageText() );

		m_cXMLFile.Add( cstrWork.operator LPCTSTR() );
	}

	// insert ErrorReport-section tail
	m_cXMLFile.Add( _T("   </ErrorReport>") );

	// clear the MessageCollection;
	g_cMsgColl.Clear();
	
	return TRUE;
}

BOOL CviFileDetect::_XMLProcessFile( CviFileInfo * pFileInfo )
{
	BOOL bRetVal;
	
	// process displayoutput
	g_cDialogMain.ShowText( pFileInfo->FullName() );
	DoEvents();

	__try
	{
		// insert the File-Header
		m_cXMLFile.Add( _T("   <File>") );

		if (m_cstrGetData.Find( _T("N"), 0) >= 0)
		{
			// process nameinformation
			bRetVal = _XMLProcessFile_Name( pFileInfo );
		}
		
		if (m_cstrGetData.Find( _T("R"), 0) >= 0)
		{
			// process Resource-Information
			bRetVal = _XMLProcessFile_Resource( pFileInfo );
		}


		if (m_cstrGetData.Find( _T("I"), 0) >= 0)
		{
			// process Icon-Information
			bRetVal = _XMLProcessFile_IconImprint( pFileInfo );
		}

		if (m_cstrGetData.Find( _T("B"), 0) >= 0)
		{
			// process Binary-Information
			bRetVal = _XMLProcessFile_BinImprint( pFileInfo );
		}

	}
	__finally
	{
		// insert the tail of File-Section
		m_cXMLFile.Add( _T("   </File>") );
	}


	return TRUE;
}


BOOL CviFileDetect::_XMLProcessFile_Name( CviFileInfo * pFileInfo )
{
	CviString cstrXMLLine;
	CviString cstrFileName;
	CviString cstrPathName;

	cstrFileName = pFileInfo->FileName();
	cstrPathName = pFileInfo->PathName();

	_MakeXMLConformeString( &cstrFileName );
	_MakeXMLConformeString( &cstrPathName );

	cstrXMLLine.Format( _T("      <Name FileName=\"%s\" PathName=\"%s\" Size=\"%d\"/>"),
						cstrFileName.operator LPCTSTR(), cstrPathName.operator LPCTSTR(), pFileInfo->GetFileSize() );

	m_cXMLFile.Add( cstrXMLLine.operator LPCTSTR() );

	return TRUE;
}

BOOL CviFileDetect::_XMLProcessFile_Resource( CviFileInfo * pFileInfo )
{
	DWORD				ignored = 0, size;
	BYTE              * pBuffer;
	tLangNCodePage		*pLNCPage = NULL;
	TCHAR				vSubBlockName[256];
	CviString           cstrResource;
	BOOL                bOk;
	UINT			    InfoSize;
	TCHAR               vDummy[MAX_PATH+1];

	// Copy the FileName
	_tcscpy(vDummy, pFileInfo->FullName() );

	size = ::GetFileVersionInfoSize( vDummy, &ignored );

	cstrResource = _T("");
	
	if (size > 0)
	{
		// set Reource Section
		m_cXMLFile.Add( _T("      <Resources>"));

		pBuffer = (BYTE*) malloc(size + 1);

		if (pBuffer)
		{
			// load the version-Information
			bOk =::GetFileVersionInfo( vDummy, ignored, size, pBuffer);	 // param 2 ignored

			// query the version-infos
			bOk = VerQueryValue(pBuffer, _T("\\VarFileInfo\\Translation"), (LPVOID*)&pLNCPage, &InfoSize);

			if (pLNCPage && InfoSize && bOk)
			{
				// format languagebuffer
				_stprintf(vSubBlockName, _T("\\StringFileInfo\\%04X%04X"), pLNCPage[0].wLanguage, pLNCPage[0].wCodePage);

				// Query Comments
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("Comments"));

				// Query CompanyName
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("CompanyName"));

				// Query FileDescription
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("FileDescription"));

				// Query FileVersion
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("FileVersion"));

				// Query InternalName
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("InternalName"));

				// Query LegalCopyright
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("LegalCopyright"));

				// Query LegalTrademarks
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("LegalTrademarks"));

				// Query OriginalFileName
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("OriginalFilename"));

				// Query ProductName
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("ProductName"));

				// Query ProductVersion
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("ProductVersion"));

				// Query PrivateBuild
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("PrivateBuild"));

				// Query SpecialBuild
				_XMLProcessFile_Resource_Value( cstrResource, vSubBlockName, pBuffer, _T("SpecialBuild"));
		
			}			
			
			free(pBuffer);

		} // end if(pBuffer)

		// close resource section
		m_cXMLFile.Add( _T("      </Resources>"));
	}

	return TRUE;
}

BOOL CviFileDetect::_XMLProcessFile_Resource_Value( CviString & pstrResource, LPCTSTR strLang, BYTE * pBuffer, LPCTSTR strResource )
{
	TCHAR	  vSubBlockName[256];
	LPVOID	  pVersionInfo = NULL;
	UINT	  InfoSize     = 0;
	CviString cstrWork;
	CviString cstrVersionInfo;
	BOOL      bOk;

	// combine the full resource path
	_stprintf(vSubBlockName, _T("%s\\%s"), strLang, strResource);

	// query the value
	bOk = VerQueryValue(pBuffer, vSubBlockName, &pVersionInfo, &InfoSize);

	// data exits ?
	if (InfoSize && pVersionInfo && bOk)
	{
		// copy th CviString
		cstrVersionInfo = (LPCTSTR) pVersionInfo;

		// make XML-String
		_MakeXMLConformeString( &cstrVersionInfo );

		// format resultstring
		cstrWork.Format( _T("         <Resource Name=\"%s\" Value=\"%s\"/>"), strResource, cstrVersionInfo.operator LPCTSTR() );

		m_cXMLFile.Add( cstrWork.operator LPCTSTR() );

	}

	return TRUE;
}


BOOL CviFileDetect::_MakeXMLConformeString( CviString * cstrLine )
{
	ULONG   iPos, iCount, iPos2;
	LPTSTR  strWork;
	TCHAR   cChar;

	strWork = _tcsdup( cstrLine->operator LPCTSTR() );

	if (strWork)
	{
		strWork[0] = _T('\0');

		iCount = cstrLine->GetLength();

		// copy all legal characters
		for( iPos=0, iPos2=0; iPos<iCount; iPos++)
		{
			// get the char
			cChar = *(cstrLine->operator LPCTSTR() + iPos);

			if ( ((unsigned char) cChar >= _T(' ')) )
			{
				strWork[iPos2++] = cChar;
			}
			else
			{
				VITRACE2(_T("Illegale Character '%c' [0x%02X].\n"), cChar, cChar );
			}
		}

		// appand the terminating NULL
		strWork[iPos2] = _T('\0');

		// copy the workstring
		(*cstrLine) = strWork;

		// replace special-chars
		cstrLine->Replace( _T("&"), _T("&amp;") );
		cstrLine->Replace( _T("\""), _T("&quot;"));
		cstrLine->Replace( _T("<"), _T("&lt;") );
		cstrLine->Replace( _T(">"), _T("&gt;") );

		// release the workstring
		free(strWork);
	}

	return TRUE;
}

BOOL CviFileDetect::_XMLProcessFile_IconImprint( CviFileInfo * pFileInfo )
{
	HICON vhIcon[1];		// vector for iconhandles
	ICONINFO IconInfo;      // icon-info-structure
	BOOL bOk;                
	LONG iRet;
	ULONG ulIconCRC;
	CviString cstrWork;

	// try to extract the icon
	iRet = ::ExtractIconEx( pFileInfo->FullName(), 0, vhIcon, NULL, 1 );

	// no icon found 
	if ( iRet != 1)
	{
		return TRUE;
	}
	
	// get infostructure from icon
	bOk = GetIconInfo( vhIcon[0], &IconInfo );

	// process CRC
	ulIconCRC = _GetCRCFromIcon( IconInfo.hbmColor );

	// fomat the XMLString
	cstrWork.Format( _T("      <IconImprint Imprint=\"%08X\"/>"), ulIconCRC);

	// appand to out-file
	bOk = m_cXMLFile.Add( cstrWork.operator LPCTSTR() );

	// cleanup the memory
	DestroyIcon(vhIcon[0]);

	return bOk;
}

ULONG CviFileDetect::_GetCRCFromIcon( HBITMAP hBitmap )
{
	unsigned char vBuffer[2048];
	LONG  iRet;
	ULONG ulCRC = 5381; 
	LONG  iPos;

	// get bitmapbuffer from icon
	iRet = GetBitmapBits( hBitmap, 2048, &vBuffer );

	// initialize the CRC
	ulCRC=5381L;

	// itterate through buffer
	for(iPos=0; iPos<iRet; iPos++)
	{
		ulCRC = ((ulCRC << 5) + ulCRC) + vBuffer[iPos];
	}

	return ulCRC;
}
/*
BOOL CviFileDetect::_XMLProcessFile_BinImprint( CviFileInfo * pFileInfo )
{
	CviString cstrWork;
	char      vImprint[512];
	TCHAR     vHexString[1025];
	size_t    iRead;
	
	char      vHexZahl[10];
	FILE    * pFile;
	LONG      iDest;
	LONG      iStep = 10;
	LONG      iPos = 0;
	LONG      iSeek;
	LONG      iIteration;

	CviFileInfo * pFI;

	// remove this line to enable BinImprint
	return TRUE;

	pFile = fopen( pFileInfo->FullName(), _T("rb") );

	if (pFile)
	{
		// seek to pos 10
		if (fseek(pFile, 10, SEEK_SET)==0)
		{
			// convert the buffer to Hex
			iDest = 0;
			iIteration = 0;

			do
			{
				//iPos = ftell( pFile );

				//VITRACE3(_T("readpos %8d x %8d x %8d.\n"), iPos , iIteration, iStep );

				// read 1 Byte
				iRead = fread(vImprint, 1, 1, pFile);

				if (iRead)
				{
					sprintf( vHexZahl, "%02X", vImprint[0] );

					vHexString[iDest*2]   = vHexZahl[0];
					vHexString[iDest*2+1] = vHexZahl[1];

					iDest++;

					iIteration++;

					if ( iIteration == 100)
					{
						iStep*=10;
						iIteration = 0;
					}

					iSeek = fseek(pFile, iStep-1, SEEK_CUR);
				}
			}
			while ((iRead==1) && (iDest<128) && (iSeek==0) );

			// appand the terminating zero
			vHexString[iDest] = '\0';

			if (iDest>64)
			{
				pFI = pFileInfo->Copy();

				if (! g_test.Add( pFI, vHexString ) )
				{
					if ( _tcsicmp( g_test.Item(vHexString)->FileName(), pFileInfo->FileName() ) != 0)
					{
						VITRACE2(_T("-diffr-> %s\n         %s\n"),pFileInfo->FullName(), g_test.Item(vHexString)->FullName());
					}
					else
					{
						VITRACE2(_T("-equal-> %s\n         %s\n"),pFileInfo->FullName(), g_test.Item(vHexString)->FullName());
					}
				}

				cstrWork.Format(_T("<BinImprint Imprint=\"%s\"/>"), vHexString );

				m_cXMLFile.Add( cstrWork.operator LPCTSTR() );
			}
			else
			{
				VITRACE1(_T("-small-> %s\n         %s\n"), pFileInfo->FullName() );
			}

		}

		fclose(pFile);
	}

	return TRUE;
} */


// Version in Lib
BOOL CviFileDetect::_XMLProcessFile_BinImprint( CviFileInfo * pFileInfo )
{
	CviString cstrWork;
	TCHAR     vHexString[1025];

	bool      bOk;

	bOk = viGetFullImprint_FileName( pFileInfo->FullName(), vHexString, 1024);
	
	if (bOk)
	{
		cstrWork.Format(_T("      <BinImprint Imprint=\"%s\"/>"), vHexString );

		m_cXMLFile.Add( cstrWork.operator LPCTSTR() );
	}

	return TRUE;
}


BOOL CviFileDetect::Priority(LPCTSTR strPriority)
{
	if (( _tcsicmp(strPriority, _T("Normal")) == 0) ||
	    ( _tcsicmp(strPriority, _T("N")) == 0)) 
	{
		m_dwPriorityClass = NORMAL_PRIORITY_CLASS;
		return TRUE;
	}

	if (( _tcsicmp(strPriority, _T("Idle")) == 0) ||
	    ( _tcsicmp(strPriority, _T("I")) == 0)) 
	{
		m_dwPriorityClass = IDLE_PRIORITY_CLASS;
		return TRUE;
	}

	return FALSE;
}


BOOL CviFileDetect::_CheckDestinationFile()
{
	FILE * pFile;
	BOOL   bRetVal;

	pFile = fopen( m_cstrFileName.operator LPCTSTR(), _T("w") );

	if (pFile)
	{
		fclose(pFile);
		bRetVal = TRUE;
	}
	else
	{
		CviString cstrError;
		cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_109 ), m_cstrFileName.operator LPCTSTR(), GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );

		g_cMsgColl.Add( 109, cstrError.operator LPCTSTR() );

		bRetVal = FALSE;
	}
	
	return bRetVal;
}

