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
    user_params = extract_user_params(params[:data])
    @user.add_participants_by_emails([user_params[:participant_email], user_params[:email]].compact)

    if @user.update(user_params.except(:participant_email))
      render status: :no_content
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create_webhook
    user_params = extract_user_params(params[:data])
    @user = User.new(user_params.except(:participant_email))
    @user.add_participants_by_emails([user_params[:participant_email], user_params[:email]].compact)

    if @user.save
      render status: :no_content
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy_webhook
    if @user.destroy
      render status: :no_content
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by!(external_id: params[:data][:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User with id: #{params[:id]} not found" }, status: :not_found
  end

  def validate_params
    required_keys = %i[id]
    missing_keys = required_keys.select { |key| params[:data][key].blank? }

    return unless missing_keys.any?

    render json: { errors: "Missing data parameters: #{missing_keys.join(', ')}" }, status: :bad_request
  end

  def extract_user_params(data)
    {
      name: "#{data[:first_name]} #{data[:last_name]}".strip,
      email: data[:email_addresses]&.first&.dig(:email_address),
      external_id: data[:id],
      participant_email: data.dig(:public_metadata, :participant_email)
    }
  end
end
