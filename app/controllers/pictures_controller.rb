# -*- encoding : utf-8 -*-
class PicturesController < InheritedResources::Base
	def create
	    create! do |format|
	      format.html{ return redirect_to project_by_slug_path(@picture.project.permalink, anchor: 'pictures') }
	      format.js { render "create"}
	    end
  	end

  	def destroy
  		destroy! do |format|
  			format.html{ return redirect_to project_by_slug_path(@picture.project.permalink, anchor: 'pictures') }
  		end
  	end
end

