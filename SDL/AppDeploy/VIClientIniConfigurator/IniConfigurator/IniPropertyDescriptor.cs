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
using System.ComponentModel;

namespace IniConfigurator
{
	public class IniPropertyDescriptor : PropertyDescriptor
	{
		private ConfigClass valueProvider;
		private string section;
		private bool deleteValueIfEmpty;
		private bool deleteSectionIfEmpty;
		private ArrayList values;

		public IniPropertyDescriptor( string name, Attribute[] attributes, string section, bool deleteValueIfEmpty, bool deleteSectionIfEmpty, ArrayList values, ConfigClass valueProvider )
		: base( name, attributes )
		{
			this.valueProvider = valueProvider;
			this.section = section;
			this.deleteValueIfEmpty = deleteValueIfEmpty;
			this.deleteSectionIfEmpty = deleteSectionIfEmpty;
			this.values = values;
		}

		public override bool CanResetValue(object component)
		{
			return( false );
		}

		public override Type ComponentType
		{
			get
			{
				return( null );
			}
		}

		public override object GetValue(object component)
		{
			return( this.valueProvider.GetValue( this.section, this.Name ) );
		}

		public override bool IsReadOnly
		{
			get
			{
				return( false );
			}
		}

		public override Type PropertyType
		{
			get
			{
				return( typeof( string ) );
			}
		}

		public override void ResetValue(object component)
		{
		}

		public override void SetValue(object component, object value)
		{
			string newString;

			if ( value.GetType().Equals( typeof( Int32 ) ) )
				newString = value.ToString();
			else
				newString = (string) value;

			if ( ( this.deleteValueIfEmpty ) && ( newString.Length == 0 ) )
				this.valueProvider.SetValue( this.section, this.Name, null, this.deleteSectionIfEmpty );
			else
				this.valueProvider.SetValue( this.section, this.Name, newString, this.deleteSectionIfEmpty );
		}

		public override bool ShouldSerializeValue(object component)
		{
			return( false );
		}

		public ICollection GetValidValues()
		{
			return( this.values );
		}





	}
}
