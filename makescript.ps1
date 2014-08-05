# Metaprog scripts, (c) Vladislav Baginsky, 2002-2014. vlad@baginsky.com

# Constants:
$DBInstanceKey="#Instance#" 
$DBRefKey="#References#" 
$SelectName = "SelectName"
$SelectShortName = "SelectShortName"
$TemplateFileFormat = "Template_{0}.txt"

# Datatypes convertor
$SQLtypes = @{ # SQLdecl = format max {0} - type, {1} - size, {2} - precision, {3} - scale
	"uniqueidentifier" = @{ "Flag"="G"; "C#" = "Guid"; "C#N" = "Guid?"; "SQLdecl" = "{0}" };
	"varchar" = @{ "Flag"="S"; "C#" = "String"; "C#N" = "String"; "SQLdecl" = "{0}({1})"};
	"nvarchar" =@{ "Flag"="S"; "C#" = "String"; "C#N" = "String"; "SQLdecl" = "{0}({1})"};
	"char" = 	@{ "Flag"="S"; "C#" = "String"; "C#N" = "String"; "SQLdecl" = "{0}({1})"};
	"nchar" = 	@{ "Flag"="S"; "C#" = "String"; "C#N" = "String"; "SQLdecl" = "{0}({1})"};
	"int" = 	@{ "Flag"="I"; "C#" = "Int";    "C#N" = "Int?"; "SQLdecl" = "{0}"};
	"bigint" = 	@{ "Flag"="I"; "C#" = "Int64";  "C#N" = "Int64?"; "SQLdecl" = "{0}"};
	"smallint" =@{ "Flag"="I"; "C#" = "Int";    "C#N" = "Int?"; "SQLdecl" = "{0}"};
	"tinyint"  =@{ "Flag"="I"; "C#" = "Byte";   "C#N" = "Byte?"; "SQLdecl" = "{0}"};
	"money" = 	@{ "Flag"="N"; "C#" = "Float";  "C#N" = "Float?"; "SQLdecl" = "{0}"};
	"decimal" =	@{ "Flag"="N"; "C#" = "Float";  "C#N" = "Float?"; "SQLdecl" = "{0}({2},{3})"};
	"numeric" =	@{ "Flag"="N"; "C#" = "Float";  "C#N" = "Float?"; "SQLdecl" = "{0}({2},{3})"};
	"DateTime" =@{ "Flag"="D"; "C#" = "DateTime";"C#N"= "DateTime?"; "SQLdecl" = "{0}"};
	"DateTime2"=@{ "Flag"="D"; "C#" = "DateTime";"C#N"= "DateTime?"; "SQLdecl" = "{0}"};
	"smallDateTime" =@{ "Flag"="D"; "C#" = "DateTime";"C#N"= "DateTime?"; "SQLdecl" = "{0}"};
	"time"		=@{ "Flag"="D"; "C#" = "DateTime";"C#N"= "DateTime?"; "SQLdecl" = "{0}"};
	"Date"		=@{ "Flag"="D"; "C#" = "DateTime";"C#N"= "DateTime?"; "SQLdecl" = "{0}"};
	"image" = 	@{ "Flag"="B"; "C#" = "Byte[]"; "C#N" = "Byte[]"; "SQLdecl" = "{0}"};
	"text" = 	@{ "Flag"="B"; "C#" = "Byte[]"; "C#N" = "Byte[]"; "SQLdecl" = "{0}"};
	"ntext" = 	@{ "Flag"="B"; "C#" = "Byte[]"; "C#N" = "Byte[]"; "SQLdecl" = "{0}"};
	"xml" = 	@{ "Flag"="B"; "C#" = "Byte[]"; "C#N" = "Byte[]"; "SQLdecl" = "{0}"};
	"binary" = 	@{ "Flag"="B"; "C#" = "Byte[]"; "C#N" = "Byte[]"; "SQLdecl" = "{0}"};
	"timestamp"=@{ "Flag"="X"; "C#" = "Int64"; "C#N" = "Int64?"; "SQLdecl" = "bigint"};
}

