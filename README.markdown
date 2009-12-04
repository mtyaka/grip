GridAttachment
==============

GridFS Attachment mixin for MongoMapper

**Usage**

    #define this somewhere
    MONGO_DB = MongoMapper.database


    class Foo
      include MongoMapper::Document
      include GridAttachment
      
      has_grid_attachment :image
      has_grid_attachment :pdf
    end
