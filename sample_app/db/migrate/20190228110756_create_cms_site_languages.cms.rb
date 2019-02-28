# This migration comes from cms (originally 20121128132941)
class CreateCmsSiteLanguages < ActiveRecord::Migration
  def change
    create_table :cms_site_languages do |t|
      t.string :name, :null => false, :uniq => true
      t.string :url, :null => false, :uniq => true

      t.timestamps
    end
  end

end
