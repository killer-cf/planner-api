class TripMailer < ApplicationMailer
  def create_trip
    @owner_name = params[:owner_name]
    @owner_email = params[:owner_email]
    @destination = params[:trip][:destination]
    @ends_at = I18n.l(params[:trip][:ends_at], format: :short)
    @starts_at = I18n.l(params[:trip][:starts_at], format: :short)

    mail to: @owner_email, subject: 'Confirm your trip'
  end
end
