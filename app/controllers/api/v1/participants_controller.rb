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
    @participant.update!(is_confirmed: true) unless @participant.is_confirmed

    if @participant.user.nil?
      redirect_to "#{web_url}/sign-up?redirect_url=#{web_url}/api/sign-up-callback?trip_id=#{@participant.trip_id}&email=#{@participant.email}"
    else
      redirect_to "#{web_url}/sign-in?redirect_url=#{web_url}/trips/#{@participant.trip_id}"
    end
  end

  private

  def set_participant
    @participant = Participant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "participant with id: #{params[:id]} not found" }, status: :not_found
  end
end
