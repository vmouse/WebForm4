<%@ WebService Language="C#" Class="ws[table_name]" %>
//[webform_version]
//Powershell connect:
//$srv = New-WebServiceProxy -uri "http://support/_srv/[table_name].asmx?wsdl" -UseDefaultCredential
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

[WebService(Namespace = "http://support/", Description = "[webform_version]")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.ComponentModel.ToolboxItem(false)]
[System.Web.Script.Services.ScriptService]
public class ws[table_name] : System.Web.Services.WebService
{
	[Serializable]
	public class it[table_name]
	{
		<FL Types="AVH">public {4} {0};<DL>
		</DL></FL>
	public it[table_name]() {} // default constructor
		public void Save() {
			it[table_name] item = Go(1, 0, <FL>{0}<DL>, </DL></FL>).ToArray()[0];
			<FL Types="AVH">{0} = item.{0};<DL>
			</DL></FL>
		}
		public void Delete(int SubMode) {
			Go(2, SubMode, <FL>{0}<DL>, </DL></FL>);
		}
	}

	[Serializable]
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
	public itTerror_name[] Find(String SearchToken, int PageNumber, int RowsPerPage)
	{
		// (string.IsNullOrEmpty(SearchToken))?null:"%" + SearchToken + "%"
		return Retrieve(0, 
		<FL>null,	// {0}<DL>
		</DL></FL>
		PageNumber, RowsPerPage);
	}


	[WebMethod]
	public it[table_name] Get(<FL Types="P">{3} {0}<DL>, </DL></FL>)
	{
		return Go(3, 0, <FL Types="P">{0}<DL>, </DL></FL>, <FL Types="p">null<DL>, </DL></FL>).FirstOrDefault();
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
		SqlCommandBuilder.DeriveParameters(Command);
		<FL Types="s">Command.Parameters["@{0}"].Value = {0};<DL>
		</DL></FL>
		<FL Types="S">Command.Parameters["@{0}"].Value = (string.IsNullOrEmpty({0}))?null:{0};<DL>
		</DL></FL>
		return Command;
	}

	public static List<itTerror> FillListFromReader(SqlDataReader Reader)
	{
		List<itTerror> rec = new List<itTerror>();
		var cols = Reader.GetSchemaTable().Rows.Cast<DataRow>().Select(row => row["ColumnName"] as String).ToList();
		while (Reader.Read())
		{
			it[table_name] item = new it[table_name]();
			// get data with check for field exists and null value
			<FL Types="AVH">item.{0} = ({4})SafeDRValue(Reader,"{0}", cols);<DL>
			</DL></FL>              
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
					if (Reader.HasRows) Results = FillListFromReader(Reader);
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
					if (Reader.HasRows) Results = FillListFromReader(Reader);
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

	[WebMethod]
	public String HelloWorld()
	{
		return "Hello " + HttpContext.Current.User.Identity.Name + "! I'm ws[table_name] service<br>\n[webform_version]\n";
	}
}

/* Check web-services section in web.config:
<system.web>
				<authentication mode="Windows"/>
				<webServices> 
				<protocols> 
					<add name="HttpGet"/> 
					<add name="HttpPost"/> 
				</protocols> 
</webServices>
</system.web>
*/