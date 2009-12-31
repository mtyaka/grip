class Tempfile
  def make_tmpname(basename, n)
    sprintf('%s%d-%d', basename, $$, n)
  end
end
module MongoMapper
  module Grip
    class Attachment
      include MongoMapper::Document

      belongs_to :owner, :polymorphic => true

      key :owner_id,      ObjectId, :required => true
      key :owner_type,    String,   :required => true

      key :name,          String
      key :file_name,     String
      key :file_size,     Integer
      key :content_type,  String
      key :variants,      Hash
      
      key :variant_attachments, Array
      
      after_save :build_variants
      
      def file=new_file
        raise InvalidFile unless (new_file.is_a?(File) || new_file.is_a?(Tempfile))
        
        self.file_name    = File.basename(new_file.path)
        self.file_size    = File.size(new_file.path)
        self.content_type = MIME::Types.type_for(new_file.path)
        
        write_to_grid new_file
      end
      
      def file
        read_from_grid grid_key
      end
      
      def grid_key
        "#{owner_type.pluralize}/#{owner_id}/#{name}".downcase
      end
      
      def self.create_method sym, &block
        define_method sym do |*block.args|
          yield
        end
      end
      
      private
        def build_variants
          self.variants.each do |variant, dimensions|
            
            eval <<-EOF
              def #{variant}
                Attachment.find_or_initialize_by_name_and_owner_id("#{variant.to_s}",self._id)
              end
            EOF
            
            eval <<-EOF
              def #{variant}=(file_hash)
                new_attachment  = Attachment.find_or_initialize_by_name_and_owner_id("#{variant.to_s}",self._id)
                new_attachment.owner_type   = self.class.to_s
                new_attachment.file         = file_hash[:tmp_file]
                new_attachment.file_name    = File.basename(file_hash[:uploaded_file].path)
                new_attachment.file_size    = File.size(file_hash[:tmp_file].path)
                new_attachment.content_type = MIME::Types.type_for(file_hash[:uploaded_file].path)
                
                puts new_attachment.grid_key
                new_attachment.save!
              end
            EOF
            
          end
        end
      
        def write_to_grid new_file
          GridFS::GridStore.open(self.class.database, grid_key, 'w', :content_type => content_type) do |f|
            f.write new_file.read
          end
        end
        
        def read_from_grid key
          GridFS::GridStore.open(self.class.database, key, 'r') { |f| f }
        end
    end
  end
end