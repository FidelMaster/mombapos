class OrderAdvancesController < ApplicationController
  before_action :set_order

  # POST /orders/:order_id/advances
  def create
    saved = false

    # Bloqueo pesimista: evita que dos cajeros abonen en paralelo y superen el total.
    @order.with_lock do
      @order_advance = @order.order_advances.build(order_advance_params)
      @order_advance.received_by = current_user
      saved = @order_advance.save
    end

    if saved
      redirect_to order_path(@order), status: :see_other,
                  notice: "Abono de #{helpers.order_money(@order_advance.amount)} registrado. Saldo pendiente: #{helpers.order_money(@order.reload.balance_amount)}."
    else
      @payment_methods = PaymentMethod.order(:id)
      @bank_accounts   = BankAccount.includes(:bank).order(:account_name)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "advance_form",
            partial: "order_advances/form",
            locals: { order: @order, order_advance: @order_advance, payment_methods: @payment_methods,
                      bank_accounts: @bank_accounts, open: true }
          ), status: :unprocessable_entity
        end
        format.html { redirect_to order_path(@order), alert: @order_advance.errors.full_messages.to_sentence }
      end
    end
  end

  # DELETE /orders/:order_id/advances/:id
  def destroy
    advance = @order.order_advances.find(params[:id])

    unless @order.editable?
      return redirect_to order_path(@order), alert: "No se pueden anular abonos de un pedido «#{@order.status_label}».",
                                             status: :see_other
    end

    @order.with_lock { advance.destroy! }
    redirect_to order_path(@order), notice: "Abono anulado. Saldos recalculados.", status: :see_other
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def order_advance_params
    params.require(:order_advance).permit(
      :amount, :payment_method_id, :bank_account_id, :exchange_rate,
      :reference_number, :payment_date, :notes
    )
  end
end
