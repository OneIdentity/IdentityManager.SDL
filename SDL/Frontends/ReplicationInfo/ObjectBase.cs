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
using System.Collections;
using System.Collections.Specialized;
using System.Text;

using VI.Base;


namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Summary description for JobBase.
	/// </summary>
	public abstract class ObjectBase
	{
		protected Hashtable     _data = CollectionsUtil.CreateCaseInsensitiveHashtable();

		public ObjectBase()
		{
			//
			// TODO: Add constructor logic here
			//
		}

		public virtual string[] Columns
		{
			get { return new string[] {"" }; }
		}

		public virtual string SQLColumns
		{
			get
			{
				StringBuilder sb = new StringBuilder();

				foreach ( string col in this.Columns )
				{
					if (sb.Length != 0)
						sb.Append( ", " );

					sb.Append( col );
				}

				return sb.ToString();
			}
		}


		public virtual string GetData( string column )
		{
			DbVal dbVal = _data[column] as DbVal;

			if (dbVal == null)
			{
				throw new Exception(String.Format("Invalid Columnname {0} for GetData in ObjectBase.", column ));
			}

			return dbVal.ToString();
		}

		public virtual void SetData( string column, string data )
		{
			_data.Add( column, new DbVal(data) );

		}

	}
}
