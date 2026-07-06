class ApplicationController < ActionController::API
  include Rendering
  include ErrorHandler
  include Serialization
  include Responses

  before_action :authenticate_request!
  before_action :ensure_active_user!
  before_action :set_locale

  attr_reader :current_user

  private

  def authenticate_request!
    header = request.headers["Authorization"]
    token  = header&.split(" ")&.last

    raise UnauthorizedError if token.blank?

    decoded = JsonWebToken.decode(token)
    raise UnauthorizedError if decoded.blank?

    @current_user = User.includes(:store, :global_permission, branch_users: [ :role, :branch ]).find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound,
         JWT::DecodeError,
         JWT::ExpiredSignature
    raise UnauthorizedError
  end

  def set_locale
    locale = request.headers["Accept-Language"]&.split(",")&.first&.strip&.split("-")&.first
    I18n.locale = locale.present? && I18n.available_locales.include?(locale.to_sym) ? locale.to_sym : I18n.default_locale
  end

  def current_branch
    return @current_branch if defined?(@current_branch)

    return @current_branch = nil unless params[:branch_id]

    @current_branch = current_store.branches.find(params[:branch_id])
  end

  def current_store
    return @current_store if defined?(@current_store)

    @current_store = current_user.store
  end

  def authorize!(record)
    policy = policy_for(record)
    action = "#{action_name}?"

    raise AuthorizationError unless policy.public_send(action)
  end

  def policy_for(record)
    policy_class = "#{record.is_a?(Class) ? record.name : record.class.name}Policy".constantize

    policy_class.new(
      current_user,
      record,
      branch: current_branch
    )
  end

  def ensure_active_user!
    return if current_user.active?

    raise InactiveUserError
  end
end
