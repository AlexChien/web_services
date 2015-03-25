class CreatePlsAccounts < ActiveRecord::Migration
  def change

    create_table :pls_accounts do |t|
      t.references :user, index: true
      t.string :name
      t.string :key
      t.string :referrer
      t.string :ogid
      t.timestamps
    end

    add_index :pls_accounts, [:name], unique: true
    add_index :pls_accounts, [:key], unique: true
    add_index :pls_accounts, [:ogid], unique: true

  end
end
