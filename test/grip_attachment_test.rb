require "test_helper"

include Grip

class GripAttachmentTest < Test::Unit::TestCase
  context "An Attachment" do
    setup do
      @attachment   = Attachment.new( :name => "image", :owner_type => "Mock", :owner_id => Mongo::ObjectID.new )
      @dir          = File.dirname(__FILE__) + '/fixtures'
      @image        = File.open("#{@dir}/cthulhu.png", 'r')
      @file_system  = MongoMapper.database['fs.files']
    end
    
    teardown do
      @file_system.drop
      @image.close
    end

    should "be an Attachment" do
      assert @attachment.is_a?(Attachment)
    end
    
    should "belong to :owner" do
      name,assoc = Attachment.associations.first
      #assert_equal(:owner, assoc.name)
      #assert_equal(:belongs_to, assoc.type)
    end
    
    context "with a valid file" do
      setup do
        @attachment.file = @image
      end

      should "have correct :content_type" do
        assert_equal("image/png", @attachment.content_type)
      end
      
      should "have correct :file_size" do
        assert_equal(27582, @attachment.file_size)
      end
      
      should "have correct :file_name" do
        assert_equal("cthulhu.png", @attachment.file_name)
      end
      
      should "read file from grid store" do
        assert_equal "image/png", @file_system.find_one(:filename => @attachment.grid_key)['contentType']
      end
      
      should "return a GridStore" do
        assert_equal(GridFS::GridStore, @attachment.file.class)
      end
      
    end
    
    context "with an invalid file" do
      should "raise Grip::InvalidFile" do
        assert_raise(InvalidFile) { @attachment.file = Hash.new }
      end
    end

  end
    
end