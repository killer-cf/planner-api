class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[update]

  def create
    @user = User.new(user_params)

    if @user.save
      @user.add_participants_by_emails([params[:participant_email], @user.email])
      render json: { user_id: @user.id }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render status: :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User with id: #{params[:id]} not found" }, status: :not_found
  end

  def user_params
    params.permit(:name, :email, :external_id)
  end
end
