// viMessage.cpp: implementation of the CviMessage class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "viMessage.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CviMessage::CviMessage()
{
	m_tPriority = mpError;
	m_ulNumber  = 0L;
	m_cstrText  = _T("");
}

CviMessage::CviMessage( ULONG ulNumber, LPCTSTR strText, tVIMessagePriority tPriority )
{
	m_ulNumber  = ulNumber;
	m_cstrText  = strText;
	m_tPriority = tPriority;

}

CviMessage::~CviMessage()
{

}


LPCTSTR CviMessage::MessageText()
{
	return m_cstrText.operator LPCTSTR();
}

void CviMessage::Text(LPCTSTR strText)
{
	m_cstrText = strText;
}

ULONG CviMessage::Number()
{
	return m_ulNumber;
}

void CviMessage::Number(ULONG ulNumber)
{
	m_ulNumber = ulNumber;
}

tVIMessagePriority CviMessage::Priority()
{
	return m_tPriority;
}

void CviMessage::Priority(tVIMessagePriority tPriority)
{
	m_tPriority = tPriority;
}

// the returned object must be released with delete
CviMessage * CviMessage::Copy()
{
	CviMessage * pNewMessage;

	pNewMessage = new CviMessage(m_ulNumber, m_cstrText.operator LPCTSTR(), m_tPriority);

	return pNewMessage;
}
