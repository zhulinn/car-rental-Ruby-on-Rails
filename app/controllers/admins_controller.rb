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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = Admin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
      params.require(:admin).permit(:name, :email, :password, :password_confirmation)
    end
end
