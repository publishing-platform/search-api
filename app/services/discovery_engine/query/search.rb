module DiscoveryEngine::Query
  class Search
    DEFAULT_PAGE_SIZE = 10
    DEFAULT_OFFSET = 0
    DEFAULT_ORDER_BY = nil # not specifying an order_by means the results are ordered by relevance

    def initialize(
      query_params
    )
      @query_params = query_params

      Rails.logger.debug { "Instantiated #{self.class.name}: Query: #{discovery_engine_params}" }
    end

    def result_set
      ResultSet.new(
        results: response.results.map { Result.from_stored_document(_1.document.struct_data.to_h) },
        total: response.total_size,
        start: offset,
        discovery_engine_attribution_token: response.attribution_token,
      )
    end

  private

    attr_reader :query_params

    def response
      @response ||= begin
        search_result = DiscoveryEngine::Clients.search_service.search(discovery_engine_params)
        search_result.response
      rescue Google::Cloud::DeadlineExceededError, Google::Cloud::InternalError => e
        Rails.logger.warn("#{self.class.name}: Did not get search results: '#{e.message}'")
        raise DiscoveryEngine::InternalError
      end
    end

    def discovery_engine_params
      {
        query:,
        serving_config: serving_config.name,
        page_size:,
        offset:,
        order_by:,
        filter:,
      }.compact
    end

    def query
      query_params[:q].presence || ""
    end

    def serving_config
      return ServingConfig.default if query_params[:serving_config].blank?

      ServingConfig.new(query_params[:serving_config])
    end

    def page_size
      query_params[:count].presence&.to_i || DEFAULT_PAGE_SIZE
    end

    def offset
      query_params[:start].presence&.to_i || DEFAULT_OFFSET
    end

    def order_by
      case query_params[:order].presence
      when "title"
        "title"
      when "-title"
        "title desc"
      when "public_timestamp"
        "public_timestamp"
      when "-public_timestamp"
        "public_timestamp desc"
      when nil, "relevance", "popularity"
        # "relevance" and "popularity" behave differently on the previous search-api, but we can
        # treat them the same with Discovery Engine (as empty searches will default to a
        # popularity-ish order anyway and we don't have an explicit popularity option available).
        DEFAULT_ORDER_BY
      else
        # This helps us spot clients that are sending unexpected values and probably should continue
        # to use the previoius search-api instead of this API.
        Rails.logger.warn("Unexpected order_by value: #{query_params[:order].inspect}")
        DEFAULT_ORDER_BY
      end
    end

    def filter
      Filters.new(query_params).filter_expression
    end
  end
end
