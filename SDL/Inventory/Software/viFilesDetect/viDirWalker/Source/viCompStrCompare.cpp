//viCompStrCompare.cpp
//

#include "stdafx.h"
#include "viCompStrCompare.h"	//Header

const int KLEINER	  = -1;
const int GROESSER	  =  1;
const int GLEICH	  =  0;
const int NICHTGLEICH = -10;


INT viCompareString( LPCTSTR strWildCard, LPCTSTR strFileName )
{
	INT iReturn;

	LPTSTR strWildCardUpper;
	LPTSTR strFileNameUpper;

	// copy string
	strWildCardUpper = _tcsdup( strWildCard );
	strFileNameUpper = _tcsdup( strFileName );;

	// convert to uppercase
	strWildCardUpper = _tcsupr( strWildCardUpper );
	strFileNameUpper = _tcsupr( strFileNameUpper );

	// use case sensitive version
	iReturn = viCompareStringCS( strWildCardUpper, strFileNameUpper );

	// release the buffers
	if ( strWildCardUpper ) free( strWildCardUpper );
	if ( strFileNameUpper ) free( strFileNameUpper );

	return iReturn;
}


INT viCompareStringCS( LPCTSTR strWildCard, LPCTSTR strFileName )
{
// Vergleicht die beiden Strings st1 und st1 auf Gleichheit.
// Wildcards "?" und "*" dürfen nur in strWildCard enthalten sein.

	int i = 0;
	int j;
	
	while ((strWildCard[i] != 0) && (strFileName[i] != 0))
	{
		switch (strWildCard[i])
		{
		case '*':
			{	//beliebig viele (0..n) Zeichen sind wurscht
				int k;

				j = i;
				while (strWildCard[i] == '*')	//alle hintereinander sitzenden Sterne zusammenfassen
					i++;
				k = i;
				if (strWildCard[k] == 0)
					return GLEICH;	//Egal was strFileName noch bietet. Ist total egal.

				while (strFileName[j] != 0)
				{
					if (strFileName[j] == strWildCard[k] || (strWildCard[k] == '?'))
					{
						if (viCompareStringCS(&strWildCard[k], &strFileName[j]) == GLEICH)
							return GLEICH;
					}

					j++;
				}

				//Ich verlange noch mindestens ein Zeichen, aber die Gleichheit kommt nicht zu stande
				return NICHTGLEICH;	//da kein Vergleich zuvor erfolgreich
			}	break;
		case '?':
			{	//ein Zeichen ist wurscht
				return viCompareStringCS(&strWildCard[i + 1], &strFileName[i + 1]);
			}	break;
		default:
			{	//Zeichen muß gleich sein
				if (strWildCard[i] != strFileName[i])
				{	//Ungleichheit gefunden
					if (strWildCard[i] < strFileName[i]) 
					{
						return KLEINER;
					} else {
						return GROESSER;
					}
				}
			}	break;
		}

		i++;
	}

	j = i;
	while (strWildCard[j] == '*')
		j++;

	if ((strWildCard[j] == 0) && (strFileName[i] == 0))
	{
		return GLEICH;	//strWildCard und strFileName sind gleich
	}

	return NICHTGLEICH;	//strWildCard und strFileName sind ungleich

	
}
