$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'grip'
require 'growler'
%w{test/unit shoulda factory_girl mongo_mapper factories}.each { |lib| require lib }


TEST_DB = 'test-grip'

MongoMapper.database = TEST_DB

class Test::Unit::TestCase
  def teardown
    MongoMapper.database.collections.each do |coll|
      coll.remove  
    end
  end

  # Make sure that each test case has a teardown
  # method to clear the db after each test.
  def inherited(base)
    base.define_method teardown do 
      super
    end
  end
end