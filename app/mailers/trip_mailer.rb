class TripMailer < ApplicationMailer
  def confirm_trip
    @destination = params[:trip][:destination]
    @ends_at = I18n.l(params[:trip][:ends_at], format: :short)
    @starts_at = I18n.l(params[:trip][:starts_at], format: :short)
    @confirmation_link = "#{ENV.fetch('APP_URL')}/api/v1/participants/#{params[:participant_id]}/confirm"

    mail to: params[:email], subject: 'Confirm your presence on the trip'
  end
end
