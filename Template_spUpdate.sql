SET ANSI_NULLS OFF
GO

/* 
[webform_version]
*/ 
[param:sp_create_mode] PROCEDURE dbo.sp[table_name]_update
<AL>(
	[v]@SubMode [v]bigint [v]= 0,[v] -- 0 - Simple update, 1 - Incremental update, else - Bitmaped update
<FL>[v]@{0} [v]{2} [v]= NULL OUTPUT<DL>,[v]
</DL></FL>
)</AL>
AS

<IF FE="fl_updated">IF (NOT @fl_updated IS NULL) AND (SELECT fl_updated FROM [table_name] WHERE <FL Types="P">({0} = @{0})<DL> AND </DL></FL>)<>@fl_updated
BEGIN
	-- Return back existed record 
	EXEC dbo.sp[table_name]_select 0, <FL>@{0} OUTPUT<DL>, </DL></FL>
	RAISERROR ('Record modified by another user! Table: [table_name]', 16, 1)
	RETURN -1 -- Record modified by other user
END</IF>

-- check for empty update
--SET ANSI_NULLS OFF must by set before CREATE/ALTER proc
IF NOT EXISTS(SELECT * FROM [table_name]<AL>
	WHERE [v](<FL Types="P">{0}=@{0})<DL> [v]AND </DL></FL> AND NOT (
	[v]<FL Types="px">({0} = @{0} [v]OR ({0} is NULL [v]AND @{0} is NULL))<DL> [v]AND
	[v]</DL></FL>))</AL>
BEGIN -- no changes of record
	EXEC dbo.sp[table_name]_select 0, <FL>@{0} OUTPUT<DL>, </DL></FL>
	RETURN 0
END

<FL Types="T">-- Check for move tree branch for link {0}->{6}
DECLARE @{0}_old @{2}
SELECT @{0}_old={0} FROM [table_name] WHERE <FL Types="P">({0}=@{0})<DL> AND </DL></FL>
</FL>

BEGIN TRAN

IF @SubMode=0 /* Standard update */
	UPDATE [table_name]<AL>
	SET <FL Types="pf">{0} = [V]@{0}<DL>,
		</DL></FL><IF FE="fl_changed">,
		fl_changed = [V]GETDATE()</IF><IF FE="fl_author">,
		fl_author = [V]SYSTEM_USER</IF></AL>
	WHERE <FL Types="P">({0} = @{0})<DL> AND </DL></FL>
ELSE
IF @SubMode=1 /* Update not null values only */
	UPDATE [table_name]<AL>
	SET <FL Types="pf">{0} = [V]ISNULL(@{0}, [v]{0})<DL>,
		</DL></FL><IF FE="fl_changed">,
		fl_changed = [V]GETDATE()</IF><IF FE="fl_author">,
		fl_author = [V]SYSTEM_USER</IF>
	WHERE <FL Types="Pf">({0} = @{0})<DL> AND </DL></FL></AL>
ELSE
	UPDATE [table_name] /* Bitmaped update */<AL>
	SET <FL Types="pf">{0} = [V]CASE WHEN (@SubMode & <CALC>[math]::Pow(2,{7}-1)</CALC>[V]<>0 THEN @{0} [V]ELSE {0} [V]END<DL>, -- @Submode = {0} <CALC>[math]::Pow(2,{7}-1)</CALC>
		</DL></FL><IF FE="fl_changed">,
		fl_changed = [V]GETDATE()</IF><IF FE="fl_author">,
		fl_author = [V]SYSTEM_USER</IF>
	WHERE <FL Types="P">({0} = @{0})<DL> AND </DL></FL></AL>

IF @@ERROR<>0  -- Last SQL-statement error
BEGIN
	IF @@TRANCOUNT<>0
		ROLLBACK TRAN
	RETURN dbo.funcGetErrorCode('UPDATE','[table_name]',@@ERROR)
END

-- Return back updated record (must be first result recorset in sequence)
EXEC dbo.sp[table_name]_select 0, <FL>@{0} OUTPUT<DL>, </DL></FL>

-- Events support
DECLARE @P1 uniqueidentifier,@P2 uniqueidentifier,@P3 uniqueidentifier
SELECT @P1=<FL Types="P">@{0}</FL>, @P2=dbo.funcBaseTables_GetID('[table_name]'), @P3=dbo.funcUser_GetID()
EXEC dbo.spEvent 'UPDATE_[table_name]', @P1, @P2, @P3, 'Update record in table [table_name]'

<FL Types="T">-- Tree support for {0} -> {6}
IF (@{0}_old<>@{0})
  EXEC dbo.spTreeNSM 4, DEFAULT, @{6}, @{0}, '[table_name]', 1
</FL>
COMMIT TRAN
RETURN 0
GO

[include:Template_inc_SQL_grants.sql]