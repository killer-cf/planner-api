class Api::V1::TripsController < ApplicationController
  before_action :authenticate
  before_action :set_trip, only: %i[show update destroy activities links participants invites current_participant]

  def index
    if params[:page].present?
      @trips = current_user.trips.order(starts_at: :desc).page(params[:page]).per(params[:per_page] || 20)
      render json: @trips, meta: pagination_dict(@trips)
    else
      @trips = current_user.trips
      render json: @trips.order(starts_at: :desc)
    end
  end

  def show
    render json: @trip
  end

  def create
    @trip = Trip.new(trip_params)
    set_participants_on_trip

    if @trip.save
      @trip.send_confirmation_emails
      render json: { trip_id: @trip.id }, status: :created
    else
      render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @trip.update(trip_params)
      render json: @trip
    else
      render json: @trip.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy!
  end

  def activities
    acts = @trip.activities.order(:occurs_at)

    difference_in_days = (@trip.ends_at.to_date - @trip.starts_at.to_date).to_i

    activities_per_date = (difference_in_days + 1).times.map do |i|
      date = @trip.starts_at + i.days
      start_of_day = date.beginning_of_day
      end_of_day = date.end_of_day
      filtered_activities = acts.select { |act| act[:occurs_at].between?(start_of_day, end_of_day) }

      { date: date, activities: filtered_activities }
    end

    render json: { activities: activities_per_date }
  end

  def links
    render json: @trip.links
  end

  def participants
    render json: @trip.guests
  end

  def invites
    @trip.participants.build(email: params[:email], name: params[:name])

    if @trip.save
      participant = @trip.participants.find_by(email: params[:email])
      TripMailer.with(email: params[:email], trip: @trip, participant_id: participant.id).confirm_trip.deliver_later
      render json: { participant_id: participant.id }
    else
      render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def current_participant
    render json: @trip.participants.find_by!(user: current_user)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Participant not found' }, status: :not_found
  end

  private

  def set_trip
    @trip = authorize Trip.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Trip with id: #{params[:id]} not found" }, status: :not_found
  end

  def set_participants_on_trip
    participants = [{ name: params[:owner_name], email: params[:owner_email], is_owner: true,
                      is_confirmed: true }]

    params[:emails_to_invite]&.each { |email| participants << { email: email } }

    @trip.participants.build(participants)
  end

  def trip_params
    params.permit(:destination, :starts_at, :ends_at)
  end
end
