require "yaml"

YAML.load_file(ENV["release_name"]+".yml")["releases"].each do |rel| 
  if "#{rel["name"]}" == ENV["release_name"]
    rel["version"]=ENV["target_version"] 
  end
puts "#{rel["name"]}/#{rel["version"]}"
end