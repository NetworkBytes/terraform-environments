
param(
  [Parameter(Mandatory=$true)]
  [string]$puppetmaster="puppet",

  [Parameter(Mandatory=$true)]
  [string]$puppetclient
)

# Create new signed puppet cert 
# John Bencic

# Remember to add cert to ca.conf whitelist in the puppet server
# Requires openssl in the path

# API docs here: https://docs.puppetlabs.com/puppet/latest/reference/http_api/http_certificate_status.html

#$puppetmaster = "dev-puppet2-1"
$basedir      = "d:\Provisioning\Terraform\terraform-environments"

$cacert    = "$basedir\files\puppet\$puppetmaster\ssl\certs\ca.pem"
$admincert = "$basedir\files\puppet\$puppetmaster\ssl\certs\terraform.pem"
$adminkey  = "$basedir\files\puppet\$puppetmaster\ssl\private_keys\terraform.pem"

$curl = "${basedir}\files\curl.exe"

#$curlbase = '"{0}" {1}' -f $curl, " --key ${adminkey} --cert ${admincert} --cacert ${cacert} -k -s -S "
$curlbase = " --key ${adminkey} --cert ${admincert} --cacert ${cacert} -k -s -S "

$CertStatusUrl  = "https://${puppetmaster}:8140/puppet-ca/v1/certificate_status/${puppetclient}"
$CertRequestUrl = "https://${puppetmaster}:8140/puppet-ca/v1/certificate_request/${puppetclient}"
$CertUrl        = "https://${puppetmaster}:8140/puppet-ca/v1/certificate/${puppetclient}"
$openSSL        = ".\files\openssl.exe"


$TempDir  = "${basedir}\Temp\${puppetclient}\ssl"
$cert_csr = "${TempDir}\certs\${puppetclient}.csr"
$cert_pub = "${TempDir}\certs\${puppetclient}.pem"
$cert_key = "${TempDir}\private_keys\${puppetclient}.pem"

# create directory and copy the cacert to the new directory
New-Item "$TempDir\certs"        -ItemType Directory -Force
New-Item "$TempDir\private_keys" -ItemType Directory -Force
Copy-Item $cacert -Destination "$TempDir\Certs\"


echo "# Checking if old cert exists"
$cmd = '"{0}" {1}' -f $curl, "$curlbase -X GET -H `"Accept: pson`" $CertStatusUrl 2>&1"
$Return = Invoke-Expression -Command "&$cmd"
if ($LASTEXITCODE -ne 0) { 
  echo "curl returned error: ${LASTEXITCODE} `r`ncontents: $Return "
  exit (1)
}

$json = ""

try { 
  # really need a TryParse here
  $json = $Return| ConvertFrom-Json 
} catch {}

if ($json -ne "") {
  if ($json.Name -eq "$puppetclient") {
    echo "  . Found cert on puppet master, deleting ..."
    $cmd = '"{0}" {1}' -f $curl, "$curlbase -X DELETE -H `"Accept: pson`" $CertStatusUrl 2>&1"
    Invoke-Expression -Command "&$cmd"
  }
} else {
  echo $Return
}





echo "# Generating Certificate Signing Request CSR"
$Return = Invoke-Expression -Command "&$openSSL req -new -newkey rsa:2048 -nodes -out ${cert_csr} -keyout ${cert_key} -subj `"/C=AU/ST=NSW/L=Sydney/O=Company A/OU=DepartmentA/CN=${puppetclient}`" -config $basedir\files\openssl.cnf 2>&1"
if ($LASTEXITCODE -ne 0) { 
  echo "openssl returned error: ${LASTEXITCODE} `r`ncontents: $Return "
  exit (2)
}


echo "# Uploading CSR to Puppet Server"
$cmd = '"{0}" {1}' -f $curl, "$curlbase -X PUT -H `"Content-Type: text/plain`" --data-binary `"@${cert_csr}`" $CertRequestUrl 2>&1"
$Return = Invoke-Expression -Command "&$cmd"
if ($LASTEXITCODE -ne 0) { 
  echo "curl returned error: ${LASTEXITCODE} `r`ncontents: $Return "
  exit (3)
}



echo "# Sign CSR on Puppet Server"
#
$data = "$basedir\scripts\desired_state-signed"
$cmd = '"{0}" {1}' -f $curl, "$curlbase -X PUT -H `'Content-Type: application/json`' --data-binary `'@${data}`' $CertStatusUrl 2>&1"
$Return = Invoke-Expression -Command "&$cmd"
if ($LASTEXITCODE -ne 0) { 
  echo "curl returned error: ${LASTEXITCODE} `r`ncontents: $Return "
  exit (4)
} else {
  echo $Return
}


# TODO: convert to functions
echo "# Verify cert is signed"
$cmd = '"{0}" {1}' -f $curl, "$curlbase -X GET -H `"Accept: pson`" $CertStatusUrl 2>&1"
$Return = Invoke-Expression -Command "&$cmd"
if ($LASTEXITCODE -ne 0) { 
  echo "curl returned error: ${LASTEXITCODE} `r`ncontents: $Return "
  exit (5)
}

$json = ""

try { 
  # really need a TryParse here
  $json = $Return| ConvertFrom-Json 
} catch {}

if ($json -ne "") {
  if (($json.name -eq "$puppetclient") -and ($json.state -eq "signed"))   {
    echo "  . Found signed cert on puppet master"
  }
} else {
  echo "Error signing cert"
  echo $Return
  exit (6)
}


echo "# Retrieving node public key from puppet server"
$cmd = '"{0}" {1}' -f $curl, "$curlbase -X GET -H `"Accept: pson`" $CertUrl > `"${cert_pub}`""
$Return = Invoke-Expression -Command "&$cmd"
if ($LASTEXITCODE -ne 0) { 
  echo "curl returned error: ${LASTEXITCODE} `r`ncontents: $Return "
  exit (7)
} else {
  #TODO verify cert
  exit (0)
}
