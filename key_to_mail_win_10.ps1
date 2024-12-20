#Main function
[string]$value="is empty"
Function GetWin10Key
{
	$Hklm = 2147483650
	$Target = $env:COMPUTERNAME
	$regPath = "Software\Microsoft\Windows NT\CurrentVersion"
	$DigitalID = "DigitalProductId"
	$wmi = [WMIClass]"\\$Target\root\default:stdRegProv"
	#Get registry value 
	$Object = $wmi.GetBinaryValue($hklm,$regPath,$DigitalID)
	[Array]$DigitalIDvalue = $Object.uValue 
	#If get successed
	If($DigitalIDvalue)
	{
		#Get product name and product ID win 10		
		$ProductName = (Get-itemproperty -Path "HKLM:Software\Microsoft\Windows NT\CurrentVersion" -Name "ProductName").ProductName
		#win 11
		$OSver=[System.Environment]::OSVersion.Version.Build
		If ($OSver -gt 22000){
			$ProductName = "Windows 11 Build " + [System.Environment]::OSVersion.Version
		}		
		$ProductID =  (Get-itemproperty -Path "HKLM:Software\Microsoft\Windows NT\CurrentVersion" -Name "ProductId").ProductId
		#Convert binary value to serial number 
		$Result = ConvertTokey $DigitalIDvalue
		$OSInfo = (Get-WmiObject "Win32_OperatingSystem"  | select Caption).Caption
			if($Result)
			{	
$COMPUTERNAME = $env:COMPUTERNAME
$COMPUTERNAME_FQDN=[System.Net.Dns]::GetHostByName($env:computerName).HostName
$OEM_Key = (Get-WmiObject -query �select * from SoftwareLicensingService�).OA3xOriginalProductKey
$Global:value ="
COMPUTERNAME     : $COMPUTERNAME
COMPUTERNAME_FQDN: $COMPUTERNAME_FQDN
ProductName      : $ProductName
ProductID        : $ProductID 
Installed Key    : $Result
OEM Key          : $OEM_Key
"
$Global:value         
			}
			Else
			{
				Write-Warning "���������� ������ � Windows 10-11"
			}
				
	}
	Else
	{
		Write-Warning "�������� ������, �� ������� �������� ����"
	}
}
#Convert binary to serial number 
Function ConvertToKey($Key)
{
	$Keyoffset = 52 
	$isWin10 = [int]($Key[66]/6) -band 1
	$HF7 = 0xF7
	$Key[66] = ($Key[66] -band $HF7) -bOr (($isWin10 -band 2) * 4)
	$i = 24
	[String]$Chars = "BCDFGHJKMPQRTVWXY2346789"	
	do
	{
		$Cur = 0 
		$X = 14
		Do
		{
			$Cur = $Cur * 256    
			$Cur = $Key[$X + $Keyoffset] + $Cur
			$Key[$X + $Keyoffset] = [math]::Floor([double]($Cur/24))
			$Cur = $Cur % 24
			$X = $X - 1 
		}while($X -ge 0)
		$i = $i- 1
		$KeyOutput = $Chars.SubString($Cur,1) + $KeyOutput
		$last = $Cur
	}while($i -ge 0)
	
	$Keypart1 = $KeyOutput.SubString(1,$last)
	$Keypart2 = $KeyOutput.Substring(1,$KeyOutput.length-1)
	if($last -eq 0 )
	{
		$KeyOutput = "N" + $Keypart2
	}
	else
	{
		$KeyOutput = $Keypart2.Insert($Keypart2.IndexOf($Keypart1)+$Keypart1.length,"N")
	}
	$a = $KeyOutput.Substring(0,5)
	$b = $KeyOutput.substring(5,5)
	$c = $KeyOutput.substring(10,5)
	$d = $KeyOutput.substring(15,5)
	$e = $KeyOutput.substring(20,5)
	$keyproduct = $a + "-" + $b + "-"+ $c + "-"+ $d + "-"+ $e
	$keyproduct   
}
GetWin10Key

$Username = "Xerox";
$Password = "khFy7g3F";
function Send-ToEmail([string]$email)

{
    $message = new-object Net.Mail.MailMessage;
    $message.From = "Xerox@ulba.kz";
    $message.To.Add($email);
    $COMPUTERNAME_FQDN=[System.Net.Dns]::GetHostByName($env:computerName).HostName
    $message.Subject = "Windows Key from "+ $COMPUTERNAME_FQDN;
    $message.Body = "$Global:value";   

    $smtp = new-object Net.Mail.SmtpClient("mail.ulba.kz", "25");
    $smtp.EnableSSL = $false;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
    $smtp.send($message);
    write-host "Mail Sent to "+ $message.To;    
    sleep 1
    $message.Dispose();
 }
write-host "----------------------------------------"
write-host ""
write-host ""

$ex=read-host 
if ($ex -eq "1" -or $ex -eq "2" ) {
    write-host "�������� �������:"
}
elseif ([string]::IsNullOrEmpty($ex)) { 
	write-host "�� ������� �������� ��������." 
	break;
}
switch ($ex){ 
	"1"{Send-ToEmail  -email "xxxxx@xxxx.kz";} 	
   Default
      {
		 Send-ToEmail  -email "xxxxx@xxxx.kz";		 
         write-host "������ �� ���"
      }
}