function FormatParams($formatstr, $params) {
	$tab =@{"{name}"  = "{0}";
			"{desc}"  = "{1}";
			"{sql}"	  = "{2}";
			"{c}" 	  = "{3}";
			"{cn}"	  = "{4}";
			"{ft}"	  = "{5}";
			"{fk}"	  = "{6}";
			"{num}"	  = "{7}";
			"{refpk}" = "{8}";
			"{size}"  = "{9}"}

	foreach ($key in $tab.Keys) {
		$formatstr = $formatstr.Replace($key, $tab[$key])
	}
	# replace non tags brakets
	$formatstr = $formatstr -replace "\W}","$&}" -replace "{\D","{$&"
	return ($formatstr -f $params)
}

# System fields
$sys_fields = @{
	"fl_created" = @{"RW"=0; "Flag"="H" };
	"fl_changed" = @{"RW"=1; "Flag"="H" };
	"fl_updated" = @{"RW"=0; "Flag"="" };
	"fl_deleted" = @{"RW"=1; "Flag"="" };
	"fl_author"  = @{"RW"=0; "Flag"="H" };
}

$virtual_fields = @{
	"$SelectName" = 	@{"Type"="varchar"; "Size"=255;};
#	"$SelectShortName"= @{"Type"="varchar"; "Size"=64;};
}

function IIF($q, $y, $n=$null) {
	if ($q -eq $true) { $y } else { $n }
}

function ISNULL($e, $ifnull) {
	if ($e -eq $null) { $ifnull } else { $e }
}

function SG($hash, $field, $default = $null) {
	if ($hash -ne $null) { 
		return $hash[$field] 
	} else { return $default }
}

# Store all object properties into hash array
function ObjectToHash {
Param(
  [Parameter(ValueFromPipeline=$true)]
   $obj,
  [Parameter(Mandatory=$False,Position=2)]
   [string[]]$TypeFilter=@("PSCustomObject"),
  [Parameter(Mandatory=$False,Position=3)]
   [int]$MaxDeep=10
)
	if (($obj -ne $null) -and ($obj.GetType().Name -contains $TypeFilter) -and ($MaxDeep -gt 0)) {
		$props = @{}
		$obj.psobject.properties.name | where { -not [string]::IsNullOrEmpty($_) } | foreach {
			$props[$_] = ObjectToHash -obj $obj.psobject.properties[$_].value -TypeFilter $TypeFilter -MaxDeep ($MaxDeep-1)
		}
		return $props
	} else { 
		return $obj 
	}
}

