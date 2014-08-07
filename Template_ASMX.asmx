<%@ WebService Language="C#" Class="ws[table_name]" %>
//[webform_version]
//Powershell connect:
//$srv = New-WebServiceProxy -uri "http://support/_srv/ws[table_name].asmx?wsdl" -UseDefaultCredential
//$srv.Exec(3,2,<FL>$null<DL>, </DL></FL>)
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Services;
using System.Security.Principal;
using System.Net;
using System.Text;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Xml.Serialization;
<IF FL="B">using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.IO;</IF>

[WebService(Namespace = "http://support/", Description = "[webform_version]")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.ComponentModel.ToolboxItem(false)]
[System.Web.Script.Services.ScriptService]
public class ws[table_name] : System.Web.Services.WebService
{
    [Serializable()]
    public class it[table_name]
    {<AL>
        <FL Types="AVHb">public [v]{4} [v]{0};<DL>
        </DL></FL>
        <FL Types="B">private [v]{4} [v]{0};
        public [v]String [v]{0}_base64 {
            get { try { return Convert.ToBase64String({0}); } catch { return null; } }
            set { {0} = Convert.FromBase64String(value); }
        }</FL></AL>
        public it[table_name]() {} // default constructor
        <FL Types="B">public void   Set_{0}(Byte[] Data) { {0} = Data; }
        public Byte[] Get_{0}() { return {0}; }</FL>
        public void Save() {<AL>
            it[table_name] item = Go(1, 0, <FL>{0}<DL>, </DL></FL>).ToArray()[0];
            <FL Types="AVH">{0}[v] = item.{0};<DL>
            </DL></FL>
        }</AL>
        public void Delete(int SubMode) {
            Go(2, SubMode, <FL>{0}<DL>, </DL></FL>);
        }
    }

    [Serializable()]
    public class it[table_name]_name
    {
        <FL Types="PV">public {4} {0};<DL>
        </DL></FL>
        public it[table_name]_name() {} // default constructor
    }

    public static Object SafeDRValue(SqlDataReader Reader, String FieldName, List<string> cols)
    {
        return ((!cols.Contains(FieldName)||(Reader.IsDBNull(Reader.GetOrdinal(FieldName)))) ? null : Reader[FieldName]);
    }

    [WebMethod]
    public it[table_name] New() {
                return new it[table_name]();
    }

    [WebMethod]
    public it[table_name] Save(it[table_name] item) {
        item.Save();
        return item;
    }

    [WebMethod]
    public void Delete(it[table_name] item) {
        item.Delete(0);
    }

    [WebMethod]
    public it[table_name] Hide(it[table_name] item) {
        item.Delete(1);
        return item;
    }

    [WebMethod]
    public it[table_name] UnHide(it[table_name] item) {
        item.Delete(2);
        return item;
    }

    [WebMethod]
    public it[table_name]_name[]  ListNames(int PageNumber, int RowsPerPage) // alt.method: (<FL Types="P">String {0}<DL>, </DL></FL>)
    {
        List<it[table_name]_name> rec = new List<it[table_name]_name>();
        Go_retrieve(0, <FL>null<DL>, </DL></FL>, PageNumber, RowsPerPage).ForEach(x => {
            rec.Add(new it[table_name]_name{<FL Types="PV">{0}=x.{0}<DL>, </DL></FL>});
        });
        return rec.ToArray();
    }

    [WebMethod]
    public it[table_name]_name[] Retrieve(int SubMode, <FL>{4} {0}<DL>, </DL></FL>, int? PageNumber, int? RowsPerPage)
    {
        List<it[table_name]_name> rec = new List<it[table_name]_name>();
        Go_retrieve(SubMode, <FL>{0}<DL>, </DL></FL>, PageNumber, RowsPerPage).ForEach(x => rec.Add(new it[table_name]_name{<FL Types="PV">{0}=x.{0}<DL>, </DL></FL>}));
        return rec.ToArray();
    }

    
    [WebMethod]
    public it[table_name]_name[] Find(String SearchToken, int PageNumber, int RowsPerPage)
    {
        String Pattern = (string.IsNullOrEmpty(SearchToken))?null:"%" + SearchToken + "%";
        return Retrieve(0, <AL>
            <FL><IFF FL="S">Pattern[else]null</IFF>,    [v]// {0}<DL>
            </DL></FL>
            PageNumber, RowsPerPage);
    }</AL>


