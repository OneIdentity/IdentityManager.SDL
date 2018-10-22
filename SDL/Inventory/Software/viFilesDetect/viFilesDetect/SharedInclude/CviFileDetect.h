// CviFileDetect.h: interface for the CviFileDetect class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CVIFILEDETECT_H__D985D718_0713_11D5_B1F3_00508B8F0099__INCLUDED_)
#define AFX_CVIFILEDETECT_H__D985D718_0713_11D5_B1F3_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "viDirWalker_INC.h"
#include "viFileStringList.h"

class CviFileDetect : public CviDirWalker
{
public:
	virtual BOOL Priority( LPCTSTR strPriority );
	virtual BOOL IsLocalHardDisk( TCHAR cDrive );
	virtual BOOL Run( void );
	virtual BOOL Wait( BOOL bWait );
	virtual BOOL GetData( LPCTSTR strGetData );
	virtual BOOL Drives( LPCTSTR strDrives );

	virtual BOOL OutFileName( LPCTSTR strOutFileName );
	virtual LPCTSTR OutFileName( void );

/*
	virtual CviFilePatternCollection * Files( void );
	virtual BOOL Files( LPCTSTR strFiles );

	virtual CviFilePatternCollection * Dirs( void );
	virtual BOOL Dirs( LPCTSTR strDirs );
*/

	CviFileDetect();
	virtual ~CviFileDetect();

protected:
	virtual BOOL _CheckDestinationFile( void );
	virtual BOOL _DeterineData( void );
	virtual BOOL _SearchFiles( void );
	virtual BOOL _SearchFilesOnDrive( CviFilesCollection  * pFilesColl, TCHAR cDriveLetter, BOOL bShowErrors );

	virtual BOOL _XMLAddAppDetect( void );
	virtual BOOL _XMLAddErrorReport( void );
	virtual BOOL _XMLProcessFile( CviFileInfo * pFileInfo );
	virtual BOOL _XMLProcessFile_Name( CviFileInfo * pFileInfo );
	virtual BOOL _XMLProcessFile_Resource( CviFileInfo * pFileInfo );
	virtual BOOL _XMLProcessFile_Resource_Value( CviString & pstrResource, LPCTSTR strLang, BYTE * pBuffer, LPCTSTR strResource );
	virtual BOOL _XMLProcessFile_IconImprint( CviFileInfo * pFileInfo );
	virtual BOOL _XMLProcessFile_BinImprint( CviFileInfo * pFileInfo );

	virtual ULONG _GetCRCFromIcon( HBITMAP hBitmap );
	virtual BOOL _MakeXMLConformeString( CviString * cstrLine );

	CviFilesCollection         m_cFilesColl;            // Collection of files 

	CviFileStringList          m_cXMLFile;              // StringCollection simulating XML-File

	CviString                  m_cstrFileName;			// Full FileName 
	CviString                  m_cstrDrives;			// String of DriveLetters
	CviString                  m_cstrGetData;			// String of N,R,I,B
	
	DWORD					   m_dwPriorityClass;		// IDLE_PRIORITY_CLASS or NORMAL_PRIORITY_CLASS

	BOOL                       m_bWait;					// Parameter /Wait


	
};

#endif // !defined(AFX_CVIFILEDETECT_H__D985D718_0713_11D5_B1F3_00508B8F0099__INCLUDED_)
