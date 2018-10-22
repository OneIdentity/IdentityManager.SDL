// CviString - Class to substitute MFC-CString-class (if it is not available)
//
//	last change: UO - 28.07.2000

#ifndef __CVISTRING_H_
  #define __CVISTRING_H_

#include <iostream>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifdef __BORLANDC__ 
 #if (__BORLANDC__ >= 0x520)
  #define _BCB_
  #include <vcl/dstring.h>
 #endif
#endif

/*
#ifndef cin_sync
  #ifdef linux
    #define cin_sync(); while(cin.peek()=='\n') cin.get();
    #warning "Linux is defined"
  #else
    #define cin_sync(); cin.sync();
  #endif
#endif
*/

#ifdef _MSC_VER		// Microsoft Compiler
  #define _MSC_
#endif

#ifdef 	_MSC_ 
  #include <TCHAR.h>
  #include <windows.h>
#else
  #define LPTSTR char *
  #define LPCTSTR const char *
  #define TCHAR char
  #define _T(a) a
  #define _tcscpy strcpy
  #define _tcscat strcat
  #define _tcsncat strncat
  #define _tcscmp strcmp
  #define _tcsdup strdup
  #define _tcsicmp stricmp
  #define _tcsnicmp strnicmp
  #define _tcslen strlen
  #define _istspace isspace
  #define _stprintf sprintf
  #define _vstprintf vsprintf
#endif

class CviString {
public:

	CviString();
	CviString(const CviString &other);
	CviString(LPCTSTR str);
	CviString(TCHAR ch);
	CviString(TCHAR ch, int Repeat = 1);	// creates a string with 'Repeat' occurrences of 'ch'
    CviString(int i);
    CviString(unsigned int ui);
    CviString(long l);
    CviString(unsigned long ul);
    CviString(float f);
    CviString(double d);
#ifdef _BCB_
	CviString(System::AnsiString AStr);
#endif

	virtual ~CviString();

	virtual void Format(LPCTSTR Format, ... );	// sprintf-like formatfunction
	virtual void FormatV(LPCTSTR Format, va_list argList);	// vsprintf-like formatfunction

#ifdef _MSC_
	virtual int LoadString(HINSTANCE hInstance, UINT uID);	// load string from ressource
#endif

	virtual void Trim();	// removes leading and trailing whitespaces
	virtual void Trim(TCHAR ch);	// removes leading and trailing 'ch'

	virtual void TrimLeft();	// removes leading whitespaces
	virtual void TrimLeft(TCHAR ch);	// removes leading 'ch'

	virtual void TrimRight();	// removes trailing whitespaces
	virtual void TrimRight(TCHAR ch);	// removes trailing 'ch'

	virtual CviString Left(int Count) const;	// returns left part of string
	virtual CviString Mid(int First, int Count = -1) const; // returns mid part of string
	virtual CviString Right(int Count) const;	// returns right part of string

	virtual int Find(LPCTSTR str, int StartPos) const;	// returns Index of first occurrence of 'str' starting at 'StartPos'
	virtual int FindNoCase(LPCTSTR str, int StartPos) const;
	virtual int ReverseFind(TCHAR ch) const;

	virtual int Delete(int StartPos, int Count = 1);	// returns length of the changed string

	virtual int Insert(int StartPos, TCHAR ch);
	virtual int Insert(int StartPos, LPCTSTR str);

	virtual int Remove(TCHAR ch);	// removes all occurences of 'ch' and returns number of removed chars

	virtual int Replace(TCHAR chOld, TCHAR chNew);
	virtual int Replace(LPCTSTR strOld, LPCTSTR strNew);
	virtual int ReplaceNoCase(TCHAR chOld, TCHAR chNew);
	virtual int ReplaceNoCase(LPCTSTR strOld, LPCTSTR strNew);

	virtual void MakeUpper();
	virtual void MakeLower();
	virtual void MakeReverse();

	virtual int GetLength() const;

	virtual bool IsEmpty() const;

	virtual void Clear();

	/*
	friend ostream& operator << (ostream& OS, const CviString& str);
	friend ostream& operator << (ostream& OS, const CviString *pStr);
	friend istream& operator >> (istream& IS, CviString& str);
	friend istream& operator >> (istream& IS, CviString *pStr);
	*/

	virtual CviString& operator = (const CviString& other);
	virtual CviString& operator = (LPCTSTR str);
	virtual CviString& operator = (const TCHAR ch);

	virtual CviString& operator + (const CviString& other);
	virtual CviString& operator + (LPCTSTR str);
	virtual CviString& operator + (const TCHAR ch);

	virtual CviString& operator += (const CviString& other);
	virtual CviString& operator += (LPCTSTR str);
	virtual CviString& operator += (const TCHAR ch);

