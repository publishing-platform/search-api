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
        public_timestamp:,
        public_timestamp_datetime: document_hash[:public_updated_at],
        document_type: document_hash[:document_type],
        organisation_status:,
        organisation_type:,
        organisation_abbreviation:,
        slug:,
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

    def public_timestamp
      return nil unless document_hash[:public_updated_at]

      # rubocop:disable Rails/TimeZone (string already contains timezone info which would be lost)
      Time.parse(document_hash[:public_updated_at]).to_i
      # rubocop:enable Rails/TimeZone
    end

    def organisation_status
      return nil unless document_hash[:document_type] == "organisation"

      document_hash
        .dig(:details, :status)
    end

    def organisation_type
      return nil unless document_hash[:document_type] == "organisation"

      document_hash
        .dig(:details, :organisation_type)
    end

    def organisation_abbreviation
      return nil unless document_hash[:document_type] == "organisation"

      document_hash
        .dig(:details, :abbreviation)
    end

    def slug
      case document_hash[:document_type]
      when "organisation"
        link&.gsub(%r{^/organisations/}, "")
      end
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
