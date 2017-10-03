class CarsController < ApplicationController
  before_action :set_car, except: %i[index new create]
  before_action :set_customer, only: %i[action schedule reserve checkout return cancel]
  before_action :back_if_not_logged_in
  before_action :back_if_customer, only: %i[new create edit update destroy]
  after_action  :delete_customer_pin, only: %i[reserve checkout return cancel]

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
    pin_customer(@customer)
    if params[:reserve_btn]
      redirect_to schedule_car_path(id: @car.id)
    elsif params[:checkout_btn]
      redirect_to checkout_car_url(id: @car.id)
    elsif params[:return_btn]
      redirect_to return_car_url(id: @car.id)
    else
      redirect_to cancel_car_url(id: @car.id)
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
        format.html { redirect_to @car, notice: 'Failed, ' + subject + 'already reserved or checked out another car.'; return }
        format.json { head :no_content }
      end
    end
  end

  def reserve
    require "date"
    start_time = Time.new(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i, params[:start_date][:hour].to_i, params[:start_date][:minute].to_i,0,"-04:00")
    end_time = Time.new(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i, params[:end_date][:hour].to_i, params[:end_date][:minute].to_i, 0, "-04:00")
    if start_time < Time.now || start_time > Time.now + 7.days
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Start Time is not valid.'; return }
        format.json { head :no_content }
      end
    elsif end_time - start_time < 1.hour || end_time - start_time > 10.hours
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Rental period exceeds the limit.'; return }
        format.json { head :no_content }
      end
    else
      record = Record.new(customer_id: @customer.id, car_id: @car.id, start: start_time, end: end_time, status: $reserved)
      record.save
      #@customer.save!
      @customer.update_status($reserved)
      @customer.update_car_id(@car.id)
      @customer.update_record_id(record.id)
      #@customer.update(record_id: record.id, status: $reserved, car_id: @car.id)
      @car.update(status: $reserved, customer_id: @customer.id)
      ########################################
      #  定时任务  endtime  change to available,
      # 借车 中断定时
      ########################################
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Car was successfully reserved.'; return }
        format.json { head :no_content }
      end
    end
  end

  def checkout
    if !@customer.record_id.nil?
      record = Record.find(@customer.record_id)
      if record.car_id == @car.id
        record.update_status($checkedout)
        record.update_start(Time.now)
      else
        subject = if current_authority == $customer
                    'you have'
                  else
                    'this customer has '
                  end
        respond_to do |format|
          format.html { redirect_to @car, notice: 'Failed, ' + subject + 'reserved another car.'; return }
          format.json { head :no_content }
        end
      end
    else
      record = Record.new(customer_id: @customer.id, car_id: @car.id, start: Time.now, status: $reserved)
      record.save
      @customer.update_record_id(record.id)
      @customer.update_car_id(@car.id)
    end
    @car.update(status: $checkedout, customer_id: @customer.id)
    @customer.update_status($checkedout)
    #endtime = now +  params[:h].to_i.hour
########################################
#  Open Timer （call return method）  endtime  change to available

########################################
    respond_to do |format|
      format.html { redirect_to @car, notice: 'Car was successfully checked out.'; return }
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
        format.html { redirect_to(@car, notice: 'Failed, ' + subject + 'didn\'t check out this car.'); return }
        format.json { head :no_content }
      end
    else
      record = Record.find(@customer.record_id)
      if @car.id != record.car_id
        respond_to do |format|
          format.html { redirect_to(@car, notice: 'Failed, ' + subject + 'didn\'t check out this car.'); return }
          format.json { head :no_content }
        end
      else
        @car.update(status: $available, customer_id: nil)
        end_time = Time.now
        hours = ((end_time - record.start) / 1.hour).ceil
        record.update_end(end_time)
        record.update_hours(hours)
        record.update_status($returned)
        charge = @customer.charge + @car.rate * hours
        @customer.update_status($returned)
        @customer.update_car_id(nil)
        @customer.update_record_id(nil)
        @customer.update_charge(charge)
        # End Timer
        respond_to do |format|
          format.html { redirect_to(@car, notice: 'Car was successfully returned.'); return }
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
        format.html { redirect_to @car, notice: 'Failed, ' + subject + 'didn\'t check out or reserve this car.'; return }
        format.json { head :no_content }
      end
    else
      record = Record.find(@customer.record_id)
      @customer.update_status($returned)
      @customer.update_record_id(nil)
      @customer.update_car_id(nil)
      record.update_status($cancelled)
      @car.update(status: $available, customer_id: nil)
      redirect_to(@car, notice: 'Reservation has been successfully cancelled.' ); return
    end
  end

  # POST /cars
  # POST /cars.json
  def create
    params[:car][:status] = $available
    params[:car][:manufacturer].downcase!
    params[:car][:model].downcase!
    params[:car][:location].downcase!
    @car = Car.new(car_params)
    respond_to do |format|
      if @car.save!
        format.html { redirect_to @car, notice: 'Car was successfully created.'; return }
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
    params[:car][:manufacturer].downcase!
    params[:car][:model].downcase!
    params[:car][:location].downcase!
    respond_to do |format|
      if @car.update(car_params)
        format.html { redirect_to @car, notice: 'Car was successfully updated.';return }
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
    # Clear customer's record_id related.
    Customer.where('id = ?', @car.customer_id).each do |customer|
      customer.update_status($returned)
      customer.update_car_id(nil)
      customer.update_record_id(nil)
    end
    #Record.where('car_id = ?', @car.id).destroy_all
    # Destroy the car.
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
                  if params.key?(:customer) && params[:customer].key?(:customer_id)
                    Customer.find(params[:customer][:customer_id])
                  else
                    current_customer
                  end
                else
                  current_user
                end
  end

  def params_clear
    params.delete(:customer)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def car_params
    params.require(:car).permit(:id, :license, :manufacturer, :model, :rate, :style, :location, :status)
  end
end
