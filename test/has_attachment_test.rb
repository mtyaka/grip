require "test_helper"
require "models"
include MongoMapper::Grip

class HasAttachmentTest < Test::Unit::TestCase
  context "A Doc that has_grid_attachment :image" do
    setup do
      @document     = Doc.new
      @dir          = File.dirname(__FILE__) + '/fixtures'
      @image        = File.open("#{@dir}/cthulhu.png", 'r')
      @file_system  = MongoMapper.database['fs.files']
    end

    teardown do
      #@file_system.drop
      @image.close
    end

    should "have many attachments" do
      name, assoc = Doc.associations.first
      assert_equal(:attachments, assoc.name)
      assert_equal(:many, assoc.type)
    end

    should "have :after_save callback" do
      assert_equal(1, Doc.after_save.collect(&:method).count)
    end

    context "when assigned a file" do
      setup do
        @document.image = @image
        @document.save!
      end

      should "should return an Attachment" do
        assert_equal(MongoMapper::Grip::Attachment, @document.image.class)
      end

      should "read file from grid store" do
        assert_equal "image/png", @file_system.find_one(:filename => @document.image.grid_key)['contentType']
      end

      should "have :thumb variant" do
        assert @document.image.respond_to?( :thumb )
      end

      should "have 2 variants" do
        assert_equal(2, @document.image.attached_variants.count)
      end

      should "have the correct names for each variant" do
        assert_equal('thumb', @document.image.thumb.name)
        assert_equal('super_thumb', @document.image.super_thumb.name)
      end

      should "be resized" do
        assert @document.image.file_size > @document.image.thumb.file_size
        assert @document.image.file_size > @document.image.super_thumb.file_size
      end

      should "retrieve variants from grid" do
        assert_equal "image/png", @file_system.find_one(:filename => @document.image.thumb.grid_key)['contentType']
      end

    end

  end

end