class AddDepartmentIdOnCustomer < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :department_id, :bigint
    add_index :customers, :department_id
    add_foreign_key :customers, :departments
  end
end
