class AddStatusToDonors < ActiveRecord::Migration[6.0]
  def change
    remove_column :donors, :address
    add_column :donors, :address_street, :string
    add_column :donors, :address_apartment, :string
    add_column :donors, :address_city, :string
    add_column :donors, :address_zip, :string

    add_column :donors, :status, :string
    add_column :donors, :number_of_masks, :integer
    add_column :donors, :mask_condition, :string
    add_column :donors, :region, :string

  end
end
