require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = 'grip'
  gem.summary = %(GridFS attachments for MongoMapper)
  gem.description = %(GridFS attachments for MongoMapper)
  gem.email = 'signalstatic@gmail.com'
  gem.homepage = 'http://github.com/twoism/grip'
  gem.authors = %w(twoism jnunemaker)

  gem.add_dependency('mongo_mapper', '>= 0.6.10')
  gem.add_dependency('miso', '>= 0.3.1')

  gem.add_development_dependency('factory_girl', '1.2.3')
  gem.add_development_dependency('shoulda', '2.10.2')
end

Jeweler::GemcutterTasks.new

Rake::TestTask.new do |test|
  test.libs << 'test'
  test.ruby_opts << '-rubygems'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test