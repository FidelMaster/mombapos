class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show]

  def index
    @receipts = Receipt.includes(:customer).order(receipt_date: :desc)
  end

  def show
  end

  def new
    @receipt = Receipt.new(receipt_date: Date.current)
    @customers = Customer.where(is_active: true).order(:name)
    @payment_methods = PaymentMethod.all.order(:name)
  end

  def create
    @receipt = Receipt.new(receipt_params)
    @receipt.tenant = Current.tenant

    if @receipt.save
      redirect_to receipts_path, notice: 'Recibo creado exitosamente.'
    else
      @customers = Customer.where(is_active: true).order(:name)
      @payment_methods = PaymentMethod.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # JSON endpoint to load customer pending accounts
  def customer_accounts
    customer = Customer.find(params[:customer_id])
    # Finding AR documents with pending balance
    accounts = customer.document_account_receivables.map do |ar|
      {
        id: ar.id,
        invoice_number: ar.document_number,
        date: ar.date,
        original_amount: ar.amount,
        balance: ar.balance
      }
    end.select { |acc| acc[:balance] > 0 }

    render json: accounts
  end

  private

  def set_receipt
    @receipt = Receipt.find(params[:id])
  end

  def receipt_params
    params.require(:receipt).permit(:customer_id, :receipt_date, :total_amount, :payment_method, :reference, :document_account_receivable_id)
  end
end
