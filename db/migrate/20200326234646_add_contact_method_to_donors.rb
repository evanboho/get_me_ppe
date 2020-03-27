class AddContactMethodToDonors < ActiveRecord::Migration[6.0]
  def change
    add_column :donors, :contact_method, :string
  end
end
