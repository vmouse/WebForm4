<% ' Begin action section form [table_name]Form

Form.FillValuesFromRequest Request,True	' Fill controls by submited values
Form.SetQuery(Request.QueryString)	' Save original query string
RedirectQS = Request.ServerVariables("SCRIPT_NAME") & Form.QueryString
RedirectRef= Request.ServerVariables("HTTP_REFERER")
Redirect=""

if Form.WasSubmited then
  if Form(Form.Name & "_Submit").Pressed then
    Form.Validate
    if Form.Validated then
      Form.FillFields
      sp[table_name]("@Mode")=1
      <IFF FL="B">sp[table_name]("@SubMode")= (<FL Types="b"><CALC>[math]::Pow(2,{7}-1)</CALC><DL>+</DL></FL>) ' Update nonfile (blob) fields
      if Form(Form.Name & "_emp_photo_clear")="1" or _
        (Not IsEmpty(Form(Form.Name & "_emp_photo").FileObject) and _
         Form(Form.Name & "_emp_photo").FileObject.Size>0) then
        sp[table_name]("@SubMode")=CLng(sp[table_name]("@SubMode"))+<FL Types="B"><CALC>[math]::Pow(2,{7}-1)</CALC><DL>+</DL></FL>
      end if[ELSE]sp[table_name]("@SubMode")=0 ' Update all fields</IFF>
      ExecFormProc sp[table_name],Form
      if Form.Validated then
        Redirect=RedirectRef
      end if ' Form submit action 
    else ' Not valid form
      Form.Invalidate("Filled data is't valid.")
    end if ' Not valid form
  elseif Form(Form.Name & "_Copy").Pressed then
    Form.Validate
    if Form.Validated then
      Form.FillFields
      sp[table_name]("@Mode")=1
      <IFF FL="B">sp[table_name]("@SubMode")= (<FL Types="b"><CALC>[math]::Pow(2,{7}-1)</CALC><DL>+</DL></FL>) ' Update nonfile (blob) fields
      if Form(Form.Name & "_emp_photo_clear")="1" or _
        (Not IsEmpty(Form(Form.Name & "_emp_photo").FileObject) and _
         Form(Form.Name & "_emp_photo").FileObject.Size>0) then
        sp[table_name]("@SubMode")=CLng(sp[table_name]("@SubMode"))+<FL Types="B"><CALC>[math]::Pow(2,{7}-1)</CALC><DL>+</DL></FL>
      end if[ELSE]sp[table_name]("@SubMode")=0 ' Update all fields</IFF>
      <FL Types="P">sp[table_name]("@{0}")=NULL
      </FL>ExecFormProc sp[table_name],Form
      Redirect = Request.ServerVariables("SCRIPT_NAME") & "?" & <FL Types="P">"{0}=" & sp[table_name]("@{0}")<DL>&</DL></FL>
    end if ' Not valid form
  elseif Form(Form.Name & "_Delete").Pressed then
    sp[table_name]("@Mode")=2
    sp[table_name]("@SubMode")=0
    <FL Types="P">sp[table_name]("@{0}")=Form(Form.Name & "{0}").value
    </FL>ExecFormProc sp[table_name],Form
    if Form.Validated then
      Redirect=RedirectRef
    end if ' Form delete action 
  end if ' Case pressed button

  if Redirect<>"" then
    Response.Redirect(Redirect)
  end if

else ' Not submited - Initial fill fields from dataset
  sp[table_name]("@Mode")=3
  sp[table_name]("@SubMode")=0
  <FL Types="P">sp[table_name]("@{0}")=IIF(Len(Request("{0}"))=0,NULL,Request("{0}"))
  </FL>ExecFormProc sp[table_name], Form
  if NOT (Form.RowSet.EOF and Form.RowSet.BOF) then
    Form.RowSet.MoveFirst()
    CardLabel = IIF(IsEmpty(Form.RowSet("SelectName").Value), "Edit: " & <FL Types="P">Request("{0}")<DL> & "." & </DL></FL>, "Edit: " & Form.RowSet("SelectName").Value)
  else
    CardLabel = "New record"
  end if
end if

 'End action section form [table_name]Form %>