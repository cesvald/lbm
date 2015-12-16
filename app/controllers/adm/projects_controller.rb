class Adm::ProjectsController < Adm::BaseController
  menu I18n.t("adm.projects.index.menu", locale: :es) => Rails.application.routes.url_helpers.adm_projects_path(locale: :es)

  has_scope :by_id, :pg_search, :user_name_contains, :by_state, :by_channel
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :order_table, default: 'created_at'

  before_filter do
    @total_projects = Project.count
  end

  [:approve, :reject, :push_to_draft].each do |name|
    define_method name do
      @project = Project.find params[:id]
      @project.send("#{name.to_s}!")
      redirect_to :back
    end
  end

  def finish
    @project = Project.find params[:id]
    if @project.online? && (@project.reached_goal? || @project.reached_partial_goal?)
      @project.update_attributes online_days: ((Time.now - @project.online_date).to_i / (24 * 60 * 60) - 1), original_online_days: @project.online_days
      @project.finish
    end
    redirect_to :back
  end

  def index
    index! do |format|
      format.html
      format.xlsx do
        @projects = end_of_association_chain.order("projects.created_at DESC")
      end
    end
  end

  def show_review
    @project = Project.find params[:id]
    render "review"
  end

  def review
    @project = Project.find params[:id]
    if @project.can_review?
      @project.review_comments = params[:review_comments]
      @project.review
      flash[:notice] = t('adm.projects.index.project_reviewed')
    end
    redirect_to adm_projects_path
  end

  def destroy
    @project = Project.find params[:id]
    if @project.can_push_to_trash?
      @project.push_to_trash!
    end

    redirect_to adm_projects_path
  end

  def collection
    @projects = end_of_association_chain.not_deleted_projects.page(params[:page])
  end
end
