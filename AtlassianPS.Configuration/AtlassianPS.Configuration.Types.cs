using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.PowerShell.Commands;

namespace AtlassianPS
{
    public enum ServerType
    {
        BITBUCKET,
        CONFLUENCE,
        JIRA
    }

    public class MessageStyle {
        public MessageStyle()
        {
            Indent = 4;
            TimeStamp = true;
            BreadCrumbs = true;
            FunctionName = true;
        }

        public MessageStyle(UInt32 _Indent, Boolean _TimeStamp, Boolean _BreadCrumbs, Boolean _FunctionName)
        {
            Indent = _Indent;
            TimeStamp = _TimeStamp;
            BreadCrumbs = _BreadCrumbs;
            FunctionName = _FunctionName;
        }

        public UInt32 Indent { get; set; }
        public Boolean TimeStamp { get; set; }
        public Boolean BreadCrumbs { get; set; }
        public Boolean FunctionName { get; set; }
    }

    [Serializable]
    public class ServerData
    {
        public ServerData(UInt32 _Id, String _Name, String _Uri, ServerType _Type)
        {
            Uri tempUri;
            Uri.TryCreate(_Uri, UriKind.RelativeOrAbsolute, out tempUri);

            Id = _Id;
            Name = _Name;
            Uri = tempUri;
            Type = _Type;
        }

        public ServerData(IDictionary Table)
        {
            bool foundId = false;
            bool foundName = false;
            bool foundUri = false;
            bool foundType = false;

            foreach (object key in Table.Keys)
            {
                switch (key.ToString().ToLower())
                {
                    case "id":
                        Id = Convert.ToUInt32(Table[key]);
                        foundId = true;
                        break;
                    case "name":
                        Name = (String)Table[key];
                        foundName = true;
                        break;
                    case "uri":
                        Uri tempUri;
                        Uri.TryCreate(Table[key].ToString(), UriKind.RelativeOrAbsolute, out tempUri);
                        Uri = tempUri;
                        foundUri = true;
                        break;
                    case "type":
                        Type = (ServerType)Enum.Parse(typeof(ServerType), (Table[key].ToString()), true);
                        foundType = true;
                        break;
                    case "session":
                        Session = Table[key];
                        break;
                    case "headers":
                        Headers = (Hashtable)Table[key];
                        break;
                    default:
                        break;
                }
            }
            if (!(foundId && foundName && foundUri && foundType))
                throw new ArgumentException("Must contain Id, Name, Uri and Type.");
        }

        public UInt32 Id { get; set; }
        public String Name { get; set; }
        public Uri Uri { get; set; }
        public ServerType Type { get; set; }
        // public Boolean IsCloudServer { get; set; }
        public Object Session { get; set; }
        public Hashtable Headers { get; set; }

        public override String ToString()
        {
            return String.Format("{0} ({1})", Name, Uri);
        }
    }
}
