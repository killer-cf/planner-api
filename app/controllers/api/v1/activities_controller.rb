class Api::V1
  before_action :set_activity, only: %i[destroy]

  def index
    @activities = Activity.all

    render json: @activities
  end

  def create
    @activity = Activity.new(activity_params)

    if @activity.save
      render json: @activity, status: :created, location: @activity
    else
      render json: { errors: @activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy!
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit(:title, :occurs_at, :trip_id)
  end
end
