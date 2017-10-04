class CarsController < ApplicationController
  before_action :set_car,
                except: %i[index new create]
  before_action :set_customer,
                only: %i[action schedule reserve checkout return cancel]
  before_action :back_if_not_logged_in
  before_action :back_if_customer, only: %i[approve disapprove]
  before_action :back_if_not_suggestion_owner,
                only: %i[edit update destroy]
  before_action :back_if_admin_edit_suggestion,
                only: :edit
  after_action  :delete_customer_pin,
                only: %i[reserve checkout return cancel]

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

  def approve
    Customer.find_by(id: @car.customer_id).update_car_id(nil)
    @car.update(status: $available, customer_id: nil)
    redirect_to @car,
                notice: 'Suggestion has been approved.'
  end

  def disapprove
    Customer.find_by(id: @car.customer_id).update_car_id(nil)
    @car.destroy
    redirect_to cars_url,
                notice: 'Suggestion has been disapproved.'
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
    start_time = Time.new(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i, params[:start_date][:hour].to_i, params[:start_date][:minute].to_i,59,"-04:00")# has to add 59s to ensure start time is right now
    hours= params[:h].to_i
    end_time = start_time +  hours.hour
    #end_time = Time.new(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i, params[:end_date][:hour].to_i, params[:end_date][:minute].to_i, 0, "-04:00")
    if start_time < Time.now || start_time > Time.now + 7.days
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Start Time is not valid.'; return }
        format.json { head :no_content }
      end
   # elsif end_time - start_time < 1.hour || end_time - start_time > 10.hours
    #  respond_to do |format|
   #     format.html { redirect_to @car, notice: 'Rental period exceeds the limit.'; return }
  #      format.json { head :no_content }
  #    end
    else
      record = Record.new(customer_id: @customer.id, car_id: @car.id, start: start_time, end: end_time, status: $reserved)
      record.save
      #@customer.save!
      @customer.update_status($reserved)
      @customer.update_car_id(@car.id)
      @customer.update_record_id(record.id)
      #@customer.update(record_id: record.id, status: $reserved, car_id: @car.id)
      @car.update_status($reserved)
      @car.update_attribute(:customer_id, "#{@customer.id}")

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
      record = Record.find_by(id: @customer.record_id)
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
      record = Record.new(customer_id: @customer.id, car_id: @car.id, start: Time.now, status: $checkedout)
      record.save
    end

    @customer.update_record_id(record.id)
    @customer.update_car_id(@car.id)
    @customer.update_status($checkedout)
    @car.update_status($checkedout)
    @car.update_attribute(:customer_id, "#{@customer.id}")
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
      record = Record.find_by(id: @customer.record_id)
      if @car.id != record.car_id
        respond_to do |format|
          format.html { redirect_to(@car, notice: 'Failed, ' + subject + 'didn\'t check out this car.'); return }
          format.json { head :no_content }
        end
      else
        @car.update_status($available)
        @car.update_attribute(:customer_id, "")

        end_time = Time.now
        hours = ((end_time - record.start) / 1.hour).ceil
        record.update_end(end_time)
        record.update_hours(hours)
        record.update_status($returned)
        charge = @customer.charge + @car.rate * hours
        @customer.update_status($returned)

        @customer.update_attribute(:car_id, "")
        @customer.update_attribute(:record_id,"")
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
      record = Record.find_by(id: @customer.record_id)
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
    params[:car][:status] = if current_authority == $customer
                              $suggested
                            else
                              $available
                            end
    @car = Car.new(car_params)
    respond_to do |format|
      if @car.save!
        if current_authority == $customer
          @car.update(customer_id: current_user.id)
          current_user.update_car_id(@car.id)
        end
        format.html do
          redirect_to @car, notice: 'Car was successfully created.'
          return
        end
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

  def back_if_not_suggestion_owner
    set_car
    set_customer
    back_to_place unless
        @car.customer_id == @customer.id &&
        @car.status == $suggested
  end

  def back_if_admin_edit_suggestion
    set_car
    back_to_place if
        @car.status == $suggested &&
        current_authority != $customer
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def car_params
    params.require(:car).permit(
      :id, :license, :manufacturer, :model,
      :rate, :style, :location, :status
    )
  end
end
