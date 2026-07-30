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
  belongs_to :global_permission, optional: true

  attribute :confirmed_at, :datetime, default: nil

  has_many :branch_users, dependent: :destroy
  has_many :branches, through: :branch_users

  has_many :created_categories, class_name: "Category", foreign_key: :created_by_id
  has_many :updated_categories, class_name: "Category", foreign_key: :updated_by_id

  has_many :created_items, class_name: "Item", foreign_key: :created_by_id
  has_many :updated_items, class_name: "Item", foreign_key: :updated_by_id

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: [ false, nil ]) }

  scope :for_branch, ->(branch) {
    joins(:branches).where(branches: { id: branch.id })
  }

  scope :for_branch_id, ->(branch_id) {
    joins(:branches).where(branches: { id: branch_id })
  }

  scope :for_branches, ->(branch_ids) {
    joins(:branches).where(branches: { id: branch_ids }).distinct
  }


  def super_admin?
    role_for_main_branch&.name == "super_admin"
  end

  def has_global_permission?(resource, action)
    global_permission&.allows?(resource, action) || false
  end

  PERMISSION_RESOURCES = %w[user store branch category item role global_permission].freeze

  def branch_ids_with_permission(resource, action)
    raise ArgumentError, "invalid resource: #{resource}" unless resource.to_s.in?(PERMISSION_RESOURCES)

    branch_users
      .joins(:role)
      .where("JSON_CONTAINS(roles.permissions, ?, ?)", "\"#{action}\"", "$.#{resource}")
      .pluck(:branch_id)
  end

  def role_for(branch)
    branch_users.includes(:role, :branch).find_by(branch: branch)&.role
  end

  def role_for_main_branch
    branch_users
      .includes(:role, :branch)
      .joins(:branch)
      .find_by(branches: { is_main: true })
      &.role
  end

  def preload_for_authorization
    return if @authorization_preloaded

    store
    global_permission
    branch_users.each do |bu|
      bu.role
      bu.branch
    end
    @authorization_preloaded = true
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
