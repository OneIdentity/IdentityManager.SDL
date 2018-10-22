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
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Collections;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Diagnostics;

using VI.Base;

namespace VI.JobService.JobComponents
{
	public class FileTransaction
	{
		private SortedList _sections;
		private SortedList _currentSection;
		private readonly string _filename;
		private readonly Encoding _encoding;

		public FileTransaction(string filename, string sectionname, Encoding encoding)
		{
			if ( string.IsNullOrEmpty(filename) )
				throw new ArgumentNullException("filename");

			_filename = filename;
			_encoding = encoding ?? Encoding.Default;

			_ReadIni();

			if ( !string.IsNullOrEmpty(sectionname) )
				_currentSection = _GetSection(sectionname);
		}

		public FileTransaction(string filename, string sectionname)
		: this(filename, sectionname, Encoding.Default)
		{}

		public FileTransaction(string filename, Encoding encoding)
		: this(filename, null, encoding)
		{ }

		public FileTransaction(string filename)
		: this(filename, (string)null)
		{}


		public void Commit()
		{
			_WriteIni();
		}

		[SuppressMessage("Microsoft.Performance", "CA1822:MarkMembersAsStatic")]
		public void Rollback()
		{
			// Do nothing?
		}

		public void BeginSection(bool init)
		{
			_CheckCurrentSection();

			if ( init )
				_currentSection.Clear();
		}

		public void BeginSection(string sectionname, bool init)
		{
			_currentSection = _GetSection(sectionname);

			BeginSection(init);
		}

		public void WriteKey(string keyname, object value)
		{
			_CheckCurrentSection();

			if ( _currentSection.Contains(keyname) )
			{
				if ( value != null )
					_currentSection[keyname] = value;
				else
					_currentSection.Remove(keyname);
			}
			else
			{
				if ( value != null )
					_currentSection.Add(keyname, value);
			}
		}

		public void WriteSections(string sections, bool overwrite)
		{
			if ( sections == null )
				throw new ArgumentNullException("sections");

			SortedList entries = _ReadSections(new StringReader(sections));

			try
			{
				if ( overwrite )
				{
					// Only put sections into our section table
					foreach ( DictionaryEntry section in entries )
					{
						_sections[section.Key] = section.Value;
					}
				}
				else
				{
					// Fill existing sections
					foreach ( DictionaryEntry section in entries )
					{
						string sectionname = section.Key as string;
						SortedList sectionentries = section.Value as SortedList;

						if ( string.IsNullOrEmpty(sectionname) || sectionentries == null )
							continue;

						BeginSection(sectionname, false);

						foreach ( DictionaryEntry entry in sectionentries )
						{
							string entrykey = entry.Key as string;

							if ( entrykey == null )
								continue;

							WriteKey(entrykey, entry.Value);
						}
					}
				}
			}
			finally
			{
				// Avoid writing into invalid section
				_currentSection = null;
			}
		}

		public string FileName
		{
			get
			{
				return _filename;
			}
		}

		#region Private members

		private void _CheckCurrentSection()
		{
			if ( _currentSection == null )
				throw new ApplicationException("No current section defined.");
		}

		private void _ReadIni()
		{

			AppData.Instance.RaiseMessage("ControlFilesComponent: Reading " + _filename);

			_sections = null;

			try
			{
				if ( File.Exists(_filename) )
				{
					// Only if config is already existant
					using ( StreamReader streamInput = new StreamReader(_filename, _encoding) )
					{
						_sections = _ReadSections(streamInput);
					}
				}
			}
			finally
			{
				if ( _sections == null )
					_sections = new SortedList(new CaseInsensitiveComparer());
			}
		}

		private static SortedList _ReadSections(TextReader reader)
		{
			string line;
			Regex regLine = new Regex("^\\s*([^=]+)=\\s*(\"?[^\"]*?\"?)\\s*$");
			Regex  regSection	= new Regex(@"^\[(.*)\]");
			SortedList	currentSection = null;

			Match  m;

			SortedList sections = new SortedList(new CaseInsensitiveComparer());

			while ( (line = reader.ReadLine()) != null )
			{
				if ( regSection.IsMatch(line) )
				{
					// Start of a new section
					m = regSection.Match(line);

					string name = m.Groups[1].Value;
					currentSection = sections[name] as SortedList;

					if ( currentSection == null )
					{
						currentSection = new SortedList(new CaseInsensitiveComparer());

						sections.Add(name, currentSection);
					}
				}
				else
				{
					// Normal line

					if ( currentSection != null )	// Only valid after section start
					{
						m = regLine.Match(line);

						if ( m.Success )	// Only if valid line
							currentSection[m.Groups[1].Value.TrimEnd()] = m.Groups[2].Value;
					}
				}
			}

			return sections;
		}

