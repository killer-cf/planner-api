class Api::V1::ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[destroy]

  def create
    @activity = Activity.new(activity_params)

    if @activity.save
      render json: @activity, status: :created
    else
      render json: { errors: @activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy!
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "activity with id: #{params[:id]} not found" }, status: :not_found
  end

  def activity_params
    params.permit(:title, :occurs_at).merge(trip_id: params[:id])
  end
end
