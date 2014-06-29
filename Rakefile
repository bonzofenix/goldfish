require 'rspec/core/rake_task'
require 'pry'

lib = File.expand_path './lib'
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'goldfish'


desc 'launch a console in the project\'s environment'
task(:console) do
  pry
end

desc 'Deploys to CF'
task(:deploy) do
  `cf file bonzofenix app/db/production.db > db/production.db`
  `cf push`
end