# Generate table schema
function WFGenFields{
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$False,Position=0)]
   [string]$Instance,
  [Parameter(Mandatory=$False,Position=1)]
   [string]$Database,
  [Parameter(Mandatory=$False,Position=2)]
   [string]$TableName,
  [Parameter(Mandatory=$False,Position=2)]
   [string]$Tunes
)
	$columns = [ordered]@{}
	$columns[$DBInstanceKey] = @{}
	$columns[$DBInstanceKey]["Name"]=$Instance
	$columns[$DBInstanceKey]["Database"] = $Database
	$columns[$DBInstanceKey]["Table"] = $TableName
	$columns[$DBInstanceKey]["Tunes"] = $Tunes

	[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
	#[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo")
	#[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Sdk.Sfc")
	#List of SQL servers
	#[Microsoft.SqlServer.Management.Smo.SmoApplication]::EnumAvailableSqlServers($false) | Select name;

	$srv = New-Object Microsoft.SqlServer.Management.Smo.Server -ArgumentList $Instance
	$db = $srv.Databases[$Database]
	$table = $db.Tables[$TableName]
	$columns[$DBInstanceKey]["MS_Description"] = $table.ExtendedProperties["MS_Description"].Value


	#Write-Host "Foreign keys:"
	$foreign = @{}
	$table.ForeignKeys | foreach {
		$fk=$_
		$fk.Columns | foreach { 
			$foreign[$_.Name]=@{}
			$foreign[$_.Name]["Tree"]=($fk.ReferencedTable -eq $fk.Parent.Name)
			$foreign[$_.Name]["Parent"]=$fk.Parent.Name
			$foreign[$_.Name]["Refer"]=$fk.ReferencedTable
			$foreign[$_.Name]["ReferCol"]=$_.ReferencedColumn
#			write-host ("{0}({2}) -> {1}({3}) it's Tree = {4}" -f $_.Name, $_.ReferencedColumn, $fk.Parent.Name, $fk.ReferencedTable, ($fk.ReferencedTable -eq $fk.Parent.Name))
		}
	}

	$colnum = 1; $title_fields = ""; $pk_field = ""
	Write-Host -ForegroundColor Red "Columns:"
	$table.Columns | where {-not $_.Computed} | foreach {
		$col = $_
		$columns[$col.Name] = [ordered]@{}
		$columns[$col.Name]["Description"]=($col.ExtendedProperties | ? { $_.Name -eq "MS_Description" }).Value
		$columns[$col.Name]["Number"]=$colnum
		$columns[$col.Name]["Type"]=$col.DataType.Name
		$columns[$col.Name]["TypeDecl"]=($SQLtypes[$col.DataType.Name]["SQLdecl"] -f $col.DataType.Name, $col.DataType.MaximumLength, $col.DataType.NumericPrecision, $col.DataType.NumericScale)
		$columns[$col.Name]["Size"]=$col.DataType.MaximumLength
		$columns[$col.Name]["NumPrecision"]=$col.DataType.NumericPrecision
		$columns[$col.Name]["NumScale"]=$col.DataType.NumericScale
		$columns[$col.Name]["Nullable"]=$col.Nullable
		$columns[$col.Name]["PK"]=$col.InPrimaryKey
		$columns[$col.Name]["FK"]=$col.IsForeignKey
		if ($col.IsForeignKey) {
			$columns[$col.Name]["FKTable"]=SG -hash $foreign[$col.Name] -field "Refer" -default ""
			$columns[$col.Name]["FKTableKey"]=SG -hash $foreign[$col.Name] -field "ReferCol" -default ""
			$columns[$col.Name]["FK_tree"]=SG -hash $foreign[$col.Name] -field "Tree" -default ""
		}
		$columns[$col.Name]["Flag"]=
			(SG -hash $SQLtypes[$col.DataType.Name] -field "Flag" -default "") + 
			(IIF -q $col.InPrimaryKey -y "P") + (IIF -q $col.IsForeignKey -y "L") + 
			(IIF -q ($sys_fields.Keys -contains $col.Name) -y "F") + 
			(SG -hash $sys_fields[$col.Name] -field "Flag" -default "") +
			(IIF -q (SG -hash $foreign[$col.Name] -field "Tree" -default "") -y "T")
		$columns[$col.Name]["RW"]=SG -hash $sys_fields[$col.Name] -field "RW" -default "1"
		write-host -ForegroundColor DarkBlue ("{0} 	{1}({2}) {3} Flags: {4}" -f $col.Name, $col.DataType.Name, $col.DataType.MaximumLength, $col.DataType.SqlDataType, $columns[$col.Name]["Flag"])
		
		if (($col.Name -like "*name") -and ([Char[]]$columns[$col.Name]["Flag"] -contains "S")) {
			if (-not [string]::IsNullOrEmpty($title_fields)) { $title_fields+=" + ' ' + " }
			$title_fields += "ISNULL("+$col.Name+", '')"
		}
		
		if ($col.InPrimaryKey -and [string]::IsNullOrEmpty($pk_field)) { $pk_field = $col.Name }

		$colnum++
	}

	if ([string]::IsNullOrEmpty($title_fields)) {
		$title_fields = "CONVERT(varchar,{0},64)" -f $pk_field
	}

	$virtual_fields.Keys | foreach {
		$columns[$_] = @{}
		$columns[$_]["Description"]="Название отображаемое в списках"
		$columns[$_]["Number"]=$colnum
		$columns[$_]["Type"] = $virtual_fields[$_]["Type"]
		$columns[$_]["Size"] = $virtual_fields[$_]["Size"]
		$columns[$_]["RW"]   = 1
		$columns[$_]["Flag"]  = "V"+(SG -hash $SQLtypes[$col.DataType.Name] -field "Flag" -default "")
		$colnum++
	}

#	$dw = New-object Microsoft.SqlServer.Management.Smo.DependencyWalker -ArgumentList $srv
#	$tree = $dw.DiscoverDependencies($table, [Microsoft.SqlServer.Management.Smo.DependencyType]::Children)
#	$cur = $tree.FirstChild.FirstChild;
#	while ($cur -ne $null)
#	{
#		$obj = $srv.GetSmoObject($cur.Urn)
#		if (($obj -ne $null) -and ($obj.Events.ToString() -eq "Microsoft.SqlServer.Management.Smo.TableEvents")) {
#			$tt = [Microsoft.SqlServer.Management.Smo.Table]$obj
#			$tt.ForeignKeys | where { $_.ReferencedTable -eq $table.Name } | foreach { 
#				$fk = $_
#				$fk.Columns | foreach { 
#					Write-Host $fk.Parent.Name, $_.Name
#				}
#			}
#		}
#    	$cur = $cur.NextSibling;
#	}

	$con = New-Object System.Data.SqlClient.SqlConnection
	$con.ConnectionString = ("Server={0}; Database={1}; Integrated Security=true;" -f $Instance, $Database)
	$con.Open()
	$cmd = New-Object System.Data.SqlClient.SqlCommand
	$cmd.CommandText = "
		SELECT OBJECT_NAME(parent_object_id) 'RefTable', c.NAME 'RefCol', cref.NAME 'LocCol', pk.COLUMN_NAME 'RefPK'
		FROM sys.foreign_key_columns fkc 
		INNER JOIN sys.columns c ON fkc.parent_column_id = c.column_id AND fkc.parent_object_id = c.object_id
		INNER JOIN sys.columns cref ON fkc.referenced_column_id = cref.column_id AND fkc.referenced_object_id = cref.object_id 
		INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE pk ON OBJECTPROPERTY(OBJECT_ID(constraint_name), 'IsPrimaryKey') = 1 AND TABLE_NAME=OBJECT_NAME(fkc.parent_object_id)
		WHERE OBJECT_NAME(referenced_object_id) = '$TableName'
	"
	$cmd.Connection = $con
	$cmd.CommandType = [System.Data.CommandType]::Text
	$rdr = $cmd.ExecuteReader()

	While ( $rdr.Read() ) {
		if ([string]::IsNullOrEmpty($rdr["LocCol"]) -ne $true) {
			$agrcolname = ("{0}.{1}" -f $rdr["RefTable"],$rdr["RefCol"])
			$columns[$agrcolname]=[ordered]@{}
			$columns[$agrcolname]["Description"]="Link {0}.{1} -> {2}.{3}" -f $rdr["RefTable"],$rdr["RefCol"],$TableName,$rdr["LocCol"]
			$columns[$agrcolname]["Number"]=$colnum # возможно надо проставлять номер поля из БД?
			$columns[$agrcolname]["Type"]=$columns[$rdr["LocCol"]]["Type"]
			$columns[$agrcolname]["TypeDecl"]=$columns[$rdr["LocCol"]]["TypeDecl"]
			$columns[$agrcolname]["Size"]=$columns[$rdr["LocCol"]]["Size"]
			$columns[$agrcolname]["PK"]=$columns[$rdr["LocCol"]]["PK"]
			$columns[$agrcolname]["FK"]=$columns[$rdr["LocCol"]]["FK"]
			$columns[$agrcolname]["FKLocalKey"]=$rdr["LocCol"]
			$columns[$agrcolname]["FKTable"]=$rdr["RefTable"]
			$columns[$agrcolname]["FKTableKey"]=$rdr["RefCol"]
			$columns[$agrcolname]["FKTablePK"]=$rdr["RefPK"]
			$columns[$agrcolname]["Flag"]=$columns[$rdr["LocCol"]]["Flag"]+"R"
			$columns[$agrcolname]["RW"]=$columns[$rdr["LocCol"]]["RW"]
			$colnum++
		}
	}		
	$rdr.Close()
	$con.Close()

	if (-not (Test-Path $Tunes)) {
		$TuneParams = @{}
		$names = $colums
		# find title fields
		$TuneParams["SelectName"]=$title_fields
		if ($columns.Keys -contains "fl_deleted") { $TuneParams["SelectName"]+=" + CASE WHEN fl_deleted IS NOT NULL THEN ' (X)' ELSE '' END" }
		$TuneParams["SelectShortName"]=$title_fields
		$TuneParams | ConvertTo-Json -Depth 3 | foreach { $_.Replace("\u0027","'") } | Out-File -Encoding UTF8 $Tunes
	}	

	$columns
}

