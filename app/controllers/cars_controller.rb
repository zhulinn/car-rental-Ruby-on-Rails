class CarsController < ApplicationController
  require "date"
  before_action :set_car,
                except: %i[index new create checkout]
  before_action :set_customer,
                only: %i[action schedule reserve beforecheckout return cancel subscribe]
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
    @cars = if current_authority == $customer
                 Car.where('status != ? or customer_id = ?', $suggested, current_user.id)# display suggested car by customer self
               else
                 Car.all
               end

    attribute = params[:attribute]
    value = params[:value]
    @cars = @cars.where("#{attribute.downcase} = ?", value.downcase) unless value.nil? || value.blank?

  end

  # GET /cars/1
  # GET /cars/1.json
  def show
      if @car.status == $reserved
        @records = Record.where('status = ? and car_id =?', $reserved, @car.id).order( :start )
      end
  end

  # GET /cars/new
  def new
    @car = Car.new
  end

  # GET /cars/1/edit
  def edit
  end

  def approve
    customer = Customer.find_by(id: @car.customer_id)
    customer.update_car_id(nil)
    @car.update(status: $available, customer_id: nil)
    CustomerMailer.approve_email(customer, @car).deliver_now
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
      redirect_to beforecheckout_car_url(id: @car.id, h: params[:h])
    elsif params[:return_btn]
      redirect_to return_car_url(id: @car.id)
    elsif params[:subscribe_btn]
      redirect_to subscribe_car_url(id: @car.id)
    else
      redirect_to cancel_car_url(id: @car.id)
    end
  end

  def subscribe
    @customer.update_subscribe_car_id(@car.id)
    respond_to do |format|
      format.html { redirect_to @car, notice: 'Car was successfully subscribed, you will receive a email when car is available'; return }
      format.json { head :no_content }
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

  def findNext car, customer
    reservations = Record.where('status = ? and car_id =? and customer_id != ?',
                                $reserved, car.id, customer.id).order( :start )
    if reservations.size == 0
      car.update_status($available)
      car.update_attribute(:customer_id, "")
      subscribes = Customer.where('subscribe_car_id =? ', car.id)
      subscribes.each do |one|
        one.update_attribute(:subscribe_car_id, "")
        CustomerMailer.available_email(one, car).deliver_now
      end
    else
      nextone = reservations.first # next reservation
      car.update_status($reserved)
      car.update_attribute(:customer_id, "#{nextone.customer_id}")

    end
  end

  def reserve
    start_time = Time.new(params[:start_date][:year].to_i,
                          params[:start_date][:month].to_i,
                          params[:start_date][:day].to_i,
                          params[:start_date][:hour].to_i,
                          params[:start_date][:minute].to_i,
                          0)# has to add 59s to ensure start time is valid
    hours= params[:h].to_i
    end_time = start_time +  hours.hour
    #end_time = Time.new(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i, params[:end_date][:hour].to_i, params[:end_date][:minute].to_i, 0, "-04:00")
    if start_time + 59.second < Time.zone.now || start_time > Time.zone.now + 7.days
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Start Time is not valid.'; return }
        format.json { head :no_content }
      end
    end

    if @car.status == $reserved
      @records = Record.where('status = ? and car_id =?', $reserved, @car)
      @records.each do |record|
        unless end_time < record.start || start_time > record.end  # check whether reservation time is overlaped
          respond_to do |format|
            format.html { redirect_to @car, notice: 'The car has been reserved during this time period.'; return }
            format.json { head :no_content }
          end
        end
      end
      #  reservation is valid
      if start_time < @records.minimum(:start)
        @car.update_attribute(:customer_id, "#{@customer.id}")
      end
    else
      @car.update_status($reserved)
      @car.update_attribute(:customer_id, "#{@customer.id}")
    end
    record = Record.create(customer_id: @customer.id,
                           car_id: @car.id,
                           start: start_time,
                           end: end_time,
                           hours: hours,
                           status: $reserved)
    @customer.update_status($reserved)
    @customer.update_car_id(@car.id)
    @customer.update_record_id(record.id)
    ########################################
    #  Timer

      elasticity = record.start + 30.minute
          #elasticity = record.start + 20.second
      job_id = $scheduler.at elasticity.to_s do
        record = Record.find_by(id: @customer.record_id)
        record.update_status($cancelled)
        record.update_hours("0")
        @customer.update_status($returned)
        @customer.update_record_id(nil)
          @customer.update_car_id(nil)
        @customer.update_attribute(:job_id, "")

        findNext @car, @customer
      end
      @customer.update_attribute(:job_id, "#{job_id}")
    ########################################
    respond_to do |format|
      format.html { redirect_to @car, notice: 'Car was successfully reserved.'; return }
      format.json { head :no_content }
    end

  end

  def beforecheckout
    subject = if current_authority == $customer
                'you have '
              else
                'this customer has '
              end
    if @customer.status == $checkedout
      respond_to do |format|
        format.html { redirect_to @car, notice: 'Failed, ' + subject  + 'checked out another car!'; return }
        format.json { head :no_content }
      end
    elsif @customer.status == $reserved
      if @customer.car_id == @car.id
        if @car.customer_id != @customer.id  # check this car belongs to whom
          respond_to do |format|
            format.html { redirect_to @car, notice: 'Failed, ' + subject  + 'reserved in another time '; return }
            format.json { head :no_content }
          end
          else
            record = Record.find_by(id: @customer.record_id)
            if record.start > Time.zone.now
              respond_to do |format|
                format.html { redirect_to @car, notice: 'Failed, ' + subject  + 'to wait until your appointment time '; return }
                format.json { head :no_content }
              end
            else
              unless $scheduler.job(@customer.job_id).nil?
                $scheduler.job(@customer.job_id).unschedule
              end
              record.update_status($checkedout)
              checkout(@car,@customer,record)
            end
        end
      else
        respond_to do |format|
          format.html { redirect_to @car, notice: 'Failed, ' + subject  + 'reserved another car '; return }
          format.json { head :no_content }
        end
      end
    elsif @car.status == $reserved
            respond_to do |format|
              format.html { redirect_to @car, notice: 'Failed, ' + subject + 'not reserved this car'; return }
              format.json { head :no_content }
            end
    else
      record = Record.create(customer_id: @customer.id,
                             car_id: @car.id,
                             start: Time.zone.now,
                             hours: params[:h].to_i,
                             status: $checkedout)

      endtime = record.start + record.hours.hour
      record.update_end(endtime)
      @car.update_attribute(:customer_id, "#{@customer.id}")
      @customer.update_record_id(record.id)
      @customer.update_car_id(@car.id)
      checkout(@car,@customer,record)
    end
  end

  def checkout car, customer, record
    customer.update_status($checkedout)
    car.update_status($checkedout)
