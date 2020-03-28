class CreateOnfleetWebhookRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :onfleet_webhook_requests do |t|
      t.text :body

      t.timestamps
    end
  end
end
