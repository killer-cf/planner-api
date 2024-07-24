class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: :show
  before_action :set_user, only: %i[update_webhook destroy_webhook]
  before_action :validate_params, only: %i[create_webhook update_webhook destroy_webhook]

  def show
    user = authorize User.find_by!(external_id: params[:id])
    render json: user
  rescue ActiveRecord::RecordNotFound
    render json: { error: "user with id: #{params[:id]} not found" }, status: :not_found
  end

  def update_webhook
    name = "#{params[:data][:first_name]} #{params[:data][:last_name]}".strip
    email = params[:data][:email_addresses]&.first&.dig(:email_address)

    @user.add_participants_by_emails([params[:data][:public_metadata][:participant_email]])

    if @user.update(name: name, email: email)
      render status: :no_content
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable
    end
  end

  def create_webhook
    name = "#{params[:data][:first_name]} #{params[:data][:last_name]}".strip
    email = params[:data][:email_addresses]&.first&.dig(:email_address)
    external_id = params[:data][:id]

    @user = User.new(name: name, email: email, external_id: external_id)
    @user.add_participants_by_emails([params.dig(:data, :public_metadata, :participant_email), @user.email])

    if @user.save
      render status: :no_content
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable
    end
  end

  def destroy_webhook
    @user.destroy
  end

  private

  def set_user
    @user = User.find_by(external_id: params[:data][:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User with id: #{params[:id]} not found" }, status: :not_found
  end

  def validate_params
    return if params[:data].present?

    render json: { errors: 'Missing data parameter' }, status: :bad_request
  end
end
