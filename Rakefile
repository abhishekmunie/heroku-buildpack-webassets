#!/usr/bin/env rake

desc 'test'
task :test do |t|
  system('heroku build $(cd $(dirname $0); cd test; pwd) -b $(cd $(dirname $0); pwd)')
end

task :default => :test