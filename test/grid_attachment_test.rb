require "test_helper"
require File.expand_path(File.dirname(__FILE__) + '/../lib/grid_attachment')


class Foo
  include MongoMapper::Document
  include GridAttachment
  key :image_path, String
  key :pdf_path, String
  has_grid_attachment :image
  has_grid_attachment :pdf
end


class TestContent< Test::Unit::TestCase
  
  context "A MongoMapper Document" do
    
    context "with an attachment" do
      setup do
        
        @image = File.open("#{File.dirname(__FILE__)}/cthulhu.png",'r')
        @pdf   = File.open("#{File.dirname(__FILE__)}/sample.pdf",'r')

        @document = Foo.create(:image=>@image,:pdf=>@pdf)
        @document.image = @image
        @document.save
        
        @from_collection = Foo.first
      end

      should "have correct mime type" do
       
        assert_equal("image/png", @from_collection.image.content_type)
        assert_equal("application/pdf", @from_collection.pdf.content_type)
      end

      should "have the correct paths" do
        assert_equal("foo/#{@document.id}/image/cthulhu.png", @document.image_path)
        assert_equal("foo/#{@document.id}/pdf/sample.pdf", @document.pdf_path)
      end

      should "cleanup attachments" do
        img_path = "foo/#{@document._id}/image/cthulhu.png", @document.image_path
        pdf_path = "foo/#{@document._id}/pdf/sample.pdf", @document.pdf_path
  
        @document.destroy
  
        assert !GridStore.exist?(MONGO_DB,img_path)
        assert !GridStore.exist?(MONGO_DB,pdf_path)
      end
      
    end
  end
end