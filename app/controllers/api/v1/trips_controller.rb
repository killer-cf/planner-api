class Api::V1::TripsController < ApplicationController
  before_action :set_trip, only: %i[show update destroy]

  # GET /trips
  def index
    if params[:page].present?
      @trips = Trip.page(params[:page]).per(params[:per_page] || 20)

      render json: @trips, meta: pagination_dict(@trips)
    else
      @trips = Trip.all
      render json: @trips
    end
  end

  # GET /trips/1
  def show
    render json: @trip
  end

  # POST /trips
  def create
    @trip = Trip.new(trip_params)

    if @trip.save
      TripMailer.with(owner_name: params[:owner_name], owner_email: params[:owner_email]).confirm_trip.deliver_later
      render json: @trip, status: :created
    else
      render json: @trip.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /trips/1
  def update
    if @trip.update(trip_params)
      render json: @trip
    else
      render json: @trip.errors, status: :unprocessable_entity
    end
  end

  # DELETE /trips/1
  def destroy
    @trip.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_trip
    @trip = Trip.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Trip with id: #{params[:id]} not found" }, status: :not_found
  end

  # Only allow a list of trusted parameters through.
  def trip_params
    params.require(:trip).permit(:destination, :starts_at, :ends_at)
  end
end
