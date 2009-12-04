GridAttachment
==============

GridFS Attachment mixin for MongoMapper

**Sample Class**

    class Foo
      include MongoMapper::Document
      include GridAttachment
      
      has_grid_attachment :image
      has_grid_attachment :pdf
    end
