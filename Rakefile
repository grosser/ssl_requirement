require "bundler"
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.libs << 'lib'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default do
 sh "RAILS='~>2' bundle && bundle exec rake test"
 sh "RAILS='~>3' bundle && bundle exec rake test"
end
