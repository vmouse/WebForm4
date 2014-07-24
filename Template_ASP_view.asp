<% ' Begin visualization list from [table_name] %>
<% if Request("mode")<>"card" then
sp[table_name]("@Mode")=3  ' Select mode
sp[table_name]("@SubMode")=3  ' Select "SelectName" and PKs fields from all Records
set [table_name]List = ExecCursor(sp[table_name])
%>
<h4>Content of [table_name]</h4>
<table>
<tr><td><a href="?mode=card<FL Types="P">&{0}=</FL>">Add new item</a></td></tr>
<% With [table_name]List
	'.MoveFirst()
	While (not .EOF) %>
	<tr><td><a href="?mode=card<FL Types="P">&{0}=<%=.Fields("{0}").value %></FL>">[ edit ]</a></td><td><%= .Fields("SelectName").value %></td></tr>
	<%	.MoveNext
	Wend
	.Close
End with
set [table_name]List = nothing %>
</table>

<% ' End visualization list from [table_name] %>
<% else ' if Request("mode")<>"card" %>

<% ' Begin visualization section form Form%>
<h4><%=CardLabel %></h4>
<b class="red"><%=Form.Errors %></b>
<%=Form.BeginForm %>
<%'Hidden controls
for Each A in Form.Group("H0") %>
  <%= A.HTML %>
<% Next %>
<table border="1" cellspacing="0" cellpadding="2">
<%'Visual controls
for Each A in Form.Group("C0") %>
  <tr valign="top">
    <td><%=A.mark("O","V","X") %></td>
    <td><%=A.Label %><%=IIF(A.Required,"<b class=""red"">*</b>","")%><br><b class="red"><%=A.Errors %></b>&nbsp;</td>
    <td>
    <% if A.ReadOnly then %>
      <%=SafeGetFieldValue(Form.RowSet,A.RSField) %>
    <% else %>
      <%=A.HTML %>
    <% end if %>
    &nbsp;</td>
  </tr>
<% Next %>
<%'File browser controls
for Each A in Form.Group("F0") %>
  <tr valign="top">
    <td><%=A.mark("O","V","X") %></td>
    <td><%=A.Label %><%=IIF(A.Required,"<b class=""red"">*</b>","")%><br><b class="red"><%=A.Errors %></b>&nbsp;</td>
    <td>
    <% if not isnull(SafeGetFieldValue(Form.RowSet,A.RSField)) then %>
      <a href="/getimg.asp?obj=[table_name]<FL Types="P">&id=<%= Form(Form.Name & "_{0}") %></FL>"><img src="/getimg.asp?obj=[table_name]<FL Types="P">&id=<%= Form(Form.Name & "_{0}") %></FL>" width="70" height="70" border="0" align="middle"></a>
      <% if not A.ReadOnly then %>
      <%=Form(A.Name & "_clear").HTML %><%=Form(A.Name & "_clear").Label %><br>
      <% End If %>
    <% End If %>
    <% if not A.ReadOnly then %>
      <%=A.HTML %>
    <% end if %>
    &nbsp;</td>
  </tr>
<% Next %>
</table>
<%=Form(Form.Name & "_Submit").Html %>
<%=Form(Form.Name & "_Delete").Html %>
<%=Form(Form.Name & "_Copy").Html %>
<%=Form.EndForm %>

<a href="?mode=list">[ List items ]</a>
<% end if 'Request("mode")<>"card" then %>
<% 'End visualization section form Form %>
