class CreatePaymentMethods < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_methods do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
