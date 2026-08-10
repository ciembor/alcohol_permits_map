class AddSameAsToTransformedLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :transformed_locations, :same_as, :text
  end
end
