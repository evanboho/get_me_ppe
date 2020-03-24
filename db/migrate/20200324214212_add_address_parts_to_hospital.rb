class AddAddressPartsToHospital < ActiveRecord::Migration[6.0]
  def change
    add_column :hospitals, :address_street, :string
    add_column :hospitals, :address_apartment, :string
    add_column :hospitals, :address_city, :string
    add_column :hospitals, :address_zip, :string
    add_column :hospitals, :address_state, :string
    add_column :hospitals, :notes, :string
  end
end