#==================================================================
#==================================================================
#==================================================================
#==================================================================

function VerticalAlign($block, [char]$align_char, [int]$tabsize=4) {	
	$reg = "(?i)\[V\]"
	$block = $block.Replace("`t","".PadLeft($tabsize, $align_char)).Replace("`r","")
	$ar = $block -split "`n"
	do {
	# find mark max ident
	$max=-1
	foreach ($str in $ar) {
		if (($m = [regex]::Match($str, $reg)).Success) {
			$ind = $m.Index
			if ($max -lt $ind) { $max = $ind }
		}
	}
	# align
	for ($i=0; $i -lt $ar.Count; $i++) {
		if (($m = [regex]::Match($ar[$i], $reg)).Success) {
			$ar[$i] = $ar[$i].Remove($m.Index, $m.Length).Insert($m.Index, "".PadLeft($max - $m.Index, $align_char))
		}
	}
	} while ($max -ge 0)
	return $ar -join "`r`n"
}

function CreateParams($col) {
	$params = @((IIF -q ([Char[]]$columns[$col]["Flag"] -contains "R") -y $columns[$col]["FKLocalKey"] -n $col); 
		ISNULL -e $columns[$col]["Description"] -ifnull $col;
		$columns[$col]["TypeDecl"];
		$SQLtypes[$columns[$col]["Type"]]["C#"]; 
		$SQLtypes[$columns[$col]["Type"]]["C#N"];
		ISNULL -e $columns[$col]["FKTable"] -ifnull "";
		ISNULL -e $columns[$col]["FKTableKey"] -ifnull "";
		$columns[$col]["Number"];
		ISNULL -e $columns[$col]["FKTablePK"] -ifnull "";
		$columns[$col]["Size"];
	)
	return $params
}

