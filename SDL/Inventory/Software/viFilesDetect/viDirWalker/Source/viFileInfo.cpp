// viFileInfo.cpp: implementation of the CviFileInfo class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "viFileInfo.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CviFileInfo::CviFileInfo()
{
}

CviFileInfo::CviFileInfo( LPCTSTR strPath, WIN32_FIND_DATA * pFindData, LONG lParam)
{
	// copy data from structure
    m_dwFileAttributes      = pFindData->dwFileAttributes; 
    m_ftCreationTime        = pFindData->ftCreationTime; 
    m_ftLastAccessTime      = pFindData->ftLastAccessTime; 
    m_ftLastWriteTime       = pFindData->ftLastWriteTime; 
    m_nFileSizeHigh         = pFindData->nFileSizeHigh; 
    m_nFileSizeLow          = pFindData->nFileSizeLow; 
    m_cstrFileName          = pFindData->cFileName;
    m_cstrAlternateFileName = pFindData->cAlternateFileName;

	// and copy the File-Path
	m_cstrPathName = strPath;

	// copy userparameter
	m_lParam = lParam;
}

CviFileInfo::~CviFileInfo()
{
	
}

//returns the filesize as a 64-Bit value
ULONGLONG CviFileInfo::GetFileSizeEx()
{
	ULONGLONG ullReturn = m_nFileSizeHigh;

	Int64ShllMod32( ullReturn, 32 );

	return ullReturn + m_nFileSizeLow;
}

// returns the filesize as a 32 Bit-Value; larger files are retuned as MAXDWORD;
DWORD CviFileInfo::GetFileSize()
{
	if ( m_nFileSizeHigh == 0 )
		return m_nFileSizeLow;
	else
		return MAXDWORD;
}

LPCTSTR CviFileInfo::FullName()
{
	static CviString cstrFullName;

	cstrFullName  = m_cstrPathName.operator LPCTSTR();
	cstrFullName += _T("\\");
	cstrFullName += m_cstrFileName;

	return cstrFullName.operator LPCTSTR();
}

LPCTSTR CviFileInfo::FileName()
{
	return m_cstrFileName;
}

LPCTSTR CviFileInfo::AlternateFileName()
{
	return m_cstrAlternateFileName;
}

LPCTSTR CviFileInfo::PathName()
{
	return m_cstrPathName.operator LPCTSTR();
}

BOOL CviFileInfo::operator >(CviFileInfo & cFileInfo)
{
	return ( _tcsicmp( this->FullName(), cFileInfo.FullName() ) > 0 );
}

void CviFileInfo::lParam( LONG lParam )
{
	m_lParam = lParam;
}


LONG CviFileInfo::lParam( void )
{
	return m_lParam;
}


const FILETIME CviFileInfo::CreationTime( )
{
	return m_ftCreationTime;
}

const FILETIME CviFileInfo::LastAccessTime( )
{
	return m_ftLastAccessTime;
}

const FILETIME CviFileInfo::LastWriteTime( )
{
	return m_ftLastWriteTime;
}

DWORD CviFileInfo::FileAttributes()
{
	return m_dwFileAttributes;
}

CviFileInfo * CviFileInfo::Copy( )
{
	CviFileInfo * pFileInfo;

	pFileInfo = new CviFileInfo( );

	if (pFileInfo)
	{
		// copy all membervariables
		pFileInfo->m_dwFileAttributes      = m_dwFileAttributes; 
		pFileInfo->m_ftCreationTime        = m_ftCreationTime; 
		pFileInfo->m_ftLastAccessTime      = m_ftLastAccessTime; 
		pFileInfo->m_ftLastWriteTime       = m_ftLastWriteTime; 
		pFileInfo->m_nFileSizeHigh         = m_nFileSizeHigh; 
		pFileInfo->m_nFileSizeLow          = m_nFileSizeLow; 
		pFileInfo->m_cstrFileName          = m_cstrFileName;
		pFileInfo->m_cstrAlternateFileName = m_cstrAlternateFileName;
		pFileInfo->m_cstrPathName          = m_cstrPathName;
		pFileInfo->m_lParam                = m_lParam;
	}

	return pFileInfo;
}
