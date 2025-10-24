# Represents an individual result
class Result
  MAX_DESCRIPTION_WORDS = 40

  include ActiveModel::Model

  attr_accessor :id, :content_id, :title, :description, :link, :document_type, :organisation_status,
                :organisation_type, :organisation_abbreviation

  # Creates a new instance based on a document stored in Discovery Engine, transforming fields as
  # appropriate
  def self.from_stored_document(document)
    attrs = document.symbolize_keys

    description = attrs[:description]&.truncate_words(MAX_DESCRIPTION_WORDS)

    new(
      attrs
        # Fields Discovery Engine documents contains verbatim
        .slice(
          :content_id, :title, :link, :document_type, :organisation_status, :organisation_type,
          :organisation_abbreviation
        )
        # Fields that need to be transformed
        .merge(
          id: attrs[:content_id],
          description: description,
        ),
    )
  end
end
