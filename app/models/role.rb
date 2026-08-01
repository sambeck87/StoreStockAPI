class Role < ApplicationRecord
  belongs_to :store

  has_many :branch_users
  has_many :users, through: :branch_users

  validates :name, presence: true, uniqueness: { scope: :store_id }

  def allows?(resource, action)
    permissions
      .fetch(resource.to_s, [])
      .include?(action.to_s)
  end
end
