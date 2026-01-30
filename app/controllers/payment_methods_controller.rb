class PaymentMethodsController < ApplicationController
  before_action :set_payment_method, only: %i[ show edit update destroy ]

  # GET /payment_methods
  def index
    @payment_methods = PaymentMethod.all
  end

  # GET /payment_methods/1
  def show
  end

  # GET /payment_methods/new
  def new
    @payment_method = PaymentMethod.new
  end

  # GET /payment_methods/1/edit
  def edit
  end

  # POST /payment_methods
  def create
    @payment_method = PaymentMethod.new(payment_method_params)

    if @payment_method.save
      redirect_to @payment_method, notice: "Payment method was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payment_methods/1
  def update
    if @payment_method.update(payment_method_params)
      redirect_to @payment_method, notice: "Payment method was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /payment_methods/1
  def destroy
    @payment_method.destroy!
    redirect_to payment_methods_url, notice: "Payment method was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_method
      @payment_method = PaymentMethod.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_method_params
      params.require(:payment_method).permit(:code, :name)
    end
end
