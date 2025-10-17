class SearchesController < ApplicationController
  before_action :validate_query_params, only: :show

  def show
    search = DiscoveryEngine::Clients.search_service.search({ query: query_params[:q], serving_config: ServingConfig.default.name, filter: "document_type: ANY(\"organisation\")" })
    render json: search.response
  end

private

  def query_params
    params.permit!
  end

  def validate_query_params
    raise ActionController::BadRequest, "Invalid query parameter" unless params.fetch(:q, "").is_a?(String)
  end
end