    [WebMethod]
    public it[table_name] Get(<FL Types="P">{3} {0}<DL>, </DL></FL>, bool WithBLOBs)
    {
        it[table_name] item = Go(3, 0, <FL Types="P">{0}<DL>, </DL></FL>, <FL Types="p">null<DL>, </DL></FL>).FirstOrDefault();
        <IF FL="B">if (!WithBLOBs) { 
            <FL Types="B">item.Set_{0}(null);
        </FL>}</IF>
        return item;
    }

    [WebMethod]
    public it[table_name] Get2(<FL Types="P">String {0}<DL>, </DL></FL>, bool WithBLOBs)
    {
        return Get(<FL Types="P">{3}.Parse({0})<DL>, </DL></FL>, WithBLOBs);
    }

    [WebMethod]
    public it[table_name][] Exec(int Mode, int SubMode, <FL>{4} {0}<DL>, </DL></FL>)
    {
        return Go(Mode, SubMode, <FL>{0}<DL>, </DL></FL>).ToArray();
    }

    public static SqlConnection PrepareSQLConn() 
    {
        SqlConnection Connection = new SqlConnection("Data Source=(local);Initial Catalog=support;Integrated Security=True");
        Connection.Open();
        return Connection;
    }

    public static SqlCommand PrepareSQLProc(SqlConnection Connection, String ProcName, <FL>{4} {0}<DL>, </DL></FL>)
    {
        SqlCommand Command = new SqlCommand(ProcName, Connection);
        Command.CommandType = CommandType.StoredProcedure;
        SqlCommandBuilder.DeriveParameters(Command);<AL>
        <FL Types="s">Command.Parameters["@{0}"].Value[v] = {0};<DL>
        </DL></FL>
        <FL Types="S">Command.Parameters["@{0}"].Value[v] = (string.IsNullOrEmpty({0}))?[v]null:{0};<DL>
        </DL></FL></AL>
        return Command;
    }

    public static List<it[table_name]> FillListFromReader(SqlDataReader Reader, bool WithBLOBs)
    {
        List<it[table_name]> rec = new List<it[table_name]>();
        var cols = Reader.GetSchemaTable().Rows.Cast<DataRow>().Select(row => row["ColumnName"] as String).ToList();
        while (Reader.Read())
        {
            it[table_name] item = new it[table_name]();
            <AL>// get data with check for field exists and null value
            <FL Types="AVHb">item.{0}[v] = ({4})[v]SafeDRValue(Reader,"{0}", cols);<DL>
            </DL></FL>
            if (WithBLOBs) {
                <FL Types="B">item.Set_{0}(({4})[v]SafeDRValue(Reader,"{0}", cols));<DL>
                </DL></FL>
            }</AL>
            rec.Add(item);
        }
        return rec;
    }


    public static List<it[table_name]> Go(int Mode, int SubMode, <FL>{4} {0}<DL>, </DL></FL>)
    {
        List<it[table_name]> Results = null;
        WindowsIdentity winId = (WindowsIdentity)HttpContext.Current.User.Identity;
        WindowsImpersonationContext ctx = null;
        try
        { // Start impersonating
            ctx = winId.Impersonate();
            using (SqlConnection Connection = PrepareSQLConn())
            {
                using (SqlCommand Command = PrepareSQLProc(Connection, "dbo.sp[table_name]", <FL>{0}<DL>, </DL></FL>))
                {
                    Command.Parameters["@Mode"].Value = Mode;
                    Command.Parameters["@SubMode"].Value = SubMode;
                    SqlDataReader Reader = Command.ExecuteReader();
                    if (Reader.HasRows) Results = FillListFromReader(Reader, (Mode==3 && SubMode==0));
                }
            }
        }
        //catch
        //{
        //}
        finally
        {
            // Revert impersonation
            if (ctx != null)
                ctx.Undo();
        }
        return Results;
    }