# Find <IF>,<IFF>,<ELIF>,<ELIFF> blocks
# $col - одно поле или массив для проврки условия, 
# 	для каждого поля должны сработать все заданные условия
#   для массива полей нужно что бы условия сработали хотя бы для одного поля
# $prevresuls - результат срабатывания предыдущего условия (для возможности соединения с ELIF)
function ParseIFMacros($iftype="IF", $text, $col, $prevresult=$false) {
	$reg_if = [regex]"(?sim)<($iftype|EL$iftype)(?:\s+(.*?)>|>)(.*?)(?:\[ELSE\](.*?)<\/\1>|</\1>)"
	$reg_opt= [regex]"(?sim)(\w+)\s*=\s*(?:(([""'])([^\3]+?)\3)|([^\s^>]*))"
	if ($col -is [Hashtable]) { $col = $col.Keys }
	$if = $reg_if.Match($text)	
	while ($if.Success) {
		$attr = $if.Groups[2].Value
		$valuetrue = $if.Groups[3].Value
		$valuefalse = $if.Groups[4].Value
		
		if ($if.Groups[1].Value -like "IF*") {	# старт нового условия
			$prevresult = $false
		} else { # продолжение старого условия в режиме else
			if ($prevresult) { $valuetrue=""; $result=$true  } # предыдущее условие отработало, значит это просто чистим
		}
		if (-not $prevresult) {
			$totalresult = $false
			foreach ($colitem in $col) { # перебор всех переданных полей
				$result = $true
				$reg_opt.Matches($attr) | ? { $result } | foreach {
					$attrname = $_.Groups[1].Value
					$attrvalue = ISNULL -e $_.Groups[4].Value -ifnull $_.Groups[5].Value
					$result = $true
					if (($attrname -eq "FE") -or ($attrname -eq "EQ")) {
						$result = $result -and ($colitem -eq $attrvalue)
					} else { 
					if ($attrname -eq "FL") {
						$found = $false
						$val = [Char[]]$attrvalue
						if ($val -notcontains "H") {	$val+="h" }# прячем скрытые поля
						if ($val -notcontains "V") {	$val+="v" }# прячем вычисляемые поля (SelectName)
						if ($val -notcontains "R") {	$val+="r" }# прячем внешние ссылки на эту таблицу
#						if ($val -notcontains "B") {	$val+="b" }# прячем BLOB-поля, т.к. как правило их надо обрабатывать отдельно
						foreach ($ch in $val) {
							if ([char]::IsLower($ch)) {
								$result = $result -and ([Char[]]$columns[$colitem]["Flag"] -notcontains $ch)
							} else {
								$found  = $found  -or ([Char[]]$columns[$colitem]["Flag"] -contains $ch)
							}
						}
						$result = $result -and $found
					} else { 
					if ($attrname -eq "FC") {
						$attrvalue = FormatParams -formatstr $attrvalue -params (CreateParams -col $colitem)
						try {
							$result = $result -and (Invoke-Expression $attrvalue)
						} catch {
							write-host -ForegroundColor red "Ошибка в выражении $attrvalue"
							return
						}
					} else { 
					if ($attrname -eq "NULLABLE") {
						$result = $result -and ($columns[$colitem]["Nullable"].ToString() -eq $attrvalue)
					}
					}}} # close all else branches
				} # foreach match <if>
				$totalresult = $totalresult -or $result
			} # foreach cols
		}
		$text = $text.Replace($if.Value, (IIF -q $totalresult -y $valuetrue -n $valuefalse))
		$prevresult=$totalresult
		$if = $reg_if.Match($text) # ищем дальше
	} # while regex.match
	return @{"prevresult"=$prevresult; "text"=$text}
}

