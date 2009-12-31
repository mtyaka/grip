module MongoMapper
  module Grip
   module HasAttachment
      module ClassMethods
        
        def has_grid_attachment name, opts={}

          define_method(name) do
            attachments.find(:first,:conditions=>{:name=>name.to_s})
          end

          define_method("#{name}=") do |new_file| 
            raise "Not a File" unless (new_file.is_a?(File) || new_file.is_a?(Tempfile))

            self['_id'] = Mongo::ObjectID.new if _id.blank?

            new_attachment = Attachment.find_or_initialize_by_name_and_owner_id(name.to_s,self._id)
            new_attachment.owner_type   = self.class.to_s
            new_attachment.file_name    = File.basename(new_file.path)
            new_attachment.file_size    = File.size(new_file.path)
            new_attachment.content_type = MIME::Types.type_for(new_file.path)
            new_attachment.file         = new_file
            new_attachment.variants     = opts[:variants]
            new_attachment.save!
            new_attachment

          end
        end
        
      end
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          after_save :save_attachments
          many :attachments, :as => :owner, :class_name => "MongoMapper::Grip::Attachment", :dependent => :destroy
        end
      end
      def save_attachments
        puts "saving"
        puts self.attachments.inspect
      end
    end
  end
end