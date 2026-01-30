class BankAccountsController < ApplicationController
  before_action :set_bank_account, only: %i[ show edit update destroy ]

  def index
    @bank_accounts = BankAccount.joins(:bank).where(banks: { tenant_id: Current.tenant.id })
  end

  def show
  end

  def new
    @bank_account = BankAccount.new
    @banks = Bank.all
  end

  def edit
    @banks = Bank.all
  end

  def create
    @bank_account = BankAccount.new(bank_account_params)
    @bank_account.tenant = Current.tenant

    if @bank_account.save
      redirect_to bank_accounts_path, notice: "Cuenta bancaria creada exitosamente."
    else
      @banks = Bank.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @bank_account.update(bank_account_params)
      redirect_to bank_accounts_path, notice: "Cuenta bancaria actualizada exitosamente."
    else
      @banks = Bank.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bank_account.destroy!
    redirect_to bank_accounts_path, notice: "Cuenta bancaria eliminada exitosamente.", status: :see_other
  end

  private
    def set_bank_account
      @bank_account = BankAccount.find(params[:id])
    end

    def bank_account_params
      params.require(:bank_account).permit(:bank_id, :account_number, :account_name, :currency)
    end
end
