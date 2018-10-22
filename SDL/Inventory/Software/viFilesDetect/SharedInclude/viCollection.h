
#ifndef VICOLLECTION_H
#define VICOLLECTION_H

#ifndef __cplusplus
#error This headerfile must only be included in C++ projects
#endif

#include <windows.h>
#include <string.h>
#include <tchar.h>

#define HASH_SIZE		101
#define ARRAY_SIZE		100
#define MIN_ARRAY_SIZE	 10
#define MIN_HASH_SIZE	  1
#define DFLT_KEYLEN		  8


/** A hash table element class.

	The class CHashElem is a helper class for CHashTable. It
	provides functions for creation and manipulation of hash table
	entries.
*/

template<class T>
class CHashElem
{
public:
	/** The constructor of CHashElem.
		The parameters are
		@param name The key of this entry
		@param data	The data entry
		@param should_delete	Should the data be deleted by our destructor?
	*/
	CHashElem(LPCTSTR name, T* data = NULL, bool should_delete = true)
	{
		if (name)
			m_pszName = _tcsdup(name);
		else
			m_pszName = NULL;

		m_pData = data;
		m_bShouldDelete = should_delete;
		m_pNext = NULL;
	}

	/** The destructor.
		It deletes also all following elements. If should_delete is set to true
		in the constructor the data is also deleted
	*/
	~CHashElem()
	{
		if (m_pszName)
			free(m_pszName);
		if (m_bShouldDelete && m_pData)
			delete m_pData;
		if (m_pNext)
			delete m_pNext;	// delete next element
	}

	/** Remove this or one of the following elements.
		The element with the given name will be removed.
	*/
	virtual bool Remove(LPCTSTR name, CHashElem<T>*& pElem)
	// returns pointer to next element
	{
		if (_tcscmp(name, m_pszName) == 0)	// it's me
		{
			pElem = m_pNext;
			
			m_pNext = NULL;	// to avoid destroying of next element
			delete this;
			return true;
		}
		else if (m_pNext)
			return m_pNext->Remove(name, m_pNext);	// ask next to remove itself
		else
			return false;	// not found
	}

	/// Set a new data value to this element.
	bool SetData(T* data)
	{
		if (m_bShouldDelete && m_pData)
			delete m_pData;
		m_pData = data;
	}

	/// Get the data value.
	T* GetData()
	{
		return m_pData;
	}

	/// Get the following entry if there is one.
	CHashElem<T>* GetNext()
	{
		return m_pNext;
	}

	/// Set the next hash entry.
	bool SetNext(CHashElem<T>* NextElem)
	{
		if (_tcscmp(m_pszName, NextElem->m_pszName) == 0)
		{
			delete NextElem;	// destroy the wrong element
			return false;	// already in table
		}

		if (m_pNext)
			return m_pNext->SetNext(NextElem);
		else
			m_pNext = NextElem;
		return true;
	}

	/** Get the element with the given name.
		Returns NULL if it's not this or one of the following elements.
	*/
	T* GetElem(LPCTSTR name)
	{
		if (_tcscmp(name, m_pszName) == 0)
			return m_pData;	// it's me
		else if (m_pNext)
			return m_pNext->GetElem(name);	// ask next
		else
			return NULL;	// not found
	}

//#ifdef _DEBUG
//	/// Count the elements after this in the same row.
//	unsigned long Count()
//	{
//		if (m_pNext)
//			return m_pNext->Count() + 1;
//		else
//			return 1;
//	}
//#endif

	/// Our key
	LPTSTR			m_pszName;

private:
	/// Should the data value be deleted?
	bool			m_bShouldDelete;
	/// The next element in this row
	CHashElem<T>*	m_pNext;
	/// The data element
	T*				m_pData;
};


/** A template hash table class.

	This class is a 
	HashTable which implements the djb2 algorithm.
	This algorithm was first reported by dan bernstein 
	many years ago in comp.lang.c. Another version of this algorithm 
	(now favored by bernstein) uses xor: hash(i) = hash(i - 1) * 33 ^ str[i]; the magic 
	of 33 has never been adequately explained. 

	@see CHashElem
*/

