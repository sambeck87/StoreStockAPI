class Api::V1::StoresController < ApplicationController
  skip_before_action :ensure_active_user!, only: %i[index show create]
  before_action :set_store, only: %i[show update destroy]

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
    authorize!(@store)

    render_serialized(
      @store,
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
    authorize!(@store)

    @store.update!(store_params)

    render_serialized(
      @store,
      with: :store,
      view: :full,
      status: :ok
    )
  end

  def destroy
    authorize!(@store)

    Stores::DeleteStore.new(actor: current_user, store: @store).call

    head :no_content
  end

  private

  def set_store
    @store = Stores::FindAccessible.new(
      current_user: current_user,
      params: { id: params[:id] }
    ).call.first!
  end

  def store_params
    params.require(:store).permit(:name)
  end
end
