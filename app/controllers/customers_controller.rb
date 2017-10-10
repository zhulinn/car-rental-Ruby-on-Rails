class CustomersController < ApplicationController
  before_action :set_customer, except: %i[index new create]
  before_action :back_if_not_logged_in, except: %i[new create destroy]
  before_action :back_if_customer, only: %i[index new create]
  before_action :back_if_not_self_customer, only: %i[show edit update]
  # GET /customers
  # GET /customers.json
  def index
    if !logged_in?
      redirect_to login_url
    elsif current_authority == $customer
      redirect_to customer_url(current_user)
    end
    @customers = Customer.all
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    if logged_in?
      if current_authority=="Customer"
        redirect_to customer_url(current_user)
      elsif current_authority=="Admin"
        redirect_to admin_url(current_user)
      else
        redirect_to super_admin_url(current_user)
      end
    end
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  # POST /customers.json
  def create
    unless Admin.find_by(email: params[:customer][:email]).nil? && SuperAdmin.find_by(email: params[:customer][:email]).nil?
      redirect_to new_customer_url
      return
    end
    @customer = Customer.new(customer_params)
    @customer.charge = 0
    @customer.status = $returned
    respond_to do |format|
      if @customer.save
        log_in @customer, $customer
        #CustomerMailer.available_email(@customer).deliver_now
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
    customer_params[:email].downcase!
    @customer.password_no_deed if current_authority != $customer
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  ensure
    @customer.password_need
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    # Update status of the car relative to this customer to 'Available'.
    unless @customer.car_id.nil?
    car = Car.find_by(id: @customer.car_id)
    car.update_status($available)
    car.update_attribute(:customer_id, "")
    end
   
    unless  $scheduler.job(@customer.job_id).nil?
      $scheduler.job(@customer.job_id).unschedule
    end
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = Customer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def customer_params
    params.require(:customer).permit(:name, :email, :password, :password_confirmation, :charge, :record_id)
  end
end
