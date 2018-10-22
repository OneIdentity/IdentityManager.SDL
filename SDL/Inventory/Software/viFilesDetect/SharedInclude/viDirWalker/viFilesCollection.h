// viFilesCollection.h: interface for the CviFilesCollection class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIFILESCOLLECTION_H__9FF5F544_F695_11D4_B1DF_00508B8F0099__INCLUDED_)
#define AFX_VIFILESCOLLECTION_H__9FF5F544_F695_11D4_B1DF_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "viCollection.h"
#include "viFileInfo.h"

//---------------------------------------
// Initial-Parameter for Collection
//---------------------------------------

#define FC_INITIAL_SIZE		100
#define FC_HASH_SIZE		101

class CviFilesCollection  
{
public:

	CviFilesCollection();
	virtual ~CviFilesCollection();

	bool Add( CviFileInfo * pItem, ULONG pos );
	bool Add( CviFileInfo * pItem, LPCTSTR key );

	bool Remove( ULONG pos );
	bool Remove( LPCTSTR key );

	CviFileInfo * Item( ULONG pos );
	CviFileInfo * Item( LPCTSTR key);

	void   Clear( void );
	ULONG  Count( void );

	void DumpCollection( void );


private:

	CCollection<CviFileInfo> * m_pFileInfoCollection;

};

#endif // !defined(AFX_VIFILESCOLLECTION_H__9FF5F544_F695_11D4_B1DF_00508B8F0099__INCLUDED_)
