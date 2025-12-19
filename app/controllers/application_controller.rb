class ApplicationController < ActionController::API
  include Rendering
  include Serialization

  before_action :authenticate_request!

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
         JWT::ExpiredSignature,
         UnauthorizedError
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  class UnauthorizedError < StandardError; end
end
