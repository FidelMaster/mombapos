class Invoice < ApplicationRecord
  belongs_to :tenant
  belongs_to :customer
  belongs_to :branch
  belongs_to :warehouse
  belongs_to :price_list, optional: true
  belongs_to :order, optional: true
  belongs_to :payment_term, optional: true
  
  has_many :invoice_items, dependent: :destroy
  has_many :invoice_payments, dependent: :destroy
  
  accepts_nested_attributes_for :invoice_items, allow_destroy: true
  accepts_nested_attributes_for :invoice_payments, allow_destroy: true

  enum invoice_type: {
    cash: "Contado",
    credit: "Crédito"
  }

  enum status: {
    draft: "Borrador",
    issued: "Emitida",
    annulled: "Anulada"
  }

  after_create :create_receivable_account, if: :credit?

  def status_color
    case status
    when 'issued', 'Emitida' then 'green'
    when 'draft', 'Borrador' then 'slate'
    when 'annulled', 'Anulada' then 'red'
    else 'gray'
    end
  end

  attr_accessor :amount_tendered
  
  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true

  before_validation :calculate_due_date

  def calculate_due_date 
    return unless payment_term && (invoice_date || Date.current)
    self.due_date ||= (invoice_date || Date.current) + (payment_term.total || 0).days
  end

  private

  def create_receivable_account
    ar = DocumentAccountReceivable.create!(
      tenant: tenant,
      customer: customer,
      payment_term: payment_term,
      document: self,
      date: invoice_date,
      amount: total_local_amount,
      exchange_rate: exchange_rate
    )

    ar.document_account_receivable_details.create!(
      document_type: :invoice,
      document_id: id,
      movement_type: :debit,
      amount: total_local_amount,
      date: invoice_date
    )
  end
end
