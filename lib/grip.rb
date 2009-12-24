require 'mongo/gridfs'
require 'mime/types'
require 'tempfile'

# if thumbnailable?
#   tmp = Tempfile.new("thumb_#{filename}")
#   MojoMagick::resize(uploaded_file.path, tmp.path, {:width => 50, :height => 40, :scale => '>'})
#   self.thumbnail = tmp.read      
# end

# open    : db, name, mode, options (:root, :metadata, :content_type)
# read    : db, name, length, offset
# unlink  : db, names
# list    : db, root collection
#
# GridStore.open(database, 'filename', 'w') { |f|
#   f.puts "Hello, world!"
# }

module Grip
  def self.included(base)
    base.extend Grip::ClassMethods
    base.class_eval do
      after_save :save_attachments
      before_destroy :destroy_attached_files
    end
  end
  
  module ClassMethods
    def has_grid_attachment(name,opts={})
      write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
      attachment_definitions[name] = opts
      
      key "#{name}_size".to_sym, Integer
      key "#{name}_path".to_sym, String
      key "#{name}_name".to_sym, String
      key "#{name}_content_type".to_sym, String
      
      define_method(name) do
        # open returns the correct mime-type, 
        # read returns a string. Not sure if 
        # this is a GridFS problem or not
        GridFS::GridStore.open(self.class.database, self["#{name}_path"], 'r') {|f| f }
      end
      
      define_method("#{name}=") do |file|
        self['_id']                  = Mongo::ObjectID.new if _id.blank?
        self["#{name}_size"]         = File.size(file)
        self["#{name}_name"]         = File.basename(file.path)
        self["#{name}_path"]         = "#{self.class.to_s.underscore}/#{name}/#{_id}"
        self["#{name}_content_type"] = file.content_type rescue MIME::Types.type_for(self["#{name}_name"]).to_s
        self.class.attachment_definitions[name][:file] = file
      end
    end
    
    def attachment_definitions
      read_inheritable_attribute(:attachment_definitions)
    end
  end
  
  def save_attachments
    self.class.attachment_definitions.each do |attachment|
      
      name, opts = attachment

      if (opts[:file].is_a?(File) || opts[:file].is_a?(Tempfile))
        GridFS::GridStore.open(self.class.database, self["#{name}_path"], 'w', :content_type => self["#{name}_content_type"]) do |f|
          processed_or_not = self.respond_to?("process_#{name}") ? send("process_#{name}",opts) : opts[:file]
          f.write(processed_or_not)
        end
      end
    end
  end
  
  def destroy_attached_files
    self.class.attachment_definitions.each do |name, attachment|
      GridFS::GridStore.unlink(self.class.database, self["#{name}_path"])
    end
  end
end
