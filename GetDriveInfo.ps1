# Get Drive Info
$Volumes = Get-WmiObject  Win32_Volume | Where-Object {$_.DriveType -eq "3" -and $_.Label -ne "System Reserved"}
$Partitions = Get-Partition
$ht_LogicalDisk = Get-WmiObject -Class win32_logicalDisk | Sort-Object DeviceId | Group-Object -AsHashTable -Property DeviceId
$ht_DiskDrive = Get-WmiObject -Class Win32_DiskDrive | Sort-Object DeviceId | Group-Object -AsHashTable -Property DeviceId

ForEach ($Volume in $Volumes)
{

    # pre-calc
    # Volume Info
    $caption = $Volume.Caption
    $driveLetter = $Volume.DriveLetter
    $disk = $Partitions | Where-Object {$_.AccessPaths -eq $caption}
    $diskNumber = ($disk | Where-Object {$_.DiskNumber -ne $null}).DiskNumber

    $volumeName = 'unknown'
    $volumeSerialNumber = 'unknown'
    if ($null -ne $driveLetter)
    {
        $volumeName = $ht_LogicalDisk[$driveLetter].VolumeName
        $volumeSerialNumber = $ht_LogicalDisk[$driveLetter].VolumeSerialNumber
    }

    # DiskDrive Info
    $diskDrive = $ht_DiskDrive[('\\.\PHYSICALDRIVE{0}' -f $diskNumber)]

    [pscustomobject]@{
        'HostName' = $Volume.PSComputerName
        'DriveLetter' = $driveLetter
        'Caption'  = $caption
        'Label'    = $Volume.Label
        'VolumeName' = $volumeName
        'VolumeSerialNumber' = $volumeSerialNumber

        'DiskNumber' = $diskNumber

        #### 'Capacity (MB)' = [math]::Round($Volume.Capacity / 1mb, 2)
        #### 'FreeSpace (MB)' = [math]::Round($Volume.FreeSpace / 1mb, 2)

        'Capacity (GB)' = [math]::Round($Volume.Capacity / 1gb, 2)
        'FreeSpace (GB)' = [math]::Round($Volume.FreeSpace / 1gb, 2)

        'SCSI (Bus/Target/LUN/Port)' = '{0}:{1}:{2}:{3}' -f $diskDrive.SCSIBus, $diskDrive.SCSITargetId, $diskDrive.SCSILogicalUnit, $diskDrive.SCSIPort

        'InterfaceType' = $diskDrive.InterfaceType
        #### 'PNPDeviceID' = $diskDrive.PNPDeviceID

        'DiskSerialNumber' = $diskDrive.SerialNumber

        'Model' = $diskDrive.Model

        'FileSystem' = $Volume.FileSystem
        'BlockSize' = $Volume.BlockSize

        'isBootVolume' = $Volume.BootVolume
        'isPageFilePresent' = $Volume.PageFilePresent
        'isIndexingEnabled' = $Volume.IndexingEnabled
        'isAutoMount' = $Volume.AutoMount
        'isCompressed' = $Volume.Compressed
        'isSystemVolume' = $Volume.SystemVolume

        'isSupportsDiskQuotas' = $Volume.SupportsDiskQuotas
        'isQuotasEnabled' = $volume.QuotasEnabled
        'isQuotasIncomplete' = $volume.QuotasIncomplete
        'isQuotasRebuilding' = $volume.QuotasRebuilding
    }

}
