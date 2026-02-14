class Store < ApplicationRecord
  belongs_to :user, optional: true

  has_many :branches, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :global_permissions, dependent: :destroy

  validates :name, presence: true
  validates :user, presence: true
  validates :user_id, uniqueness: true
end
