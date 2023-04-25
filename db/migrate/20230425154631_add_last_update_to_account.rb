class AddLastUpdateToAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :last_update, :integer
  end
end
