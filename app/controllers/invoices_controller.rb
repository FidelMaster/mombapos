class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show edit update destroy ]

  # GET /invoices
  def index
    @invoices = manage_resource(Invoice.includes(:customer))
  end

  # GET /invoices/1
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
    
    if params[:order_id].present?
      @order = Order.find(params[:order_id])
      @invoice.order = @order
      @invoice.customer = @order.customer
      @invoice.customer_name_snapshot = @order.customer_name
      @invoice.subtotal_amount = @order.total
      @invoice.total_local_amount = @order.total # Assuming no tax for now or calculate it
      
      @order.order_items.each do |item|
        @invoice.invoice_items.build(
          product_id: item.product_id,
          quantity: item.quantity,
          unit_price: item.unit_price,
          total: item.subtotal
        )
      end
    else
      @invoice.invoice_items.build # Start with one item
    end
    
    @invoice.invoice_payments.build(
      amount: @invoice.total_local_amount,
      currency: 'NIO',
      exchange_rate: ExchangeRate.first&.rate || 1.0
    )
    load_form_collections
  end

  # GET /invoices/1/edit
  def edit
    load_form_collections
  end

  # POST /invoices
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.tenant = Current.tenant

    # Fix invoice number generation - extract numeric part only
    last_invoice = Invoice.where(tenant: Current.tenant).order(:id).last
    next_number = if last_invoice && last_invoice.invoice_number.present?
      # Extract number from format like "FAC-00001"
      last_invoice.invoice_number.scan(/\d+/).last.to_i + 1
    else
      1
    end
    
    invoice_number_mask = "FAC-XXXXX"
    @invoice.invoice_number = invoice_number_mask.sub("XXXXX", next_number.to_s.rjust(5, "0"))
    
    # Simple logic to set defaults if not present
    @invoice.status ||= :issued 
    @invoice.branch = Branch.where(tenant: Current.tenant, is_default: true).first || Branch.first
    @invoice.warehouse = Warehouse.where(tenant: Current.tenant, is_default: true).first || Warehouse.first
    
    # Set exchange rate from first exchange rate record
    exchange_rate_record = ExchangeRate.first
    @invoice.exchange_rate = exchange_rate_record&.rate || 1.0
    
    # Calculate total_foreign_amount (total in USD)
    if @invoice.total_local_amount.present? && @invoice.exchange_rate.present? && @invoice.exchange_rate > 0
      @invoice.total_foreign_amount = (@invoice.total_local_amount / @invoice.exchange_rate).round(2)
    end
    
    # Process inventory reduction
    @invoice.invoice_items.each do |invoice_item|
      main_product = Product.find(invoice_item.product_id)
      
      if main_product.kit? && main_product.product_composition.present?
        # If it's a kit, reduce stock for each component
        main_product.product_composition.product_composition_items.each do |comp_item|
          reduce_stock(
            product_id: comp_item.product_id,
            quantity: comp_item.quantity * invoice_item.quantity,
            warehouse_id: @invoice.warehouse_id,
            invoice: @invoice,
            origin_product_id: main_product.id
          )
        end
      else
        # Regular product or kit without composition
        reduce_stock(
          product_id: invoice_item.product_id,
          quantity: invoice_item.quantity,
          warehouse_id: @invoice.warehouse_id,
          invoice: @invoice
        )
      end
    end

    if @invoice.save
      if @invoice.order_id.present?
        @invoice.order.update(status: :closed)
        @invoice.order.dining_table.update(status: :free) if @invoice.order.dining_table.present?
      end
      redirect_to @invoice, notice: "Invoice was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invoices/1
  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Invoice was successfully updated.", status: :see_other
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /invoices/1
  def destroy
    @invoice.destroy!
    redirect_to invoices_url, notice: "Invoice was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end
    
    def load_form_collections
      @customers = Customer.where(is_active: true).order(:name)
      @products = Product.where(is_active: true).where.not(product_type: :raw_material).order(:name)
      @payment_methods = PaymentMethod.all.order(:name)
      @price_lists = PriceList.where(is_active: true).order(:name)
      @exchange_rates = ExchangeRate.first
      @payment_terms = PaymentTerm.all.order(:name)
      #make bank name concat account_number - bank name - account_name
      @bank_accounts = BankAccount.joins(:bank).where(banks: { tenant_id: Current.tenant.id }).order(:account_name)
      
      # Build a map of prices per price list for JS
      # Structure: { price_list_id: { product_id: price } }
      @price_map = {}
      @price_lists.each do |list|
        @price_map[list.id] = PriceListItem.where(price_list_id: list.id).pluck(:product_id, :price).to_h
      end
      
      # Also include base product prices for default fallback
      @price_map[0] = @products.pluck(:id, :price).to_h

      # Default values for new invoice
      if @invoice.new_record?
        @invoice.price_list ||= @price_lists.first
        @invoice.invoice_date ||= Date.current
      end
    end

    def reduce_stock(product_id:, quantity:, warehouse_id:, invoice:, origin_product_id: nil)
      product = Product.find(product_id)
      warehouse_stock = WarehouseStock.find_or_create_by!(product_id: product_id, warehouse_id: warehouse_id)
      
      StockMovement.create!(
        branch_id: invoice.branch_id || Branch.first.id,
        tenant_id: invoice.tenant_id,
        product_id: product_id,
        warehouse_id: warehouse_id,
        movement_type: :sale,
        quantity_before: product.quantity || 0,
        quantity: quantity,
        reference_type: origin_product_id ? "ProductComposition" : "Invoice",
        reference_id: origin_product_id || invoice.id
      )

      # Update warehouse stock
      warehouse_stock.update(stock_available: (warehouse_stock.stock_available || 0) - quantity)
      
      # Update total product quantity if maintained
      product.update(quantity: (product.quantity || 0) - quantity)
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      params.require(:invoice).permit(
        :customer_id, :order_id, :customer_name_snapshot, :invoice_date, :invoice_type, :status, :price_list_id, :payment_term_id,
        :total_items, :subtotal_amount, :tax_amount, :total_local_amount, :notes,
        invoice_items_attributes: [:id, :product_id, :quantity, :unit_price, :total, :_destroy],
        invoice_payments_attributes: [:id, :payment_method_id, :amount, :bank_account_id, :currency, :exchange_rate, :_destroy]
      )
    end
end
