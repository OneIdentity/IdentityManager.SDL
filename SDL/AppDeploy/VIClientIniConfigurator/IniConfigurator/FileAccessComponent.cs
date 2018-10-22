#region One Identity - Open Source License
//
// One Identity - Open Source License
//
// Copyright 2018 One Identity LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software. Any and all copies of the above
// copyright and this permission notice contained in the Software shall not be
// removed, obscured, or modified.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
#endregion


using System;
using System.IO;
using System.Text;
using System.Collections;

namespace IniConfigurator
{
	/// <summary>
	/// Verwaltet eine Hashtable für die sections, in welcher wiederum Hashtables für die Keys gespeichert sind,
	/// in denen die Werte der Keys drin sind. Keys, die nicht ausgelesen wurden, sind nicht in der table drin,
	/// keys, die auf null gesetzt wurden, sind in der Hashtable drin mit einem Verweis auf ein Objekt vom typ
	/// object.
	/// </summary>
	public class FileAccessComponent : IDataProvider
	{
		private string fileName;
		public string FileName { get { return( this.fileName ); } }
		private DefaultValueProvider defaultValueProvider;

		private Hashtable sections;
		private StringBuilder buffer;
		private int sizeMax;

		public FileAccessComponent( string fileName, DefaultValueProvider defaultValueProvider )
		{
			this.fileName = fileName;
			this.defaultValueProvider = defaultValueProvider;
			this.sections = new Hashtable();
			this.sizeMax = 65536;
			this.buffer = new StringBuilder( this.sizeMax, this.sizeMax );
		}

		public string GetValue( string sectionName, string keyName )
		{
			IniSectionEntry sectionEntry = (IniSectionEntry) this.sections[ sectionName ];

			if ( sectionEntry == null )
			{
				sectionEntry = new IniSectionEntry( sectionName );
				this.sections[ sectionName ] = sectionEntry;
			}

			IniFileEntry entry = (IniFileEntry) sectionEntry.Values[ keyName ];

			if ( entry == null )
			{
				Helper.GetPrivateProfileStringA( sectionName, keyName, "$|VI_NOTFOUND|$", this.buffer, this.sizeMax, this.fileName );
				string value = this.buffer.ToString();

				if ( value.Equals( "$|VI_NOTFOUND|$" ) )
				{
					entry = new IniFileEntry( keyName, this.defaultValueProvider.GetDefaultValue( sectionName, keyName ) );
				}
				else
					entry = new IniFileEntry( keyName, value );

				sectionEntry.Values[ keyName ] = entry;
			}

			return( entry.Value );
		}

		public void SetValue( string sectionName, string keyName, string value, bool deleteSectionIfEmpty )
		{
			IniSectionEntry sectionEntry = (IniSectionEntry) this.sections[ sectionName ];

			if ( sectionEntry == null )
			{
				sectionEntry = new IniSectionEntry( sectionName );
				this.sections[ sectionName ] = sectionEntry;
			}

			sectionEntry.DeleteSectionIfEmpty = deleteSectionIfEmpty;

			IniFileEntry entry = (IniFileEntry) sectionEntry.Values[ keyName ];

			if ( entry == null )
			{
				entry = new IniFileEntry( keyName, null );
				sectionEntry.Values[ keyName ] = entry;
			}

			entry.Value = value;
		}

		/// <summary>
		/// Speichert alle Werte, die sich geändert haben.
		/// </summary>
		/// <param name="saveDefaults"></param>
		public void Save( bool saveDefaults )
		{
			if ( this.fileName == null )
				throw new Exception( "No file name set." );

			foreach ( IniSectionEntry sectionEntry in this.sections.Values )
			{
				foreach ( IniFileEntry entry in sectionEntry.Values.Values )
				{
					if ( entry.Altered )
					{
						string defaultValue = this.defaultValueProvider.GetDefaultValue( sectionEntry.SectionName, entry.KeyName );

						if ( entry.Value == defaultValue )
						{
							if ( saveDefaults )
								Helper.WritePrivateProfileStringA( sectionEntry.SectionName, entry.KeyName, entry.Value, this.fileName );
							else
								Helper.WritePrivateProfileStringA( sectionEntry.SectionName, entry.KeyName, null, this.fileName );
						}
						else
							Helper.WritePrivateProfileStringA( sectionEntry.SectionName, entry.KeyName, entry.Value, this.fileName );
					}
					else
					{
						string defaultValue = this.defaultValueProvider.GetDefaultValue( sectionEntry.SectionName, entry.KeyName );

						if ( ( entry.Value == defaultValue ) && ( saveDefaults ) )
							Helper.WritePrivateProfileStringA( sectionEntry.SectionName, entry.KeyName, defaultValue, this.fileName );
					}

					// delete section if empty ?
					if ( ( sectionEntry.DeleteSectionIfEmpty ) && ( Helper.GetPrivateProfileSectionA( sectionEntry.SectionName, this.buffer, 3, this.fileName ) == 0 ) )
					{
						// section empty -> delete
						Helper.WritePrivateProfileSectionA( sectionEntry.SectionName, null, this.fileName );
					}
				}
			}

			//Falls das File nach dem Speichern keine Werte aufweisen sollte, erstelle einfach ein leeres.
			if ( !File.Exists( this.fileName ) )
				using ( File.Create( this.FileName ) ) {}
		}

		/// <summary>
		/// Kopiert das aktuelle file an den Zielort, falls es dort noch nicht existiert, setzt fileName member und
		/// speichert alle Änderungen.
		/// </summary>
		/// <param name="fileName"></param>
		/// <param name="saveDefaults"></param>
		public void SaveAs( string fileName, bool saveDefaults )
		{
			if ( this.fileName != null )
			{
				System.IO.File.Copy( this.fileName, fileName, true );
			}

			this.fileName = fileName;
			this.Save( saveDefaults );
		}
	}
}
