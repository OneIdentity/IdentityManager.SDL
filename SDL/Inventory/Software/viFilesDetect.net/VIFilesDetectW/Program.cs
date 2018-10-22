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
using System.Collections.Specialized;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using NConsoler;

namespace VIFilesDetectW
{
    class VIFilesDetectW
    {
        static void Main(params string[] args)
        {
            Consolery.Run(typeof(VIFilesDetectW), args);
            //Console.ReadLine();
        }

        [Action]
        public static void ParseCommandLine(
            [Required(Description="Output directory")]
            string PathName,
            [Optional("*", Description="Drive to search")]
            string Drive,
            [Optional("+*.exe|+*.com", Description="Files to scan")]
            string Files,
            [Optional("+*", Description="Directories to scan")]
            string Dirs,
            [Optional("NRB", Description="Attributes to fetch")]
            string Get,
            [Optional("Idle", Description="System load")]
            string P,
            [Optional(false, Description="Scan only exe files")]
            bool Exe,
            [Optional("cwd", Description="Working directory")]
            string BaseDir)
        {
            StringCollection scFilePattern = new StringCollection();
            StringCollection scDirPattern = new StringCollection();
			StringCollection colFiles = new StringCollection();
			ProcessingErrors colErrors = new ProcessingErrors();
            string[] sFilePatternArr;
            string[] sTargetFiles;

            string[] sDirPatternArr;

            if (string.Equals(BaseDir, "cwd", StringComparison.OrdinalIgnoreCase))
                BaseDir = System.IO.Directory.GetCurrentDirectory();

            if (!System.IO.Path.HasExtension(PathName))
            {
                string sFileName = String.Empty;
                sFileName = System.DateTime.Now.ToString("yyyyMMddHHmmss") + System.Environment.MachineName + ".xml";
                PathName = System.IO.Path.Combine(PathName, sFileName);
            }

            // Files
            if (!Exe)
            {
                if (Files.Contains("|"))
                {
                    foreach (string sPattern in Files.Split('|'))
                    {
                        if (!sPattern.StartsWith("+") && !sPattern.StartsWith("-"))
                        {
                            Console.WriteLine("Wrong filter for files specified.");
                            System.Environment.Exit(-1);
                        }
                        if (sPattern.StartsWith("+"))
                        {
                            scFilePattern.Add(sPattern.Remove(0, 1));
                        }
                    }
                }
                else
                {
                    if (!Files.StartsWith("+") && !Files.StartsWith("-"))
                    {
                        Console.WriteLine("Wrong filter for files specified.");
                        System.Environment.Exit(-1);
                    }
                    if (Files.StartsWith("+"))
                    {
                        scFilePattern.Add(Files.Remove(0, 1));
                    }
                }
            }
            else
            {
                scFilePattern.Add("*.exe");
            }

            sFilePatternArr = new String[scFilePattern.Count];
            scFilePattern.CopyTo(sFilePatternArr, 0);

            // Directories
            if (Dirs.Contains("|"))
            {
                foreach (string sPattern in Dirs.Split('|'))
                {
                    if (!sPattern.StartsWith("+") && !sPattern.StartsWith("-"))
                    {
                        Console.WriteLine("Wrong filter for directories specified.");
                        System.Environment.Exit(-1);
                    }
                    if (sPattern.StartsWith("+"))
                    {
                        scDirPattern.Add(sPattern.Remove(0, 1));
                    }
                }
            }
            else
            {
                if (!Dirs.StartsWith("+") && !Dirs.StartsWith("-"))
                {
                    Console.WriteLine("Wrong filter for directories specified.");
                    System.Environment.Exit(-1);
                }
                if (Dirs.StartsWith("+"))
                {
                    scDirPattern.Add(Dirs.Remove(0, 1));
                }
            }

            sDirPatternArr = new String[scDirPattern.Count];
            scDirPattern.CopyTo(sDirPatternArr, 0);

			GetFiles(colFiles, colErrors, BaseDir, sFilePatternArr);

			CreateXML_1(PathName, colFiles, colErrors);
        }

