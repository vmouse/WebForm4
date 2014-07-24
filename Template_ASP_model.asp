<% '[webform_version]
' Data and control objects  declaration
Set DB = GetDataBase()
Set sp[table_name] = StoredProc(DB,"dbo.sp[table_name]")
<FL Types="L">
Set sp{5}_{0} = StoredProc(DB,"dbo.sp{5}")
sp{5}_{0}("@Mode")=3 ' Select mode
sp{5}_{0}("@SubMode")=3 ' SelectName submode (fill values list)
sp{5}_{0}("@{6}")=IIF(Len(Request("{0}"))>0,Request("{0}"), NULL) ' ERR!!! Add form name! Unlock probably deleted record
Set {5}_{0}_List = ExecCursor(sp{5}_{0})
</FL>
set Form = new AspForm
Form.Name = "[table_name]Form"
<FL Types="P">
Set Element = New FormControl
with Element
	.AssignField sp[table_name]("@{0}"), "{0}"
	.MakeHidden Form.Name & "_{0}", ""
	Form.AddToGroup Element,"H0"
end with
</FL><FL Types="pfb">
Set Element = New FormControl
with Element
	.Label = "{1}"
<IF FL="L">
	.AssignFieldNull spRoles("@{0}"), -3, "{0}"
	.MakeSelect Form.Name & "_{0}", "-3"
	.AddSelectOption "Chose One",  "-1"
	.AddSelectOption "---------------",  "-2"
	.AddSelectOption "- Empty -",  "-3"
	.FillSOFromRowset {5}_{0}_List ,"SelectName","{6}"
	.AddNotEqualValidator -1,"You must choose " & .Label
	.AddNotEqualValidator -2,"You must choose " & .Label
	</IF><ELIF FL="S" FC="{9} -gt 63">
	.AssignField sp[table_name]("@{0}"), "{0}"
	.MakeTextArea Form.Name & "_{0}", ""
	.Options("size") = "{9}"
	.Options("cols") = "40"
	.Options("rows") = "5"
	.AddMaxLenValidator {9}, "Length of text should not exceed {9} symbols"
'	.NoHTMLEncode = True
	</ELIF><ELIF FL="S" FC="{9} -gt 1">
	.AssignField sp[table_name]("@{0}"), "{0}"
	.MakeText Form.Name & "_{0}", ""
	.Options("size") = "{9}"
	.AddMaxLenValidator {9}, "Length of text should not exceed {9} symbols"
'	.NoHTMLEncode = True
	</ELIF><ELIF FL="S" FC="{9} -eq 1">
	.AssignField sp[table_name]("@{0}"), "{0}"
	.MakeCheckBox Form.Name & "_{0}", "0","1","0"
	</ELIF><ELIF FL="D">
	.AssignField sp[table_name]("@{0}"), "{0}"
	.MakeDate Form.Name & "_{0}", NOW ' or NULL for empty
'	.MakeDate Form.Name & "_{0}", DateSerial(Year(NOW)-30,06,16) ' optimal for birthday
'	.MinYear = Year(DateAdd("yyyy", -90, NOW))
'	.MaxYear = Year(DateAdd("yyyy", -15, NOW))
	</ELIF><IF NULLABLE=False>True
	.Required = True
	.AddRequiredValidator "You must specify " & .Label[ELSE].Required = False</IF>
	.Options("class") = "user_input"
	Form.AddToGroup Element,"C0"
end with
</FL><FL Types="B">
Set Element = New FormControl
with Element
	.AssignField sp[table_name]("@{0}"), "{0}"
	.Label = "{1}"
	.MakeFile Form.Name & "_{0}"
	.Options("class") = "user_input"
	.Options("size") = "40"
	Form.AddToGroup Element,"F0"
	.AddFileValidExtValidator Split("jpg|jpeg", "|"), "Invalid file extention (jpg,jpeg only)"
	'.AddFileValidContentValidator Split("image/jpeg|image/pjpeg", "|"), "File content is not valid jpeg-image"
	'.AddFileValidMaxSizeValidator "100Kb", "Limit of file size is exceeded (100Kb)"
Set Element = New FormControl
with Element
	.Label = "{1} clear"
	.Comment = ""
	.MakeCheckBox Form.Name & "_{0}_clear", "0","1","0"
	.Options("class") = "user_input"
	Form.AddToGroup Element,"FC0"end with
end with
</FL><FL Types="F">
Set Element = New FormControl
with Element
	.AssignField sp[table_name]("@{0}"), "{0}"
	.MakeHidden Form.Name & "_{0}", ""
	Form.AddToGroup Element,"H0"
end with</FL>

Set Element = New FormControl
with Element
	.MakeSubmit  Form.Name & "_Submit", "Save"
	.Options("class") = "user_input"
	Form.AddControl(Element)
end with

Set Element = New FormControl
with Element
	.MakeSubmit  Form.Name & "_Delete", "Delete"
	.Options("class") = "user_input"
	.Options("onClick") = "return window.confirm('Are you sure ?');"
	Form.AddControl(Element)
end with

Set Element = New FormControl
with Element
	.MakeSubmit  Form.Name & "_Copy", "Save as New copy"
	.Options("class") = "user_input"
	.Options("onClick") = "return window.confirm('Are you sure ?');"
	Form.AddControl(Element)
end with
<FL Types="L">
{5}_{0}_List.Close
Set {5}_{0}_List = nothing
Set sp{5}_{0} = nothing
</FL>
' End data and control objects declaration
%>