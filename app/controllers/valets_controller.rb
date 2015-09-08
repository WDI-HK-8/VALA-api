class ValetsController < ApplicationController

  def update
    @valet = Valet.find_by_id(params[:id])
    if @valet.nil?
      render json: {message: "404 Not Found"}
    else
      @valet.update(valet_params)
    end
  end

  def show
    @valet = Valet.find_by_id(params[:id])
    if @valet.nil?
      render json: {message: "400 Bad Request"}
    end
  end

  def index
    @valets = Valet.all
  end

  def available
    @valets = Valet.where(status: "available")
  end


  private
  def valet_params
    params.require(:valet).permit(:email, :password, :confirm_password, :phone_number, :driving_license_exp_date, :manual, :status)
  end


end
