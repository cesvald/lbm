# -*- encoding : utf-8 -*-
class EmailsController < ApplicationController
  def index
    render text: 'teste', layout: 'email'
  end
end
