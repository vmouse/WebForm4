/* 
[webform_version]
*/ 
[param:sp_create_mode] PROCEDURE dbo.sp[table_name]_select
<AL>(
	[v]@SubMode [v]bigint [v]= 0,[v] -- 0 - Select single, 1 - Select all, 2 - Select Filtered, 3 - Select SelectName and PK only
<FL>[v]@{0} [v]{2} [v]= NULL OUTPUT<DL>,[v]
</DL></FL>
)</AL>
AS
IF @SubMode=0 -- Select into result recordset 
BEGIN<AL>
	-- Select first record into SP parameters 
	SELECT *
	FROM view[table_name]Resolved
	WHERE <FL Types="P">({0}=@{0})<DL> AND </DL></FL>

	SELECT TOP 1 <FL>[v]@{0} [v]= {0}<DL>, 
	</DL></FL>
	FROM view[table_name]
	WHERE <FL Types="P">({0}=@{0})<DL> AND </DL></FL></AL>
END
ELSE IF @SubMode=1 -- Return all records.*/
BEGIN
	SELECT *
	FROM view[table_name]Resolved<IF FE="fl_deleted">
	WHERE (fl_deleted is NULL) OR (fl_admin_access = 1) OR (<FL Types="P">{0}=@{0}<DL> AND </DL></FL>)</IF>
	ORDER BY <FL Types="V">{0}<DL>, </DL></FL>
END
ELSE IF @SubMode=2 -- Filter mode. Use parameters as filter 
BEGIN<AL>
	SELECT *
	FROM view[table_name]Resolved
	WHERE [v]<FL Types="Svf">(({0} [v]LIKE [v]@{0}) [v]OR (@{0} [v]is NULL))<DL> AND
		[v]</DL></FL><FL Types="<svf">(({0} [v]= [v]@{0}) [v]OR (@{0} [v]is NULL))<DL> AND
		[v]</DL></FL><IF FE="fl_deleted"> AND
		[v]((fl_deleted is NULL) OR (fl_admin_access = 1) OR (<FL Types="P">{0}=@{0}<DL> AND </DL></FL>))</IF>
	ORDER BY <FL Types="V">{0}<DL>, </DL></FL></AL>
END
ELSE IF @SubMode=3 -- Return all SelectNames.*/
BEGIN
	SELECT <FL Types="PV">{0}<DL>, </DL></FL>
	FROM view[table_name]Resolved<IF FE="fl_deleted">
	WHERE (fl_deleted is NULL) OR (fl_admin_access = 1) OR (<FL Types="P">{0}=@{0}<DL> AND </DL></FL>)</IF>
	ORDER BY <FL Types="V">{0}<DL>, </DL></FL>
END
ELSE
	RETURN dbo.funcGetErrorCode('ERRSUBMODE','[table_name]',0)
GO

[include:Template_inc_SQL_grants.sql]