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
using System.Drawing.Design;
using System.Xml;

namespace IniConfigurator
{
	public class ConfigClass : ICustomTypeDescriptor
	{
		private IDataProvider dataProvider;
		private PropertyDescriptorCollection descriptors;

		public ConfigClass( IDataProvider dataProvider, XmlNode maskRoot )
		{
			ArrayList descriptors = new ArrayList();
			XmlDocument doc = new XmlDocument();
			this.dataProvider = dataProvider;

			// build PropertyDescriptorCollection
			foreach ( XmlNode sectionNode in maskRoot.ChildNodes )
			{
				try
				{
					CategoryAttribute ca = new CategoryAttribute( sectionNode.Attributes[ "Name" ].Value );
					bool deleteSectionIfEmpty = sectionNode.Attributes[ "DeleteIfEmpty" ].Value.Equals( "true" );

					foreach ( XmlNode propertyNode in sectionNode.ChildNodes )
					{
						try
						{
							PropertyDescriptor pd = this.GetPropertyDescriptor( propertyNode, ca, sectionNode.Attributes[ "Name" ].Value, deleteSectionIfEmpty );
							descriptors.Add( pd );
						}
						catch {}
					}
				}
				catch {}
			}

			this.descriptors = new PropertyDescriptorCollection( (PropertyDescriptor[]) descriptors.ToArray( typeof( PropertyDescriptor ) ) );

		}

		private PropertyDescriptor GetPropertyDescriptor( XmlNode propertyNode, Attribute ca, string sectionName, bool deleteSectionIfEmpty )
		{
			DescriptionAttribute da = new DescriptionAttribute( propertyNode.Attributes[ "Comment" ].Value );
			ArrayList attributes = new ArrayList();
			attributes.Add( ca );
			attributes.Add( da );
			ArrayList values = null;

			TypeConverterAttribute tca = null;
			PropertyDescriptor pd = null;

			bool canBeEmpty = true;

			switch ( propertyNode.Attributes[ "PropertyType" ].Value )
			{
				case "FreeText" :
					break;

				case "Number" :
					canBeEmpty = propertyNode.Attributes[ "CanBeEmpty" ].Value.Equals( "true" );

					if ( canBeEmpty )
						tca = new TypeConverterAttribute( typeof( IniInt32Converter ) );
					else
						tca = new TypeConverterAttribute( typeof( Int32Converter ) );

					attributes.Add( tca );
					break;

				case "Enum" :
					tca = new TypeConverterAttribute( typeof( StaticDomainStringConverter ) );
					canBeEmpty = propertyNode.Attributes[ "CanBeEmpty" ].Value.Equals( "true" );
					attributes.Add( tca );
					values = this.GetPropertyValues( propertyNode );

					if ( canBeEmpty )
						values.Insert(0, string.Empty );

					break;
			}

			pd = new IniPropertyDescriptor( propertyNode.Attributes[ "Name" ].Value, (Attribute[]) attributes.ToArray( typeof( Attribute ) ), sectionName, propertyNode.Attributes[ "DeleteIfEmpty" ].Value.Equals( "true" ), deleteSectionIfEmpty, values, this );
			return( pd );
		}

		private ArrayList GetPropertyValues( XmlNode propertyNode )
		{
			ArrayList list = new ArrayList();

			foreach ( XmlNode memberNode in propertyNode.SelectSingleNode( "EnumMembers" ).ChildNodes )
				list.Add( memberNode.Attributes[ "Value" ].Value );

			return( list );
		}

		public TypeConverter GetConverter()
		{
			return( new TypeConverter() );
		}

		public EventDescriptorCollection GetEvents(Attribute[] attributes)
		{
			return( new EventDescriptorCollection( new EventDescriptor[ 0 ] ) );
		}

		EventDescriptorCollection System.ComponentModel.ICustomTypeDescriptor.GetEvents()
		{
			return( new EventDescriptorCollection( new EventDescriptor[ 0 ] ) );
		}

		public string GetComponentName()
		{
			return( "TestComponent" );
		}

		public object GetPropertyOwner( PropertyDescriptor pd )
		{
			return( this );
		}

		public AttributeCollection GetAttributes()
		{
			return( new AttributeCollection( new Attribute[ 0 ] ) );
		}

		private PropertyDescriptorCollection GetProperties()
		{
			return( this.descriptors );
		}

		public PropertyDescriptorCollection GetProperties(Attribute[] attributes)
		{
			return( this.GetProperties() );
		}

		PropertyDescriptorCollection System.ComponentModel.ICustomTypeDescriptor.GetProperties()
		{
			return( this.GetProperties() );
		}

		public object GetEditor(Type editorBaseType)
		{
			return( new UITypeEditor() );
		}

		public PropertyDescriptor GetDefaultProperty()
		{
			return( null );
		}

		public EventDescriptor GetDefaultEvent()
		{
			return( null );
		}

		public string GetClassName()
		{
			return( string.Empty );
		}

		public string GetValue( string sectionName, string keyName )
		{
			return( this.dataProvider.GetValue( sectionName, keyName ) );
		}


		public void SetValue( string sectionName, string keyName, string value, bool deleteSectionIfEmpty )
		{
			this.dataProvider.SetValue( sectionName, keyName, value, deleteSectionIfEmpty );
		}
	}





}
