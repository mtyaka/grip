# Usage
# define MONGO_DB = MongoMapper.database
#
# class Foo
#   include MongoMapper::Document
#   include GridAttachment
#   key :image_path, String
#   key :pdf_path, String
#   has_grid_attachment :image
#   has_grid_attachment :pdf
# end
include Mongo
include GridFS
module GridAttachment
  
  module InstanceMethods
    
    # Save Path: <classname>/<id>/<method_name>/<file_basename>
    def file_save_path name,file_name
      [self.class.to_s.underscore,self.id,name,file_name].join("/")
    end
    
    def save_attachments
      self.class.attachment_definitions.each do |attachment|
        name, file = attachment
        if file.is_a? File
          path = file_save_path(name,file.path.split("/").last)
          
          GridStore.open(MONGO_DB, path, 'w') do |f|
            f.content_type = MIME::Types.type_for(file.path).first.content_type
            f.puts file.read
          end
          
          self.send("#{name}_path=",path)
          save_to_collection
        end
      end
    end
    
    def destroy_attached_files
      self.class.attachment_definitions.each do |name, attachment|
        GridStore.unlink(MONGO_DB, send("#{name}_path"))
      end
    end
    
    def file_from_grid name
      GridStore.open(MONGO_DB, send("#{name}_path"), 'r') {|f| f }
    end

  end
  module ClassMethods
    
    def has_grid_attachment name
      raise GridAttachmentNamingError, "#{self.to_s} does not respond to #{name}_path!" unless self.column_names.include? "#{name}_path"
      include InstanceMethods
      
      # thanks to thoughtbot's paperclip!
      write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
      attachment_definitions[name] = {}
      
      after_save :save_attachments
      before_destroy :destroy_attached_files
      
      define_method name do
        file_from_grid name
      end

      define_method "#{name}=" do |file|
        self.class.attachment_definitions[name] = file
      end
    end
    
    def attachment_definitions
      read_inheritable_attribute(:attachment_definitions)
    end
    
    class GridAttachmentNamingError < StandardError #:nodoc: 
    end
  end
  
  def self.included(base)
    base.extend GridAttachment::ClassMethods
  end
end
