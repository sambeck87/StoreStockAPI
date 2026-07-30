class BranchUser < ApplicationRecord
  belongs_to :branch
  belongs_to :user
  belongs_to :role

  validates :user_id, uniqueness: { scope: :branch_id }
end
