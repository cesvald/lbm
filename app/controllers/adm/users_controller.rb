# -*- encoding : utf-8 -*-
class Adm::UsersController < Adm::BaseController
  inherit_resources
  menu I18n.t("adm.users.index.menu", locale: :es) => Rails.application.routes.url_helpers.adm_users_path(locale: :es)
  before_filter :set_title
  before_filter :set_totals

  has_scope :by_id, :by_name, :by_email, :by_payer_email, :by_key, :has_credits, :has_credits_difference, only: :index

  def index
    index! do |format|
      format.html
      format.xlsx do
        @users = end_of_association_chain.order_by('coalesce(user_totals.sum, 0) DESC').includes(:user_total)
      end
    end
  end
  
  protected

  def set_totals
    totals = end_of_association_chain.backer_totals
    @total_users = totals[:users].to_i
    @total_backs = totals[:backs]
    @total_backed = totals[:backed]
    @total_credits = totals[:credits]
    @total_credits_used = totals[:credits_used]
  end

  def set_title
    @title = t("adm.users.index.title")
  end

  def collection
    @users ||= end_of_association_chain.order_by(params[:order_by] || 'coalesce(user_totals.sum, 0) DESC').includes(:user_total).page(params[:page])
  end
end

