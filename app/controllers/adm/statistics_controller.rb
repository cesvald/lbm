# -*- encoding : utf-8 -*-
class Adm::StatisticsController < Adm::BaseController
  inherit_resources
  defaults  resource_class: Statistics
  menu I18n.t("adm.statistics.index.menu", locale: :es) => Rails.application.routes.url_helpers.adm_statistics_path(locale: :es)
  actions :index
  
  def index
    params[:currency_id] = 1 if params[:currency_id].nil?
    @currency_code = Currency.find(params[:currency_id]).code
    @projects = Project.by_currency_id(params[:currency_id])
    @projects = @projects.created_on_year(params[:year]) if params[:year].present?
    @backs = Backer.confirmed.by_currency_id(params[:currency_id])
    @backs =  @backs.confirmed_on_year(params[:year]) if params[:year].present?
  end
end