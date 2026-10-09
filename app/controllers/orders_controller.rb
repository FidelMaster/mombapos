class OrdersController < ApplicationController
  PER_PAGE = 25

  before_action :set_order, only: %i[ show edit update destroy transition quotation ]
  before_action :ensure_workflow_editable, only: %i[ edit update ]

  # GET /orders — Pedidos de joyería (vitrina / taller)
  def index
    base = Order.workflow
    @status_counts = base.group(:status).count
    @summary = {
      in_workshop: @status_counts.fetch("in_workshop", 0),
      ready: @status_counts.fetch("ready_for_pickup", 0),
      overdue: base.overdue.count,
      receivable: base.active_workflow.sum(:balance_amount)
    }

    scope = base.includes(:customer)
    scope = scope.where(status: params[:status]) if Order::WORKFLOW_STATUSES.include?(params[:status])
    scope = scope.where(order_kind: params[:kind]) if Order.order_kinds.key?(params[:kind])
    scope = scope.overdue if params[:filter] == "overdue"

    if params[:q].present?
      term = "%#{Order.sanitize_sql_like(params[:q].to_s.strip)}%"
      scope = scope.left_joins(:customer)
                   .where("orders.order_code ILIKE :t OR orders.customer_name ILIKE :t OR customers.name ILIKE :t", t: term)
    end

    scope = if params[:sort] == "promised"
              scope.order(Arel.sql("orders.promised_delivery_date ASC NULLS LAST"), created_at: :desc)
            else
              scope.order(created_at: :desc)
            end

    @total_count = scope.count
    @page        = [params[:page].to_i, 1].max
    @total_pages = [(@total_count / PER_PAGE.to_f).ceil, 1].max
    @orders      = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  # GET /orders/history
  def history
    @active_orders = Order.where(status: :open).order(created_at: :desc)
    @pickup_orders = @active_orders.where(order_type: :pickup)
    @closed_orders = Order.where(status: [:closed, :cancelled]).order(created_at: :desc).limit(50)
  end

  # GET /orders/1
  def show
    respond_to do |format|
      format.html do
        @order_items = @order.order_items.includes(:product, product_variant: { photos_attachments: :blob })
        @order_advances = @order.order_advances.includes(:payment_method, :bank_account, :received_by)
        @order_advance = build_advance
        load_advance_collections
      end
      format.json { render json: @order.as_json(include: { order_items: { include: :product } }) }
      format.pdf  { render_quotation_pdf }
    end
  end

  # GET /orders/1/quotation
  def quotation
    respond_to do |format|
      format.html do
        @order_items = @order.order_items.includes(:product, :product_variant)
        @order_advances = @order.order_advances.includes(:payment_method)
        render :quotation, layout: "pdf"
      end
      format.pdf { render_quotation_pdf }
    end
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.order_type = params[:order_type] if params[:order_type].present?

    # Flujo POS (pickup / delivery)
    return render :new_pickup if @order.pickup? || @order.delivery?

    # Flujo de pedidos de joyería
    @order.order_kind = params[:kind].presence_in(Order.order_kinds.keys) || "custom_order"
    @order.status = "draft"
    @order.order_items.build(quantity: 1)
    load_form_collections
  end

  # GET /orders/1/edit
  def edit
    load_form_collections
  end

  # POST /orders
  def create
    @order = Order.new(order_params)
    @order.tenant_id = Current.tenant.id
    @order.status = requested_workflow_status(default: "draft") if workflow_request?

    respond_to do |format|
      if @order.save
        # Update table status (POS restaurante)
        @order.dining_table.update(status: :occupied) if @order.dining_table

        format.html { redirect_to after_create_path, notice: create_notice }
        format.json { render json: @order.as_json(include: { order_items: { include: :product } }), status: :created }
      else
        format.html do
          load_form_collections
          render :new, status: :unprocessable_entity
        end
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  def update
    @order.assign_attributes(order_params)
    # "Confirmar pedido" desde un borrador → esperando anticipo
    @order.status = "pending_deposit" if @order.draft? && params[:workflow_action] == "confirm"

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Pedido actualizado correctamente.", status: :see_other }
        format.json { render json: @order.as_json(include: { order_items: { include: :product } }), status: :ok }
      else
        format.html do
          load_form_collections
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /orders/1/transition?to=ready_for_pickup
  def transition
    target = params[:to].to_s

    if @order.transition_to(target)
      redirect_to @order, notice: "Pedido #{@order.order_code} ahora está «#{@order.status_label}».", status: :see_other
    else
      redirect_to @order, alert: @order.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # DELETE /orders/1
  def destroy
    if @order.destroy
      redirect_to (@order.workflow? ? orders_url : history_orders_url), notice: "Pedido eliminado.", status: :see_other
    else
      redirect_to @order, alert: "No se puede eliminar: #{@order.errors.full_messages.to_sentence}. Cancélalo en su lugar.",
                          status: :see_other
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  # Los pedidos entregados/cancelados quedan bloqueados. El POS (open) no se ve afectado.
  def ensure_workflow_editable
    return unless @order.workflow?
    return if @order.editable?

    respond_to do |format|
      format.html { redirect_to @order, alert: "Un pedido «#{@order.status_label}» ya no puede modificarse." }
      format.json { render json: { error: "order_locked" }, status: :unprocessable_entity }
    end
  end

  # El formulario de joyería siempre envía order_kind; el POS no.
  def workflow_request?
    params.dig(:order, :order_kind).present?
  end

  def requested_workflow_status(default:)
    params[:workflow_action] == "confirm" ? "pending_deposit" : default
  end

  def after_create_path
    if @order.dining_table
      pos_table_path(@order.dining_table)
    elsif @order.workflow?
      order_path(@order)
    else
      pos_order_path(@order)
    end
  end

  def create_notice
    return "Order was successfully created." unless @order.workflow?

    @order.draft? ? "Cotización #{@order.order_code} guardada como borrador." : "Pedido #{@order.order_code} creado. Registra el anticipo para enviarlo a taller."
  end

  def build_advance
    OrderAdvance.new(
      order: @order,
      amount: @order.balance_amount,
      payment_date: Time.current,
      exchange_rate: current_exchange_rate
    )
  end

  def current_exchange_rate
    ExchangeRate.order(effective_date: :desc, created_at: :desc).first&.rate || 1.0
  end

  def load_form_collections
    @customers = Customer.order(:name)
    @products  = Product.where.not(product_type: Product.product_types[:raw_material]).order(:name)
  end

  def load_advance_collections
    @payment_methods = PaymentMethod.order(:id)
    @bank_accounts   = BankAccount.includes(:bank).order(:account_name)
  end

  def render_quotation_pdf
    @order_items = @order.order_items.includes(:product, :product_variant)
    @order_advances = @order.order_advances.includes(:payment_method)
    clean_code = (@order.order_code.presence || "ORD-#{@order.id}").tr("#", "")
    filename = "Cotizacion_#{clean_code}.pdf"

    render pdf: filename,
           template: "orders/quotation",
           layout: "pdf",
           formats: [:html, :pdf],
           disposition: "inline",
           page_size: "Letter",
           orientation: "Portrait",
           margin: { top: "12mm", bottom: "12mm", left: "12mm", right: "12mm" },
           encoding: "UTF-8",
           print_media_type: true
  end

  # status / totales / tenant se calculan en servidor: no se aceptan del cliente.
  def order_params
    params.require(:order).permit(
      :order_code, :dining_table_id, :customer_id, :customer_name, :order_type,
      :order_kind, :promised_delivery_date, :workshop_notes,
      order_items_attributes: [
        :id, :product_id, :product_variant_id, :quantity, :unit_price, :subtotal, :notes,
        :engraving_text, :custom_specifications, :_destroy
      ]
    )
  end
end
