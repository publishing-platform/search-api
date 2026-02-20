# Represents an individual result
class Result
  MAX_DESCRIPTION_WORDS = 40

  include ActiveModel::Model

  attr_accessor :id, :content_id, :title, :description, :link, :public_timestamp, :document_type,
                :organisation_status, :organisation_type, :organisation_abbreviation, :slug

  # Creates a new instance based on a document stored in Discovery Engine, transforming fields as
  # appropriate
  def self.from_stored_document(document)
    attrs = document.symbolize_keys

    public_timestamp = Time.zone.at(attrs[:public_timestamp]).iso8601 if attrs[:public_timestamp]
    description = attrs[:description]&.truncate_words(MAX_DESCRIPTION_WORDS)

    new(
      attrs
        # Fields Discovery Engine documents contains verbatim
        .slice(
          :content_id, :title, :link, :document_type, :organisation_status, :organisation_type,
          :organisation_abbreviation, :slug
        )
        # Fields that need to be transformed
        .merge(
          id: attrs[:content_id],
          description: description,
          # Stored as a timestamp in Discovery Engine, but we want to return an ISO8601 string
          public_timestamp:,
        ).compact,
    )
  end
end