template<class T>
class  /* __declspec(dllexport) */ CHashTable
{
public:
	/** The constructor.
		It accepts following parameters:

		@param size The size of the hash table. For optimal results it should be a prime number.
		@should_delete Should the data entries be deleted in the destructor or Remove functions?
	*/
	CHashTable(unsigned long size = HASH_SIZE, bool should_delete = true)
	{		
		m_ulTableSize = size < MIN_HASH_SIZE ? MIN_HASH_SIZE : size;
		m_bShouldDelete = should_delete;
		m_vTable = new CHashElem<T>*[m_ulTableSize];
		memset(m_vTable, 0, sizeof(CHashElem<T>*) * m_ulTableSize);
		m_pszLastName = NULL;
	}

	/// The destructor.
	virtual ~CHashTable()
	{
		unsigned long l;
		for (l=0; l < m_ulTableSize; l++)
		{
			if (m_vTable[l])
				delete m_vTable[l];
		}
		delete[] m_vTable;
	}

	/** Add an entry to the hash table.
		@param name	Key of the entry.
		@param data Data value.
	*/
	virtual bool Add(LPCTSTR name, T* data)
	{
		CHashElem<T>* myElem;
		unsigned long pos;

		if (!name)
			return false;

		myElem = new CHashElem<T>(name, data, m_bShouldDelete);
		pos = GetHashValue(name);
		
		m_pszLastName = myElem->m_pszName;

		if (m_vTable[pos])
			return m_vTable[pos]->SetNext(myElem);
		else
			m_vTable[pos] = myElem;
		return true;
	}

	/** Find the specified entry.
		@param name	Key of the searched entry.
	*/
	virtual T* Find(LPCTSTR name)
	{
		unsigned long pos;

		if (!name)
			return false;

		pos = GetHashValue(name);
		
		if (m_vTable[pos])
			return m_vTable[pos]->GetElem(name);
		else
			return NULL;
	}

	/** Remove the specified entry.
		@param name	Key of the entry.
	*/
	virtual bool Remove(LPCTSTR name)
	{
		unsigned long pos;

		if (!name)
			return false;

		if (m_pszLastName && (_tcscmp(name, m_pszLastName) == 0))
			m_pszLastName = NULL;

		pos = GetHashValue(name);

		if (m_vTable[pos])
			return m_vTable[pos]->Remove(name, m_vTable[pos]);
		else
			return false;
	}

	/** Clear the hash table.
		All entries will be removed. If should_delete was true in the
		constructor the data elements will also be deleted.
	*/
	virtual void Clear()
	{
		unsigned long i;

		for (i = 0; i < m_ulTableSize; i++)
		{
			if (m_vTable[i])
			{
				delete m_vTable[i];
				m_vTable[i] = NULL;
			}
		}

		m_pszLastName = NULL;
	}

//#ifdef _DEBUG
	/** Counts the entries per hash table cell.
		ONLY for debug purposes.
	*/
//	virtual unsigned long Count(unsigned long pos)
//	{
//		return m_ulTableSize;
//
//		if (pos >= m_ulTableSize || !m_vTable[pos])
//			return 0UL;
//		else
//			return m_vTable[pos]->Count();
//	}
//#endif
	
private:
	/// Size of hash table
	unsigned long	m_ulTableSize;
	/// The real hash table
	CHashElem<T>**	m_vTable;

protected:
	/// Do we have to delete our members?
	bool			m_bShouldDelete;
	/// Pointer to last inserted key
	LPTSTR			m_pszLastName;

	/** The hash function.
		Simply overwrite this function for new behaviour.

		@param str Key of the entry.
		@return position in the hash table.
	*/
	virtual unsigned long
    GetHashValue(LPCTSTR str)
    {
        unsigned long hash = 5381;
        int c;

        while (c = *str++)
            hash = ((hash << 5) + hash) + c;

        return hash % m_ulTableSize;
    }
};

/** A helper class for CCollection.
*/