# $tag - regex match object where:
#   group[1] - whole tag
#   group[2] - tag attributes
#   group[3] - tag value
$global:dl_parsed=""
function ParseFieldList($tag, $can_continue) {
#	write-host -ForegroundColor DarkGreen ("Parse: " + $tag.Value)
	$reg_dl = [regex]"(?sim)<DL\s*?(.*?)>(.*?)<\/DL>"
	$reg_opt= [regex]"(?sim)(\w+)\s*=\s*(?:(([""'])([^\3]+?)\3)|([^\s^>]*))"

	$fl_opt = $tag.Groups[2].Value
	$fl_val = $tag.Groups[3].Value
	# extract DL
	$dl = $reg_dl.Match($fl_val)
	if ($dl.Success) {
		$dl_opt = $dl.Groups[1].Value
		$dl_val = $dl.Groups[2].Value
		$fl_val = $fl_val.Replace($dl.Value, $dl_value)
	} else { $dl_opt = ""; $dl_val = "" }

	$fl_attr = @{}
	$reg_opt.Matches($fl_opt) | foreach {
		$fl_attr[$_.Groups[1].Value] = ISNULL -e $_.Groups[4].Value -ifnull $_.Groups[5].Value
	}
	$dl_attr = @{}
	$reg_opt.Matches($dl_opt) | foreach {
		$dl_attr[$_.Groups[1].Value] = $_.Groups[2].Value
	}

	$field_list = ""
	if ($fl_attr["Types"].Length -gt 0) {
		$fl_filter = [Char[]]($fl_attr["Types"] -replace "\s")
		$all_fields_base = ($fl_filter -contains "A") -or ($fl_attr["Types"] -ceq $fl_attr["Types"].ToLower())
	} else { 
		$all_fields_base = $true 
		$fl_filter = [Char[]]("A")
	}
	$fl_name_filter = ISNULL -e $fl_attr["Like"] -ifnull "*"
	
	if ($fl_filter -notcontains "H") {	$fl_filter+="h" }# прячем скрытые поля
	if ($fl_filter -notcontains "V") {	$fl_filter+="v" }# прячем вычисляемые поля (SelectName)
	if ($fl_filter -notcontains "R") {	$fl_filter+="r" }# прячем внешние ссылки на эту таблицу
#	if ($fl_filter -notcontains "B") {	$fl_filter+="b" }# прячем BLOB-поля, т.к. как правило их надо обрабатывать отдельно
	
	if ($fl_filter -contains "&") { # фильтр обязательного совпадения всех указанных флагов
		$fl_filter = $fl_filter -ne "&"
		$fl_min_overlap = ($fl_filter | where { [char]::IsUpper($_) }).Count # считаем только разрешающие фильтры
	} else { $fl_min_overlap = 1; }
	
	$columns.keys | where {($DBInstanceKey, $DBRefKey) -notcontains $_} | where {
		# собираем совпадения флагов фильтра и флагов поля
		$colflag = [Char[]]$columns[$_]["Flag"]
		$denied=$_ -notlike $fl_name_filter
		$overlap = [Char[]]($fl_filter | where { 
			$colflag -contains $_ 
		} | foreach { 
			if ([char]::IsLower($_)) { 
				$denied = $true
			} 
			return $_
		})
		return (-not $denied) -and (($overlap.Length -ge $fl_min_overlap) -or $all_fields_base)
	} | sort { $columns[$_]["Number"]} | foreach {
		$params = CreateParams -col $_
		
		$ifmac = ParseIFMacros -iftype "IFF" -text $fl_val -col $_ -prevresult $ifmac["prevresult"]
		$fl_parsed = $ifmac["text"]

		$continue = ((-not [string]::IsNullOrEmpty($field_list)) -or ($can_continue -and ($fl_filter -contains "<")))
		if ($continue) {
			$field_list += $global:dl_parsed
		}
		try {
			$global:dl_parsed = (FormatParams -formatstr $dl_val -params $params)
			$field_list += (FormatParams -formatstr $fl_parsed -params $params)
		} catch {
			Write-Host "`n`nError in template: $Template"
			Write-Host ("Look  entry of <FL> block: " + $fl_parsed)
		}
	}

	return $field_list
}

