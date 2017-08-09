class Engines::DepositopygController < Engines::BaseController
    layout :false
    
    SCOPE = "projects.backers.checkout"
    
    def review
        @backer = Backer.find params[:id]
    end
    
    def respond
        backer = Backer.find params[:id]
        backer.update_attribute :payment_method, 'Depósito PYG'
        flash[:success] = 'Genial, te hemos enviado un email con el código de identificación, esperamos pronto saber de tu donación'
        redirect_to project_backer_path(project_id: backer.project.id, id: backer.id)
    end
end