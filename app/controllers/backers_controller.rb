class BackersController < ApplicationController
  inherit_resources
  defaults resource_class: Backer, collection_name: 'backs', instance_name: 'back'
  belongs_to :user
  actions :index
  respond_to :json, only: [:index]

  def index
    index! do |format|
      format.json{ return render json: @backs.includes(:user, :reward, project: [:user, :category, :project_total]).to_json({include_project: true, can_manage: (can? :manage, @user)}) }
      format.html{ return render nothing: true, status: 404 }
    end
  end

  def request_refund
    back = Backer.find(params[:id])

    authorize! :request_refund, back
    if back.value > back.user.user_total.credits
      flash[:failure] = I18n.t('credits.index.insufficient_credits')
    elsif can?(:request_refund, back) && back.can_request_refund?
      back.request_refund!
      flash[:notice] = I18n.t('credits.index.refunded')
    end

    redirect_to user_path(parent, anchor: 'credits')
    # render json: {status: status, credits: current_user.reload.display_credits}
  end

  def certificate_request
    @user = User.find(params[:user_id])
    if params[:backer].blank?
      flash[:failure] = I18n.t('users.backs.certify_request.not_backers')
      redirect_to @user
    else
      @backers = Backer.find(params[:backer])
    end
  end

  def confirm_certificate_request
    @user = User.find(params[:user_id])
    if params[:user][:cpf].blank? || params[:user][:full_name].blank? || params[:user][:state_inscription].blank?
      flash[:failure] = I18n.t('users.backs.certify_request.field_mandatory')
      redirect_to action: :certificate_request, params: params
    else
      @user.update_attributes(params[:user])
      if params[:cpf_file].blank? || params[:state_inscription_file].blank?
        flash[:failure] = I18n.t('users.backs.certify_request.file_mandatory')
        redirect_to action: :certificate_request, params: params
      else
        @backers = Backer.find(params[:backer])
        if params[:backer].blank?
          flash[:failure] = I18n.t('users.backs.certify_request.backers_mandatory')
          redirect_to action: :certificate_request, params: params
        else
          BackersMailer.request_certify(@user, @backers, params[:cpf_file], params[:state_inscription_file]).deliver
          flash[:success] = I18n.t('users.backs.certify_request.success')
          redirect_to @user
        end
      end
    end
  end

  protected
  def collection
    @backs = end_of_association_chain.available_to_count.order("confirmed_at DESC")
    @backs = @backs.not_anonymous unless @user == current_user or (current_user and current_user.admin)
    @backs = @backs.page(params[:page]).per(10)
  end
end