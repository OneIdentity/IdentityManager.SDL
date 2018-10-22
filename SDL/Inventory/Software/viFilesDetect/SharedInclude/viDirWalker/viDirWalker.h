// viDirWalker.h: interface for the CviDirWalker class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIDIRWALKER_H__ACF399AB_F144_11D4_B1DA_00508B8F0099__INCLUDED_)
#define AFX_VIDIRWALKER_H__ACF399AB_F144_11D4_B1DA_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "viFilePatternCollection.h"
#include "viMessageCollection.h"
#include "viFilesCollection.h"


class CviDirWalker;

// type definitions for CallBack Functions
typedef LPCTSTR (*PFGETHASHVALUE)( CviDirWalker * pCaller, CviFileInfo * pFileInfo );
#define GETHASHVALUE(fn) LPCTSTR fn( CviDirWalker * pCaller, CviFileInfo * pFileInfo )

typedef INT (*PFACCEPTDIR)( CviDirWalker * pCaller, LPCTSTR strDirectory, WIN32_FIND_DATA * pFindData );
#define ACCEPTDIR(fn) INT fn( CviDirWalker * pCaller, LPCTSTR strDirectory, WIN32_FIND_DATA * pFindData )

typedef INT (*PFACCEPTFILE)( CviDirWalker * pCaller, LPCTSTR strDirectory, WIN32_FIND_DATA * pFindData );
#define ACCEPTFILE(fn) INT fn( CviDirWalker * pCaller, LPCTSTR strDirectory, WIN32_FIND_DATA * pFindData )

typedef INT (*PFFOUNDFILE)( CviDirWalker * pCaller, LPCTSTR strDirectory, WIN32_FIND_DATA * pFindData );
#define FOUNDFILE(fn) INT fn( CviDirWalker * pCaller, LPCTSTR strDirectory, WIN32_FIND_DATA * pFindData )



// two default functions

GETHASHVALUE(GetHashFullPath);   // the full FileName is used as HashValue
GETHASHVALUE(GetHashRelPath);    // the relative FileName to baseDirectory is used as HashValue


class CviDirWalker  
{
public:

	virtual void ExecutableOnly( BOOL bExeOnly );
	virtual BOOL ExecutableOnly( void );
	
	virtual void LowerPriority( BOOL bLowPriority );
	virtual BOOL LowerPriority( void );

	virtual void IgnoreErrors( BOOL bIgnoreErrors );
	virtual BOOL IgnoreErrors( void );

	virtual BOOL SetBaseDirectory( LPCTSTR strBaseDir );
	virtual CviMessageCollection & MessageCollection ( void );
	virtual BOOL IsDotDirectory(LPCTSTR szDirName );
	virtual BOOL IsGeneralDirectory( LPCTSTR szDirMatchPattern );
	virtual BOOL IsGeneralFile(LPCTSTR szFileMatchPattern);

	virtual BOOL Run( CviFilesCollection * pFilesCollection );
	CviDirWalker();
	virtual ~CviDirWalker();

	virtual BOOL SetFiles( LPCTSTR strFileList );
	virtual BOOL SetFiles( CviFilePatternCollection * pFiles );
	virtual BOOL SetDirectories( LPCTSTR strDirList );
	virtual BOOL SetDirectories( CviFilePatternCollection * pDirs );

	virtual LPCTSTR GetFiles( void );
	virtual LPCTSTR GetDirectories( void );
	virtual LPCTSTR GetBaseDirectory( void );
	virtual LPCTSTR GetRelFileName( LPCTSTR strFullName );

	// callback funtions
	virtual void SetHashValueFunction( PFGETHASHVALUE pfHashValueFunction );
	virtual void SetAcceptDirFunction( PFACCEPTDIR pfAcceptDirFunction );
	virtual void SetAcceptFileFunction( PFACCEPTFILE pfAcceptFileFunction );
	virtual void SetFoundFileFunction( PFFOUNDFILE pfFoundFileFunction );

protected:
	virtual BOOL _IsExecutable( LPCTSTR szPathName, LPCTSTR szFileName );
	virtual BOOL _IsExecutable_2( LPCTSTR strDirectory, WIN32_FIND_DATA * pFindData );

	virtual BOOL _ParseDirectory( LPCTSTR szDirName );
	virtual INT  _MatchDirectoryName( LPCTSTR szDirName );
	virtual INT  _MatchFileName( LPCTSTR szFileName );

	virtual CviString & _GetErrorText( DWORD dwErrorNr );
	virtual void _DoEvents( void );

	CviFilePatternCollection	m_cplFiles;
	CviFilePatternCollection	m_cplDirectories;
	
	CviFilesCollection          * m_pFilesCollection;
	CviMessageCollection        m_cMsgCollection;

	CviString                   m_cstrBaseDir;
	LONG                        m_lBaseDirLen;

	BOOL                        m_bLowPriority;
	BOOL                        m_bIgnoreErrors;
	BOOL                        m_bExeOnly;

	// pointer to CallBack-Function for determine HashValue
	PFGETHASHVALUE				m_pfGetHashValue;
	PFACCEPTDIR                 m_pfAcceptDir;
	PFACCEPTFILE                m_pfAcceptFile;
	PFFOUNDFILE                 m_pfFoundFile;
};

#endif // !defined(AFX_VIDIRWALKER_H__ACF399AB_F144_11D4_B1DA_00508B8F0099__INCLUDED_)
