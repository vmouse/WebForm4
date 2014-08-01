$srv = New-WebServiceProxy -uri "http://support/_srv/wsEmployee.asmx?wsdl" -UseDefaultCredential

$srv.ListNames(0,0) | foreach {
	$emp = $srv.Get($_.emp_id)
	if ($emp.emp_photo.Count -gt 0) {
		[IO.File]::WriteAllBytes(("c:\temp\Photos\{0}.jpg" -f ($emp.SelectName -replace "\s+","_")), $emp.emp_photo)
	}
}
