require 'lita-gitlab'
require 'lita/rspec'

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path("#{File.dirname(__FILE__)}/fixtures/#{filename}.json")
  File.read(file_path)
end
