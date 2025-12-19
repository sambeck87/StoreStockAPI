class User < ApplicationRecord
  has_secure_password

  normalizes :email, with: ->(e) { e.strip.downcase }

  before_validation :normalize_full_name

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true

  # Relaciones directas
  belongs_to :store, optional: true
  belongs_to :role, optional: true

  # Relaciones por sucursal
  has_many :branch_users, dependent: :destroy
  has_many :branches, through: :branch_users

  # Auditoría
  has_many :created_categories, class_name: "Category", foreign_key: :created_by_id
  has_many :updated_categories, class_name: "Category", foreign_key: :updated_by_id

  has_many :created_items, class_name: "Item", foreign_key: :created_by_id
  has_many :updated_items, class_name: "Item", foreign_key: :updated_by_id

  private

  def normalize_full_name
    return if full_name.blank?

    self.full_name = full_name.strip.titleize
  end
end