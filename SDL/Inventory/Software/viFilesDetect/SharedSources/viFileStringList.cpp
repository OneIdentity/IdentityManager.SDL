// viFileStringList.cpp: implementation of the CviFileStringList class.
//
//////////////////////////////////////////////////////////////////////

#include "..\SharedInclude\stdafx.h"
#include "..\SharedInclude\viFileStringList.h"
#include "..\SharedInclude\viDirWalker_INC.h"
#include <COMDEF.H>
#include "..\SharedInclude\viDialogMain.h"
#include "..\SharedInclude\viHelper.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CviFileStringList::CviFileStringList()
{

}

CviFileStringList::~CviFileStringList()
{

}


BOOL  CviFileStringList::Add( LPCTSTR strText )
{
	CviString * pString;
	BOOL        bRetVal = FALSE;

	pString = new CviString( strText );

	if (pString)
	{
		bRetVal = m_cStringList.Add(pString);

		if (!bRetVal)
		{
			delete(pString);
		}
	}

	return bRetVal;
}
	
CviString * CviFileStringList::Line( ULONG ulPos )
{
	return m_cStringList.Item( ulPos );
}

void CviFileStringList::Clear( void )
{
	m_cStringList.Clear();
}

ULONG  CviFileStringList::Count( void )
{
	return m_cStringList.Count();
}

void CviFileStringList::DumpCollection( void )
{
	ULONG ulPos;

	if (Count() == 0)
	{
		VITRACE(_T("The FileStringList is empty.\n") );
	}
	else
	{
		for ( ulPos=0; ulPos < Count(); ulPos++)
		{
			VITRACE1(_T("%s\n"), Line(ulPos)->operator LPCTSTR() );
		}
	}
}

BOOL CviFileStringList::WriteToFile(LPCTSTR strFileName)
{
	ULONG       iPos;
	_bstr_t     bstrDummy;
	BOOL        bRetVal = TRUE;
	CviString * cstrLine;
	CviString   cstrTmpFileName;
	DWORD       dwWritten;
	HANDLE      hFile;
	
	g_cDialogMain.ShowText( strFileName );

	DoEvents();

	// build temporary filename
	cstrTmpFileName = strFileName;
	cstrTmpFileName += _T(".tmp");

	hFile = ::CreateFile( cstrTmpFileName,	// filename
						  GENERIC_WRITE,	// open for write
						  0,				// nofilesharing
						  NULL,             // Security descriptor
						  CREATE_NEW,       // Createtype
						  FILE_ATTRIBUTE_NORMAL, //fileattributes
						  NULL );           // no templatefile

	
	if (hFile != INVALID_HANDLE_VALUE)
	{

		// write unicode tag
		bRetVal = ::WriteFile( hFile, "\xFF\xFE",  2 * sizeof(char), &dwWritten, NULL );

		for (iPos=0; iPos<Count(); iPos++)
		{
			cstrLine = Line(iPos);

			bstrDummy = cstrLine->operator LPCTSTR();

			// now write to file
			bRetVal = ::WriteFile( hFile, (wchar_t*) bstrDummy, wcslen(bstrDummy) * sizeof(wchar_t), &dwWritten, NULL );

			if (bRetVal)
				bRetVal = ::WriteFile( hFile, L"\r\n", 2 * sizeof(wchar_t), &dwWritten, NULL );

			if ( ! bRetVal )
			{
				CviString cstrError;
				cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_112 ), cstrTmpFileName, GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );
				g_cMsgColl.Add( 112, cstrError.operator LPCTSTR() );
				bRetVal = FALSE;
				break;
			}
		}

		::CloseHandle(hFile);

		if (bRetVal)
		{
			// and last but not least rename the file
			bRetVal = MoveFileEx( cstrTmpFileName, strFileName, MOVEFILE_REPLACE_EXISTING );

			if ( ! bRetVal )
			{
				CviString cstrError;
				cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_112 ), strFileName, GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );
				g_cMsgColl.Add( 112, cstrError.operator LPCTSTR() );
				bRetVal = FALSE;
			}
		}
		else
		{
			DeleteFile(cstrTmpFileName);
		}

	}
	else
	{
		CviString cstrError;
		cstrError.Format( g_cMsgColl.GetResourceString( IDS_STRING_DE_107 ), strFileName, GetLastError(), GetErrorText(GetLastError()).operator LPCTSTR() );
		g_cMsgColl.Add( 107, cstrError.operator LPCTSTR() );
		
		bRetVal = FALSE;
	}

	return bRetVal;
}

