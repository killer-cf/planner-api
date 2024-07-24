class Api::V1::ParticipantsController < ApplicationController
  before_action :authenticate, except: %i[confirm]
  before_action :set_participant, only: %i[update destroy confirm]

  def update
    if @participant.update(participant_params)
      render status: :no_content
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
      redirect_to sign_up_url_with_params, allow_other_host: true
    else
      redirect_to sign_in_url_with_params, allow_other_host: true
    end
  end

  private

  def set_participant
    @participant = authorize Participant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "participant with id: #{params[:id]} not found" }, status: :not_found
  end

  def participant_params
    params.permit(:name)
  end

  def sign_in_url_with_params
    sign_in_url = "#{web_url}/sign-in"
    redirect_url = "#{web_url}/api/sign-in-callback"
    nested_params = { trip_id: @participant.trip_id }

    encoded_redirect_url = "#{redirect_url}?#{nested_params.to_query}"
    encoded_redirect_url = URI.encode_www_form_component(encoded_redirect_url)

    "#{sign_in_url}?redirect_url=#{encoded_redirect_url}"
  end

  def sign_up_url_with_params
    sign_up_url = "#{web_url}/sign-up"
    redirect_url = "#{web_url}/api/sign-up-callback"
    nested_params = { trip_id: @participant.trip_id, email: @participant.email }

    encoded_redirect_url = "#{redirect_url}?#{nested_params.to_query}"
    encoded_redirect_url = URI.encode_www_form_component(encoded_redirect_url)

    "#{sign_up_url}?redirect_url=#{encoded_redirect_url}"
  end
end
