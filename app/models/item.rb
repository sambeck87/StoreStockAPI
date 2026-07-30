class Item < ApplicationRecord
  belongs_to :store
  belongs_to :category
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true

  has_many :branch_items, dependent: :destroy
  has_many :branches, through: :branch_items

  validates :name, presence: true, uniqueness: { scope: :store_id }
  validates :measure, presence: true
end
