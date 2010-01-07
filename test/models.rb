class Doc
  include MongoMapper::Document
  include Grip::HasAttachment
  has_grid_attachment :image, :variants => {:thumb=>{:width=>50,:height=>50},:super_thumb=>{:width=>10,:height=>10}}
end