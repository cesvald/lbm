class Channels::FinancialChannelsController < Channels::BaseController
    [:close_summoning, :close_applying, :announce].each do |name|
        define_method name do
            @financial_channel = FinancialChannel.find params[:id]
            @financial_channel.send("#{name.to_s}!")
            redirect_to :back
        end
    end
end