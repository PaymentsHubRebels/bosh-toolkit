require 'yaml'

blobs_config = YAML.load_file(ARGV[0])

blobs_config.each do |blob_info|
  `curl --create-dirs --location -o "#{blob_info.fetch('bosh_blob_path')}" "#{blob_info.fetch('url')}"` unless File.exist?("#{blob_info.fetch('bosh_blob_path')}")
end