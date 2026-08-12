module MoneyHelper
  def format_money(amount, tenant = nil, currency = nil)
    curr = currency || tenant&.currency

    return amount.to_s unless curr

    formatted = number_with_precision(amount, precision: 2, delimiter: ",")

    "#{curr.symbol} #{formatted}"
  end
end