function ParseEvalBlock($tag, $can_continue) {
	return (Invoke-Expression $tag.Groups[3].Value)
}

function ParseAlignBlock($tag, $can_continue) {
	return (VerticalAlign -block $tag.Groups[3].Value -align_char " ")
}

#find all $tagname tags and parse it by $func
function ParseTagBlocks ($text, $tagname, $parse_func) {
	$continue_flag = $false 
	$reg_pat = "(?sim).*(<$tagname\s*?(.*?)>(.*?)<\/$tagname>)" 
	$reg_end = "(?sim).*?</$tagname>" # паттерн вылавливания первого конца тэга (нужно для возможности вложенного поиска)
	while (($mstop = [regex]::Match($text, $reg_end )).Success) {
		if (-not ($tag = [regex]::Match($mstop.Value, $reg_pat)).Success) {
			Write-Host -ForegroundColor red "'$tagpat' not found for '$tagend' in position $($mstop.index)"
			throw 
		} else { # tag found, start parsing
			$last_index = -1
			if ($tag.Index -eq $last_index) {
				# предыдущий парсинг ничего не изменил в тексте?
				throw "Parser error!"
			}
			$last_index = $tag.Index			
			$parsed = (& $parse_func -tag $tag -can_continue $continue_flag)
			$continue_flag = -not [string]::IsNullOrEmpty($parsed)
			$text = $text.Replace($tag.Groups[1].Value, $parsed)
#			Write-Host $tag.Groups[1].Value, $text
#			Write-Host ""
		}
	}
	return $text
}

