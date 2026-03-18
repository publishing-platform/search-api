module DiscoveryEngine
  module Clients
  module_function

    def document_service
      @document_service ||= Google::Cloud::DiscoveryEngine.document_service(version: :v1)
    end

    def search_service
      @search_service ||= Google::Cloud::DiscoveryEngine.search_service(version: :v1)
    end
  end
end
