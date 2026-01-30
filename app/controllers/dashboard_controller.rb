class DashboardController < ApplicationController
  def index
    # Filters
    @date_from = params[:date_from].presence || Date.current.beginning_of_day
    @date_to = params[:date_to].presence || Date.current.end_of_day

    # Facturación (Daily Consumption)
    @daily_invoices = Invoice.issued.where(created_at: @date_from..@date_to)
    @daily_revenue = @daily_invoices.sum(:total_local_amount)
    
    @total_revenue = Invoice.issued.sum(:total_local_amount)
    @recent_invoices = Invoice.order(created_at: :desc).limit(10)

    # Resumen por Medios de Pago (para Dashboard)
    @payment_methods_summary = InvoicePayment.joins(:invoice, :payment_method)
                                            .where(invoices: { status: :issued, created_at: @date_from..@date_to })
                                            .group("payment_methods.name", "invoice_payments.currency")
                                            .select("payment_methods.name as method_name, invoice_payments.currency as currency, sum(invoice_payments.amount) as total_amount")
                                            .order("total_amount DESC")

    # Inventario
    @total_products = Product.count
    @low_stock_products = Product.joins(:warehouse_stocks)
                                 .where("warehouse_stocks.stock_available <= warehouse_stocks.min_quantity")
                                 .distinct
                                 .limit(10)
    
    # Top Products (by quantity sold)
    @top_products = InvoiceItem.joins(:invoice)
                               .where(invoices: { status: :issued })
                               .group(:product_id)
                               .select("product_id, sum(quantity) as total_qty")
                               .order("total_qty DESC")
                               .limit(5)
  end

  def academic
    # Cursos/Planes (Original Academic Dashboard)
    @total_students = Student.count
    @active_plans = Plan.where(is_active: true).count
    @recent_plans = Plan.order(created_at: :desc).limit(10)
    @active_groups = Group.abierto.count
  end
end

