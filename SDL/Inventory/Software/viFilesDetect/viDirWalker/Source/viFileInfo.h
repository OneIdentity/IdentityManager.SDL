// viFileInfo.h: interface for the CviFileInfo class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIFILEINFO_H__9FF5F541_F695_11D4_B1DF_00508B8F0099__INCLUDED_)
#define AFX_VIFILEINFO_H__9FF5F541_F695_11D4_B1DF_00508B8F0099__INCLUDED_

#include <viString.h>

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000



class CviFileInfo  
{
public:
	virtual LPCTSTR PathName( void );

	virtual LPCTSTR FullName( void );
	CviFileInfo();
	CviFileInfo( LPCTSTR strPath, WIN32_FIND_DATA * pFindData,LONG lParam = 0 );
	virtual ~CviFileInfo();

	BOOL operator >(CviFileInfo & cFileInfo);

	virtual void lParam( LONG lParam );
	virtual LONG lParam( void );

	virtual DWORD FileAttributes();
	virtual DWORD GetFileSize( void );
	virtual ULONGLONG GetFileSizeEx( void );
	virtual LPCTSTR FileName( void );
	virtual LPCTSTR AlternateFileName( void );
	const virtual FILETIME CreationTime( void );
	const virtual FILETIME LastAccessTime( void );
	const virtual FILETIME LastWriteTime( void );

	virtual CviFileInfo * Copy( void );

private:

	CviString			m_cstrPathName;

	DWORD		m_dwFileAttributes; 
	FILETIME	m_ftCreationTime; 
	FILETIME	m_ftLastAccessTime; 
	FILETIME	m_ftLastWriteTime; 
	DWORD		m_nFileSizeHigh; 
	DWORD		m_nFileSizeLow; 
	DWORD		m_dwOID; 
	CviString   m_cstrFileName;
	CviString   m_cstrAlternateFileName;

	LONG        m_lParam;

};

#endif // !defined(AFX_VIFILEINFO_H__9FF5F541_F695_11D4_B1DF_00508B8F0099__INCLUDED_)
