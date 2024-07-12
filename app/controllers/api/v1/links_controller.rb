class Api::V1::LinksController < ApplicationController
  before_action :set_link, only: %i[destroy]

  def index
    @links = Link.all

    render json: @links
  end

  def create
    @link = Link.new(link_params)

    if @link.save
      render json: @link, status: :created
    else
      render json: { errors: @link.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @link.destroy!
  end

  private

  def set_link
    @link = Link.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "link with id: #{params[:id]} not found" }, status: :not_found
  end

  def link_params
    params.permit(:title, :url, :trip_id)
  end
end
