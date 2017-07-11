# -*- encoding : utf-8 -*-
class Engines::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:notifications]
  skip_before_filter :detect_locale, :only => [:notifications]
  skip_before_filter :set_locale, :only => [:notifications]
  skip_before_filter :force_http
end
