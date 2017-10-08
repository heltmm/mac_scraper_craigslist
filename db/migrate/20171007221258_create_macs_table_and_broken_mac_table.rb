class CreateMacsTableAndBrokenMacTable < ActiveRecord::Migration[5.1]
  def change
    create_table(:macs) do |t|
      t.column(:link, :string)
      t.column(:condition, :string)
      t.column(:date_posted, :date)
      t.column(:model, :string)
      t.column(:price, :integer)
      t.column(:description, :string)
      t.column(:title, :string)
      t.column(:address, :string)
      t.column(:normal, :boolean)
    end
  end
end
