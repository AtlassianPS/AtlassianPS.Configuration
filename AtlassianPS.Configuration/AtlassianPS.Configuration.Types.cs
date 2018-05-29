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

    public class Configuration
    {
        public String Name { get; set; }
        public Object Value { get; set; }
    }

    [Serializable]
    public class ServerData
    {
        // public ServerData().
        // {
        //     IsCloudServer = false;
        // }
        public ServerData(Hashtable Table)
        {
            bool foundName = false;
            bool foundUri = false;
            bool foundType = false;

            foreach (object key in Table.Keys)
            {
                switch (key.ToString().ToLower())
                {
                    case "name":
                        Name = (string)Table[key];
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
                    default:
                        break;
                }
            }
            if (!(foundName && foundUri && foundType))
                throw new ArgumentException("Must contain Name, Uri and Type.");
        }
        public String Name { get; set; }
        public Uri Uri { get; set; }
        public ServerType Type { get; set; }
        // public Boolean IsCloudServer { get; set; }
        public object Session { get; set; }
        public Hashtable Headers { get; set; }
        public override String ToString()
        {
            return String.Format("{0} ({1})", Name, Uri);
        }
    }
}
