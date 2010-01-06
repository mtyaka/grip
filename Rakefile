require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
 
begin
  require 'jeweler'
  Jeweler::Tasks.new do |g|
    g.name = 'grip'
    g.summary = %(GridFS attachments for MongoMapper)
    g.description = %(GridFS attachments for MongoMapper)
    g.email = 'signalstatic@gmail.com'
    g.homepage = 'http://github.com/twoism/grip'
    g.authors = %w(twoism jnunemaker)
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install jeweler'
end
 
Rake::TestTask.new do |t|
  t.libs = %w(test)
  t.pattern = 'test/**/*_test.rb'
end
 
task :default => :test