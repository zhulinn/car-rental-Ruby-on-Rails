class CarsController < ApplicationController
  before_action :set_car, only: [:show, :edit, :update, :destroy, :schedule, :reserve, :checkout, :return, :cancel]
  before_action :set_customer, only: [:schedule, :reserve, :checkout, :return, :cancel]
  before_action :back_if_not_logged_in
  before_action :back_if_customer, only: [:new, :create, :edit, :update, :destroy]

  # GET /cars
  # GET /cars.json
  def index
    attribute = params[:attribute]
    value = params[:value]
    @cars = if value.nil? || value.blank?
              Car.all
            else
              Car.where("#{attribute}.downcase = ?", value.downcase)
            end
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

  def action
    if params[:reserve_btn]
      respond_to do |format|
        format.html { redirect_to schedule_car_url(customer_id: @customer, id: @car) }
        format.json { head :no_content }
      end
=begin
    elsif params[:checkout_btn]
      redirect_to checkout_car_url(customer_id: @customer, id: @car)
    elsif params[:return_btn]
      redirect_to return_car_url(customer_id: @customer, id: @car)
    else
      redirect_to cancel_car_url(customer_id: @customer, id: @car)
=end
    end
  end

  def schedule
    subject = if current_authority == $customer
                'you have '
              else
                'this customer has '
              end
    if @customer.status != $returned
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Failed, ' + subject + 'already reserved or checked out another car.' }
        format.json { head :no_content }
      end
    end
  end

  def reserve
    #require "date"
    start_time = Time.new(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i, params[:start_date][:hour].to_i, params[:start_date][:minute].to_i,0,"-04:00")
    end_time = Time.new(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i, params[:end_date][:hour].to_i, params[:end_date][:minute].to_i, 0, "-04:00")
    if start_time < Time.now || start_time > Time.now + 7.days
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Start Time is not valid.' }
        format.json { head :no_content }
      end
    elsif end_time - start_time < 1.hour || end_time - start_time > 10.hours
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Rental period exceeds the limit.' }
        format.json { head :no_content }
      end
    else
      record = Record.new(customer_id: @customer, car_id: @car, start: start_time, end: end_time, status: $reserved)
      record.save
      @car.update(status: $reserved)
      @customer.update(record_id: record.id, status: $reserved, car_id: @car.id)
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

  def checkout
    if !@customer.record_id.nil?
      record = Record.find(@customer.record_id)
      if record.car_id == @car.id
        record.update(status: $checkedout, start: Time.now)
      else
        subject = if current_authority == $customer
                    'you have'
                  else
                    'this customer has '
                  end
        respond_to do |format|
          format.html { redirect_to @car, notice: 'Failed, ' + subject + 'reserved another car.' }
          format.json { head :no_content }
        end
      end
    else
      record = Record.new(customer_id: @customer, car_id: @car, start: Time.now, status: $reserved)
      record.save
      @customer.update(record_id: record.id, status: $checkedout, car_id: @car.id)
    end
    @car.update(status: $checkedout)
    #endtime = now +  params[:h].to_i.hour
########################################
#  Open Timer （call return method）  endtime  change to available

########################################
    respond_to do |format|
      format.html { redirect_to @car, notice: 'Car was successfully checked out.' }
      format.json { head :no_content }
    end
  end

  def return
    subject = if current_authority == $customer
                'you '
              else
                'this customer '
              end
    if @customer.record_id.nil?
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Failed, ' + subject + 'didn\'t check out this car.' }
        format.json { head :no_content }
      end
    else
      record = Record.find(@customer.record_id)
      if @car.id != record.car_id
        respond_to do |format|
          format.html { redirect_to @car, notice: 'Failed, ' + subject + 'didn\'t check out this car.' }
          format.json { head :no_content }
        end
      else
        @car.update(status: $available)
        endtime = Time.now
        hours = ((endtime - record.start) / 1.hour).ceil
        record.update(end: endtime, hours: hours)
        charge = @customer.charge + @car.rate * hours
        @customer.update(charge: charge, record_id: nil, car_id: nil, status: $returned) # delete current Record_id in customer
        # End Timer
        respond_to do |format|
          format.html { redirect_to @car, notice: 'Car was successfully returned.' }
          format.json { head :no_content }
        end
      end
    end
  end

  def cancel
    subject = if current_authority == $customer
                'you '
              else
                'this customer '
              end
    if @customer.record_id.nil? || @car.id != @customer.car_id
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Failed, ' + subject + 'didn\'t check out or reserve this car.' }
        format.json { head :no_content }
      end
    else
      record = Record.find(@customer.record_id)
      @customer.update(status: $returned, record_id: nil, car_id: nil )
      record.update(status: $cancelled)
      @car.update(status: $available)
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

  def set_customer
    @customer = if current_authority != $customer
                  Customer.find(params[:customer_id])
                else
                  current_user
                end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def car_params
    params.require(:car).permit(:id, :license, :manufacturer, :model, :rate, :style, :location, :status)
  end
end
