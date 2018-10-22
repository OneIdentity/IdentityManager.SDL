#include "..\SharedInclude\stdafx.h"
#include "..\SharedInclude\viHelper.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

void DoEvents()
{
	MSG message;

	while (::PeekMessage(&message, NULL, 0, 0, TRUE))
	{
		::TranslateMessage(&message);
		::DispatchMessage(&message);
	}
}


CviString & GetErrorText(DWORD dwErrorNr)
{
	static CviString cstrErrorText;
	LPVOID lpMsgBuf;

	FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | 
				   FORMAT_MESSAGE_FROM_SYSTEM | 
				   FORMAT_MESSAGE_IGNORE_INSERTS,
				   NULL,
				   dwErrorNr,
				   MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
				   (LPTSTR) &lpMsgBuf,
				   0,
				   NULL );

	cstrErrorText = (LPCTSTR) lpMsgBuf;

	cstrErrorText.TrimRight();
	
	// Free the buffer.
	LocalFree( lpMsgBuf );

	return cstrErrorText;
}

BOOL FileExists( LPCTSTR szFullFileName )
{
	HFILE		handle;
	OFSTRUCT	ofStruct;

	handle = OpenFile( szFullFileName, &ofStruct, OF_EXIST );

	return (handle > 0);
}

CviString & viGetTempFileName( LPCTSTR strDir, LPCTSTR strPrefix, LPCTSTR strExtension )
{
	TCHAR szBuffer[ MAX_PATH ];
	CviString cstrDir;
	static CviString cstrFullName;
	DWORD  dwTime;
	
	// copy directoryname
	cstrDir = strDir;

	// empty dir ? so get a name
	if ( cstrDir.IsEmpty() )
	{
		GetTempPath( MAX_PATH, szBuffer );
  		cstrDir = szBuffer;
	}

	dwTime = GetTickCount() & 0xFFFF;

	do
	{
		dwTime++;
		cstrFullName.Format(_T("%s%s%04XX.%s"), (LPCTSTR) cstrDir, (LPCTSTR) strPrefix, dwTime, strExtension);
	} while ( FileExists(cstrFullName) );

	return cstrFullName;
}

BOOL FileOlder( LPCTSTR szFullFileName, LPFILETIME lpCompareTime )
{
	HANDLE		handle;
//	FILETIME	CreateTime;
//	FILETIME    LastAccessTime;
	FILETIME    LastWriteTime;
	BOOL        bOk;
	LONG        lReturn = -1;   // local file is older

	handle = CreateFile( szFullFileName, GENERIC_READ, FILE_SHARE_READ, NULL,
							OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );

    if (handle != INVALID_HANDLE_VALUE)
    {
		bOk = GetFileTime( handle, NULL, NULL, & LastWriteTime );

        if (bOk)
        {
			FILETIME ftDummy = LastWriteTime;

			FileTimeToLocalFileTime( &ftDummy, &LastWriteTime );

			/*
			CTime t1(*lpCompareTime,0);
			CTime tc(CreateTime,0);
			CTime ta(LastAccessTime,0);
			CTime tw(LastWriteTime,0);

			TRACE(_T("   Compare: %s"), t1.FormatGmt("%Y.%m.%d %H:%M:%S\n") );
			TRACE(_T("    Create: %s"), tc.FormatGmt("%Y.%m.%d %H:%M:%S\n") );
			TRACE(_T("LastAccess: %s"), ta.FormatGmt("%Y.%m.%d %H:%M:%S\n") );
			TRACE(_T(" LastWrite: %s"), tw.FormatGmt("%Y.%m.%d %H:%M:%S\n") ); */


            lReturn = CompareFileTime( &LastWriteTime, lpCompareTime );

        }

        CloseHandle(handle);
    }
	else
	{
		//TRACE( _T("OpenFile '%s' failed!?!"), szFullFileName  );
	}

	return (lReturn < 0 ); // local file is older or file does not exits?
}
