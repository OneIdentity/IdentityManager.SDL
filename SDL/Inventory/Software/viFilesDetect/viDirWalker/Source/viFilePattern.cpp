// viFilePattern.cpp: implementation of the CviFilePattern class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "viFilePattern.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CviFilePattern::CviFilePattern()
{

}

CviFilePattern::~CviFilePattern()
{

}

BOOL CviFilePattern::SetInitialString(LPCTSTR szPattern)
{
	CviString   cstrPattern;

	// copy the string
	cstrPattern = szPattern;

	// remove all whitespace characters
	cstrPattern.TrimLeft();
	cstrPattern.TrimRight();

	switch ( cstrPattern[0] )
	{
	case _T('-'): // its an exclude pattern
				  m_bInclude = FALSE;

				  // remove the '-'
				  cstrPattern = cstrPattern.Right( cstrPattern.GetLength() - 1 );
		 break;

	case _T('+'): // its an include pattern
				  m_bInclude = TRUE;

				  // remove the '-'
				  cstrPattern = cstrPattern.Right( cstrPattern.GetLength() - 1 );
		break;

	default:
		// every thing else its an include-pattern
		m_bInclude = TRUE;
	}	

	// trim again to avoid whitespace characters between '+' and Filename
	cstrPattern.TrimLeft();

	// now copy to our membervariable
	m_cstrFilePattern = cstrPattern;

	return TRUE;
}

LPCTSTR CviFilePattern::GetPatternString()
{
	return m_cstrFilePattern.operator LPCTSTR();
}

BOOL CviFilePattern::IsInclude()
{
	return m_bInclude;
}

CviFilePattern * CviFilePattern::Copy()
{
	CviFilePattern * pFilePattern;

	pFilePattern = new CviFilePattern;

	if ( ! pFilePattern ) 
		return NULL;

	// copy the memberdata
	pFilePattern->m_bInclude        = this->m_bInclude;
	pFilePattern->m_cstrFilePattern = this->m_cstrFilePattern;

	return pFilePattern;
}
