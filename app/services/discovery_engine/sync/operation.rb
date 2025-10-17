module DiscoveryEngine::Sync
  class Operation
    def initialize(type, content_id, payload_version: nil)
      @type = type
      @content_id = content_id
      @payload_version = payload_version
      @attempt = 1
    end

  private

    attr_reader :type, :content_id, :payload_version, :attempt

    def document_name
      [Branch.default.name, "documents", content_id].join("/")
    end
  end
end
