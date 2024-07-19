class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :set_web_url

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