template <class T>
class CCollElem 
{
public:
	/** The constructor.
		@param ShouldDelete Should the data be deleted in the destructor?
	*/
	CCollElem(bool ShouldDelete = false) 
		: m_bDelete(ShouldDelete)
	{
		m_pData = NULL;
		m_pszKey = NULL;
	}

	/// The destructor
	~CCollElem() 
	{
		if (m_bDelete && m_pData && 
			!m_pszKey)	// We MUST NOT delete the data, if it is in a hash table!!!
			delete m_pData;
	}

	/// Our data object
	T*				m_pData; 
	/// The key, which is used for this object in the hash table.
	LPTSTR			m_pszKey;
protected:
	/// Should the data be deleted?
	bool			m_bDelete;
};

/** A template collection class.
	
	This collection class implements the methods and properties of the
	Visual Basic collection class. It is based on a dynamic array, so random 
	access per numeric index is very fast.

	@see CCollElem
*/
template <class T>
class /* __declspec(dllexport) */ CCollection : protected CHashTable<T>
{
public:	
	/** The constructor

		@param array_size Initial size of the data array.
		@param hash_size Size of the hash table. Should be a prime number for
							optimal results.
		@param should_delete Should the data members be deleted by this class?
	*/
	CCollection(unsigned long array_size = ARRAY_SIZE,
				unsigned long hash_size = HASH_SIZE, 
				bool should_delete = true);
	/// The destructor.
	/* virtual */ ~CCollection();

	/** Add an item using the associated key.
		
		If the key is NULL, there is not entry done in the hash table.

		@param data The data item.
		@param key The key, which must be unique.
	*/
	/* virtual */ bool Add(T* data, LPCTSTR key = NULL);
	/** Add an item at the specified position.

		@param data The data item.
		@param pos The position where the item should be added.
	*/
	/* virtual */ bool Add(T* data, long pos);
	
	/// The index of the last added item.
	/* virtual */ unsigned long LastIndex() const;
	
	/** Remove one item.
		@param key The key of the item which should be removed.
	*/
	/* virtual */ bool Remove(LPCTSTR key);

	/** Remove one item.
		@param pos The position of the item which should be removed.
	*/
	/* virtual */ bool Remove(unsigned long pos);

	/// Clear the collection
	/* virtual */ void Clear();

	/// Count of items in the collection.
	/* virtual */ unsigned long Count() const;

	/** Sort the Collection.

		For sorting the collection the Quick Sort algorithm is used.
		Every class, which should be stored must implement the > operator
	*/
	/* virtual */ bool Sort();
	/// Get the item at position pos
	/* virtual */ T* Item(unsigned long pos);
	/// Get the item which was inserted using the key
	/* virtual */ T* Item(LPCTSTR key);
	/// Get the item at position pos
	/* virtual */ T* operator[](unsigned long pos);
	/// Get the item which was inserted using the key
	/* virtual */ T* operator[](LPCTSTR key);
	/// Get the item at position pos
	/* virtual */ const T* Item(unsigned long pos) const;
	/// Get the item which was inserted using the key
	/* virtual */ const T* Item(LPCTSTR key) const;
	/// Get the item at position pos
	/* virtual */ const T* operator[](unsigned long pos) const;
	/// Get the item which was inserted using the key
	/* virtual */ const T* operator[](LPCTSTR key) const;

protected:
	/// Increase the size of the array
	/* virtual */ bool ReDim(unsigned long oldsize, unsigned long newsize);
	/// help function for the sort algorithm
	/* virtual */ void Sort(long lo, long up);

private:
	/// Our array of elements
	CCollElem<T>**	m_pArray;
	/// The current size of the array
	unsigned long	m_ulSize;
	/// Position of the first free array cell
	unsigned long	m_ulPos;
	/// Increase step if array is to small
	unsigned long	m_ulInc;
	/// Index of the last added element
	unsigned long	m_ulLastIndex;
	//	unsigned long	m_ulAddCnt;
};

