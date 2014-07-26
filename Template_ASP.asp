<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001" LCID=1049 %><%
Session.lcid=1049
Session.codepage=65001
SetLocale("ru-RU")
Response.CharSet = "UTF-8"
%>
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<style type="text/css">
<!--
.red {
	font-weight: bold;
	color: #FF0000;
}
-->
</style>
</head>
<body>
<!--#include virtual="\lib\mainlib.asp" -->
<!--#include virtual="\lib\FormLib.asp" -->

[include:Template_ASP_model.txt]

[include:Template_ASP_control.txt]

[include:Template_ASP_view.txt]

<% ' Begin destroy objects for [table_name]Form
Set [table_name]Form = nothing
Set DB = nothing
' End destroy objects for [table_name]Form %>
</body>
</html>