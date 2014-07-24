####### test block, remove before publishihg
# clear
# $writer = New-Object System.IO.StringWriter
####### end of test block ###################

########### Initialize ############

### declare global variables and functions
$ServiceURI = "http://support/_srv/[table_name].asmx"

$textbox = New-Object System.Web.UI.WebControls.TextBox
$button = New-Object System.Web.UI.WebControls.Button
$label = New-Object System.Web.UI.WebControls.Label

$grid = New-Object System.Web.UI.WebControls.DataGrid
$grid.AllowPaging = $true
$grid.PageSize = 10
$grid.CellPadding = 2
$grid.GridLines = [System.Web.UI.WebControls.GridLines]::None
$grid.PagerStyle.Mode = [System.Web.UI.WebControls.PagerMode]::NumericPages
$grid.HeaderStyle.BackColor = [System.Drawing.Color]::LightGray
$grid.AutoGenerateColumns = $false
<FL>
$col =New-Object System.Web.UI.WebControls.BoundColumn
$col.HeaderText = "{1}"
$col.DataField = "{0}"
$grid.Columns.Add($col)
<DL></DL></FL>

<FL>${0} = New-Object System.Web.UI.WebControls.TextBox
<DL></DL></FL>

#$class_text.TextMode = [System.Web.UI.WebControls.TextBoxMode]::MultiLine
#$class_text.Rows = 10
#$class_text.Columns = 100

############## Load ##############

### first time the OnLoad fires bfore CreateChildControls
function OnLoad
{
	# Check if GET Request (first request).
	if($isPostBack -eq $false)
	{
		$label.Text = 'GET request.'
	}
}

######## 3. Create Controls ########

## create child controls
function CreateChildControls($controls)
{
	$controls.Add($grid)
<FL>
	$controls.Add(${0})<dl></dl></FL>

	$controls.Add($textbox)
	$button.Text = 'Click Me'
	Subscribe-Event $button 'Click' 'OnButtonClicked'
  	$controls.Add($button)

	$controls.Add($label)
}

######## Events ########

## handle control events
## subscribe to an event with "Subscribe-Event($control, 'eventName','callback function name')"
function OnButtonClicked($sender, $args)
{
   $label.Text = $textbox.Text
}

## fires when the AJAX timer has elapsed
## function OnAjaxRefresh{}

######### Connections #########

#### Provider ####

## returns an object containing the properties you want to provide (for reflection only)
#function GetSchema{ return $null}

## returns an object matching the schema defined in the Get-RowSchema function
#function SendRow{ return $null }

## returns a collection of objects matching the schema defined in Get-RowSchema function
##function SendTable{ return $null }

#### Consumer ####

## receives an object from a webpart row provider
#function OnReceiveRow($row, $schema){}

## receives a collection of objects from a webpart table provider
##function OnReceiveTable($table, $schema){}

######### PreRender #########

### Is fired when the event stage is completed.
### Last chance to modify controls before rendering
### function OnPreRender{ }

########## Render  #########

### render html
function Render($writer)
{
	$writer.Write("<h1>[table_name] web-part</h1>")
	#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

	$px[table_name] = New-WebServiceProxy -Uri $ServiceURI -UseDefaultCredential
	$writer.Write(("<p>{0}</p>" -f $px[table_name].HelloWorld()))

	$source = $px[table_name].Exec(3,2,<FL>
		$null<dl>, 	# {0}</dl></FL>)


	$writer.Write("Top 10 select names:<br>")
	$source	| select -first 10 | foreach {	$writer.Write(("{0}<br>" -f $_.SelectName))	}
	$writer.Write("<br>")

	$grid.DataSource = $source
	$grid.DataBind()
	$grid.RenderControl($writer)
<FL GenFields=True>
	${0}.Text = $item.%0:s
	${0}.RenderControl($writer)
	$writer.Write("<br/>`n")<dl></dl></FL>
}

######### Error Handling #########

### render custom error message
##function OnError($exception, $writer){}

########## Unload #########

### clean up
##function OnUnload()
##{
##}

#################################################
################# Reference #####################
#################################################

############# Global Variables ##################

### $this (iLoveSharePoint.WebControls.PowerControl)
### $page (System.Web.UI.Page)
### $viewState (System.Web.UI.StateBag)
### $isPostBack (System.Boolean)
### $spContext (Microsoft.SharePoint.SPContext)
### $httpContext (System.Web.HttpContext)
### $scriptManager (System.Web.UI.ScriptManager)
### $webPartManager (Microsoft.SharePoint.WebPartPages.SPWebPartManager)
### $site (Microsoft.SharePoint.SPSite)
### $web (Microsoft.SharePoint.SPWeb)
### $list (Microsoft.SharePoint.SPList)
### $item (Microsoft.SharePoint.SPListItem)
### $webpart.Parameter1 (string)
### $webpart.Parameter2 (string)
### $webpart.Parameter3 (string)
### $webpart.Parameter4 (string)
### $webpart.Parameter5 (string)
### $webpart.Parameter6 (string)
### $webpart.Parameter7 (string)
### $webpart.Parameter8 (string)
### $webpart.Parameter9 (string)
### $webpart.Parameter10 (string)
### $webpart.Parameter11 (string)
### $webpart.Parameter12 (string)
### $webpart.Parameter13 (string)
### $webpart.Parameter14 (string)
### $webpart.Parameter15 (string)
### $webpart.Parameter16 (string)
### $webpart.Parameter17 (string)
### $webpart.Parameter18 (string)
### $webpart.Parameter19 (string)
### $webpart.Parameter20 (string)

################## Functions #####################

### Get-SPSite -webUrl
### Get-SPWeb -webUrl
### Subscribe-Event -object -event -callback
### Import-PowerModule -name [-noCache](loads a script from the PowerLibrary)
### Import-Assembly -name [-noCache] (loads a .NET assembly from the PowerLibrary)
### Query-Connections (Get data from webpart connections. Fires OnReceiveRow and OnReceiveTable functions)
### Save-Parameters (Saves the webpart parameters to the profile store)
### Init-Parameter -name -defaultValue [-defaultOnEmpty]
### Register-JavaScriptBlock -name -script
### Register-CSSBlock -css
### Register-JavaScriptInclude -name -url
### Register-CSSInclude -url
### Add-HtmlToHeader -html
### RunAs-System -script -args

############ http://iLoveSharePoint.com ##########
############### by Christian Glessner #############

#render($writer)						#remove before publishihg
#$sb = $writer.GetStringBuilder()	#remove before publishihg
#$sb.ToString()						#remove before publishihg