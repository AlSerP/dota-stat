class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.integer :steamID32
      t.string :username

      t.timestamps
    end
  end
end
