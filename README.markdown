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
      include Grip::HasAttachment
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
    

###License

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

***

###Credits
c. burnett ( github.com/twoism || twoism.posterous.com )
m. mongeau ( github.com/toastyapps )



