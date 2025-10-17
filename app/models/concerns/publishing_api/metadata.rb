module PublishingApi
  module Metadata
    WEBSITE_ROOT = "https://www.publishing-platform.co.uk".freeze

    # Extracts a hash of structured metadata about this document.
    def metadata
      {
        content_id: document_hash[:content_id],
        title: document_hash[:title]&.strip,
        description: document_hash[:description],
        link:,
        url:,
        document_type: document_hash[:document_type],
        debug:,
      }.compact_blank
    end

    def link
      document_hash[:base_path]
    end

  private

    def link_relative?
      link&.start_with?("/")
    end

    def url
      return link unless link_relative?

      WEBSITE_ROOT + link
    end

    # Useful information about the document that is not intended to be exposed to the end user.
    def debug
      {
        last_synced_at: Time.zone.now.iso8601,
        payload_version: document_hash[:payload_version]&.to_i,
      }
    end
  end
end