    public static List<it[table_name]> Go_retrieve(int SubMode, <FL>{4} {0}<DL>, </DL></FL>, int? PageNumber, int? RowsPerPage)
    {
        List<it[table_name]> Results = null;
        WindowsIdentity winId = (WindowsIdentity)HttpContext.Current.User.Identity;
        WindowsImpersonationContext ctx = null;
        try
        { // Start impersonating
            ctx = winId.Impersonate();
            using (SqlConnection Connection = PrepareSQLConn())
            {
                using (SqlCommand Command = PrepareSQLProc(Connection, "dbo.sp[table_name]_retrieve", <FL>{0}<DL>, </DL></FL>))
                {
                    Command.Parameters["@SubMode"].Value = SubMode;
                    Command.Parameters["@PageNumber"].Value = PageNumber;
                    Command.Parameters["@RowsPerPage"].Value = RowsPerPage;
                    SqlDataReader Reader = Command.ExecuteReader();
                    if (Reader.HasRows) Results = FillListFromReader(Reader, false);
                }
            }
        }
        //catch
        //{
        //}
        finally
        {
            // Revert impersonation
            if (ctx != null)
                ctx.Undo();
        }
        return Results ?? new List<it[table_name]>();
    }
<IF FL="B">
    public static Image ResizeImage(Image image, int desWidth, int desHeight, bool fillPadding)
    {
        int x, y, w, h;

        if (image.Height > image.Width)
        {
            w = (image.Width * desHeight) / image.Height;
            h = desHeight;
            x = (desWidth - w) / 2;
            y = 0;
        }
        else
        {
            w = desWidth;
            h = (image.Height * desWidth) / image.Width;
            x = 0;
            y = (desHeight - h) / 2;
        }

        var bmp = new Bitmap(desWidth, desHeight);

        using (Graphics g = Graphics.FromImage(bmp))
        {
            if (fillPadding) {
                g.Clear((new Bitmap(image)).GetPixel(0, 0));
            }
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.DrawImage(image, x, y, w, h);
        }
        return bmp;
    }

    <FL Types="B">
    [WebMethod]
    public String GetImage_{0}(<FL Types="P">{3} {0}, </FL>int Width, int Height, String OutputFormat)
    {
        it[table_name] item = Go(3, 0, <FL Types="P">{0}<DL>, </DL></FL>, <FL Types="p">null<DL>, </DL></FL>).FirstOrDefault();
        byte[] img = item.Get_{0}();
        if (img != null) {
            ImageConverter conv = new ImageConverter();
            using(MemoryStream ms = new MemoryStream())
            {
                var resized = ResizeImage((Bitmap)(conv.ConvertFrom(img)), Width, Height, (OutputFormat == "image/jpeg"));
                if (OutputFormat == "image/png") {
                    resized.Save(ms, ImageFormat.Png);
                } else if (OutputFormat == "image/jpeg") {
                    resized.Save(ms, ImageFormat.Jpeg);
                } else { throw new Exception("Invalid OutputFormat! Allowed image/png or image/jpeg only"); }
                return "data:"+OutputFormat+";base64,"+Convert.ToBase64String(ms.ToArray());
            }
    //        return "data:image/jpeg;base64"+Convert.ToBase64String((byte[])conv.ConvertTo(resized, typeof(byte[])));
        } else return "";
    }
</FL></IF>
    [WebMethod]
    public String HelloWorld()
    {
        string str = HttpContext.Current.Request.ApplicationPath.ToString();
        return "Hello " + HttpContext.Current.User.Identity.Name + "! I'm ws[table_name] service<br>\n[webform_version]\n";
    }
}

/* Check web-services section in web.config:
<system.web.extensions>
    <scripting>
      <webServices>
        <jsonSerialization maxJsonLength="5000000"/>
      </webServices>
    </scripting>
    <webServices> 
        <protocols> 
            <clear />
            <add name="HttpGet"/> 
            <add name="HttpPost"/> 
        </protocols> 
    </webServices>
</system.web.extensions>
<system.webServer>
    <security>
        <authentication>
            <windowsAuthentication useKernelMode="true">
                <extendedProtection tokenChecking="None" />
                <providers>
                    <clear />
                    <add value="NTLM" />
                </providers>
            </windowsAuthentication>
        </authentication>
        <authorization>
            <add accessType="Deny" users="?" />
        </authorization>
    </security>
</system.webServer>
<system.web>
    <authentication mode="Windows"/>
    <identity impersonate="false" />
    <customErrors mode="Off" />
</system.web>
*/