	virtual int Compare(LPCTSTR str) const;
	virtual int CompareNoCase(LPCTSTR str) const;

	virtual bool operator == (const CviString& other);
	virtual bool operator == (LPCTSTR str);
	virtual bool operator == (const TCHAR ch);

	virtual bool operator != (const CviString& other);
	virtual bool operator != (LPCTSTR str);
	virtual bool operator != (const TCHAR ch);

	virtual bool operator > (const CviString& other);
	virtual bool operator > (LPCTSTR str);

	virtual bool operator < (const CviString& other);
	virtual bool operator < (LPCTSTR str);

	virtual bool operator >= (const CviString& other);
	virtual bool operator >= (LPCTSTR str);

	virtual bool operator <= (const CviString& other);
	virtual bool operator <= (LPCTSTR str);

	virtual operator LPCTSTR() const;
	virtual TCHAR operator [] (int Idx);
	
	virtual operator int() const;
	virtual operator unsigned int() const;
	virtual operator long() const;
	virtual operator unsigned long() const;
	virtual operator float() const;
	virtual operator double() const;

	virtual int ToInt() const;
	virtual unsigned int ToUInt() const;
    virtual long ToLong() const;
	virtual unsigned long ToULong() const;
    virtual float ToFloat() const;
    virtual double ToDouble() const;

#ifdef _BCB_
	virtual AnsiString ToAnsiString( void ) { return AnsiString(pBuf); }
#endif

	static LPTSTR _tcsdup_n(LPCTSTR str);

protected:

	LPTSTR m_lpszBuffer;	// character buffer
	int m_iStrLen;			// string length
	int m_iBufLen;			// allocated buffer length

	bool Assign(LPCTSTR str);	// intern assign-method

	bool Add2(LPCTSTR str);		// intern add-method for '+'
	bool Add3(LPCTSTR str);		// intern add-method for '+='
};

//---------------------------------------------------------------------------
inline CviString::CviString()
{
	m_lpszBuffer = NULL;
	m_iStrLen = -1;
	m_iBufLen = 0;
}

//---------------------------------------------------------------------------
inline CviString::CviString(const CviString &other)
{
	m_lpszBuffer = NULL;
	Assign(other.m_lpszBuffer);
}

//---------------------------------------------------------------------------
inline CviString::CviString(LPCTSTR str)
{
	m_lpszBuffer = NULL;
	Assign(str);
}

//---------------------------------------------------------------------------
inline CviString::CviString(TCHAR ch)
{
	TCHAR vBuf[2];

	vBuf[0] = ch;
	vBuf[1] = '\0';

	m_lpszBuffer = NULL;
	Assign(vBuf);
}

//---------------------------------------------------------------------------
inline CviString::CviString(int i)
{
    TCHAR vBuf[129];

    _stprintf(vBuf, _T("%i"), i);
	m_lpszBuffer = NULL;
    Assign(vBuf);
}

//---------------------------------------------------------------------------
inline CviString::CviString(unsigned int ui)
{
    TCHAR vBuf[129];

    _stprintf(vBuf, _T("%u"), ui);
	m_lpszBuffer = NULL;
    Assign(vBuf);
}

//---------------------------------------------------------------------------
inline CviString::CviString(long l)
{
    TCHAR vBuf[129];

    _stprintf(vBuf, _T("%li"), l);
	m_lpszBuffer = NULL;
    Assign(vBuf);
}

//---------------------------------------------------------------------------
inline CviString::CviString(unsigned long ul)
{
    TCHAR vBuf[129];

    _stprintf(vBuf, _T("%lu"), ul);
	m_lpszBuffer = NULL;
    Assign(vBuf);
}

//---------------------------------------------------------------------------
inline CviString::CviString(float f)
{
    TCHAR vBuf[129];

    _stprintf(vBuf, _T("%f"), f);
	m_lpszBuffer = NULL;
    Assign(vBuf);
}

//---------------------------------------------------------------------------
inline CviString::CviString(double d)
{
    TCHAR vBuf[129];

    _stprintf(vBuf, _T("%lf"), d);
	m_lpszBuffer = NULL;
    Assign(vBuf);
}

//---------------------------------------------------------------------------
#ifdef _BCB_
inline CviString::CviString(System::AnsiString AStr)
{
    if (!AStr.IsEmpty())
	{
		m_lpszBuffer = NULL;
		Assign(AStr.c_str());
	}
	else
	{
		Clear();
	}
}
#endif

//---------------------------------------------------------------------------
inline CviString::~CviString()
{
	Clear();
}

//---------------------------------------------------------------------------
inline void CviString::Format(LPCTSTR Format, ... )
{
	va_list	argList;

	va_start(argList, Format);
	FormatV(Format, argList);
	va_end(argList);
}

