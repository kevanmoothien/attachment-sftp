class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.string :sfid
      t.boolean :processed

      t.timestamps
    end
  end
end