		private static void CreateXML_1(string sFileName, StringCollection colFiles, ProcessingErrors colErrors)
        {
            XmlDocument xmlFile = new XmlDocument();
            XmlElement xmlAppdetect;
            XmlElement xmlFiles;
            XmlElement xmlFileName;
            XmlElement xmlFileResources;
            XmlElement xmlFileResource;
			XmlElement xmlIconImprint;
            XmlElement xmlFileBinImprint;
            XmlElement xmlErrorReport;
			XmlElement xmlError;

            xmlFile.AppendChild(xmlFile.CreateXmlDeclaration("1.0", "UTF-8", ""));

            xmlAppdetect = xmlFile.CreateElement("AppDetect");
            xmlAppdetect.SetAttribute("ComputerName", System.Environment.MachineName);
            xmlAppdetect.SetAttribute("UserName", System.Environment.UserName);
            xmlAppdetect.SetAttribute("ProcessTime", System.DateTime.Now.ToString("yyyyMMddHHmmss"));

			foreach (string sFile in colFiles)
            {
				try
				{
					xmlFiles = xmlFile.CreateElement("File");

					xmlFileName = xmlFile.CreateElement("Name");
					xmlFileName.SetAttribute("FileName", Path.GetFileName(sFile));
					xmlFileName.SetAttribute("PathName", Path.GetDirectoryName(sFile));
					FileInfo FileInfo = new FileInfo(sFile);

					using(FileStream fin = FileInfo.Open(FileMode.Open, FileAccess.Read))
					{
						xmlFileName.SetAttribute("Size", FileInfo.Length.ToString());

						xmlFiles.AppendChild(xmlFileName);

						xmlFileResources = xmlFile.CreateElement("Resources");

						PEFile pe = new PEFile(fin, (int) FileInfo.Length);
						foreach (KeyValuePair<string, string> dVS in pe.VersionInfo)
						{
							xmlFileResource = xmlFile.CreateElement("Resource");
							xmlFileResource.SetAttribute("Name", dVS.Key.Replace(" ", ""));
							xmlFileResource.SetAttribute("Value", dVS.Value);
							xmlFileResources.AppendChild(xmlFileResource);
						}
						xmlFiles.AppendChild(xmlFileResources);

						xmlFileBinImprint = xmlFile.CreateElement("BinImprint");
						xmlFileBinImprint.SetAttribute("Imprint", pe.BinImprint);
						xmlFiles.AppendChild(xmlFileBinImprint);

						pe.Dispose();

						uint imprint = IconImprint.GetCRCFromIcon(sFile);

						if (imprint != 0)
						{
							xmlIconImprint = xmlFile.CreateElement("IconImprint");
							xmlIconImprint.SetAttribute("Imprint", imprint.ToString("X8"));
							xmlFiles.AppendChild(xmlIconImprint);
						}

					}

					xmlAppdetect.AppendChild(xmlFiles);
				}
				catch (Exception ex)
				{
					colErrors.Add(new ProcessingError(sFile, ex));
				}
            }

            xmlErrorReport = xmlFile.CreateElement("ErrorReport");
			foreach( ProcessingError pError in colErrors )
			{
				xmlError = xmlFile.CreateElement("Message");
				xmlError.SetAttribute("Type", "Error" );
				xmlError.SetAttribute("Number", "1");
				xmlError.SetAttribute("File", pError.File);
				xmlError.SetAttribute("Text", pError.Exception.Message);
				xmlErrorReport.AppendChild(xmlError);
			}
            xmlAppdetect.AppendChild(xmlErrorReport);

            xmlFile.AppendChild(xmlAppdetect);

            XmlTextWriter xmlWriter = new XmlTextWriter(sFileName, System.Text.Encoding.GetEncoding("UTF-8"));
            xmlWriter.Formatting = Formatting.Indented;
            xmlFile.Save(xmlWriter);
        }

		private static void GetFiles(StringCollection colFiles, ProcessingErrors colErrors, string sPathName, params string[] sFilePattern)
		{
			try
			{
				DirectoryInfo diBase = new DirectoryInfo(sPathName);

				foreach (string pattern in sFilePattern)
				{
					foreach (FileInfo fInfo in diBase.GetFiles(pattern))
					{
						try
						{
							if ((fInfo.Attributes & FileAttributes.ReparsePoint) > 0)
								continue;

							if (!colFiles.Contains(fInfo.FullName))
								colFiles.Add(fInfo.FullName);
						}
						catch (Exception ex)
						{
							colErrors.Add(new ProcessingError(fInfo.FullName, ex));
						}
					}

					foreach (DirectoryInfo diSub in diBase.GetDirectories())
					{
						try
						{
							if ((diSub.Attributes & FileAttributes.ReparsePoint) > 0)
								continue;

							GetFiles(colFiles, colErrors, diSub.FullName, pattern);
						}
						catch (Exception ex)
						{
							colErrors.Add(new ProcessingError(diSub.FullName, ex));
						}
					}
				}
			}
			catch (Exception ex)
			{
				colErrors.Add(new ProcessingError(sPathName, ex));
			}
		}
    }
}
