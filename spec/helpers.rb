
module Helpers
  #Establishes a connection at the give url with faraday
  #return faradayConnection
  def getFaradayConnection (url)
    newConnection= Faraday.new(:url => url,
                               :headers => {'Host' => host_inventory['hostname']}) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
    return newConnection
  end

  #Parses .properties files
  #return key => value map
  def parsePropertiesFile (fileLocation)
    propertiesFile = {}
    if fileLocation.length < 180
      open(fileLocation).each_line do |line|
        propertiesFile[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
      end
      output = "File Name #{fileLocation} \n"
      propertiesFile.each { |key, value| output += " #{key}= #{value} \n" }
    else
      fileLocation.each_line do |line|
        propertiesFile[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
      end
      output = 'Properties file parsed! \n'
      propertiesFile.each { |key, value| output += " #{key}= #{value} \n" }
    end
    return propertiesFile
  end

end