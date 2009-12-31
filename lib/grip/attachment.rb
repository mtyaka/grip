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
        define_method sym do
          yield
        end
      end
      
      private
        def build_variants
          self.variants.each do |variant, dimensions|
            self.class.create_method(variant) do
              
            end
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