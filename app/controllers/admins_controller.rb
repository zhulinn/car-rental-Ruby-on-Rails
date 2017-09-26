class AdminsController < ApplicationController
  #skip_before_action :verify_authenticity_token
  before_action :set_admin, only: [:show, :edit, :update, :destroy]

  # GET /admins
  # GET /admins.json
  def index
    @admins = Admin.all
  end

  # GET /admins/1
  # GET /admins/1.json
  def show
  end

  def show_customer
    @admin=Admin.find(params[:id_admin])
    @customer=Customer.find(params[:id_customer])
  end

  # GET /admins/new
  def new
    @admin = Admin.new
  end

  # GET /admins/1/edit
  def edit
  end

  # POST /admins
  # POST /admins.json
  def create
    @admin = Admin.new(admin_params)

    respond_to do |format|
      if @admin.save
        format.html { redirect_to @admin, notice: 'Admin was successfully created.' }
        format.json { render :show, status: :created, location: @admin }
      else
        format.html { render :new }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admins/1
  # PATCH/PUT /admins/1.json
  def update
    respond_to do |format|
      if @admin.update(admin_params)
        format.html { redirect_to @admin, notice: 'Admin was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin }
      else
        format.html { render :edit }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    @admin.destroy
    respond_to do |format|
      format.html { redirect_to admins_url, notice: 'Admin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def all_customers
    @customers=Customer.all
    @admin=Admin.find(params[:id])
  end

  def edit_customer
    @customer=Customer.find(params[:id_customer])
    @admin=Admin.find(params[:id_admin])
  end

  def update_customer
    @customer=Customer.find(params[:id_customer])
    @admin=Admin.find(params[:id_admin])
    @customer.password_no_deed
    if @customer.update_attributes(params[:customer].permit(:name, :email))
      redirect_to show_admin_customer_url(@admin.id, @customer.id)
    else
      render 'edit_customer'
    end
  ensure
    @customer.password_need
  end

  def destory_customer
    @customer=Customer.find(params[:id_customer])
    @admin=Admin.find(params[:id_admin])
    @customer.destroy
    redirect_to all_customers_admin_path(@admin), notice: 'Customer was successfully destroyed.'
  end

  def search_customer
    #  set_customer if @customer.nil?
    q = params[:q]
    if q.nil? || q.blank?
      @cars = Car.all
    else
      w = params[:w]
      @cars = Car.where("lower(#{w}) = ?", q.downcase)
    end
  end

  def reserve_customer
    @car=Car.find(params[:id_car])
    @customer=Customer.find(params[:id_customer])
    @admin=Admin.find(params[:id_admin])
    require "date"
    starttime = DateTime.new(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i, params[:start_date][:hour].to_i, params[:start_date][:minute].to_i,59,'-4')

    if starttime  < Time.now || starttime > Time.now + 7.days
      respond_to do |format|
        format.html { redirect_to show_admin_customer_car_path, notice: 'Start Time is not valid.' }
        format.json { head :no_content }
      end
    else
      @car.update(status: 'Reserved')
      @customer.update_attribute(:recordid, "#{-1 - @car.id}")
      ########################################
      #  定时任务  endtime  change to available,
      # 借车 中断定时
      ########################################
      respond_to do |format|
        format.html { redirect_to show_admin_customer_car_path, notice: 'Car was successfully reserved.' }
        format.json { head :no_content }
      end
    end
  end

  def checkout_customer
    @car=Car.find(params[:id_car])
    @customer=Customer.find(params[:id_customer])
    @admin=Admin.find(params[:id_admin])
    @car.update(status: 'Checked out')
    arecord = Record.new()
    arecord.customer= @customer
    arecord.car = @car
    now = Time.current
    arecord.save
    @customer.update_attribute(:recordid, "#{arecord.id}")
    arecord.update_attribute(:start, "#{now}")

    endtime = now +  params[:h].to_i.hour
########################################
#  Open Timer （call return method）  endtime  change to available

########################################
    respond_to do |format|
      format.html { redirect_to show_admin_customer_car_path, notice: 'Car was successfully checked out.' }
      format.json { head :no_content }
    end
  end

  def return_customer
    @car=Car.find(params[:id_car])
    @customer=Customer.find(params[:id_customer])
    @admin=Admin.find(params[:id_admin])
    @car.update(status: 'Available')
    now = Time.current
    @record = Record.find(@customer.recordid)
    @record.update_attribute(:end, "#{now}")
    hours = ((@record.end - @record.start) / 1.hour).ceil
    @record.update_attribute(:hours, "#{hours}")
    sum = 0
    @customer.records.each do |record|
      unless record.hours.nil?
        sum = record.hours * @car.rate
      end
    end
    @customer.update_attribute(:charge, "#{sum}")#delete current Record
    @customer.update_attribute(:recordid, "")#delete current Record

    # End Timer


    respond_to do |format|
      format.html { redirect_to show_admin_customer_car_path, notice: 'Car was successfully returned.' }
      format.json { head :no_content }
    end
  end

  def show_car_customer
    @car = Car.find(params[:id_car])
    @customer = Customer.find(params[:id_customer])
    @admin=Admin.find(params[:id_admin])
  end

  def history_customer
    @admin=Admin.find(params[:id_admin])
    @customer=Customer.find(params[:id_customer])
    @records = @customer.records
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = Admin.find(params[:id])
      @@admin=@admin
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
      params.require(:admin).permit(:name, :email, :password, :password_confirmation)
    end
end
