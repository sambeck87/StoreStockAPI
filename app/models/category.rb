class Category < ApplicationRecord
  belongs_to :store
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true

  has_many :items, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :store_id }

  scope :by_name, ->(name) {
    where("name ILIKE ?", "%#{name}%")
  }
end
