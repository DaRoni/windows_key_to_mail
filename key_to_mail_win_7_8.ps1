[string]$value="is empty"
function Get-WindowsKey 
{
## function to retrieve the Windows Product Key from any PC
## by Jakob Bindslet (*** Email address is removed for privacy ***)
param ($targets = “.”)
$hklm = 2147483650
$regPath = “Software\Microsoft\Windows NT\CurrentVersion”
$regValue = “DigitalProductId”
Foreach ($target in $targets)
    {
$productKey = $null
$win32os = $null
$wmi = [WMIClass]”\\$target\root\default:stdRegProv”
$data = $wmi.GetBinaryValue($hklm,$regPath,$regValue)
$binArray = ($data.uValue)[52..66]
$charsArray = “B”,”C”,”D”,”F”,”G”,”H”,”J”,”K”,”M”,”P”,”Q”,”R”,”T”,”V”,”W”,”X”,”Y”,”2”,”3”,”4”,”6”,”7”,”8”,”9”

## decrypt base24 encoded binary data
For ($i = 24; $i -ge 0; $i--) 
{
$k = 0
For ($j = 14; $j -ge 0; $j--) {
$k = $k * 256 -bxor $binArray[$j]
$binArray[$j] = [math]::truncate($k / 24)
$k = $k % 24
}
$productKey = $charsArray[$k] + $productKey
If (($i % 5 -eq 0) -and ($i -ne 0)) 
    {
$productKey = “-” + $productKey
    }
}


$win32os = Get-WmiObject Win32_OperatingSystem -computer $target
$obj = New-Object Object
$obj | Add-Member Noteproperty Computer -value $target
$obj | Add-Member Noteproperty Caption -value $win32os.Caption
$obj | Add-Member Noteproperty CSDVersion -value $win32os.CSDVersion
$obj | Add-Member Noteproperty OSArch -value $win32os.OSArchitecture
$obj | Add-Member Noteproperty BuildNumber -value $win32os.BuildNumber
$obj | Add-Member Noteproperty RegisteredTo -value $win32os.RegisteredUser
$obj | Add-Member Noteproperty ProductID -value $win32os.SerialNumber
$obj | Add-Member Noteproperty ProductKey -value $productkey
$obj
write-host ""
write-host "----------------------------------------"
write-host "Global"

$COMPUTERNAME = $env:COMPUTERNAME
$COMPUTERNAME_FQDN=[System.Net.Dns]::GetHostByName($env:computerName).HostName

$Global:value ="
COMPUTERNAME     : $COMPUTERNAME
COMPUTERNAME_FQDN: $COMPUTERNAME_FQDN
ProductName      : "+$win32os.Caption+"
CSDVersion       : "+$win32os.CSDVersion+"
ProductID        : "+$win32os.SerialNumber+"
Installed Key    : $productkey
"


$Global:value
}}
write-host ""
write-host "----------------------------------------"
write-host ""
Get-WindowsKey
sleep 1
$Username = "SarmurzanovDA";
$Password = "fmkk9RFUJK";

function Send-ToEmail([string]$email)

{
    $message = new-object Net.Mail.MailMessage;
    $message.From = "SarmurzanovDA@ulba.kz";
    $message.To.Add($email);
    $COMPUTERNAME_FQDN=[System.Net.Dns]::GetHostByName($env:computerName).HostName
    $message.Subject = "Windows Key from "+ $COMPUTERNAME_FQDN;
    $message.Body = "$Global:value";   

    $smtp = new-object Net.Mail.SmtpClient("mail.ulba.kz", "25");
    $smtp.EnableSSL = $false;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
    $smtp.send($message);
    write-host "email"
    write-host $Global:value.ToString()
    write-host "Mail Sent to "+ $message.To;     
    sleep 1
    $message.Dispose();
 }
write-host ""
write-host "----------------------------------------"
write-host ""


$ex=read-host 
if ($ex -eq "1" -or $ex -eq "2" ) {
    write-host "Выполняю функцию:"
}
elseif ([string]::IsNullOrEmpty($ex)) { 
	write-host "Вы указали неверный параметр." 
	break;
}
switch ($ex){
 
	"1"{Send-ToEmail  -email "xxxxx@xxxx.kz";}
 
	"2"{Send-ToEmail  -email "xxxxx@xxxx.kz";}				
	
   Default
      {
         Send-ToEmail  -email "xxxxx@xxxx.kz";
         write-host "Решено за вас, отправляем по адресу xxxxx@xxxx.kz"
      }
}