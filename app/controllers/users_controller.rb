class UsersController < ApplicationController

  def update
    @user = User.find(params[:id])

    if @user.nil?
      render json: {message: "User Not Found"}, status: :not_found
    else
      if @user.update(user_params)
        render :show
      else 
        render json: {message: @user.error.messages}, status: :bad_request
      end
    end

  end

  def show
    @user = User.find(params[:id])

    if @user.nil?
      render json: {message: "User Not Found"}, status: :not_found
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :profile_picture, :phone_number, :car_picture, :car_color, :car_license_plate, :is_manual, :email, :password)
  end
end
