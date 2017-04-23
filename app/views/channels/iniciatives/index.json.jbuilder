json.iniciatives @iniciatives do |iniciative|
    json.extract! iniciative, :id, :lat, :lng, :department, :average_age, :benefited_count, :blog_url, :contact_email, :contact_name, :contact_phone, :description, :facebook_url, :municipality, :name, :other_municipality, :participants_count, :video_url, :web_url, :women_count, :year
    json.zone t("formtastic.options.iniciative.#{iniciative.zone}")
    json.activities iniciative.activities.html_safe
    json.category iniciative.category.name_es
    json.main_image iniciative.main_image.url
end