/* 
[webform_version]
*/ 
[param:sp_create_mode] PROCEDURE dbo.sp[table_name]_retrieve
<AL>(
    [v]@SubMode [v]bigint [v]= 0,[v] -- 0 - Retrieve from PageNumber, 1 - Retrieve from <FL Types="P">{0}<DL>+</DL></FL>
<FL>[v]@{0} [v]{2} [v]= NULL OUTPUT<DL>,[v]
</DL></FL>,
[v]@PageNumber [v]int [v]= 0,
[v]@RowsPerPage [v]bigint [v]= 20 [v] -- 0 - unlimited
)</AL>
AS

IF @RowsPerPage<1 
    SET @RowsPerPage = (SELECT count(*) from [table_name])

IF @SubMode=0 -- Select list for filling lookup controls. Ranged by RowsPerPage items from @PageNumber
BEGIN<AL>
    SELECT * FROM (
        SELECT <FL Types="PV">{0}<DL>, </DL></FL>, ROW_NUMBER() OVER(ORDER BY SelectName) AS NUMBER
        FROM view[table_name]
        WHERE ((<FL Types="bvfp">[v]( <IFF FC='("{3}" -eq "String") -and ({9} -gt 1)'>{0} [v]LIKE [v]@{0}[ELSE]{0} [v]= [v]@{0}</IFF> )<DL> [v]OR 
            </DL></FL></AL><AL>
               ) OR (<FL Types="bvfp">( @{0} [v]is NULL )<DL> [v]AND 
                     </DL></FL>[v])
              )<IF FE="fl_deleted"> AND (( fl_deleted is NULL) OR (fl_admin_access = 1) OR (<FL Types="P">{0}=@{0}<DL> AND </DL></FL>))</IF>
        ) t1
    WHERE (NUMBER > @PageNumber * @RowsPerPage) AND (NUMBER <= ((@PageNumber+1) * @RowsPerPage))
    ORDER BY <FL Types="V">{0}<DL>, </DL></FL></AL>
END
/*
ELSE IF @SubMode=1 -- Filling lookup controls. Ranged by RowsPerPage items from ID
BEGIN
    DECLARE @From_row_number bigint
    SET @From_row_numbe = 0
    IF <FL Types="P">(NOT @{0} IS NULL)<DL> AND </DL></FL>
    BEGIN -- Use limit from setted ID
        SELECT @From_row_number=CurrentRowNumber 
        FROM (
            SELECT ROW_NUMBER() OVER (ORDER BY <FL Types="V">{0}<DL>, </DL></FL>, <FL Types="P">{0}<DL>, </DL></FL>) as CurrentRowNumber,
                CASE WHEN <FL Types="P">{0} = @{0}<DL> AND </DL></FL> THEN 1 ELSE 0 END Flag
            FROM view[table_name]
            <IF FE="fl_deleted">WHERE ((fl_deleted is NULL) OR (fl_admin_access = 1) OR (<FL Types="P">{0}=@{0}<DL> AND </DL></FL>))</IF>
        ) t
        WHERE (Flag = 1)

    END
    SELECT <FL Types="PV">{0}<DL>, </DL></FL> 
    FROM (
        SELECT <FL Types="PVf">{0}<DL>, </DL></FL>, ROW_NUMBER() OVER (ORDER BY <FL Types="V">{0}<DL>, </DL></FL>, <FL Types="P">{0}<DL>, </DL></FL>) as CurrentRowNumber
        FROM view[table_name]
        <IF FE="fl_deleted">WHERE ((fl_deleted is NULL) OR (fl_admin_access = 1) OR (<FL Types="P">{0}=@{0}<DL> AND </DL></FL>))</IF>
        ) t1
    WHERE (CurrentRowNumber > @From_row_number) AND ((CurrentRowNumber - @From_row_number) <= @RowsPerPage)
END 
*/
ELSE
    RETURN dbo.funcGetErrorCode('ERRSUBMODE','[table_name]',0)
GO

GRANT EXEC ON dbo.sp[table_name]_retrieve TO public
GO
