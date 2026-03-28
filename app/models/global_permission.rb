class GlobalPermission < ApplicationRecord
  belongs_to :store

  validates :name, presence: true, uniqueness: { scope: :store_id }
  validates :permissions, presence: true

  ALL_PERMISSIONS = {
                      user:              %i[index show create update delete manage revoke_access detach_store],
                      store:             %i[index show create update delete],
                      branch:            %i[index show create update delete],
                      category:          %i[index show create update delete],
                      item:              %i[index show create update delete],
                      role:              %i[index show create update delete],
                      global_permission: %i[index show create update delete]
                    }.freeze

  def allows?(resource, action)
    return false unless valid_permission?(resource, action)
    permissions
      .fetch(resource.to_s, [])
      .include?(action.to_s)
  end

  private

  def valid_permission?(resource, action)
    ALL_PERMISSIONS[resource.to_sym]&.include?(action.to_sym)
  end
end