function WFMakeScript{
[CmdletBinding()]
Param(
  [Parameter(ValueFromPipeline=$true)]
  $columns, 
  [Parameter(Mandatory=$True)]
  [string]$Template,
  [Parameter(Mandatory=$False)]
  [string]$OutFile, # может быть шаблоном, куда вставится имя таблицы нулевым параметром
  [Parameter(Mandatory=$False)]
  [string]$Tunes,   # индивидуальные настройки для этой таблицы (либо хэш, либо имя файла json)
  [Parameter(Mandatory=$False)]
  $ConfigParams  # хэш доп.параметров шаблона
)

	$Instance = $columns[$DBInstanceKey]["Name"]
	$Database = $columns[$DBInstanceKey]["Database"]
	$table_name= $columns[$DBInstanceKey]["Table"]
	if ($Tunes.GetType().Name -eq "String") {
		if ([string]::IsNullOrEmpty($Tunes)) {
			$TuneParams = @{}
		} else {
			$TuneParams = Get-Content $Tunes -Raw | ConvertFrom-Json | ObjectToHash -MaxDeep 1
		}
	} else { $TuneParams = $Tunes }

	$OutFile = ($OutFile -f $table_name)
	Write-Host "Creating $OutFile from template: $Template"

	$out = [Io.File]::ReadAllText($Template)
	while ($out -match  "\[include:(.+?)\]") {
		$incfile = $Matches[1]
		if ($incfile.IndexOf("\") -lt 0) { $incfile = (pwd).ToString() + "\$incfile"}
		$out = $out.Replace($Matches[0], [Io.File]::ReadAllText($incfile))
	}
	$out = $out -replace "\[webform_version\]", ("Created "+[datetime]::Now.ToString("yyyy-MM-dd hh:mm")+" by ASP-WEB Form generator, ver: 4.0.0.1, Powershell Edition. (c) Vladislav Baginsky (vlad@baginsky.com), 2002-2014")
	$out = $out -replace "\[table_name\]", $table_name
	while (($out -match  "\[param:(.+?)\]") -and ($ConfigParams -ne $null)) {
		$out = $out.Replace($Matches[0], $ConfigParams[$Matches[1]])
	}
	while (($out -match  "\[tune:(.+?)\]") -and ($ConfigParams -ne $null)) {
		$out = $out.Replace($Matches[0], $TuneParams[$Matches[1]])
	}

	$out = (ParseIFMacros -iftype "IF" -text $out -col $columns)["text"]

	# parse [pk]
	$pk = $columns.keys | where {($DBInstanceKey, $DBRefKey) -notcontains $_} | where { [Char[]]$columns[$_]["Flag"] -contains "P" }
	if ($out -match "\[pk\]") {
		if (($pk.count -gt 1) -or ($pk -eq $null)) {
			throw "Single-field Primary key need!"
		}
		$out = $out -replace "\[pk\]", $pk
	}

	$reg_fl = ".*(<FL\s*?(.*?)>(.*?)<\/FL>)" 
	$reg_fl_end = ".*?</FL>" # паттерн вылавливания первого конца тэга FL (нужно для возможности вложенного поиска)
	
	$dl_parsed = ""
	$ifmac = @{"prevresult"=$false}

	$out = ParseTagBlocks -text $out -tagname "FL" -parse_func ParseFieldList
	
	$out = ParseTagBlocks -text $out -tagname "CALC" -parse_func ParseEvalBlock
	
	$out = ParseTagBlocks -text $out -tagname "AL" -parse_func ParseAlignBlock

	if ($OutFile.Length -gt 0) {
		$out | Out-File -LiteralPath $OutFile -Encoding utf8
	} else { 
		$out
	}
}	

function WFMakeAllScripts{
[CmdletBinding()]
Param(
  [Parameter(ValueFromPipeline=$true)]
  $columns,
  [Parameter()]
  $target_dir = ""
)
	if ($columns.GetType().Name -eq "String") {
		$columns = Get-Content $columns -Raw | ConvertFrom-Json | ObjectToHash
	}
	$curdir = pwd
	Write-Host "Working dir $curdir"
	$conf = Get-Content "$curdir\makescript.json" -Raw | ConvertFrom-Json | ObjectToHash
	$conf.Keys | where { $conf[$_]["enable"] -eq $true } | foreach {
		$name 	  = $conf[$_]["name"]
		$template = $conf[$_]["template"]
		$params = $conf[$_]["params"]
		$tunes = $columns[$DBInstanceKey]["Tunes"]
		$columns | WFMakeScript -Template "$curdir\$template" -Tunes $tunes -OutFile "$target_dir\$name" -ConfigParams $params
	}
}
