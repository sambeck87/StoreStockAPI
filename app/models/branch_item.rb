class BranchItem < ApplicationRecord
  belongs_to :branch
  belongs_to :item
  belongs_to :updated_by, class_name: "User", optional: true

  validates :item_id, uniqueness: { scope: :branch_id }
  validates :current_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :minimum_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
