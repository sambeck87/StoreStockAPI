class Api::V1::CategorySerializer < BaseSerializer
  def initialize(category)
    @category = category
  end

  def compact
    {
      id: @category.id,
      name: @category.name,
      active: @category.active
    }
  end

  def full
    {
      id: @category.id,
      name: @category.name,
      active: @category.active,
      updated_by: @category.updated_by&.full_name,
      created_by: @category.created_by&.full_name
    }
  end
end