########################################
#  Open Timer （call return method）  endtime  change to available
        #tmp = record.start +  40.second  #  should comment
       # job_id= $scheduler.at tmp.to_s do
      job_id= $scheduler.at record.end do
          record.update_status($returned)
          CustomerMailer.return_email(customer, car).deliver_now
          charge = customer.charge + car.rate * record.hours

          customer.update_status($returned)
          customer.update_attribute(:car_id, "")
          customer.update_attribute(:record_id,"")
          customer.update_charge(charge)
          customer.update_attribute(:job_id, "")

          findNext car, customer
      end
      customer.update_attribute(:job_id, "#{job_id}")
########################################
    respond_to do |format|
      format.html { redirect_to car, notice: 'Car was successfully checked out.'; return }
      format.json { head :no_content }
    end
  end

  def return
    subject = if current_authority == $customer
                'you '
              else
                'this customer '
              end
    if  @car.customer_id != @customer.id
      respond_to do |format|
        format.html { redirect_to(@car, notice: 'Failed, ' + subject + 'didn\'t check out this car.'); return }
        format.json { head :no_content }
      end
    end

        unless $scheduler.job(@customer.job_id).nil?
          $scheduler.job(@customer.job_id).unschedule
        end

        record = Record.find_by(id: @customer.record_id)
        end_time = Time.zone.now
        hours = ((end_time - record.start) / 1.hour).ceil
        charge = @customer.charge + @car.rate * hours

        record.update_end(end_time)
        record.update_hours(hours)
        record.update_status($returned)

        @customer.update_status($returned)
        @customer.update_attribute(:job_id, "")
        @customer.update_attribute(:car_id, "")
        @customer.update_attribute(:record_id,"")
        @customer.update_charge(charge)

        findNext @car, @customer

        respond_to do |format|
          format.html { redirect_to(@car, notice: 'Car was successfully returned.'); return }
          format.json { head :no_content }
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
      unless $scheduler.job(@customer.job_id).nil?
        $scheduler.job(@customer.job_id).unschedule
      end


      record = Record.find_by(id: @customer.record_id)
      record.update_status($cancelled)
      record.update_hours("0")

      @customer.update_status($returned)
      @customer.update_record_id(nil)
      @customer.update_car_id(nil)
      @customer.update_attribute(:job_id, "")

      findNext @car, @customer

      redirect_to(@car, notice: 'Reservation has been successfully cancelled.' ); return
    end
  end

  # POST /cars
  # POST /cars.json
  def create
    if current_authority == $customer
       params[:car][:status] =  $suggested
      str = "suggested."
    else
       params[:car][:status] =  $available
      str = "created."
    end
    @car = Car.new(car_params)
    respond_to do |format|
      if @car.save
        if current_authority == $customer
          @car.update(customer_id: current_user.id)
          current_user.update_car_id(@car.id)
        end
        format.html do
          redirect_to @car, notice: "Car was successfully "+ str
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
      unless $scheduler.job(customer.job_id).nil?
        $scheduler.job(customer.job_id).unschedule
        customer.update_attribute(:job_id, "")
      end
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
    return unless @car.status == $suggested
    set_car
    back_to_place unless
        current_authority == $customer &&
        @car.customer_id == current_user.id
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
