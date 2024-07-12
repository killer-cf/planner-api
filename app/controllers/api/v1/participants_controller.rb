class Api::V1::ParticipantsController < ApplicationController
  def confirm
    participant = Participant.find(params[:id])

    redirect_to "http://localhost:3000/trips/#{participant.trip_id}" and return if participant.is_confirmed

    participant.update!(is_confirmed: true)
    redirect_to "http://localhost:3000/trips/#{participant.trip_id}"
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Participant with id: #{params[:id]} not found" }, status: :not_found
  end
end
