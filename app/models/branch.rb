class Branch < ApplicationRecord
  belongs_to :store
  belongs_to :manager, class_name: "User", optional: true

  has_many :branch_users, dependent: :destroy
  has_many :users, through: :branch_users

  has_many :branch_items, dependent: :destroy
  has_many :items, through: :branch_items

  validates :name, presence: true
  validate :only_one_main_per_store, if: :is_main?

  before_destroy :prevent_main_deletion

  private

  def only_one_main_per_store
    return unless store

    if store.branches.where(is_main: true).where.not(id: id).exists?
      errors.add(:is_main, "already exists for this store")
    end
  end

  def prevent_main_deletion
    throw(:abort) if is_main?
  end
end
