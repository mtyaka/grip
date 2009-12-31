class Doc
  include MongoMapper::Document
  include MongoMapper::Grip::HasAttachment
  has_grid_attachment :image, :variants => {:thumb=>{:width=>50,:height=>50},:super_thumb=>{:width=>10,:height=>10}}
  has_grid_attachment :other_image, :variants => {:thumb=>{:width=>75,:height=>75}}
end