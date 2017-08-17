class AddTermsLinkToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :terms_link, :text
  end
end
