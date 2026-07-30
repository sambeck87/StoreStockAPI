module Paginatable
  extend ActiveSupport::Concern

  def pagination_params
    {
      page: params[:page] || 1,
      per_page: params[:per_page] || Pagination::DEFAULT_PER_PAGE
    }
  end

  def paginate(scope, page: 1, per_page: Pagination::DEFAULT_PER_PAGE)
    pagination = Pagination.new(scope, page: page, per_page: per_page)
    [ pagination.records, pagination.metadata ]
  end
end
