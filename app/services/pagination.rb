class Pagination
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  def initialize(scope, page: 1, per_page: DEFAULT_PER_PAGE)
    @scope = scope
    @page = [ page.to_i, 1 ].max
    @per_page = [ [ per_page.to_i, 1 ].max, MAX_PER_PAGE ].min
  end

  def records
    @scope.limit(@per_page).offset(offset)
  end

  def metadata
    {
      page: @page,
      per_page: @per_page,
      total: total_count,
      total_pages: total_pages
    }
  end

  private

  def offset
    (@page - 1) * @per_page
  end

  def total_count
    @total_count ||= @scope.unscope(:select).count
  end

  def total_pages
    (total_count.to_f / @per_page).ceil
  end
end
