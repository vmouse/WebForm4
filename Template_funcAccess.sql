/* 
[webform_version]
*/ 
[param:sp_create_mode] VIEW dbo.func[table_name]Access
(
	@AccessType		int	=	1  -- 1 = Read only, 2 = Insert (write only) , 3 - Update (read + write), 4 - Delete
)
RETURNS @[table_name]Access TABLE (
	<FL Types="P">{0}  AS view_{0}<DL>, </DL></FL> uniqueidentifier,
	fl_read_access int,
	fl_write_access int,
	fl_sign_access int,
	fl_manage_access int,
	fl_admin_access int
)
AS

IF @AccessType=4
	SET @AccessType=3 -- Temporary DeleteAccess = UpdateAccess

DECLARE @userid uniqueidentifier
DECLARE @guestid uniqueidentifier
SET @userid = dbo.funcUser_GetID()
SET @guestid = dbo.funcUser_GetGuestID()

INSERT @@[table_name]Access
SELECT <FL Types="P">{0}  AS view_{0}<DL>, </DL></FL>,
	MAX(oacc_method_reader_fl) % 2 as fl_read_access,
	MAX(oacc_method_writer_fl) % 2 as fl_write_access,
	MAX(oacc_method_signer_fl) % 2 as fl_sign_access,
	MAX(oacc_method_manager_fl) % 2 as fl_manage_access,
	MAX(oacc_method_admin_fl) % 2 as fl_admin_access
FROM (
SELECT <FL Types="P">t0.{0} AS view_{0}),
	</FL> -- whole table access
	t1.oacc_method_reader_fl,
	t1.oacc_method_writer_fl,
	t1.oacc_method_signer_fl,
	t1.oacc_method_manager_fl,
	t1.oacc_method_admin_fl
FROM  Roles t0
INNER JOIN dbo.ObjAccessMethod t1 ON
	<FL Types="P">(t0.{0} = t1.oacc_method_obj_id OR t1.oacc_method_obj_id is NULL)<DL> AND 
	</DL></FL>
	(t1.oacc_method_obj_name='[table_name]')
INNER JOIN RoleMapEmployee t2 ON t1.oacc_method_role_id = t2.rme_role_id AND
           (t2.rme_emp_id=@userid OR t2.rme_emp_id=@guestid)
UNION ALL
/* Check whole table access rights (for insert access)*/
SELECT t1.oacc_method_obj_id,
	t1.oacc_method_reader_fl,
	t1.oacc_method_writer_fl,
	t1.oacc_method_signer_fl,
	t1.oacc_method_manager_fl,
	t1.oacc_method_admin_fl
FROM ObjAccessMethod t1
INNER JOIN RoleMapEmployee t2 ON t1.oacc_method_role_id = t2.rme_role_id AND
           (t2.rme_emp_id=@userid OR t2.rme_emp_id=@guestid)
WHERE t1.oacc_method_obj_id is NULL AND t1.oacc_method_obj_name='[table_name]'
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
) AS MegaAccessSet
WHERE  (@AccessType = 1 AND (oacc_method_reader_fl <> 0)) OR  -- Check Read access
       (@AccessType = 2 AND (oacc_method_writer_fl <> 0 and oacc_method_reader_fl % 2 = 0)) OR  -- Check WriteOnly (Insert)
       (@AccessType = 3 AND (oacc_method_writer_fl % 2 = 1 and oacc_method_reader_fl % 2 = 1))   -- Check Read+Write (Update)
GROUP BY view_role_id
HAVING (@AccessType = 1 and MAX(oacc_method_reader_fl) % 2 = 1) OR  -- Check Readonly access
       (@AccessType = 2 and MAX(oacc_method_writer_fl) % 2 = 1) OR -- Check Writeonly access
       (@AccessType = 3 and MAX(oacc_method_writer_fl) % 2 = 1 and MAX(oacc_method_reader_fl) % 2 = 1)  -- Check Read+Write (Update)
RETURN
END

GO