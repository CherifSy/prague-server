class CreateWebhookEndpoints < ActiveRecord::Migration[4.2]
  def change
    create_table :webhook_endpoints do |t|
      t.integer :organization_id
      t.text :url
      t.string :name
      t.timestamps
    end
  end
end
