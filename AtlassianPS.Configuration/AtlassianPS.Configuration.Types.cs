using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.PowerShell.Commands;
using System.Security.Cryptography.X509Certificates;

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
            BreadCrumbs = false;
            FunctionName = true;
        }

        public MessageStyle(UInt32 Indent, Boolean TimeStamp, Boolean BreadCrumbs, Boolean FunctionName)
        {
            this.Indent = Indent;
            this.TimeStamp = TimeStamp;
            this.BreadCrumbs = BreadCrumbs;
            this.FunctionName = FunctionName;
        }

        public UInt32 Indent { get; set; }
        public Boolean TimeStamp { get; set; }
        public Boolean BreadCrumbs { get; set; }
        public Boolean FunctionName { get; set; }
    }

    [Serializable]
    public class ServerData
    {
        public ServerData(UInt32 Id, String Name, String Url, ServerType Type)
        {
            Uri tempUri;
            Uri.TryCreate(Url, UriKind.RelativeOrAbsolute, out tempUri);

            this.Id = Id;
            this.Name = Name;
            this.Uri = tempUri;
            this.Type = Type;
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
                    case "certificate":
                        Certificate = (X509Certificate)Table[key];
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
        public X509Certificate Certificate { get; set; }
        public Hashtable Headers { get; set; }

        public override String ToString()
        {
            return String.Format("{0} ({1})", Name, Uri);
        }
    }

    public sealed class Connection : IDisposable
    {
        private PSCredential credential;
        private String authenticationUsername;
        private System.Security.SecureString token;
        private WebRequestSession webSession;

        public Guid InstanceId { get; private set; }
        public Guid RegistryGeneration { get; private set; }
        public Guid SourceInstanceId { get; private set; }
        public Int32 Id { get; private set; }
        public String Name { get; private set; }
        public String Product { get; private set; }
        public Uri BaseUri { get; private set; }
        public Uri SiteUri { get; private set; }
        public String CloudId { get; private set; }
        public String DeploymentType { get; private set; }
        public String Username { get; private set; }
        public String AuthenticationMode { get; private set; }
        public String State { get; private set; }
        public Boolean IsOverride
        {
            get { return SourceInstanceId != Guid.Empty; }
        }

        public Connection(
            String name,
            String product,
            Uri baseUri,
            Uri siteUri,
            String cloudId,
            String mode,
            String email,
            PSCredential credential,
            System.Security.SecureString token,
            Guid generation)
        {
            InstanceId = Guid.NewGuid();
            RegistryGeneration = generation;
            Name = name;
            Product = product;
            BaseUri = baseUri;
            SiteUri = siteUri;
            CloudId = cloudId;
            AuthenticationMode = mode;
            Username = credential == null ? email : credential.UserName;
            authenticationUsername = Username;
            this.credential = credential == null
                ? null
                : new PSCredential(credential.UserName, credential.Password.Copy());
            this.token = token == null ? null : token.Copy();
            State = "Candidate";
        }

        public void SetValidationResult(String deploymentType, String username)
        {
            if (State != "Candidate")
            {
                throw new InvalidOperationException("Connection metadata is frozen.");
            }

            DeploymentType = deploymentType;
            if (!String.IsNullOrEmpty(username))
            {
                Username = username;
            }
        }

        public void Register(Int32 id)
        {
            if (State != "Candidate")
            {
                throw new InvalidOperationException("Only a candidate can be registered.");
            }

            Id = id;
            State = "Active";
        }

        public void MakeStandalone(Guid sourceInstanceId)
        {
            if (State != "Candidate")
            {
                throw new InvalidOperationException("Only a candidate can become a request context.");
            }

            SourceInstanceId = sourceInstanceId;
            State = "Standalone";
        }

        public String GetAuthorizationHeader()
        {
            if (State == "Disconnected")
            {
                throw new InvalidOperationException("Connection is disconnected.");
            }

            if (AuthenticationMode == "Anonymous")
            {
                return null;
            }

            String secret = null;
            IntPtr pointer = IntPtr.Zero;
            try
            {
                var secure = credential == null ? token : credential.Password;
                pointer = System.Runtime.InteropServices.Marshal.SecureStringToBSTR(secure);
                secret = System.Runtime.InteropServices.Marshal.PtrToStringBSTR(pointer);
                if (AuthenticationMode == "PersonalAccessToken")
                {
                    return "Bearer " + secret;
                }

                return "Basic " + Convert.ToBase64String(
                    System.Text.Encoding.UTF8.GetBytes(authenticationUsername + ":" + secret));
            }
            finally
            {
                if (pointer != IntPtr.Zero)
                {
                    System.Runtime.InteropServices.Marshal.ZeroFreeBSTR(pointer);
                }

                secret = null;
            }
        }

        public WebRequestSession GetWebSession()
        {
            if (State == "Disconnected")
            {
                throw new InvalidOperationException("Connection is disconnected.");
            }

            if (webSession == null)
            {
                webSession = new WebRequestSession();
            }

            return webSession;
        }

        public void Dispose()
        {
            if (credential != null)
            {
                credential.Password.Dispose();
            }

            if (token != null)
            {
                token.Dispose();
            }

            credential = null;
            token = null;

            var disposableSession = (webSession as object) as IDisposable;
            if (disposableSession != null)
            {
                disposableSession.Dispose();
            }

            webSession = null;
            State = "Disconnected";
        }

        public override String ToString()
        {
            return Product + ":" + Name + " (" + (SiteUri ?? BaseUri) + ")";
        }
    }
}
