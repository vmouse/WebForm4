/* 
[webform_version]
*/ 
[param:sp_create_mode] PROCEDURE dbo.sp[table_name]_insert
<AL>(
	[v]@SubMode [v]bigint [v]= 0,[v] -- not used 
<FL>[v]@{0} [v]{2} [v]= NULL OUTPUT<DL>,[v]
</DL></FL>
)</AL>
AS

<FL Types="P">
IF @{0} is NULL 
	SET @{0}=NEWID()
</FL>
BEGIN TRAN

INSERT INTO [table_name] (<FL>{0}<DL>, </DL></FL><IF FE="fl_created">, fl_created</IF><IF FE="fl_changed">, fl_changed</IF><IF FE="fl_author">, fl_author</IF>
	fl_created, fl_changed, fl_author)
VALUES (<FL>@{0}<DL>, </DL></FL>, <IF FE="fl_created">GETDATE()</IF><IF FE="fl_changed">, GETDATE()</IF><IF FE="fl_author">, SYSTEM_USER</IF>)

IF @@ERROR<>0  -- Last SQL-statement error
BEGIN
	IF @@TRANCOUNT<>0
		ROLLBACK TRAN
	RETURN dbo.funcGetErrorCode('INSERT','[table_name]',@@ERROR)
END

-- Return back inserted record (must be first result in recorset sequence)
EXEC dbo.sp[table_name]_select 0, <FL>@{0} OUTPUT<DL>, </DL></FL>
<FL Types="T">
-- Tree support for {0} -> {6}
EXEC dbo.spTreeNSM 0, DEFAULT, @{6}, @{0}, '[table_name]', {7}
</FL>

-- Events support
DECLARE @P1 uniqueidentifier,@P2 uniqueidentifier,@P3 uniqueidentifier
SELECT <FL Types="P">@P1=@{0}, </FL>@P2=dbo.funcBaseTables_GetID('[table_name]'), @P3=dbo.funcUser_GetID()
EXEC dbo.spEvent 'INSERT_[table_name]', @P1, @P2, @P3, 'Insert new record into table [table_name]'

COMMIT TRAN

RETURN 0

GO

[include:Template_inc_SQL_grants.txt]