//---------------------------------------------------------------------------
inline void CviString::Trim()
{
	TrimLeft();
	TrimRight();
}

//---------------------------------------------------------------------------
inline void CviString::Trim(TCHAR ch)
{
	TrimLeft(ch);
	TrimRight(ch);
}

//---------------------------------------------------------------------------
inline CviString CviString::Left(int Count) const
{
	return Mid(0, Count);
}

//---------------------------------------------------------------------------
inline CviString CviString::Right(int Count) const
{
	return Mid(max(m_iStrLen - Count, 0));
}

//---------------------------------------------------------------------------
inline int CviString::ReverseFind(TCHAR ch) const
{
	return _tcsrchr(m_lpszBuffer, ch) ? (_tcsrchr(m_lpszBuffer, ch) - m_lpszBuffer) : -1;
}

//---------------------------------------------------------------------------
inline int CviString::GetLength() const
{
	return m_iStrLen;
}

//---------------------------------------------------------------------------
inline bool CviString::IsEmpty() const
{
	return (m_iStrLen < 1);
}

//---------------------------------------------------------------------------
inline void CviString::Clear()
{
	if (m_lpszBuffer)
	{
		delete m_lpszBuffer;
		m_lpszBuffer = NULL;
	}

	m_iStrLen = -1;
	m_iBufLen = 0;
}

/*
//---------------------------------------------------------------------------
inline ostream& operator << (ostream& OS, const CviString& str)
{
    OS << str.m_lpszBuffer;
    return OS;
}

//---------------------------------------------------------------------------
inline ostream& operator << (ostream& OS, const CviString *pStr)
{
    if(pStr)
		OS << pStr->m_lpszBuffer;
    else
		OS << _T("(null)");

    return OS;
}

//---------------------------------------------------------------------------
inline istream& operator >> (istream& IS, CviString *pStr)
{
    if(pStr)
		IS >> *pStr;

    return IS;
}
*/

//---------------------------------------------------------------------------
inline CviString& CviString::operator = (const CviString& other)
{
	Assign(other.m_lpszBuffer);

	return *this;
}

//---------------------------------------------------------------------------
inline CviString& CviString::operator = (LPCTSTR str)
{
	Assign(str);

	return *this;
}

//---------------------------------------------------------------------------
inline CviString& CviString::operator = (const TCHAR ch)
{
	TCHAR vBuf[2];

	vBuf[0] = ch;
	vBuf[1] = '\0';

	Assign(vBuf);

	return *this;
}

//---------------------------------------------------------------------------
inline CviString& CviString::operator + (const CviString& other)
{
	Add2(other.m_lpszBuffer);

	return *this;
}

//---------------------------------------------------------------------------
inline CviString& CviString::operator + (LPCTSTR str)
{
	Add2(str);

	return *this;
}

//---------------------------------------------------------------------------
inline CviString& CviString::operator + (const TCHAR ch)
{
	TCHAR vBuf[2];

	vBuf[0] = ch;
	vBuf[1] = '\0';

	Add2(vBuf);

	return *this;
}

//---------------------------------------------------------------------------
inline CviString& CviString::operator += (const CviString& other)
{
	Add2(other.m_lpszBuffer);

	return *this;
}

//---------------------------------------------------------------------------
inline CviString& CviString::operator += (LPCTSTR str)
{
	Add2(str);

	return *this;
}

//---------------------------------------------------------------------------
inline CviString& CviString::operator += (const TCHAR ch)
{
	TCHAR vBuf[2];

	vBuf[0] = ch;
	vBuf[1] = '\0';

	Add2(vBuf);

	return *this;
}

//---------------------------------------------------------------------------
inline int CviString::Compare(LPCTSTR str) const
{
	if (m_lpszBuffer && str)
	{
		return _tcscmp(m_lpszBuffer, str);
	}
	else
	{
		return -5;
	}
}

//---------------------------------------------------------------------------
inline int CviString::CompareNoCase(LPCTSTR str) const
{
	if (m_lpszBuffer && str)
	{
		return _tcsicmp(m_lpszBuffer, str);
	}
	else
	{
		return -5;
	}
}

