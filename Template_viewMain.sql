/* 
[webform_version]
*/ 
[param:sp_create_mode] VIEW dbo.view[table_name]
AS
SELECT	<FL Types="AH">{0}<DL>,
	</DL></FL>,
	CASE WHEN <FL Types="P">{0} IS NULL<DL> AND </DL></FL> THEN 'Access denied!' ELSE
		<FL Types="S" Like="*name">{0}<DL> + </DL></FL><IF FE="fl_deleted"> + 
		CASE WHEN fl_deleted IS NOT NULL THEN ' (X)' ELSE '' END</IF> 
	END AS SelectName,
	<FL Types="S" Like="*name">{0}<DL> + </DL></FL> AS SelectShortName,
	oaccSecureFlags.fl_read_access   % 2 as fl_read_access,
	oaccSecureFlags.fl_write_access  % 2 as fl_write_access,
	oaccSecureFlags.fl_sign_access   % 2 as fl_sign_access,
	oaccSecureFlags.fl_manage_access % 2 as fl_manage_access,
	oaccSecureFlags.fl_admin_access  % 2 as fl_admin_access
FROM [table_name]
INNER JOIN view[table_name]Access oaccSecureFlags ON <FL Types="P">{0}=view_{0}<DL> AND </DL></FL> AND oaccSecureFlags.fl_read_access % 2 = 1
GO

GRANT SELECT ON dbo.view[table_name] TO public
GO