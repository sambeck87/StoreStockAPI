class Api::V1::StoresController < ApplicationController
  skip_before_action :ensure_active_user!, only: %i[index show create]

  def index
    stores = Stores::FindAccessible.new(
      current_user: current_user,
      params: params
    ).call

    render_serialized(
      stores,
      with: :store,
      view: :compact,
      status: :ok
    )
  end

  def show
    store = Stores::FindAccessible.new(
      current_user: current_user,
      params: { id: params[:id] }
    ).call.first!

    authorize!(store)

    render_serialized(
      store,
      with: :store,
      view: :full,
      status: :ok
    )
  end

  def create
    store = Stores::OnboardStore.new(
      user: current_user,
      store_params: store_params
    ).call

    render_serialized(
      store,
      with: :store,
      view: :full,
      status: :created
    )
  end

  def update
    store = Stores::FindAccessible.new(
      current_user: current_user,
      params: { id: params[:id] }
    ).call.first!

    authorize!(store)

    store.update!(store_params)

    render_serialized(
      store,
      with: :store,
      view: :full,
      status: :ok
    )
  end

  private

  def store_params
    params.require(:store).permit(:name)
  end
end
