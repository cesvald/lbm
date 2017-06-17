# -*- encoding : utf-8 -*-
class IniciativeObserver < ActiveRecord::Observer
  observe :iniciative
  
  def after_create(iniciative)
    if (user = new_draft_recipient)
        Notification.create_notification_once(
            :new_iniciative
            user,
            {iniciative_id: iniciative.id},
            {project: project, project_name: project.name, from: project.user.email, display_name: project.user.display_name}
        )
    end

    Notification.create_notification_once(
        project.new_project_received_notification_type,
        project.user,
        {project_id: project.id},
        {project: project, project_name: project.name}
    )
  end

  def after_update(project)
    if not project.updated_by.nil? && project.updated_by == project.user && project.reviewed?
      Notification.create_notification(:project_reviewed_changes,
                                        User.where(email:Configuration[:email_projects]).first,
                                        {project: project, project_name: project.name })
    end
  end
  
  def notify_owner_that_project_is_waiting_funds(project)
    Notification.create_notification_once(:project_in_wainting_funds,
      project.user,
      {project_id: project.id},
      project: project)
  end

  def notify_owner_project_review(project)
    Notification.create_notification(:project_review,
      project.user,
      {project: project, review_comments: project.review_comments, from: Configuration[:email_projects]})
  end

  def notify_owner_that_project_is_successful(project)
    Notification.create_notification_once(:project_success,
      project.user,
      {project_id: project.id},
      project: project)
  end

  def notify_admin_that_project_reached_deadline(project)
    if (user = User.where(email: ::Configuration[:email_payments]).first)
      Notification.create_notification_once(:adm_project_deadline,
        user,
        {project_id: project.id},
        project: project,
        from: ::Configuration[:email_system],
        project_name: project.name)
    end
  end

  def notify_owner_that_project_is_rejected(project)
    Notification.create_notification_once(:project_rejected,
      project.user,
      {project_id: project.id},
      project: project)
  end

  def notify_owner_that_project_is_online(project)
    Notification.create_notification_once(:project_visible,
      project.user,
      {project_id: project.id},
      project: project)
  end

  def notify_admin_documents_ready(project)
    if (user = User.where(email: ::Configuration[:"email_projects"]).first)
      Notification.create_notification_once(:adm_documents_ready,
        user,
        {project_id: project.id},
        project: project)
    end
  end

  def notify_users(project)
    project.backers.confirmed.each do |backer|
      unless backer.notified_finish
        Notification.create_notification_once(
          (
            case project.state
            when 'successful'
              :backer_project_successful
            when 'failed'
              :backer_project_unsuccessful
            when 'partial_successful'
              :backer_project_partial_successful
            end
          ),
          backer.user,
          {backer_id: backer.id},
          backer: backer,
          project: project,
          project_name: project.name)
        backer.update_attributes({ notified_finish: true })
      end
    end

    if project.failed?
      project.backers.in_time_to_confirm.each do |backer|
        Notification.create_notification_once(
          :pending_backer_project_unsuccessful,
          backer.user,
          {backer_id: backer.id},
          {backer: backer, project: project, project_name: project.name })
      end
    end
    
    Notification.create_notification_once(
      (
        case project.state
        when 'successful'
          :project_success
        when 'failed'
          :project_unsuccessful
        when 'partial_successful'
          :project_partial_success
        end
      ),
      project.user,
      {project_id: project.id, user_id: project.user.id},
      project: project
    )

    if (user = User.where(email: ::Configuration[:email_payments]).first)
      Notification.create_notification_once(:adm_project_deadline,
        user,
        {project_id: project.id},
        project: project,
        from: ::Configuration[:email_system],
        project_name: project.name)
    end
  end

  def remind_owner_rewards(project)
    Notification.create_notification_once(:reminder_rewards,
        project.user,
        {project_id: project.id, from: Configuration[:email_projects]},
        project: project)
  end

  def remind_owner_rewards_and_impact(project)
    Notification.create_notification_once(:reminder_rewards_and_impact,
        project.user,
        {project_id: project.id, from: Configuration[:email_projects]},
        project: project)
  end

  def sync_with_mailchimp(project)
    begin
      user = project.user
      mailchimp_params = { EMAIL: user.email, FNAME: user.name, CITY: (user.address_city || 'other'), STATE: (user.address_state || 'other') }

      if project.successful?
        CatarseMailchimp::API.subscribe(mailchimp_params, Configuration[:mailchimp_successful_projects_list])
      end

      if project.failed?
        CatarseMailchimp::API.subscribe(mailchimp_params, Configuration[:mailchimp_failed_projects_list])
      end
    rescue Exception => e
      Rails.logger.info "-----> #{e.inspect}"
    end
  end

end