module OrdersHelper
  STATUS_STYLES = {
    "draft"            => { badge: "bg-slate-100 text-slate-600 ring-slate-200",       dot: "bg-slate-400" },
    "pending_deposit"  => { badge: "bg-amber-50 text-amber-700 ring-amber-200",        dot: "bg-amber-500" },
    "in_workshop"      => { badge: "bg-violet-50 text-violet-700 ring-violet-200",     dot: "bg-violet-500" },
    "ready_for_pickup" => { badge: "bg-sky-50 text-sky-700 ring-sky-200",              dot: "bg-sky-500" },
    "completed"        => { badge: "bg-emerald-50 text-emerald-700 ring-emerald-200",  dot: "bg-emerald-500" },
    "cancelled"        => { badge: "bg-rose-50 text-rose-700 ring-rose-200",           dot: "bg-rose-500" },
    "open"             => { badge: "bg-orange-50 text-orange-700 ring-orange-200",     dot: "bg-orange-500" },
    "closed"           => { badge: "bg-emerald-50 text-emerald-700 ring-emerald-200",  dot: "bg-emerald-500" }
  }.freeze

  # Acciones de cambio de fase: etiqueta, estilo y si requieren confirmación.
  TRANSITION_ACTIONS = {
    "pending_deposit"  => { label: "Confirmar pedido",          icon: "✓", style: :primary },
    "in_workshop"      => { label: "Enviar a taller",           icon: "⚒", style: :primary },
    "ready_for_pickup" => { label: "Marcar listo para entrega", icon: "◆", style: :primary },
    "completed"        => { label: "Entregar al cliente",       icon: "✓", style: :success },
    "draft"            => { label: "Regresar a borrador",       icon: "↺", style: :ghost },
    "cancelled"        => { label: "Cancelar pedido",           icon: "✕", style: :danger,
                            confirm: "¿Cancelar este pedido? Esta acción no se puede deshacer." }
  }.freeze

  WORKFLOW_STEPS = %w[draft pending_deposit in_workshop ready_for_pickup completed].freeze

  def order_money(amount)
    symbol = current_tenant&.currency&.symbol.presence || "C$"
    number_to_currency(amount.to_d, unit: symbol, format: "%u %n", precision: 2, delimiter: ",", separator: ".")
  end

  def order_currency_symbol
    current_tenant&.currency&.symbol.presence || "C$"
  end

  def order_status_badge(status, size: :md)
    style = STATUS_STYLES.fetch(status.to_s, STATUS_STYLES["draft"])
    sizing = size == :lg ? "px-3.5 py-1.5 text-xs" : "px-2.5 py-1 text-[11px]"

    content_tag(:span, class: "inline-flex items-center gap-1.5 rounded-full font-bold ring-1 ring-inset whitespace-nowrap #{sizing} #{style[:badge]}") do
      safe_join([content_tag(:span, "", class: "h-1.5 w-1.5 rounded-full #{style[:dot]}"), Order.status_label(status)])
    end
  end

  def order_kind_badge(kind)
    if kind.to_s == "custom_order"
      content_tag(:span, "⚒ Taller", class: "inline-flex items-center gap-1 rounded-lg bg-gradient-to-r from-amber-100 to-yellow-50 px-2 py-1 text-[11px] font-bold text-amber-800 ring-1 ring-inset ring-amber-200")
    else
      content_tag(:span, "◇ Vitrina", class: "inline-flex items-center gap-1 rounded-lg bg-slate-50 px-2 py-1 text-[11px] font-bold text-slate-600 ring-1 ring-inset ring-slate-200")
    end
  end

  def transition_button_classes(style)
    base = "inline-flex w-full items-center justify-center gap-2 rounded-2xl px-4 py-3 text-sm font-black transition-all active:scale-[0.98] cursor-pointer"
    variant = case style
              when :primary then "bg-slate-900 text-white shadow-lg shadow-slate-900/20 hover:bg-slate-800"
              when :success then "bg-emerald-600 text-white shadow-lg shadow-emerald-600/20 hover:bg-emerald-700"
              when :danger  then "bg-white text-rose-600 ring-1 ring-inset ring-rose-200 hover:bg-rose-50"
              else               "bg-white text-slate-600 ring-1 ring-inset ring-slate-200 hover:bg-slate-50"
              end
    "#{base} #{variant}"
  end

  def order_step_state(order, step)
    return :cancelled if order.cancelled?

    current = WORKFLOW_STEPS.index(order.status) || 0
    index   = WORKFLOW_STEPS.index(step)
    return :done if index < current || order.completed?
    return :current if index == current

    :pending
  end

  def order_filter_link(label, status:, count: nil)
    active = params[:status].to_s == status.to_s && params[:filter].blank?
    classes = if active
                "bg-slate-900 text-white shadow-md shadow-slate-900/10"
              else
                "bg-white text-slate-600 ring-1 ring-inset ring-slate-200 hover:ring-slate-300 hover:text-slate-900"
              end

    link_to orders_path(request.query_parameters.except("page", "filter").merge("status" => status.presence).compact),
            class: "inline-flex items-center gap-2 rounded-full px-4 py-2 text-xs font-bold transition-all #{classes}" do
      safe_join([label, (content_tag(:span, count, class: "rounded-full px-1.5 py-0.5 text-[10px] #{active ? 'bg-white/20' : 'bg-slate-100'}") if count)].compact)
    end
  end

  def promised_date_label(order)
    return content_tag(:span, "—", class: "text-slate-300") if order.promised_delivery_date.blank?

    date = order.promised_delivery_date
    days = (date - Date.current).to_i
    text = date.strftime("%d/%m/%Y")

    if order.overdue?
      content_tag(:span, class: "inline-flex flex-col") do
        safe_join([content_tag(:span, text, class: "font-bold text-rose-600"),
                   content_tag(:span, "Vencido hace #{-days} d", class: "text-[10px] font-bold uppercase tracking-wide text-rose-400")])
      end
    elsif order.editable? && days <= 3
      content_tag(:span, class: "inline-flex flex-col") do
        safe_join([content_tag(:span, text, class: "font-bold text-amber-600"),
                   content_tag(:span, days.zero? ? "Hoy" : "En #{days} d", class: "text-[10px] font-bold uppercase tracking-wide text-amber-500")])
      end
    else
      content_tag(:span, text, class: "font-semibold text-slate-700")
    end
  end
end
