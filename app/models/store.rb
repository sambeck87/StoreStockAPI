class Store < ApplicationRecord
  belongs_to :user # owner / creator

  has_many :branches, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :roles, dependent: :destroy

  validates :name, presence: true
  validates :user, presence: true
end
