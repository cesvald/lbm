class AddArtSportCaterogyRecords < ActiveRecord::Migration
  def up
    Category.create(name_pt: "Arte y Cultura", name_en: "Art and Culture", name_es: "Arte y Cultura")
    Category.create(name_pt: "Deportes", name_en: "Sports", name_es: "Deportes")
  end

  def down
    Category.where(name_pt: "Arte y Cultura").destroy_all
    Category.where(name_pt: "Deportes").destroy_all
  end
end
