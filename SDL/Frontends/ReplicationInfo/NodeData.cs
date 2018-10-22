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


namespace VI.Tools.ReplicationInfo
{
	/// <summary>
	/// Summary description for NodeData.
	/// </summary>
	public class NodeData
	{
		private NodeType _nodetype;
		private string   _nodedata1;
		private string   _nodedata2;

		public NodeData()
		{
			_nodetype = NodeType.Root;
			_nodedata1 = "";
			_nodedata2 = "";
		}

		public NodeData( NodeType type, string data1, string data2)
		{
			_nodetype = type;
			_nodedata1 = data1;
			_nodedata2 = data2;
		}

		public NodeType Type
		{
			get { return _nodetype;  }
			set { _nodetype = value; }
		}

		public string Data1
		{
			get { return _nodedata1;  }
			set { _nodedata1 = value; }
		}

		public string Data2
		{
			get { return _nodedata2;  }
			set { _nodedata2 = value; }
		}

	}

	/// <summary>
	///
	/// </summary>
	public enum NodeType
	{
		Root,			// for RootNodes only
		Domain,			// Domain-Node
		Server,			// Server-Node
		AppProfiles,		// static ApplicationProfiles node
		DrvProfiles,		// static DriverProfiles node
		MacTypes,        // static MachineType node
		AppProfile,		// dynamic ApplicationProfile node
		DrvProfile,		// dynamic DriverProfile node
		MacType			// dynamic MachineType node
	};
}
