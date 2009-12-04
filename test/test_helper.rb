%w{rubygems mongomapper shoulda mongo/gridfs mime/types}.each {|f| require f}



MongoMapper.database = "test-attachments"

# For GridAttachment
MONGO_DB = MongoMapper.database


class ActiveSupport::TestCase
  # Drop all columns after each test case.
  def teardown
    MongoMapper.connection.drop_database "test-attachments"
    MongoMapper.database = "test-attachments"
  end

  # Make sure that each test case has a teardown
  # method to clear the db after each test.
  def inherited(base)
    base.define_method teardown do 
      super
    end
  end
end