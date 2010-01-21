require "mongo_mapper"
variants = { :thumb => {:width=>50, :height=>50} }
Factory.define :attachment do |a|
  a.owner_id Mongo::ObjectID.new
  a.owner_type  'Mock'
  a.name 'image'
  a.file_name 'mock.png'
  a.file_size 100
  a.content_type 'image/png'
  a.variants variants
end