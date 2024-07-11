class TripMailer < ApplicationMailer
  def confirm_trip
    @owner_name = params[:owner_name]
    @owner_email = params[:owner_email]

    mail to: @owner_email, subject: 'Confirm your trip'
  end
end
