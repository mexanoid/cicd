configuration OctopusServer
{
    param (
        [parameter(Mandatory)]
        [PSCredential]
        $Credential,
        [parameter(Mandatory)]
        [String]
        $WebListenPrefix
        )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName OctopusDSC 
    Import-DscResource -ModuleName SqlServerDsc
    Import-DscResource -ModuleName StorageDsc

    Import-DSCResource -Name WindowsFeature    

    Node "localhost"
    {   
        File CreateInstallMediaDir
        {
            Type = 'Directory'
            DestinationPath = 'C:\InstallMedia'
            Ensure = "Present"
        }

        Script DownloadSqlISO
        {
            TestScript = {
                Test-Path "C:\InstallMedia\en_sql_server_2017_developer_x64_dvd_11296168.iso"
            }
            SetScript = {
                $source = "https://infrastorm.blob.core.windows.net/dsc/en_sql_server_2017_developer_x64_dvd_11296168.iso"
                $dest = "C:\InstallMedia\en_sql_server_2017_developer_x64_dvd_11296168.iso"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {
                @{Result = "DownloadSqlISO"}
            }
            DependsOn = "[File]CreateInstallMediaDir"
        }        

        MountImage ISO
        {
            ImagePath   = 'C:\InstallMedia\en_sql_server_2017_developer_x64_dvd_11296168.iso'
            DriveLetter = 'S'
            DependsOn   = '[Script]DownloadSqlISO'
        }

        WaitForVolume WaitForISO
        {
            DriveLetter      = 'S'
            RetryIntervalSec = 10
            RetryCount       = 20
        }

        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }

        SqlSetup InstallDefaultInstance
        {
            Action                 = "Install"
            SourcePath             = 'S:\'
            InstanceName           = 'MSSQLSERVER'
            Features               = 'SQLENGINE'
            SQLCollation           = 'SQL_Latin1_General_CP1_CI_AS'
            PsDscRunAsCredential   = $Credential
            SQLSysAdminAccounts    = @('Administrators')
            UpdateEnabled          = 'False'
            ForceReboot            = $false
            InstallSharedDir       = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir    = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir            = 'C:\Program Files\Microsoft SQL Server'
            InstallSQLDataDir      = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLUserDBDir           = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLUserDBLogDir        = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLTempDBDir           = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLTempDBLogDir        = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLBackupDir           = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup'
            DependsOn              =  '[WindowsFeature]NetFramework45', '[WaitForVolume]WaitForISO'
        }
    }
}
