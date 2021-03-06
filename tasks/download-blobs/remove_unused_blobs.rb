require 'set'
require 'yaml'

def all_blobs_config_dir
  ARGV[0]
end

def all_blobs_yml
  Dir.glob("#{all_blobs_config_dir}/**/blobs.yml")
end

def merged_blobs_config
  all_blobs_yml.map{ |path| YAML.load_file(path)}.flatten
end

def all_possible_blobs
  merged_blobs_config.map{|blob| blob.fetch('bosh_blob_path')}.to_set
end

def all_existing_blobs
  Dir.glob('**/*').select { |f| File.file? f }
end

all_existing_blobs.each do |blob_path|
  File.delete(blob_path) unless all_possible_blobs.include? blob_path
end
