class TripMailer < ApplicationMailer
  def create_trip
    @owner_name = params[:owner_name]
    @destination = params[:trip][:destination]
    @ends_at = I18n.l(params[:trip][:ends_at], format: :short)
    @starts_at = I18n.l(params[:trip][:starts_at], format: :short)
    @confirmation_link = "http://localhost:4000/api/v1/trips/#{params[:trip][:id]}/confirm"

    mail to: params[:owner_email], subject: 'Confirm your trip'
  end

  def confirm_trip
    @destination = params[:trip][:destination]
    @ends_at = I18n.l(params[:trip][:ends_at], format: :short)
    @starts_at = I18n.l(params[:trip][:starts_at], format: :short)
    @confirmation_link = "http://localhost:4000/api/v1/trips/#{params[:trip][:id]}/confirm/#{params[:participant_id]}"

    mail to: params[:email], subject: 'Confirm your presence on the trip'
  end
end
