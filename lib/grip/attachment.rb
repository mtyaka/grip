module Grip
  class Attachment
    include MongoMapper::Document

    belongs_to  :owner, 
                :polymorphic => true
                
    many  :attached_variants, 
          :as => :owner, 
          :class_name => "Grip::Attachment", 
          :dependent => :destroy
          
    key :owner_id,      ObjectId, :required => true
    key :owner_type,    String,   :required => true

    key :name,          String
    key :file_name,     String
    key :file_size,     Integer
    key :content_type,  String
    key :variants,      Hash
    
    after_save      :build_variants
    before_destroy  :destroy_file
    
    def file=new_file
      raise InvalidFile unless (new_file.is_a?(File) || new_file.is_a?(Tempfile))
      
      self.file_name    = new_file.is_a?(Tempfile) ? new_file.original_filename : File.basename(new_file.path)
      self.file_size    = File.size(new_file.path)
      self.content_type = MIME::Types.type_for(new_file.path)
      
      write_to_grid self,new_file
    end
    
    def file
      read_from_grid grid_key
    end
    
    def grid_key
      "#{owner_type.pluralize}/#{owner_id}/#{name}".downcase
    end
    
    def self.create_method method_name, &block
      define_method(method_name) do |*args|
        yield *args
      end
    end
    
    private
      def build_variants
        self.variants.each do |variant, dimensions|
          
          self.class.create_method variant.to_sym do
            attached_variants.find_or_create_by_name(:name=>"#{variant.to_s}")
          end
          
          self.class.create_method "#{variant}=".to_sym do |file_hash|
            
            new_attachment              = Attachment.find_or_initialize_by_name_and_owner_id("#{variant.to_s}",self._id)
            new_attachment.owner_type   = self.class.to_s
            new_attachment.file_name    = File.basename(file_hash[:uploaded_file].path)
            new_attachment.file_size    = File.size(file_hash[:resized_file].path)
            new_attachment.content_type = MIME::Types.type_for(file_hash[:uploaded_file].path)
            new_attachment.save!

            write_to_grid new_attachment, file_hash[:resized_file]
          end
        
        end
      end
      
      def destroy_file
        GridFS::GridStore.unlink(self.class.database, grid_key)
      end
    
      def write_to_grid attachment, new_file
        GridFS::GridStore.open(self.class.database, attachment.grid_key, 'w', :content_type => attachment.content_type) do |f|
          f.write new_file.read
        end
      end
      
      def read_from_grid key
        GridFS::GridStore.new(self.class.database, key, 'r')
      end
  end
end
