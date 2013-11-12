require 'rspec/core/rake_task'
require 'pry'

lib = File.expand_path '.'
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'goldfish'


desc 'launch a console in the project\'s environment'
task(:console) do
  pry
end

