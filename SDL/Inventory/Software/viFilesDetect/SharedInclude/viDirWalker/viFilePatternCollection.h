// viFilePatternCollection.h: interface for the CviFilePatternCollection class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIFILEPATTERNCOLLECTION_H__758D6547_F764_11D4_B1E0_00508B8F0099__INCLUDED_)
#define AFX_VIFILEPATTERNCOLLECTION_H__758D6547_F764_11D4_B1E0_00508B8F0099__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "..\SharedInclude\viCollection.h"
#include "viFilePattern.h"

//---------------------------------------
// Initial-Parameter for Collection
//---------------------------------------

#define FC_INITIAL_SIZE		100
#define FC_HASH_SIZE		101

class CviFilePatternCollection;  

class CviFilePatternCollection  
{
public:
	virtual BOOL CopyFrom( CviFilePatternCollection * pSource );
	virtual LPCTSTR GetString( void );
	BOOL SetString( LPCTSTR strPatternList );
	CviFilePatternCollection();
	virtual ~CviFilePatternCollection();

	BOOL  Add( CviFilePattern * pFilePattern );

	CviFilePattern * Item( ULONG ulPos );

	void   Clear( void );
	ULONG  Count( void );

private:

	CCollection<CviFilePattern> * m_pFilePatternCollection;

	CviString  m_cstrPatternList;

};

#endif // !defined(AFX_VIFILEPATTERNCOLLECTION_H__758D6547_F764_11D4_B1E0_00508B8F0099__INCLUDED_)
