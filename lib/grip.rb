%w{mongo/gridfs mime/types tempfile miso}.each { |lib| require lib }

module MongoMapper
  module Grip
    class GripError < StandardError;  end
    class InvalidFile < GripError;  end
  end
end

%w{grip/attachment grip/has_attachment}.each { |lib| require lib }
