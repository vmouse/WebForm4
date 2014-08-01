/* 
[webform_version]
*/ 
[param:sp_create_mode] PROCEDURE dbo.sp[table_name]
<AL>(
	[v]@Mode [v]int [v]= 3,[v] -- 0 - Insert, 1 - Update, 2 - Delete, 3 - Select
[v]@SubMode [v]bigint [v]= 0,[v] -- 0 - Simple mode, other - see Insert,Update,Delete,Select
<FL>[v]@{0} [v]{2} [v]= NULL OUTPUT<DL>,[v]
</DL></FL>
)</AL>
AS

DECLARE @RETURN_RESULT INT
SET @RETURN_RESULT=-99999 -- Unknown Error

-- Reset empty strings to NULL
<AL><FL Types="Sfv">SELECT @{0} = [v]CASE LTRIM(RTRIM(@{0})) [v]WHEN '' THEN NULL ELSE @{0} [v]END<DL>
</DL></FL></AL>

DECLARE @check_content_double int
SET @check_content_double = 0<AL>
IF (@Mode in (0,1,2))<FL Types="P"> AND (@{0} is NULL)<DL></DL></FL> -- check for content doubling
	SELECT @check_content_double = 1<FL Types="P">, @{0} = {0}</FL>
	FROM [table_name]
	WHERE <FL Types="pvf">[v]({0}=@{0} [v]OR ({0} is NULL [v]AND @{0} is NULL))<DL> [v]AND
		</DL></FL></AL>

IF (@Mode in (0)) and (@check_content_double=1)
	BEGIN
		RAISERROR ('Double content insert into "[table_name]"', 16, 1)
		RETURN dbo.funcGetErrorCode('DENYINSERTDBL', '[table_name]',0)
	END

IF (@Mode=0) /* Insert */ OR (@Mode=1 AND NOT EXISTS(SELECT * FROM [table_name] WHERE <FL Types="P">(@{0} = {0})<DL> AND </DL></FL>))
BEGIN
	IF dbo.funcCheckWriteAccess('[table_name]',NULL)=0
	BEGIN
		RAISERROR ('DENYINSERT into [table_name]', 16, 1)
		RETURN dbo.funcGetErrorCode('DENYINSERT', '[table_name]',0)
	END
	EXEC @RETURN_RESULT = dbo.sp[table_name]_insert @SubMode=@SubMode, <FL>@{0}=@{0} OUTPUT<DL>, </DL></FL>
END
ELSE
IF @Mode=1 /* Update */
BEGIN
	IF dbo.funcCheckReadWriteAccess('[table_name]',@role_id)=0
	BEGIN
		RAISERROR ('DENYUPDATE [table_name]', 16, 1)
		RETURN dbo.funcGetErrorCode('DENYUPDATE', '[table_name]',0)
	END
	EXEC @RETURN_RESULT = dbo.sp[table_name]_update @SubMode=@SubMode, <FL>@{0}=@{0} OUTPUT<DL>, </DL></FL>
END
ELSE
IF @Mode=2 /* Delete */
BEGIN
	IF dbo.funcCheckDeleteAccess('[table_name]',@role_id)=0
	BEGIN
		RAISERROR ('DENYDELETE from [table_name]', 16, 1)
		RETURN dbo.funcGetErrorCode('DENYDELETE', '[table_name]',0)
	END
	EXEC @RETURN_RESULT = dbo.sp[table_name]_delete @SubMode=@SubMode, <FL Types="P">@{0}=@{0}<DL>, </DL></FL>
END
ELSE
IF @Mode=3 /* Select */
	EXEC @RETURN_RESULT = dbo.sp[table_name]_select @SubMode=@SubMode, <FL>@{0}=@{0} OUTPUT<DL>, </DL></FL>
ELSE
IF @Mode=4 /* Retrieve lists */
	EXEC @RETURN_RESULT = dbo.sp[table_name]_retrieve @SubMode=@SubMode, <FL>@{0}=@{0} OUTPUT<DL>, </DL></FL>
ELSE
BEGIN
	RAISERROR ('ERRMODE (Unknown) with sp[table_name]', 16, 1)
	RETURN dbo.funcGetErrorCode('ERRMODE','[table_name]',0)
END

RETURN @RETURN_RESULT
GO


GRANT EXEC ON dbo.sp[table_name] TO public
GO

[include:Template_inc_SQL_grants.sql]