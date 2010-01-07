%w{mongo_mapper mongo/gridfs mime/types ftools tempfile RMagick miso}.each { |lib| require lib }

module Grip
  class GripError < StandardError;  end
  class InvalidFile < GripError;  end
end

%w{grip/attachment grip/has_attachment}.each { |lib| require lib }
