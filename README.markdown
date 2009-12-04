GridAttachment
==============

GridFS Attachment mixin for MongoMapper

**Usage**

  MONGO_DB = MongoMapper.database

  class Foo
    include MongoMapper::Document
    include GridAttachment
    key :image_path, String
    key :pdf_path, String
    has_grid_attachment :image
    has_grid_attachment :pdf
  end
