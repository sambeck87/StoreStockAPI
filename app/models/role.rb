class Role < ApplicationRecord
  belongs_to :store

  has_many :users
  has_many :branch_users

  validates :name, presence: true

  ALL_PERMISSIONS = {user: [:create, :read, :update, :delete],
                      store: [:create, :read, :update, :delete],
                      branch: [:create, :read, :update, :delete],
                      category: [:create, :read, :update, :delete],
                      item: [:create, :read, :update, :delete],
                      role: [:create, :read, :update, :delete],
                      permission: [:create, :read, :update, :delete]
                    }
end
