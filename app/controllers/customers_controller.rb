class CustomersController < ApplicationController
  before_action :set_customer, except: [:index, :new, :create]
  before_action :set_car, only: [:reserve, :return, :checkout, :show_car]
  # GET /customers
  # GET /customers.json
  def index
    @customers = Customer.all
  end
  def search
    #  set_customer if @customer.nil?
    q = params[:q]
    if q.nil? || q.blank?
      @cars = Car.all
    else
      w = params[:w]
      @cars = Car.where("lower(#{w}) = ?", q.downcase)
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
  end

  def show_car
    #@car = Car.find(params[:id])
    #@customer = @@customer
  end

  def myhistory
    @records = @customer.records
  end
  # GET /customers/new
  def new
    @customer = Customer.new
  end

  def checkout
    @car.update(status: 'Checked out')

    arecord = Record.new()
    arecord.customer= @@customer
    arecord.car = @car
    now = Time.current
    arecord.save
    @@customer.update_attribute(:recordid, "#{arecord.id}")
    arecord.update_attribute(:start, "#{now}")

    endtime = now +  params[:h].to_i.hour
########################################
#  Open Timer （call return method）  endtime  change to available

########################################
    respond_to do |format|
      format.html { redirect_to showcar_customer_customer_path(@car), notice: 'Car was successfully checked out.' }
      format.json { head :no_content }
    end
  end

  def return
    @car.update(status: 'Available')
    now = Time.current
    @record = Record.find(@@customer.recordid)
    @record.update_attribute(:end, "#{now}")
    hours = ((@record.end - @record.start) / 1.hour).ceil
    @record.update_attribute(:hours, "#{hours}")
    sum = 0
    @@customer.records.each do |record|
      unless record.hours.nil?
        sum = record.hours * @car.rate
      end
    end
    @@customer.update_attribute(:charge, "#{sum}")#delete current Record
    @@customer.update_attribute(:recordid, "")#delete current Record

    # End Timer


    respond_to do |format|
      format.html { redirect_to showcar_customer_customer_path(@car), notice: 'Car was successfully returned.' }
      format.json { head :no_content }
    end
  end

  def reserve
    require "date"
    starttime = DateTime.new(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i, params[:start_date][:hour].to_i, params[:start_date][:minute].to_i,59,'-4')

    if starttime  < Time.now || starttime > Time.now + 7.days
      respond_to do |format|
        format.html { redirect_to showcar_customer_customer_path(@car), notice: 'Start Time is not valid.' }
        format.json { head :no_content }
      end
    else
      @car.update(status: 'Reserved')
      @@customer.update_attribute(:recordid, "#{-1 - @car.id}")
      ########################################
      #  定时任务  endtime  change to available,
      # 借车 中断定时
      ########################################
      respond_to do |format|
        format.html { redirect_to showcar_customer_customer_path(@car), notice: 'Car was successfully reserved.' }
        format.json { head :no_content }
      end
    end

  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)
    @customer.charge = 0
    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to all_customers_admin_url($admin.id), notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    # if @customer.nil?
    unless params[:id]==nil
      @customer = Customer.find(params[:id])
    else
      @customer = Customer.find(params[:id_customer])
    end
    #@@customer = @customer
    #end
  end

  def set_car
    unless params[:id]==nil
      @car = Car.find(params[:id])
    else
      @car = Car.find(params[:id_car])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def customer_params
    params.require(:customer).permit(:name, :email, :password, :password_confirmation, :charge, :recordid)
  end
end