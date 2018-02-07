class Channels::FinancialProjectsController < Channels::BaseController
    
    def add_vote
    	financial_project = FinancialProject.find(params[:id])
    	if financial_project.already_voted?(current_user)
		    flash[:failure] = 'Ya has realizado este voto, solo puedes votar una vez por proyecto'
    	else
			financial_project.add_vote
			financial_project.votes.build(user: current_user)
			financial_project.save
			flash[:success] = 'Has votado por este proyecto!!'
    	end
    	redirect_to :back
    end

end