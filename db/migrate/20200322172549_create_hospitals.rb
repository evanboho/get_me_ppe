class CreateHospitals < ActiveRecord::Migration[6.0]
  def change
    create_table :hospitals do |t|
      t.string  :organization
      t.string  :address
      t.string  :contact_name
      t.string  :contact_email
      t.string  :contact_phone
      t.boolean :respirators
      t.boolean :gowns
      t.boolean :goggles
      t.boolean :gloves
      t.boolean :sanitzer
      t.boolean :sample_collection_products
      t.boolean :hand_sewn_masks
      t.boolean :accepts_opened_ppe
      t.float   :latitude
      t.float   :longitude

      t.timestamps
    end
  end
end
