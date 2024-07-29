class Api::V1::ActivitiesController < ApplicationController
  before_action :authenticate
  before_action :set_activity, only: %i[destroy update]

  def create
    @activity = authorize Activity.new(activity_params)

    if @activity.save
      render json: { activity_id: @activity.id }, status: :created
    else
      render json: { errors: @activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @activity.update(activity_params.except(:trip_id))
      render status: :no_content
    else
      render json: { errors: @activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy!
  end

  private

  def set_activity
    @activity = authorize Activity.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "activity with id: #{params[:id]} not found" }, status: :not_found
  end

  def activity_params
    params.permit(:title, :occurs_at).merge(trip_id: params[:id])
  end
end
