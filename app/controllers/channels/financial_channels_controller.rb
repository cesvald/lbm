class Channels::FinancialChannelsController < Channels::BaseController
    [:open_applying, :close_applying, :announce].each do |name|
        define_method name do
            @financial_channel = FinancialChannel.find params[:id]
            @financial_channel.send("#{name.to_s}!")
            redirect_to :back
        end
    end
end