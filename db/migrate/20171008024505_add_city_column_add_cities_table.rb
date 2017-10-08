class AddCityColumnAddCitiesTable < ActiveRecord::Migration[5.1]
  def change
    add_column(:macs, :city, :string)

    create_table(:cities) do |t|
      t.column(:city, :string)
      t.column(:state, :string)
      t.column(:link, :string)
    end
  end
end
