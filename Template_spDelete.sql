/* 
[webform_version]
*/ 
[param:sp_create_mode] PROCEDURE dbo.sp[table_name]_delete
<AL>(
	[v]@SubMode [v]bigint [v]= 0,[v] -- 0 - Simple Delete; 1 - Hide record; 2 - Unhide record; 10,11,12 - Cascaded delete with linked objects by @SubMode - 10
<FL>[v]@{0} [v]{2} [v]= NULL OUTPUT<DL>,[v]
</DL></FL>
)</AL>
AS

<IF FE="fl_updated">
IF (NOT @fl_updated IS NULL) AND (SELECT fl_updated FROM [table_name] WHERE <FL Types="P">({0} = @{0})<DL> AND </DL></FL>)<>@fl_updated
BEGIN
	-- Return back existed record 
	EXEC dbo.sp[table_name]_select 0, <FL>@{0} OUTPUT<DL>, </DL></FL>
	RAISERROR ('Record modified by another user! Table: [table_name]', 16, 1)
	RETURN -1 -- Record modified by other user
END</IF>

DECLARE @RETURN_RESULT INT
DECLARE @EventName  nvarchar(32)
SET @RETURN_RESULT=0

DECLARE @SelName  nvarchar(128)
SET @SelName = (SELECT SelectName FROM view[table_name] WHERE <FL Types="P">({0} = @{0})<DL> AND </DL></FL>)

IF	@SubMode=0
BEGIN
	SET @EventName='DELETE_[table_name]'
	-- Delete access rules
	DELETE FROM ObjAccessMethod WHERE oacc_method_obj_name='[table_name]' AND <FL Types="P">(oacc_method_obj_id = @{0})<DL> AND </DL></FL>

	<FL Types="T">
	-- Tree support for {0} -> {6}
	UPDATE [table_name] -- connect parent and chield before element deleting
	SET @{0} = (SELECT {0} FROM [table_name] WHERE ({6} = @{6}))
	WHERE {0} = @{6}
	EXEC dbo.spTreeNSM 2, 2, @{6}, @{0}, '[table_name]', {7} -- remove item from tree
	</FL><AL>
	<FL Types="R">-- DELETE FROM {5} [v]WHERE {6} = [v]@{0} [v]-- delete details from {5}<DL>
	</DL></FL></AL>

	-- Delete record
	DELETE FROM [table_name] WHERE <FL Types="P">({0} = @{0})<DL> AND </DL></FL>
END

ELSE IF @SubMode=1 -- hide record
BEGIN
	SET @EventName='HIDE_[table_name]'
	UPDATE [table_name] SET fl_deleted=GETDATE() WHERE (role_id=@role_id)
END

ELSE IF @SubMode=2 -- unhide record
BEGIN
	SET @EventName='UNHIDE_[table_name]'
	UPDATE [table_name] SET fl_deleted=NULL WHERE (role_id=@role_id)
END

ELSE IF @SubMode=3 -- clear whole table
BEGIN
	SET @EventName='CLEAR_[table_name]'
	DELETE FROM ObjAccessMethod WHERE oacc_method_obj_name='[table_name]' -- clear access rights
	DELETE FROM TreeNSM WHERE tree_table='[table_name]' -- clear Trees
	DELETE FROM [table_name] -- delete all records from table
END

ELSE IF @SubMode>9 AND @SubMode<20 -- Recursive delete with linked objects
BEGIN
	SET @EventName='DELTREE_[table_name]'
	DECLARE @child_row_id uniqueidentifier

	<FL Types="R">

	-- WARNING!!! This code may be wrong! You can change @Mode Delele(2) for Update(1) to disconnect linked element without deleting it.
	-- Cascade delete for branch {5}.{6} -> [table_name].{0}
/*
	DECLARE child_tables_rows CURSOR LOCAL FOR
		SELECT {8}
		FROM  {5}
		WHERE {6} = @{0}
	OPEN child_tables_rows
	FETCH NEXT FROM child_tables_rows INTO @child_row_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC @RETURN_RESULT = dbo.sp{5} @Mode=2, @SubMode=@SubMode, @evs_id=@child_row_id
		FETCH NEXT FROM child_tables_rows INTO @child_row_id
	END
	CLOSE child_tables_rows
	DEALLOCATE child_tables_rows
*/	
	</FL>

	-- After deleting linked object, delete main object
	SET @SubMode = @SubMode - 10
	EXEC @RETURN_RESULT = dbo.sp[table_name] @Mode=2, @SubMode=@SubMode, <FL Types="P">@{0}=@{0}<DL>, </DL></FL><IF FE="fl_updated">, @fl_updated=@fl_updated</IF>
END
ELSE
	RETURN dbo.funcGetErrorCode('ERRSUBMODE','[table_name]',0)

IF @@ERROR<>0  -- Last SQL-statement error
BEGIN
	IF @@TRANCOUNT<>0
		ROLLBACK TRAN
	RETURN dbo.funcGetErrorCode('DELETE','[table_name]',@@ERROR)
END

-- Events support
SET @SelName = @EventName + ' record "'+@SelName+'" from table "[table_name]"'
DECLARE @P1 uniqueidentifier,@P2 uniqueidentifier,@P3 uniqueidentifier
SELECT <FL Types="P">@P1=@{0}, </FL>@P2=dbo.funcBaseTables_GetID('[table_name]'), @P3=dbo.funcUser_GetID()
EXEC dbo.spEvent @EventName, @P1, @P2, @P3, @SelName


RETURN @RETURN_RESULT
GO

[include:Template_inc_SQL_grants.sql]