template <class T>
CCollection<T>::CCollection(unsigned long array_size,
				unsigned long hash_size, 
				bool should_delete)
				: CHashTable<T>(hash_size, should_delete)
{
	m_pArray = NULL;
	m_ulSize = 0;
	m_ulPos = 0;

	m_ulInc = array_size < MIN_ARRAY_SIZE ? MIN_ARRAY_SIZE : array_size;
	m_ulLastIndex = 0;

	ReDim(0, (array_size < MIN_ARRAY_SIZE ? MIN_ARRAY_SIZE : array_size));

}

template <class T>
CCollection<T>::~CCollection()
{
	unsigned long i;

	if (m_pArray)
	{
		for (i = 0; i < m_ulPos; i++)
			delete m_pArray[i];

		delete[] m_pArray;
	}
}

template <class T>
bool CCollection<T>::Add(T* data, LPCTSTR key)
{
	CCollElem<T>* pElem;
	bool bRet;

	if (!data)
		return false;

	if (m_ulPos >= m_ulSize)
		if (!ReDim(m_ulSize, m_ulSize + m_ulInc))
			return false;

	if (key)
		bRet = CHashTable<T>::Add(key, data);
	else	// Add without key
		bRet = true;

	if (bRet)
	{
		// create new element, if it is also in the hash table we must not destroy it
		// if it is not in the hash table we MUST destroy it
		pElem = new CCollElem<T>(!key && m_bShouldDelete);
		
		if (key)
			pElem->m_pszKey = CHashTable<T>::m_pszLastName;
		else
			pElem->m_pszKey = NULL;

		pElem->m_pData = data;
		m_ulLastIndex = m_ulPos;
		m_pArray[m_ulPos++] = pElem;
		return true;
	}
	else
		return false;
}

template <class T>
bool CCollection<T>::Add(T* data, long pos)
{
	CCollElem<T>* pElem;

	if (!data)
		return false;

	// standard value for pos --> first new position
	if (pos < 0|| (unsigned long)pos > m_ulPos)
		pos = m_ulPos;

	if (m_ulPos >= m_ulSize)
		if (!ReDim(m_ulSize, m_ulSize + m_ulInc))
			return false;

	long i;

	pElem = new CCollElem<T>(m_bShouldDelete);
	pElem->m_pszKey = NULL;
	pElem->m_pData = data;
	// shift all elements backward
	for (i = (long)m_ulPos - 1; i >= pos; i--)
		m_pArray[i+1] = m_pArray[i];
	// insert new element
	m_pArray[pos] = pElem;
	m_ulLastIndex = (unsigned long)pos;
	// increment size of used places
	m_ulPos++;
	return true;
}

template <class T>
inline unsigned long CCollection<T>::LastIndex() const
{
	return m_ulLastIndex;
}

template <class T>
bool CCollection<T>::Remove(LPCTSTR key)
{
	// **********************************************************
	// this function is very ineffective
	// --> sequential search
	// please avoid to use it
	// **********************************************************

	unsigned long i;

	if (!key)
		return false;

	for (i = 0; i < m_ulPos; i++)
		if (m_pArray[i]->m_pszKey && _tcscmp(m_pArray[i]->m_pszKey, key) == 0)
			return Remove(i);

	return false;
}

template <class T>
bool CCollection<T>::Remove(unsigned long pos)
{
	bool bRet;

	if (pos >= m_ulPos)
		return false;

	if (m_pArray[pos]->m_pszKey)
		bRet = CHashTable<T>::Remove(m_pArray[pos]->m_pszKey);
	else
		bRet = true;

	if (bRet)
	{
		unsigned long i;

		// remove array element on position pos
		delete m_pArray[pos];

		// move all elements after 1 position to front
		for (i = pos + 1; i < m_ulPos; i++)
			m_pArray[i - 1] = m_pArray[i];

		// decrement size of used array elements
		m_ulPos--;
	}

	return bRet;
}

template <class T>
void CCollection<T>::Clear()
{
	unsigned long i;

	// delete array elements
	for (i = 0; i < m_ulPos; i++)
		delete m_pArray[i];

	// set fill value
	m_ulPos = 0;

	// clear hash table
	CHashTable<T>::Clear();
}

/*
template <class T>
inline unsigned long CCollection<T>::Count() const
{
	MessageBox(NULL, _T("CCollection<T>::Count()"), _T("Info"), 0);
	DebugBreak();
	return m_ulPos;
}
*/

