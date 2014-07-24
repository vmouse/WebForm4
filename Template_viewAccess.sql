/* 
[webform_version]
*/ 
[param:sp_create_mode] VIEW dbo.view[table_name]Access --WITH SCHEMABINDING
AS
SELECT <FL Types="P">{0}  AS view_{0}<DL>, </DL></FL>,
	max(fl_read_access)   AS fl_read_access,
	max(fl_write_access)  AS fl_write_access,
	max(fl_sign_access)   AS fl_sign_access,
	max(fl_manage_access) AS fl_manage_access,
	max(fl_admin_access)  AS fl_admin_access
from (
SELECT <FL Types="P">{0},
	</FL> -- whole table access
	fl_read_access,
	fl_write_access,
	fl_sign_access,
	fl_manage_access,
	fl_admin_access
FROM	dbo.viewObjAccessMethodUserAccess, dbo.[table_name]
WHERE 	oacc_method_obj_name='[table_name]' and oacc_method_obj_id is NULL
UNION ALL
SELECT -- row level access
	oacc_method_obj_id,
	fl_read_access,
	fl_write_access,
	fl_sign_access,
	fl_manage_access,
	fl_admin_access
FROM	dbo.viewObjAccessMethodUserAccess
WHERE	oacc_method_obj_name='[table_name]' and oacc_method_obj_id is not NULL
<FL Types="L">
/* UNION ALL -- inherited access from {5} (all parents tree)
SELECT
	<FL Types="P">t0.{0},</FL>
	fl_read_access,
	fl_write_access,
	fl_sign_access,
	fl_manage_access,
	fl_admin_access
FROM [table_name] t0
INNER JOIN view{5}Access t1 ON t1.view_{6} = t0.{0}
*/
/* UNION ALL -- inherited access from {5} (from first (direct) parent only)
SELECT
	<FL Types="P">t0.{0},</FL>
	fl_read_access,
	fl_write_access,
	fl_sign_access,
	fl_manage_access,
	fl_admin_access
FROM dbo.viewObjAccessMethodUserAccess
INNER JOIN [table_name] t1 ON t1.{0} = oacc_method_obj_id
WHERE oacc_method_obj_name='{5}'
*/
</FL>
) tt
group by <FL Types="P">{0}<DL>, </DL></FL>
--HAVING max(fl_read_access) % 2 = 1 -- moved to main view and resolved view

GO