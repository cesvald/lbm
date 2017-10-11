# -*- encoding : utf-8 -*-

class ProjectDecorator < Draper::Decorator
  decorates :project
  include Draper::LazyHelpers

  def remaining_days
    source.time_to_go[:time]
  end

  def display_status
    if source.online?
      (source.reached_goal? ? 'reached_goal' : (source.reached_partial_goal? ? 'reached_partial_goal' : 'not_reached_goal'))
    else
      source.state
    end
  end

  # Method for width of progress bars only
  def display_progress
    return 100 if source.successful? || source.progress > 100
    return 8 if source.progress > 0 and source.progress < 8
    source.progress
  end

  def display_image(version = 'project_thumb' )
    if source.image.present?
      source.image.send(version).url
    elsif source.uploaded_image.present?
      source.uploaded_image.send(version).url
    elsif source.video_thumbnail.url.present?
      source.video_thumbnail.send(version).url
    elsif source.video
      source.video.thumbnail_large
    else
      image_path("project.png")
    end
  end

  def display_mark
    image_tag "lbm/mark_#{source.state}_#{I18n.locale}.png", class: "mark"
  end

  def display_icon_category
    embedded_svg "lbm/#{source.category.icon_text}.svg"
  end

  def display_video_thumbnail(version = 'project_picture')
    if source.video.present?
      if source.video.instance_of? VideoInfo::Providers::Vimeo
        source.video.thumbnail_large
      elsif source.video.instance_of? VideoInfo::Providers::Youtube
        if source.video_url[/youtu\.be\/([^\?]*)/]
          youtube_id = $1
        else
          source.video_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
          youtube_id = $5
        end
        "http://img.youtube.com/vi/#{ youtube_id }/sddefault.jpg"
      end
    end
  end

  def display_video_embed_url
    if source.video.present?
      if source.video.instance_of? VideoInfo::Providers::Vimeo
        if source.video_embed_url
          "#{source.video_embed_url}?title=0&byline=0&portrait=0&autoplay=0"
        end
      elsif source.video.instance_of? VideoInfo::Providers::Youtube
        if source.video_url[/youtu\.be\/([^\?]*)/]
          youtube_id = $1
        else
          source.video_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
          youtube_id = $5
        end
        "https://www.youtube.com/embed/#{ youtube_id }"
      end
    end
  end

  def display_expires_at
    source.expires_at ? I18n.l(source.expires_at.to_date) : ''
  end

  def display_pledged
    number_to_currency source.pledged, unit: source.currency, precision: 0, delimiter: '.'
  end

  def display_pledged_platform_discount
    number_to_currency source.pledged_platform_discount, unit: source.currency, precision: 0, delimiter: '.'
  end
  
  def display_earnings
    number_to_currency source.earnings, unit: source.currency, precision: 0, delimiter: '.'
  end
  
  def display_goal
    number_to_currency source.goal, unit: source.currency, precision: 0, delimiter: '.'
  end
  
  def progress_bar
    width = source.progress > 100 ? 100 : source.progress
    content_tag(:div, id: :progress_wrapper) do
      content_tag(:div, nil, id: :progress, style: "width: #{width}%")
    end
  end


  def successful_flag
    return nil unless source.successful?
    
    content_tag(:div, class: [:successful_flag]) do
      image_tag("channels/successful.png")
    end
      
  end
end

