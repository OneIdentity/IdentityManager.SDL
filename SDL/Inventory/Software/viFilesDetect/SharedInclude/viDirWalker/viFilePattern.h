// viFilePattern.h: interface for the CviFilePattern class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIFILEPATTERN_H__758D6546_F764_11D4_B1E0_00508B8F0099__INCLUDED_)
#define AFX_VIFILEPATTERN_H__758D6546_F764_11D4_B1E0_00508B8F0099__INCLUDED_


#include "viString.h"

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000



class CviFilePattern  
{
public:
	virtual CviFilePattern * Copy( void );
	virtual BOOL IsInclude( void );
	virtual LPCTSTR GetPatternString( void );
	virtual BOOL SetInitialString( LPCTSTR szPattern );
	CviFilePattern();
	virtual ~CviFilePattern();

private:

	CviString m_cstrFilePattern;

	BOOL    m_bInclude;

};

#endif // !defined(AFX_VIFILEPATTERN_H__758D6546_F764_11D4_B1E0_00508B8F0099__INCLUDED_)
