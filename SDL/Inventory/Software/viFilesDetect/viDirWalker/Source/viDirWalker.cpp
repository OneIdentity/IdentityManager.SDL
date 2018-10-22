// viDirWalker.cpp: implementation of the CviDirWalker class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include <shellapi.h>
#include "viDirWalker.h"
#include "viFileInfo.h"
#include "viFilePattern.h"
#include "viCompStrCompare.h"

#include <iostream>
#include <fstream>

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

DWORD AbsoluteSeek(HANDLE, DWORD);
BOOL  IsExecutable( LPCTSTR strFileName );

using namespace std;

CviString & CviDirWalker::_GetErrorText(DWORD dwErrorNr)
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


void CviDirWalker::_DoEvents()
{
	MSG message;

	while (::PeekMessage(&message, NULL, 0, 0, TRUE))
	{
		::TranslateMessage(&message);
		::DispatchMessage(&message);
	}
}


CviDirWalker::CviDirWalker()
{
	// initialize membervariables
	m_bLowPriority  = FALSE;
	m_bIgnoreErrors = FALSE;
	m_bExeOnly		= FALSE;
	m_lBaseDirLen   = 0;
	m_pFilesCollection = NULL;

	m_pfGetHashValue = NULL;
	m_pfAcceptDir   = NULL;
	m_pfAcceptFile  = NULL;
	m_pfFoundFile    = NULL;

	
}

CviDirWalker::~CviDirWalker()
{

}

BOOL CviDirWalker::SetFiles( LPCTSTR strFileList )
{
	m_cplFiles.SetString( strFileList );

	return TRUE;
}

BOOL CviDirWalker::SetFiles( CviFilePatternCollection * pFiles )
{
	m_cplFiles.CopyFrom( pFiles );

	return TRUE;
}


BOOL CviDirWalker::SetDirectories( LPCTSTR strDirList )
{
	m_cplDirectories.SetString( strDirList );

	return TRUE;
}


BOOL CviDirWalker::SetDirectories( CviFilePatternCollection	 * pDirs )
{
	m_cplDirectories.CopyFrom( pDirs );

	return TRUE;
}


LPCTSTR CviDirWalker::GetFiles( void )
{
	return m_cplFiles.GetString();
}

LPCTSTR CviDirWalker::GetDirectories( void )
{
	return m_cplDirectories.GetString();
}


BOOL CviDirWalker::Run( CviFilesCollection * pFilesCollection )
{
	BOOL bReturn = FALSE;

	// copy the list to membervariabe
	m_pFilesCollection = pFilesCollection;
	m_cMsgCollection.Clear();

	// set prioritylowering
	if ( m_bLowPriority) SetPriorityClass( GetCurrentProcess(), IDLE_PRIORITY_CLASS );
	
	__try
	{
		bReturn = _ParseDirectory( m_cstrBaseDir );
	}
	__except(1) 
	{
		// no exception handling
	};

	// reset prioritylowering
	if ( m_bLowPriority ) SetPriorityClass( GetCurrentProcess(), NORMAL_PRIORITY_CLASS );
	

	return bReturn;
}

INT CviDirWalker::_MatchFileName(LPCTSTR szFileName)
{
	ULONG lIndex;					// simple counter
	BOOL  bReturn= FALSE;	     	// This file matchs the patternlist ?
	CviFilePattern * pFilePattern;	// pointer to handle patter object

	for ( lIndex=0; lIndex < m_cplFiles.Count(); lIndex++ )
	{
		// get pattern object
		pFilePattern = m_cplFiles.Item( lIndex );

		// compare the filenames
		if ( viCompareString( pFilePattern->GetPatternString(), szFileName) == 0 )
		{
			//yaa, this pattern matches
			bReturn = pFilePattern->IsInclude();
		}
	}

	return (bReturn) ? 1 : -1;
}

INT CviDirWalker::_MatchDirectoryName(LPCTSTR szDirName)
{
	ULONG lIndex;					// simple counter
	BOOL  bReturn= FALSE;	     	// This DirName matchs the patternlist ?
	CviFilePattern * pFilePattern;	// pointer to handle patter object

	for ( lIndex=0; lIndex < m_cplDirectories.Count(); lIndex++ )
	{
		// get pattern object
		pFilePattern = m_cplDirectories.Item( lIndex );

		// compare the filenames
		if ( viCompareString( pFilePattern->GetPatternString(), szDirName) == 0 )
		{
			//yaa, this pattern matches
			bReturn = pFilePattern->IsInclude();
		}
	}

	return (bReturn) ? 1 : -1;
}