		[SuppressMessage("VI", "VI000:UseEnvironmentNewLine")]
		private void _WriteIni()
		{
			string dir = Path.GetDirectoryName(_filename);
			dir = Path.Combine(dir, Guid.NewGuid().ToString());	// append the UID_Directory
			string tmpfile = Path.Combine(dir, Path.GetFileName(_filename) );
			IDictionary entries;

			// Create temp-directory on demand
			if (! Directory.Exists(dir))
				Directory.CreateDirectory(dir);

			AppData.Instance.RaiseMessage("ControlFilesComponent: Writing to " + tmpfile);

			try
			{
				// Store data
				using ( StreamWriter writer = new StreamWriter( tmpfile, false, _encoding ) )
				{
					writer.NewLine = "\r\n";	// Force windows line breaks

					foreach ( DictionaryEntry section in _sections )
					{
						entries = section.Value as IDictionary;

						if ( entries == null || entries.Count == 0 )
							continue;	// Don't write empty sections

						writer.WriteLine("[{0}]", section.Key);

						foreach ( DictionaryEntry entry in entries )
						{
							if ( entry.Value == null || entry.Value.ToString().Length == 0 )
								writer.WriteLine("{0}=\"\"", entry.Key);
							else
								writer.WriteLine("{0}={1}", entry.Key, entry.Value);
						}

						writer.WriteLine("");
					}

					writer.Flush();
				}

				if ( AppData.Instance.RuntimeEnvironment.IsMono )
				{
					// take rights from old to new file
					string parms = "-c 'getfacl \"" + _filename + "\" | setfacl --set-file=- \"" + tmpfile + "\"'";

					// Old: chmod parameters
					//string cmd = "`stat -c %a \"" + _filename + "\"` \"" + tmpfile + "\"";

					try
					{
						AppData.Instance.RaiseMessage("ControlFilesComponent: Copying permissions from " + _filename + " to " + tmpfile);

						Process p = Process.Start("bash", parms);
						p.WaitForExit();
					}
					catch ( Exception ex )
					{
						AppData.Instance.RaiseMessage("ControlFilesComponent: Copying permissions failed with \"" + ex.Message + "\"");
					}
				}

				for (int i = 0; i < 5; i++)
				{
					try
					{
						AppData.Instance.RaiseMessage("ControlFilesComponent: Deleting " + _filename);
						File.Delete(_filename);
						AppData.Instance.RaiseMessage("ControlFilesComponent: Renaming " + tmpfile + " to " + _filename);
						File.Move(tmpfile, _filename);
						break;	// No more retries
					}
					catch (IOException exc)
					{
						AppData.Instance.RaiseMessage("...failed with exception: " + ViException.ErrorString(exc));

						if (i < 4)
						{
							AppData.Instance.RaiseMessage("Retry: " + (i + 1) );
							// stop thread for 100 to 500 milliseconds
							Thread.Sleep(new Random().Next(100, 500));
						}
						else
						{
							AppData.Instance.RaiseMessage("Finally failed!");
							// Remove temporary file
							File.Delete(tmpfile);

							throw;
						}
					}
				}
			}
			finally
			{
				try
				{
					if ( File.Exists(tmpfile) )
						File.Delete(tmpfile);

					// Delete directory on demand
					if ( Directory.Exists(dir) )
						Directory.Delete(dir);
				}
				catch ( Exception ex )
				{
					AppData.Instance.RaiseMessage(MsgSeverity.Serious, "Error during cleanup: " + ex.Message);
				}
			}
		}

		/// <summary>
		/// Get or create section hash table.
		/// </summary>
		/// <param name="name"></param>
		/// <returns></returns>
		private SortedList _GetSection(string name)
		{
			SortedList section = _sections[name] as SortedList;

			if ( section == null )
			{
				// Section does not exist
				// -> create it
				section = new SortedList(new CaseInsensitiveComparer());

				// and add it to sections
				_sections.Add(name, section);
			}

			return section;
		}

		#endregion
	}

}
