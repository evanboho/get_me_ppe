class AddOnfleetTaskIdToDonors < ActiveRecord::Migration[6.0]
  def change
    add_column :donors, :onfleet_task_id, :string
    add_column :donors, :other_ppe, :string
    add_column :donors, :donor_comments, :string

    add_column :donors, :mask_count, :integer
    add_column :donors, :gloves_count, :integer
    add_column :donors, :other_ppe_count, :integer

    add_column :donors, :timestamp, :string

    add_index :donors, :onfleet_task_id
  end
end
