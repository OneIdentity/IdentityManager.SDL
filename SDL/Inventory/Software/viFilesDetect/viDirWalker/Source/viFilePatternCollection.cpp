// viFilePatternCollection.cpp: implementation of the CviFilePatternCollection class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "viFilePatternCollection.h"
#include "viSeparatorList.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CviFilePatternCollection::CviFilePatternCollection()
{
	m_pFilePatternCollection = new CCollection<CviFilePattern>(FC_INITIAL_SIZE, FC_HASH_SIZE);
}

CviFilePatternCollection::~CviFilePatternCollection()
{
	if (m_pFilePatternCollection) delete( m_pFilePatternCollection );
}


BOOL  CviFilePatternCollection::Add( CviFilePattern * pFilePattern )
{
	return m_pFilePatternCollection->Add( pFilePattern );

}

CviFilePattern * CviFilePatternCollection::Item( ULONG ulPos )
{
	return m_pFilePatternCollection->Item( ulPos );
}

void CviFilePatternCollection::Clear( void )
{
	m_pFilePatternCollection->Clear();
}

ULONG CviFilePatternCollection::Count( void )
{
	return m_pFilePatternCollection->Count();
}

BOOL CviFilePatternCollection::SetString(LPCTSTR strPatternList)
{
	CviSeparatorList cSepList;
	LONG             lPos;
	CviFilePattern  * pPattern;
	BOOL             bOk;  

	// copy to member-variable
	m_cstrPatternList = strPatternList;

	// use a separatorlist to cut the string into pieces
	cSepList.SetSeparators(_T("|"));
	cSepList.SetStringList( strPatternList );

	for( lPos=0; lPos < cSepList.GetCount(); lPos++)
	{
		pPattern = new CviFilePattern( );

		bOk = pPattern->SetInitialString( cSepList.GetIndex(lPos)->operator LPCTSTR() );

		// errorhandling
		if (bOk)
		{
			// ok, so insert into collection
			m_pFilePatternCollection->Add( pPattern );
		}
		else
		{
			// error, so delete the object
			if (pPattern) delete( pPattern );
		}

	}

	cSepList.Clear();

	return TRUE;
}

LPCTSTR CviFilePatternCollection::GetString()
{
	return m_cstrPatternList;
}

BOOL CviFilePatternCollection::CopyFrom(CviFilePatternCollection *pSource )
{
	CviFilePattern * pFilePattern;
	ULONG            iPos;

	// cleanup the old collection
	Clear();

	for (iPos=0; iPos< pSource->Count(); iPos++)
	{
		pFilePattern = pSource->Item(iPos)->Copy();

		if (!pFilePattern)
			return FALSE;

		if ( ! Add( pFilePattern ) )
		{
			if( pFilePattern ) free( pFilePattern );
			return FALSE;
		}
	}

	return TRUE;
}
