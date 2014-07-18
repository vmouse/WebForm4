/* 
[webform_version]
*/ 
[param:sp_create_mode] VIEW dbo.view[table_name]Resolved
AS
<AL>
SELECT [v]t0.*, 
	[v]<FL Types="L">t{7}.SelectName [v]AS {0}_Name<DL>, -- Resolved lookup links
	[v]</DL></FL>
	[v]<FL Types="T">Tree{7}.tree_top [v]AS Tree{7}_tree_top, Tree{7}.tree_lft AS Tree{7}_tree_lft, Tree{7}.tree_rgt AS Tree{7}_tree_rgt<DL>, -- Tree support
	[v]</DL></FL></AL><AL>
FROM [v]view[table_name] t0
<FL Types="L">LEFT JOIN [v]view{5} [v]t{7} [v]ON t0.{0} [v]= t{7}.{6}<DL>
</DL></FL>
<FL Types="T">LEFT JOIN [v]TreeNSM [v]Tree{7} [v]ON Tree{7}.tree_name [v]= '[table_name]' and Tree{7}.tree_num = {7}<DL>
</DL></FL></AL>
GO

GRANT SELECT ON dbo.view[table_name]Resolved TO public
GO
