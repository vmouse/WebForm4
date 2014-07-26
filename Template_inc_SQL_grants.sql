<AL>exec dbo.spEventType [V]1, 0, [V]'INSERT_[table_name]', [V]'Insert into table [table_name]', [V]0
exec dbo.spEventType [V]1, 0, [V]'UPDATE_[table_name]', [V]'Update in table [table_name]', [V]0
exec dbo.spEventType [V]1, 0, [V]'DELETE_[table_name]', [V]'Delete from table [table_name]', [V]0
exec dbo.spEventType [V]1, 0, [V]'HIDE_[table_name]', [V]'Hide in table [table_name]', [V]0
exec dbo.spEventType [V]1, 0, [V]'UNHIDE_[table_name]', [V]'Unhide in table [table_name]', [V]0
exec dbo.spEventType [V]1, 0, [V]'CLEAR_[table_name]', [V]'Clear table [table_name]', [V]0
exec dbo.spEventType [V]1, 0, [V]'DELTREE_[table_name]', [V]'Cascade delete in table [table_name]', [V]0
exec dbo.spBaseTables [V]1, 1, [V]DEFAULT, DEFAULT, '[table_name]', '[table_name]', 'sp[table_name]', 'SelectName', DEFAULT, DEFAULT, '[table_name]'
</AL>
declare @tmp uniqueidentifier
set @tmp =(SELECT role_id FROM Roles WHERE role_name='_MegaCreater')
exec dbo.spObjAccessMethod 1, 0, default, @tmp, '[table_name]', NULL, 0,1,0,0,0,40
exec dbo.spObjAccessMethod 1, 0, default, @tmp, '[table_name]', NULL, 1,1,1,1,1,40
set @tmp =(SELECT role_id FROM Roles WHERE role_name='_Auditor')
exec dbo.spObjAccessMethod 1, 0, default, @tmp, '[table_name]', NULL, 41,0,0,0,0,0
GO
