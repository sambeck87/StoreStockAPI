class User < ApplicationRecord
  has_secure_password

  PASSWORD_FORMAT = /\A(?=.*[A-Z])(?=.*\d).+\z/
  PASSWORD_MIN_LENGTH = 8

  normalizes :email, with: ->(e) { e.strip.downcase }

  before_validation :normalize_full_name

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :password,
  length: { minimum: PASSWORD_MIN_LENGTH },
  format: {
    with: PASSWORD_FORMAT,
    message: :invalid
  },
  allow_nil: true
  validates :password_confirmation, presence: true, if: :password_being_set?

  belongs_to :store, optional: true
  belongs_to :role, optional: true

  has_many :branch_users, dependent: :destroy
  has_many :branches, through: :branch_users

  has_many :created_categories, class_name: "Category", foreign_key: :created_by_id
  has_many :updated_categories, class_name: "Category", foreign_key: :updated_by_id

  has_many :created_items, class_name: "Item", foreign_key: :created_by_id
  has_many :updated_items, class_name: "Item", foreign_key: :updated_by_id

  def role_for(branch)
    branch_users.find_by(branch: branch)&.role
  end

  private

  def normalize_full_name
    return if full_name.blank?

    self.full_name = full_name.strip.titleize
  end

  def password_being_set?
    password.present?
  end
end