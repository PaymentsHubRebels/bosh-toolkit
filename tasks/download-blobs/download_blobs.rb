require 'yaml'

blobs_config = YAML.load_file(ARGV[0])

def delete_unused_cached_blobs
  cachedBlobs= Dir.glob('./**/*').select{ |e| File.file? e }.map{ |f| f.reverse.chomp("./".reverse).reverse }
  requiredBLobs =[]
  blobs_config.each { |item| requiredBLobs << item.fetch("bosh_blob_path") }
  unusedBlobs = cachedBlobs.difference(requiredBLobs)
  unusedBlobs.each { |file | File.delete(file) if File.exist?(file) }
end

delete_unused_cached_blobs

blobs_config.each do |blob_info|
  `curl --create-dirs --location -o "#{blob_info.fetch('bosh_blob_path')}" "#{blob_info.fetch('url')}"` unless File.exist?("#{blob_info.fetch('bosh_blob_path')}")
end