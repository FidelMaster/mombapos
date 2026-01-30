class ReportsController < ApplicationController
  def sales_summary
    @date_from = params[:date_from].presence || Date.current.beginning_of_day
    @date_to = params[:date_to].presence || Date.current.end_of_day

    @invoices = Invoice.issued.where(created_at: @date_from..@date_to)
    
    @total_count = @invoices.count
    @subtotal_sum = @invoices.sum(:subtotal_amount)
    @total_sum = @invoices.sum(:total_local_amount)
    
    # Optional: Group by day if the range is large
  end

  def payment_methods
    @date_from = params[:date_from].presence || Date.current.beginning_of_day
    @date_to = params[:date_to].presence || Date.current.end_of_day

    @payments = InvoicePayment.joins(:invoice, :payment_method)
                              .left_joins(bank_account: :bank)
                              .where(invoices: { status: :issued, created_at: @date_from..@date_to })
                              .group("payment_methods.name", "invoice_payments.currency","bank_accounts.account_number", "bank_accounts.account_name", "banks.name")
                              .select(
                                "payment_methods.name as method_name", 
                                "invoice_payments.currency as currency", 
                                "concat(banks.name, ' - ', bank_accounts.account_name, ' (', bank_accounts.account_number, ')') as bank_account_name",
                                "count(*) as payment_count", 
                                "sum(invoice_payments.amount) as total_amount"
                              ).order("payment_methods.name ASC", "invoice_payments.currency ASC")
    
    @totals_by_currency = @payments.group_by(&:currency).transform_values { |p| p.sum(&:total_amount) }
  end

  def inventory_impact
    @date_from = params[:date_from].presence || Date.current.beginning_of_day
    @date_to = params[:date_to].presence || Date.current.end_of_day

    # Sales by Product (Including Kits)
    @detailed_sales = InvoiceItem.joins(:invoice, :product)
                                 .where(invoices: { status: :issued, created_at: @date_from..@date_to })
                                 .group("products.id", "products.name", "products.product_type")
                                 .select(
                                   "products.id as product_id",
                                   "products.name as product_name",
                                   "products.product_type as p_type",
                                   "sum(invoice_items.quantity) as total_qty",
                                   "sum(invoice_items.subtotal) as total_rev"
                                 ).order("total_qty DESC")
  end

  def kardex
    @date_from = params[:date_from].presence || Date.current.beginning_of_day
    @date_to = params[:date_to].presence || Date.current.end_of_day
    
    @product_id = params[:product_id]
    @warehouse_id = params[:warehouse_id]

    @movements = StockMovement.includes(:product, :warehouse)
                              .where(created_at: @date_from..@date_to)
    
    @movements = @movements.where(product_id: @product_id) if @product_id.present?
    @movements = @movements.where(warehouse_id: @warehouse_id) if @warehouse_id.present?
    
    @movements = @movements.order(created_at: :desc)

    @products = Product.all.order(:name)
    @warehouses = Warehouse.all.order(:name)
  end
end
