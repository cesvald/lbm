# -*- encoding : utf-8 -*-
class ChannelDecorator < Draper::Decorator
  decorates :channel
  include Draper::LazyHelpers

  def display_pledged_total
  	number_to_currency source.pledged_total, unit: 'COP', precision: 0, delimiter: '.'
  end
  
  def display_video_thumbnail
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
        if source.video.embed_url
          "#{source.video.embed_url}?title=0&byline=0&portrait=0&autoplay=0"
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
  
end
