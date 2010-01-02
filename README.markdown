grip
====

GridFS attachments for MongoMapper.

Installation
------------

The grip gem is hosted on gemcutter.org and uses Miso (http://github.com/Fingertips/Miso) for image resizing

    gem install miso grip

Setup (Rails)
-------------

    # config/environment.rb

    config.gem 'grip'

Then:

    rake gems:install





Usage (See tests for better docs)
---------------------------------

Create a MongoMapper model and `include MongoMapper::Grip::HasAttachment` and call `has_grid_attachment :<attachment_name>` to the model. Then if your attachment is an image, you can specify a hash of variants along with their :width & :height.


    class Doc
      include MongoMapper::Document
      include MongoMapper::Grip::HasAttachment
      has_grid_attachment :image, :variants => {:thumb => {:width=>50,:height=>50}}
    end
    
To save a file to your model, just send any file to the symbol that you specified.

    image = File.open('foo.png', 'r')
    @doc = Doc.create(:image => image)
    
Alternately just set it on the model and save:

    @doc.image = image
    
Each attachment as well as variants respond to the following methods:

    puts @doc.image.name 
    => "image"
    
    puts @doc.image.file_size
    => 100
    
    puts @doc.image.file_name
    => "foo.png"
    
    puts @doc.image.grid_key
    => "docs/<id>/image"    
    
    @doc.image.file # contents read from gridfs for serving from rack/metal/controller 
    
Variants are created `after_save` and can be referenced through the attachment they belong to:

    @doc.image.thumb.name
    @doc.image.thumb.file_name
    @doc.image.thumb.grid_key
    @doc.image.thumb.content_type

