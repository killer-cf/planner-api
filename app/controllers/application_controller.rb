class ApplicationController < ActionController::API
  include JsonWebToken
  include Pundit::Authorization

  before_action :set_web_url

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate
    header = request.headers['Authorization']
    header = header.split.last if header
    decoded = jwt_decode(header)
    if decoded
      @current_user = User.find_by(external_id: decoded[:sub])
      render json: { error: 'Não autorizado' }, status: :unauthorized unless @current_user
    else
      render json: { error: 'Não autorizado' }, status: :unauthorized
    end
  end

  def set_web_url
    @web_url = ENV.fetch('WEB_URL')
  end

  attr_reader :current_user, :web_url

  def user_not_authorized
    render json: { error: 'Forbidden' }, status: :forbidden
  end

  def pagination_dict(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end
