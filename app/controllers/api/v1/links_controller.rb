class Api::V1::LinksController < ApplicationController
  before_action :authenticate
  before_action :set_link, only: %i[destroy]

  def create
    @link = authorize Link.new(link_params)

    if @link.save
      render json: { link_id: @link.id }, status: :created
    else
      render json: { errors: @link.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @link.destroy!
  end

  private

  def set_link
    @link = authorize Link.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "link with id: #{params[:id]} not found" }, status: :not_found
  end

  def link_params
    params.permit(:title, :url).merge(trip_id: params[:id])
  end
end
