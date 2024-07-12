class Api::V1::ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[show update destroy confirm]

  def show
    render json: @participant
  end

  def update
    if @participant.update(participant_params)
      render json: @participant
    else
      render json: { errors: @participant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @participant.destroy!
  end

  def confirm
    redirect_to "http://localhost:3000/trips/#{@participant.trip_id}" and return if @participant.is_confirmed

    @participant.update!(is_confirmed: true)
    redirect_to "http://localhost:3000/trips/#{@participant.trip_id}"
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Participant with id: #{params[:id]} not found" }, status: :not_found
  end

  private

  def set_participant
    @participant = Trip.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "participant with id: #{params[:id]} not found" }, status: :not_found
  end
end
