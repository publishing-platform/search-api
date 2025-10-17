module PublishingApi
  module Action
    # When a document is unpublished in the source system, its document type changes to one of
    # these values. While semantically different for other systems, we only need to know that they
    # imply removal from search.
    UNPUBLISH_DOCUMENT_TYPES = %w[gone redirect substitute vanish].freeze

    def sync?
      !desync?
    end

    def desync?
      unpublish_type? || on_ignorelist? || unaddressable? || withdrawn?
    end

    def action_reason
      if unpublish_type?
        "unpublish type (#{document_type})"
      elsif on_ignorelist?
        "document_type on ignorelist (#{document_type})"
      elsif unaddressable?
        "unaddressable"
      elsif withdrawn?
        "withdrawn"
      end
    end

  private

    def unpublish_type?
      UNPUBLISH_DOCUMENT_TYPES.include?(document_type)
    end

    # rubocop:disable Style/CaseEquality (no semantically equal alternative to compare String/Regex)
    def on_ignorelist?
      Rails.configuration.document_type_ignorelist.any? { _1 === document_type }
    end
    # rubocop:enable Style/CaseEquality

    def withdrawn?
      document_hash[:withdrawn_notice].present?
    end

    def document_type
      document_hash.fetch(:document_type)
    end

    def unaddressable?
      base_path.blank?
    end

    def base_path
      document_hash[:base_path]
    end

    def update_type
      document_hash[:update_type]
    end
  end
end
