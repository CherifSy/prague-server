class ChargeAmountIsInteger < ActiveRecord::Migration[4.2]
  def up
    connection.execute(%q{
    alter table charges
    alter column amount
    type integer using cast(amount as integer)
  })
  end

  def down
    change_column(:charges, :amount, :string)
  end
end
