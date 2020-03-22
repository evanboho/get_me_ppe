class CreateDonors < ActiveRecord::Migration[6.0]
  def change
    create_table :donors do |t|
      t.string :name
      t.string :address
      t.string :email_address
      t.string :phone_number
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
