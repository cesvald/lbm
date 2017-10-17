# -*- encoding : utf-8 -*-
class Adm::StatisticsController < Adm::BaseController
  inherit_resources
  defaults  resource_class: Statistics
  menu I18n.t("adm.statistics.index.menu", locale: :es) => Rails.application.routes.url_helpers.adm_statistics_path(locale: :es)
  actions :index
  
  def index
    @projects = Project
    @backs = Backer.confirmed
  end
end
