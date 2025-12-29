class ApplicationController < ActionController::API
  include Rendering
  include ErrorHandler
  include Serialization
  include Responses

  before_action :authenticate_request!
  before_action :set_locale

  attr_reader :current_user

  private

  def authenticate_request!
    header = request.headers["Authorization"]
    token  = header&.split(" ")&.last

    raise UnauthorizedError if token.blank?

    decoded = JsonWebToken.decode(token)
    raise UnauthorizedError if decoded.blank?

    @current_user = User.find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound,
         JWT::DecodeError,
         JWT::ExpiredSignature
    raise UnauthorizedError
  end

  def set_locale
    I18n.locale =
      request.headers["Accept-Language"]&.to_sym || I18n.default_locale
  end

  def current_branch
    branch_id = params[:branch_id]

    @current_branch = branch_id ? current_user.branches.find(branch_id) : nil
  end

  def authorize!(record)
    policy = policy_for(record)
    action = "#{action_name}?"

    unless policy.public_send(action)
      raise UnauthorizedError
    end
  end

  def policy_for(record)
    policy_class = "#{record.is_a?(Class) ? record.name : record.class.name}Policy".constantize

    policy_class.new(
      current_user,
      record,
      branch: current_branch
    )
  end

  def find_resource(klass)
    param =
      params["#{klass.name.underscore}_id"] ||
      params[:id]

    klass.find(param)
  end
end