// returns TRUE if the given pattern matchs to all DirNames e.g. "*" or "**"
BOOL CviDirWalker::IsGeneralDirectory(LPCTSTR szDirMatchPattern)
{
	LPCTSTR szPos = szDirMatchPattern;

	while(*szPos)
	{
		if ((*szPos) != _T('*')) return FALSE;
		szPos++;
	}

	return TRUE;
}

// returns true if the given directory is "." or ".."
BOOL CviDirWalker::IsDotDirectory(LPCTSTR szDirName )
{
	if ( _tcscmp( szDirName, _T(".")) == 0) return TRUE;

	if ( _tcscmp( szDirName, _T("..")) == 0) return TRUE;

	return FALSE;

}

// returns TRUE if the given pattern matchs to all Filenames e.g. "*" or "*.**"
BOOL CviDirWalker::IsGeneralFile(LPCTSTR szFileMatchPattern)
{
	LPCTSTR szPos = szFileMatchPattern;
	BOOL bDotFound = FALSE;

	while(*szPos)
	{
		if ((*szPos) != _T('*')) 
		{
			if (((*szPos) == _T('.')) && (!bDotFound) ) 
				bDotFound = TRUE;
			else
				return FALSE;
		}
		szPos++;
	}

	return TRUE;
}

BOOL CviDirWalker::_ParseDirectory(LPCTSTR szDirName)
{
	WIN32_FIND_DATA FindFileData;
	HANDLE			hFind;
	BOOL			bReturn = TRUE;
	CviString       cstrFullName;
	CviString       cstrMatchName;
	CviFileInfo *   pviFileInfo;
	INT             iRes;
	INT             iInsert;


	cstrMatchName = szDirName;   // copy direcory name

	// trim the string
	cstrMatchName.TrimRight(_T('*'));
	cstrMatchName.TrimRight(_T('.'));
	cstrMatchName.TrimRight(_T('\\'));
	cstrMatchName.TrimRight(_T('\t'));
	
	// now appand our matchpattern
	cstrMatchName += _T("\\*");

	// process events
	_DoEvents();

	hFind = FindFirstFile( cstrMatchName, &FindFileData);

	if (hFind == INVALID_HANDLE_VALUE) 
	{
		CviString cstrError;
		cstrError.Format(_T("Error: '%s' [%d - %s]"), szDirName, GetLastError(), _GetErrorText(GetLastError()).operator LPCTSTR() );
		m_cMsgCollection.Add( 1, (LPCTSTR) cstrError );

		if (m_bIgnoreErrors) 
			return TRUE;
		else
			return FALSE;
	}

	do
	{
		if ( (FindFileData.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT) == FILE_ATTRIBUTE_REPARSE_POINT )
		{
			// its a link --> do nothing
		}
		else if ( (FindFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == FILE_ATTRIBUTE_DIRECTORY )
		{
			// its a directory
			if ( ! IsDotDirectory( FindFileData.cFileName ) )
			{
				if ( m_pfAcceptDir )
				{	// callbackfunction defined
					iRes = m_pfAcceptDir( this, szDirName, &FindFileData );
				}
				else
				{
					// no callbackfunction is defined 
					iRes = 0;
				}
				
				if ( iRes == 0)
				{
					iRes = _MatchDirectoryName ( FindFileData.cFileName );
				}
				
				if ( iRes > 0  )
				{
					// MatchName without '*'
					cstrFullName = cstrMatchName.Left( cstrMatchName.GetLength() - 1 );

					// appand the SubdirectoryName
					cstrFullName += FindFileData.cFileName;

					// SZ For debug only 2014-11-26
					//ofstream fout("C:\\vi\\Tools\\Debug.log", ios::app );
					//fout << (LPCTSTR)cstrFullName <<endl;
					//fout.close();

					bReturn = _ParseDirectory( cstrFullName );
				}
			}
		}
		else
		{	
			// callbackfunction defined ???
			if ( m_pfAcceptFile )
			{	// callbackfunction defined
				iRes = m_pfAcceptFile( this, szDirName, &FindFileData );
			}
			else
			{
				// no callbackfunction is defined 
				iRes = 0;
			}
			
			// check filename internal
			if ( iRes == 0)
			{
				iRes = _MatchFileName( FindFileData.cFileName );

				// check executeable only
				if ( m_bExeOnly && (iRes>0) )
				{
					// iRes = _IsExecutable( szDirName, FindFileData.cFileName ) ? 1 : -1;

					iRes = _IsExecutable_2( szDirName, &FindFileData ) ? 1 : -1;
				}
			}

			
			if ( iRes > 0  )
			{
				// remove our matchpattern "\*"
				cstrFullName = cstrMatchName.Left( cstrMatchName.GetLength() - 2 );

								// call FoundFile CallBack
				if ( m_pfFoundFile )
				{
					// call the FileFoundCallBack
					iInsert = m_pfFoundFile( this, szDirName, &FindFileData );
				}
				else
				{
					// always insert if there is nor CallBack
					iInsert = 1;
				}

				// is to insert?
				if (iInsert>0)
				{
					// create a FileInfoObject
					pviFileInfo = new CviFileInfo( cstrFullName, &FindFileData);

					// appand this object into the collection
					if ( m_pfGetHashValue )
					{
						// appand this object into the collection with hash-value
						bReturn = m_pFilesCollection->Add( pviFileInfo, m_pfGetHashValue(this, pviFileInfo) );
					}
					else
					{
						// appand this object into the collection without hash-value
						bReturn = m_pFilesCollection->Add( pviFileInfo, (LPCTSTR) NULL );
					}

					// can't insert CviFileInfo-Class into Collection
					if (!bReturn)
					{
						delete(pviFileInfo);
					}
				}
			}
		}

		// handle error-ignoration
		if (m_bIgnoreErrors) 
			bReturn = TRUE;

	}	
	while ( FindNextFile( hFind, &FindFileData )  && bReturn);
  	
	FindClose(hFind);

	return bReturn;
}

CviMessageCollection & CviDirWalker::MessageCollection ( void )
{
	return m_cMsgCollection;
}

BOOL CviDirWalker::SetBaseDirectory(LPCTSTR strBaseDir)
{
	m_cstrBaseDir = strBaseDir;
	m_lBaseDirLen = m_cstrBaseDir.GetLength();
	return TRUE;
}

LPCTSTR CviDirWalker::GetBaseDirectory( void )
{
	return m_cstrBaseDir.operator LPCTSTR();
}

BOOL CviDirWalker::LowerPriority()
{
	return m_bLowPriority;
}

void CviDirWalker::LowerPriority(BOOL bLowPriority)
{
	m_bLowPriority = bLowPriority;
}

void CviDirWalker::IgnoreErrors( BOOL bIgnoreErrors )
{
	m_bIgnoreErrors = bIgnoreErrors;
}

BOOL CviDirWalker::IgnoreErrors( void )
{
	return m_bIgnoreErrors;
}

void CviDirWalker::ExecutableOnly( BOOL bExeOnly )
{
	m_bExeOnly = bExeOnly;
}

BOOL CviDirWalker::ExecutableOnly( void )
{
	return m_bExeOnly;
}


/***************************************************************************
 * 
 * Removes this part from the FileName that is set as BaseDirectory.
 *
 ***************************************************************************/
LPCTSTR CviDirWalker::GetRelFileName(LPCTSTR strFullName)
{
	return strFullName + m_lBaseDirLen + 1; 
}


/***************************************************************************
 * 
 * Set the function that computes the hashstring for al file
 * You can use 'GetHashFullPath' to use the full pathname or 
 * 'GetHashRelPath' to uses the relative PathName to the BaseDirectory.
 *
 ***************************************************************************/
void CviDirWalker::SetHashValueFunction( PFGETHASHVALUE pfHashValueFunction )
{
	m_pfGetHashValue = pfHashValueFunction;
}

/***************************************************************************
 * 
 * Set the function that 
 *
 ***************************************************************************/
void CviDirWalker::SetAcceptDirFunction( PFACCEPTDIR pfAcceptDirFunction )
{
	m_pfAcceptDir = pfAcceptDirFunction;
}


/***************************************************************************
 * 
 * Set the function that 
 *
 ***************************************************************************/
void CviDirWalker::SetAcceptFileFunction( PFACCEPTFILE pfAcceptFileFunction )
{
	m_pfAcceptFile = pfAcceptFileFunction;
}

/***************************************************************************
 * 
 * Set the function that 
 *
 ***************************************************************************/
void CviDirWalker::SetFoundFileFunction( PFFOUNDFILE pfFoundFileFunction )
{
	m_pfFoundFile = pfFoundFileFunction;
}


/**********************************************************************************************************


/***************************************************************************
 * 
 * Default HashValue-FullPath
 *
 ***************************************************************************/
GETHASHVALUE(GetHashFullPath)
{
	return pFileInfo->FullName();
}

/***************************************************************************
 * 
 * Default HashValue-FullPath
 *
 ***************************************************************************/
GETHASHVALUE(GetHashRelPath)
{
	return pCaller->GetRelFileName( pFileInfo->FullName() );
}

BOOL CviDirWalker::_IsExecutable( LPCTSTR szPathName, LPCTSTR szFileName)
{
	DWORD_PTR  dwReturn;
	SHFILEINFO rFileInfo;
	CviString  cstrFullName;

	cstrFullName.Format(_T("%s\\%s"), szPathName, szFileName);

	dwReturn = SHGetFileInfo( cstrFullName.operator LPCTSTR(), 0, &rFileInfo, sizeof(rFileInfo), SHGFI_EXETYPE ); 

	return (dwReturn>0);
}

BOOL CviDirWalker::_IsExecutable_2( LPCTSTR strDirectory, WIN32_FIND_DATA * pFindData )
{
	CviString  cstrFullName;
	ULONGLONG  ulFileSize;
	BOOL       bResult = FALSE;
	CviString  cstrExtension;


	ulFileSize = pFindData->nFileSizeHigh;
	Int64ShllMod32( ulFileSize, 32 );
	ulFileSize =  ulFileSize + pFindData->nFileSizeLow;


	// check fileextension

	cstrExtension = pFindData->cFileName;

	// check for ".COM" extension
	if ( cstrExtension.Right(4).CompareNoCase(".com") == 0 )
	{
		return TRUE;
	}

	// check filesize
	if (ulFileSize <= sizeof(IMAGE_DOS_HEADER))
	{
		return FALSE;
	}

	cstrFullName.Format(_T("%s\\%s"), strDirectory, pFindData->cFileName);

	bResult = IsExecutable( cstrFullName.operator LPCTSTR() );

	return bResult;
}

/*---------------------------------------------------------------------------------------------*/

BOOL IsExecutable( LPCTSTR strFileName )
{
    HANDLE hImage;

    DWORD  SectionOffset;
    DWORD  CoffHeaderOffset;
	DWORD  dwRead;
	BOOL   bReturn = FALSE;

    ULONG  ntSignature;

    IMAGE_DOS_HEADER      image_dos_header;
    IMAGE_FILE_HEADER     image_file_header;

    // Open the reference file.
    hImage = CreateFile(strFileName,
                        GENERIC_READ,
                        FILE_SHARE_READ,
                        NULL,
                        OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL,
                        NULL);

    if (INVALID_HANDLE_VALUE == hImage)
    {
        return FALSE;
    }

	__try
	{
		// Read the MS-DOS image header.
     
		ReadFile(hImage, &image_dos_header, sizeof(IMAGE_DOS_HEADER), &dwRead, NULL);
		
		if (IMAGE_DOS_SIGNATURE != image_dos_header.e_magic)
		{
			__leave;
		}

		if ( image_dos_header.e_lfanew == 0)
		{
			// its a very old exe
			bReturn = TRUE;
			__leave;
		}


        //  Get actual COFF header.
		CoffHeaderOffset = AbsoluteSeek(hImage, image_dos_header.e_lfanew) +
						   sizeof(ULONG);

		if (CoffHeaderOffset == -1)
		{
			__leave;
		}

		ReadFile(hImage, &ntSignature, sizeof(ULONG), &dwRead, NULL);

		if (IMAGE_NT_SIGNATURE != ntSignature)
		{
			__leave;
		}

		SectionOffset = CoffHeaderOffset + IMAGE_SIZEOF_FILE_HEADER +
						IMAGE_SIZEOF_NT_OPTIONAL_HEADER;

		ReadFile(hImage, &image_file_header, IMAGE_SIZEOF_FILE_HEADER, &dwRead, NULL);

		if ( image_file_header.Machine != IMAGE_FILE_MACHINE_I386 )
		{
			bReturn = FALSE;
			__leave;
		}

		if ( (image_file_header.Characteristics & IMAGE_FILE_DLL) == IMAGE_FILE_DLL)
		{
			// its a DLL
			bReturn = FALSE;
		}
		else
		{
			// its a exe
			bReturn = TRUE;
		}

	}
	__finally
	{
		CloseHandle( hImage );
	}

	return bReturn;
}

DWORD
AbsoluteSeek(HANDLE hFile,
             DWORD  offset)
{
    DWORD newOffset;

    if ((newOffset = SetFilePointer(hFile,
                                    offset,
                                    NULL,
                                    FILE_BEGIN)) == 0xFFFFFFFF)
    {
        newOffset = -1;
    }

    return newOffset;
}

  
/*---------------------------------------------------------------------------------------------*/