//---------------------------------------------------------------------------
inline bool CviString::operator == (const CviString& other)
{
	return (Compare(other.m_lpszBuffer) == 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator == (LPCTSTR str)
{
	return (Compare(str) == 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator == (const TCHAR ch)
{
	return ((m_iStrLen != 1) ? false : (m_lpszBuffer[0] == ch));
}

//---------------------------------------------------------------------------
inline bool CviString::operator != (const CviString& other)
{
	return (Compare(other.m_lpszBuffer) != 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator != (LPCTSTR str)
{
	return (Compare(str) != 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator != (const TCHAR ch)
{
	return ((m_iStrLen != 1) ? true : (m_lpszBuffer[0] != ch));
}

//---------------------------------------------------------------------------
inline bool CviString::operator > (const CviString& other)
{
	return (Compare(other.m_lpszBuffer) > 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator > (LPCTSTR str)
{
	return (Compare(str) > 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator < (const CviString& other)
{
	return (Compare(other.m_lpszBuffer) < 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator < (LPCTSTR str)
{
	return (Compare(str) < 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator >= (const CviString& other)
{
	return (Compare(other.m_lpszBuffer) >= 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator >= (LPCTSTR str)
{
	return (Compare(str) >= 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator <= (const CviString& other)
{
	return (Compare(other.m_lpszBuffer) <= 0);
}

//---------------------------------------------------------------------------
inline bool CviString::operator <= (LPCTSTR str)
{
	return (Compare(str) <= 0);
}

//---------------------------------------------------------------------------
inline CviString::operator LPCTSTR() const
{
	return (LPCTSTR)m_lpszBuffer;
}

//---------------------------------------------------------------------------
inline TCHAR CviString::operator [] (int Idx)
{
	if (Idx < m_iBufLen)
	{
		return m_lpszBuffer[Idx];
	}
	else
	{
		return (TCHAR)0;
	}
}

//---------------------------------------------------------------------------
inline CviString::operator int() const
{
	return ToInt();
}

//---------------------------------------------------------------------------
inline CviString::operator unsigned int() const
{
	return ToUInt();
}

//---------------------------------------------------------------------------
inline CviString::operator long() const
{
	return ToLong();
}

//---------------------------------------------------------------------------
inline CviString::operator unsigned long() const
{
	return ToULong();
}

//---------------------------------------------------------------------------
inline CviString::operator float() const
{
	return ToFloat();
}

//---------------------------------------------------------------------------
inline CviString::operator double() const
{
	return ToDouble();
}

//---------------------------------------------------------------------------
inline int CviString::ToInt() const
{
	return (m_iStrLen) ? _ttoi(m_lpszBuffer) : 0;
}

//---------------------------------------------------------------------------
inline unsigned int CviString::ToUInt() const
{
	return (m_iStrLen) ? ((unsigned int)_tcstoul(m_lpszBuffer, NULL, 10)) : 0;
}

//---------------------------------------------------------------------------
inline long CviString::ToLong() const
{
	return (m_iStrLen) ? _ttol(m_lpszBuffer) : 0L;
}

//---------------------------------------------------------------------------
inline unsigned long CviString::ToULong() const
{
	return (m_iStrLen) ? _tcstoul(m_lpszBuffer, NULL, 10) : 0UL;
}

//---------------------------------------------------------------------------
inline double CviString::ToDouble() const
{
#ifdef _UNICODE
	return 0.0;
#else
	return (m_iStrLen) ? atof(m_lpszBuffer) : 0.0;
#endif

}

//---------------------------------------------------------------------------
inline LPTSTR CviString::_tcsdup_n(LPCTSTR str)
{
	LPTSTR lpszRet = NULL;

	if (str)
	{
		lpszRet = new TCHAR[_tcslen(str) + 1];
		if (lpszRet)
		{
			_tcscpy(lpszRet, str);
		}
	}

	return lpszRet;
}

//---------------------------------------------------------------------------
//-----							protected:							    -----
//---------------------------------------------------------------------------
inline bool CviString::Assign(LPCTSTR str)
{
	bool bRetVal = false;

	Clear();

	if (str)
	{
		m_lpszBuffer = _tcsdup_n(str);
		if (m_lpszBuffer)
		{
			m_iStrLen = _tcslen(str);
			m_iBufLen = m_iStrLen + 1;

			bRetVal = true;
		}
	}

	return bRetVal;
}

//---------------------------------------------------------------------------
inline bool CviString::Add2(LPCTSTR str)
{
    bool bRetVal = false;
	LPTSTR lpszTemp = NULL;

	if (str)
	{
		lpszTemp = new TCHAR[m_iStrLen + _tcslen(str) + 1];
		_stprintf(lpszTemp, _T("%s%s"), m_lpszBuffer, str);
		Assign(lpszTemp);

		delete lpszTemp;
		bRetVal = true;
	}

	return bRetVal;
}

//---------------------------------------------------------------------------
inline bool CviString::Add3(LPCTSTR str)
{
    bool bRetVal = false;
	LPTSTR lpszTemp = NULL;

	if (str)
	{
		lpszTemp = new TCHAR[m_iStrLen + m_iStrLen + _tcslen(str) + 1];
		_stprintf(lpszTemp, _T("%s%s%s"), m_lpszBuffer, m_lpszBuffer, str);
		Assign(lpszTemp);

		delete lpszTemp;
		bRetVal = true;
	}

	return bRetVal;
}

#endif //__CVISTRING_H_