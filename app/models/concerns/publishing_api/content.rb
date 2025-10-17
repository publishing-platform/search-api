module PublishingApi
  module Content
    # All the possible keys in the message hash that can contain the primary unstructured document
    # content that we want to index, represented as JsonPath path strings.
    #
    # Note that this also indexes some things that are in metadata attributes (e.g. title,
    # description) as it seems that the engine is better at picking up on them if they are in the
    # unstructured content.
    INDEXABLE_CONTENT_VALUES_JSON_PATHS = %w[
      $.title
      $.description

      $.details.abbreviation
      $.details.body
    ].map { JsonPath.new(_1, use_symbols: true) }.freeze
    INDEXABLE_CONTENT_SEPARATOR = "\n".freeze

    # The limit of content length on Discovery Engine API is currently 1MB (not MiB), a small
    # handful of documents exceed this so we need to truncate the content to a reasonable size.
    # This is slightly lower than 1 million bytes to allow for some rounding error.
    INDEXABLE_CONTENT_MAX_BYTE_SIZE = 999_000

    # Extracts a single string of indexable unstructured content from the document.
    def content
      values_from_json_paths = INDEXABLE_CONTENT_VALUES_JSON_PATHS.map do |item|
        item.on(document_hash).map { |body| BodyContent.new(body).html_content }
      end

      values_from_json_paths
       .compact_blank
       .join(INDEXABLE_CONTENT_SEPARATOR)
       .truncate_bytes(INDEXABLE_CONTENT_MAX_BYTE_SIZE)
    end
  end
end