template <class T>
unsigned long CCollection<T>::Count() const
{
	return m_ulPos;
}

template <class T>
bool CCollection<T>::Sort()
{
	if (m_ulPos > 1)
		Sort(0, m_ulPos - 1);	

	return true;
}


template <class T>
inline T* CCollection<T>::Item(unsigned long pos)
{
	if (pos >= m_ulPos)
		return NULL;

	return m_pArray[pos]->m_pData;
}

template <class T>
inline T* CCollection<T>::Item(LPCTSTR key)
{
	if (!key)
		return NULL;
	return Find(key);
}
	
template <class T>
inline T* CCollection<T>::operator[](unsigned long pos)
{
	return Item(pos);
}

template <class T>
inline T* CCollection<T>::operator[](LPCTSTR key)
{
	return Item(key);
}

template <class T>
inline const T* CCollection<T>::Item(unsigned long pos) const 
{
	return ((CCollection<T>*)this)->Item(pos);
}

template <class T>
inline const T* CCollection<T>::Item(LPCTSTR key) const 
{
	return ((CCollection<T>*)this)->Item(key);
}
	
template <class T>
inline const T* CCollection<T>::operator[](unsigned long pos) const 
{
	return ((CCollection<T>*)this)->Item(pos);
}

template <class T>
const T* CCollection<T>::operator[](LPCTSTR key) const 
{
	return ((CCollection<T>*)this)->Item(key);
}

template <class T>
inline bool CCollection<T>::ReDim(unsigned long oldsize, unsigned long newsize)
{
	CCollElem<T>** p_newArray;
	
	if (newsize < oldsize)
		return false;

	if (newsize == oldsize)	// initial size was 0
		newsize++;

	p_newArray = new CCollElem<T>*[newsize];

	if (oldsize > 0)	// not initial
	{
		unsigned long i;

		for (i=0; i<oldsize; i++)
			p_newArray[i] = m_pArray[i];

		//delete []m_pArray;
		delete m_pArray;
	}

	m_ulSize = newsize;

	m_pArray = p_newArray;

	return true;
}

template <class T>
void CCollection<T>::Sort(long lo, long up )
{
	long  i, j;

	CCollElem<T>* tempr;
	
	while ( up > lo ) 
	{          
		i = lo;          
		j = up;
        tempr = m_pArray[lo];          /*** Split file in two ***/
        while ( i < j ) 
		{               
			for ( ; j>0 && *m_pArray[j]->m_pData > *tempr->m_pData; j-- );
				for ( m_pArray[i] = m_pArray[j]; i < j && 
					  !(*m_pArray[i]->m_pData > *tempr->m_pData); i++ );	/*** <= is equal to !> ***/
            m_pArray[j] = m_pArray[i];
		}          
		m_pArray[i] = tempr;
          
		/*** Sort recursively, the smallest first ***/
        if ( i - lo < up - i ) 
		{ 
			Sort(lo, i - 1);  
			lo = i + 1; 
		}
        else    
		{ 
			Sort(i + 1, up);  
			up = i - 1; 
		}          
	}     
}

/*
template <class T>
void CCollection<T>::_BuildDummyKey(LPTSTR key)
{
	unsigned int i;
	TCHAR val;

	// build unique key (ONLY UNIQUE FOR THIS COLLECTION) 
	for (i=0; i < DFLT_KEYLEN; i++)
	{
		val = (char)((m_ulAddCnt >> 4 * i) & 0xF);
		if (val < 0xA)
			key[DFLT_KEYLEN - 1 - i] = val + 0x30;
		else
			key[DFLT_KEYLEN - 1 - i] = val + 0x37;
	}
	m_ulAddCnt++;
	key[DFLT_KEYLEN] = '\0';
}*/

/*
template <class T>
class CTest1
{
	long lval;
	T* data;

public:
	CTest1() { lval = 0; data = NULL; }

	void IncLVal(void) { lval++; }

	long GetLVal(void)	{ return lval; }
};
*/

#endif	// VICOLLECTION_H