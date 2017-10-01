# -*- encoding : utf-8 -*-
class Adm::ProjectsController < Adm::BaseController
  menu I18n.t("adm.projects.index.menu", locale: :es) => Rails.application.routes.url_helpers.adm_projects_path(locale: :es)

  has_scope :by_id, :pg_search, :user_name_contains, :by_state, :by_channel, :by_user_email
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :order_table, default: 'projects.created_at'

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

  def generate_agreement
    @project = Project.find params[:id]
    respond_to do |format|
      format.docx do
        # Initialize DocxReplace with your template
        doc = DocxReplace::Doc.new("#{Rails.root}/lib/docx_templates/acuerdo_template.docx", "#{Rails.root}/tmp")
  
        # Replace some variables. $var$ convention is used here, but not required.
        doc.replace("FULLNAME", @project.user.allowed_name, true)
        doc.replace("USERCC", @project.user.cpf, true)
        doc.replace("project", @project.name, true)
        doc.replace("AMOUNT", @project.display_pledged, true)
        doc.replace("PERCENT", @project.progress, true)
        doc.replace("FINALPLEDGE", @project.display_earnings, true)
        doc.replace("DISCOUNT", @project.display_pledged_platform_discount, true)
        doc.replace("PROJECTSTATE", (@project.successful? ? "totalmente exitoso" : "parcialmente exitoso"))
        doc.replace("SIGNDATE", l(Date.today, format: "%d días del mes de %B del %Y"))
        
        doc.replace("SUBMITDATE", l(Date.today, format: "%d de %B de %Y"), true)
        doc.replace("PROJECTID", @project.id, true)
        doc.replace("NUMBACKERS", @project.total_backers, true)
        doc.replace("CITY", "#{@project.user.address_city.camelcase unless @project.user.address_city.nil?}", true)
        
        # Write the document back to a temporary file
        tmp_file = Tempfile.new('word_tempate', "#{Rails.root}/tmp")
        doc.commit(tmp_file.path)
  
        # Respond to the request by sending the temp file
        send_file tmp_file.path, filename: "Acuerdo #{@project.name}.docx", disposition: 'attachment'
      end
    end
  end
  
  def collection
    @projects = end_of_association_chain.not_deleted_projects.page(params[:page])
  end
end
