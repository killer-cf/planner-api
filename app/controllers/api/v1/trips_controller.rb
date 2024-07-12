class Api::V1::TripsController < ApplicationController
  before_action :set_trip, only: %i[show update destroy confirm activities links]

  def index
    if params[:page].present?
      @trips = Trip.page(params[:page]).per(params[:per_page] || 20)

      render json: @trips, meta: pagination_dict(@trips)
    else
      @trips = Trip.all
      render json: @trips
    end
  end

  def show
    render json: @trip
  end

  def create
    @trip = Trip.new(trip_params)
    set_participants_on_trip

    if @trip.save
      TripMailer.with(owner_name: params[:owner_name], owner_email: params[:owner_email],
                      trip: @trip).create_trip.deliver_later
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

  def confirm
    redirect_to "http://localhost:3000/trips/#{@trip.id}" and return if @trip.is_confirmed

    @trip.update!(is_confirmed: true)

    participants = @trip.participants.where(is_owner: false)
    participants.each do |p|
      TripMailer.with(email: p.email, trip: @trip, participant_id: p.id).confirm_trip.deliver_later
    end

    redirect_to "http://localhost:3000/trips/#{@trip.id}"
  end

  def activities
    render json: @trip.activities
  end

  def links
    render json: @trip.links
  end

  private

  def set_trip
    @trip = Trip.find(params[:id])
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
