json.iniciatives @iniciatives do |iniciative|
    json.extract! iniciative, :id, :lat, :lng, :department, :average_age, :benefited_count, :blog_url, :contact_email, :contact_name, :contact_phone, :description, :facebook_url, :municipality, :name, :other_municipality, :participants_count, :video_url, :web_url, :women_count, :ethnic_count, :year
    json.zone t("formtastic.options.iniciative.#{iniciative.zone}")
    json.activities iniciative.activities.html_safe
    json.category iniciative.category.to_s
    json.image "/" + iniciative.category.name_es.downcase + ".png"
    json.main_image iniciative.main_image.url
    json.share_twitter "http://twitter.com/?status=#{t('channels.iniciatives.i_share_iniciative', name: iniciative.name, channel: iniciative.financial_channel.channel.name)} #{controller.view_context.root_url(subdomain: iniciative.financial_channel.channel.permalink)}"
    json.share_facebook "http://www.facebook.com/share.php?u=#{controller.view_context.root_url(subdomain: iniciative.financial_channel.channel.permalink)}"
end