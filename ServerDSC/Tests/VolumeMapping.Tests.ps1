param(
    [ValidateNotNullOrEmpty()]
	[string]$IPAddress,
    [ValidateNotNullOrEmpty()]
	[string]$OctopusUsername,
    [ValidateNotNullOrEmpty()]
	[string]$OctopusPassword,
	[ValidateNotNullOrEmpty()]
	[string]$OctopusVersion
)
$OctopusURI="http://$($IPAddress):81"

 
Describe 'Volume Mounts' {

	$endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURI
	$repository = new-object Octopus.Client.OctopusRepository $endpoint
		
	$LoginObj = New-Object Octopus.Client.Model.LoginCommand 
	$LoginObj.Username = $OctopusUsername
	$LoginObj.Password = $OctopusPassword
	$repository.Users.SignIn($LoginObj)
	
	Context 'C:\Packages' {
		it 'should have provided a package for the Server' {
			$packages = $repository.BuiltInPackageRepository.ListPackages("Serilog.Sinks.TextWriter")
			$packages.TotalResults | should be 1
			$packages.Items[0].Version | should be "2.1.0"
		}
	}
	
	Context 'C:\TaskLogs' {
		it 'should contain logs of tasks' {
			$description = "Health check started for Docker Testing";
			$Task = $repository.Tasks.ExecuteHealthCheck($description)
			$repository.Tasks.WaitForCompletion($Task);

			$files=(Get-ChildItem "../tests/TaskLogs/$($task.Id.ToLower())_*" -Recurse)
			$files[0].FullName | Should Contain $description
			
		}
	}

}