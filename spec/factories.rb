FactoryBot.define do
  factory :store do
    name { Faker::Company.name }
    user { association :user, store: nil }
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    full_name { Faker::Name.name }
    password { "Password1" }
    password_confirmation { "Password1" }
    active { true }
    store
  end

  factory :global_permission do
    sequence(:name) { |n| "permission#{n}" }
    permissions { { "item" => [ "index", "show", "create", "update", "delete" ] } }
    store

    trait :super_admin do
      name { "super_admin" }
      permissions { {} }
    end

    factory :global_permission_super_admin do
      initialize_with { GlobalPermission.find_or_initialize_by(store: store, name: "super_admin") }
    end
  end

  factory :branch do
    name { Faker::Company.name }
    is_main { false }
    store
  end

  factory :category do
    sequence(:name) { |n| "Category#{n}" }
    active { true }
    store
  end

  factory :item do
    sequence(:name) { |n| "Item#{n}" }
    measure { "pieza" }
    cost { 10.00 }
    active { true }
    store
    category
  end

  factory :branch_item do
    current_quantity { 100 }
    minimum_quantity { 10 }
    branch
    item
  end

  factory :role do
    sequence(:name) { |n| "role#{n}" }
    permissions { { "item" => [ "index", "show" ] } }
    store
  end

  factory :branch_user do
    user
    branch
    role
  end

  factory :inventory_export do
    status { 'pending' }
    filters { {} }
    user
    store
  end
end
