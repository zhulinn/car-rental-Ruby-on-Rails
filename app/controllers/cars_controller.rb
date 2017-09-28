class CarsController < ApplicationController
  before_action :set_car, only: [:show, :edit, :update, :destroy, :return, :reserve, :checkout]
  before_action :back_if_not_logged_in
  before_action :back_if_customer, only: [:new, :create, :edit, :update, :destroy]

  # GET /cars
  # GET /cars.json
  def index
    @cars = Car.all
  end

  # GET /cars/1
  # GET /cars/1.json
  def show
  end

  # GET /cars/new
  def new
    @car = Car.new
  end

  # GET /cars/1/edit
  def edit
  end

  def reserve
    require "date"
    starttime = DateTime.new(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i, params[:start_date][:hour].to_i, params[:start_date][:minute].to_i,59,'-4')

    if starttime  < Time.now || starttime > Time.now + 7.days
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Start Time is not valid.' }
        format.json { head :no_content }
      end
    else

      @car.update(status: 'Reserved')
      current_user.update_attribute(:recordid, "#{-1 - @car.id}")
      ########################################
      #  定时任务  endtime  change to available,
      # 借车 中断定时
      ########################################
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Car was successfully reserved.' }
        format.json { head :no_content }
      end
    end
  end

  # POST /cars
  # POST /cars.json
  def create
    @car = Car.new(car_params)

    respond_to do |format|
      if @car.save
        format.html { redirect_to @car, notice: 'Car was successfully created.' }
        format.json { render :show, status: :created, location: @car }
      else
        format.html { render :new }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cars/1
  # PATCH/PUT /cars/1.json
  def update
    respond_to do |format|
      if @car.update(car_params)
        format.html { redirect_to @car, notice: 'Car was successfully updated.' }
        format.json { render :show, status: :ok, location: @car }
      else
        format.html { render :edit }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.json
  def destroy
    #Clear customer's record_id related.
    Record.find_all_by(car_id: @car).each do |id|
      Customer.find(Record.find(id).customer_id).update_attribute(:record_id, nil)
      Record.destroy(id)
    end
    #Destroy the car.
    @car.destroy
    respond_to do |format|
      format.html { redirect_to cars_url, notice: 'Car was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_car
    @car = Car.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def car_params
    params.require(:car).permit(:id, :license, :manufacturer, :model, :rate, :style, :location, :status)
  end
end
