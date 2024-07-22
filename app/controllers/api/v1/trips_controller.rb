class Api::V1::TripsController < ApplicationController
  before_action :authenticate, except: :confirm
  before_action :set_trip, only: %i[show update destroy confirm activities links participants invites]

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
    render json: @trip.participants.where(is_owner: false)
  end

  def invites
    @trip.participants.build(email: params[:email], name: params[:name])

    if @trip.save
      participant = @trip.participants.find_by(email: params[:email])
      TripMailer.with(email: params[:email], trip: @trip, participant_id: participant.id).confirm_trip.deliver_later
      render json: { trip_id: @trip.id }, status: :created
    else
      render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
    end
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
