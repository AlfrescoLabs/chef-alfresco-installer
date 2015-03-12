default["localPath"] = false

case node['platform_family']
when 'windows'
  default['java_8_download_path'] = "qa/QA_Applications/jdk-8u40-windows-x64.exe"
  default["java_installer"]["local"] = "c:/jdk-8u40-windows-x64.exe"
  default["java_installer"]["java_home"] = "C:\\java\\jdk\\"
  default["java_installer"]["checksum"] = '71f28563968a5acdf5cbca19154a60f4bff3b400f30b87c0272ba770d4008dbd'
when 'solaris'
  default['java_8_download_path'] = "qa/QA_Applications/jdk-8u40-solaris-x64.tar.gz"
  default["java_installer"]["local"] = "resources/jdk-8u40-solaris-x64.tar.gz"
  default["java_installer"]["checksum"] = '8d880e24a12197b8349493f15092a6b19468f8dfe22466325961bbfc2020d7f4'
else
  default['java_8_download_path'] = "qa/QA_Applications/jdk-8u31-linux-x64.tar.gz"
  default["java_installer"]["local"] = "resources/jdk-8u31-linux-x64.tar.gz"
  default["java_installer"]["checksum"] = 'efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437'
end