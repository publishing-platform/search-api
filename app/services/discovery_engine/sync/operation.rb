module DiscoveryEngine::Sync
  class Operation
    def initialize(type, content_id)
      @type = type
      @content_id = content_id
      @attempt = 1
    end

  private

    attr_reader :type, :content_id, :attempt

    def document_name
      [Branch.default.name, "documents", content_id].join("/")
    end
  end
end
