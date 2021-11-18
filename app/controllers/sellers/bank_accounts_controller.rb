class Sellers::BankAccountsController < Sellers::BaseController

  # def bank_details
  #   @bank_account = "123123123123"
  #   # @address = current_provider.address
  #   # @bank_account = @bank_account || current_provider.build_bank_account
  #   # @address = @address || current_provider.build_address
  #   # key_mappings = {"line1"=>"street_address","postal_code"=>"zip_code"}
  #   # stripe_account = current_provider.get_provider_stripe_account
  #   # stripe_account.requirements.errors.each{ |e|
  #   # key = e.requirement.split('.').last=="line1" || e.requirement.split('.').last=="postal_code" ? key_mappings[e.requirement.split('.').last] : e.requirement.split('.').last
  #   # @bank_account.errors.add("#{key.to_sym}", "Error in #{key.titleize}: #{e.reason}")} if stripe_account.present? && stripe_account.requirements.errors.present?
    
  # end

  # def update_bank_account
  #   @bank_account = current_provider.bank_account
  #   @address = current_provider.address
  #   @bank_account.present? ? @bank_account.assign_attributes(bank_account_params) : @bank_account = current_provider.build_bank_account(bank_account_params)
  #   @address.present? ? @address.assign_attributes(address_params) : @address = current_provider.build_address(address_params)
    
  #   if @bank_account.valid? && @address.valid?
                
  #       accuont_params = { provider: current_provider, remote_ip: "172.18.80.19", bank_account: @bank_account, address: @address  }
  #       stripe_account_creator = Stripe::CustomAccountCreator.call(accuont_params)
  #       unless  stripe_account_creator.status
  #           stripe_account_creator.errors.each do |e|
  #               @bank_account.errors.add(e.keys.first, e[e.keys.first])
  #           end 
  #           render 'bank_details'
  #       else
  #           @bank_account.save
  #           @address.save
  #           stripe_account_creator.pending_verification ? flash[:notice] = 'Your Bank Account Information has been updated and pending verification. Keep refreshing for any feedback' : flash[:notice] = 'Your Bank Account Information has been updated successfully'
  #           redirect_to bank_details_path
  #       end 
  #   else
  #       @address.errors.each{|e| @bank_account.errors.add("address.#{e.attribute}",e.message) } if @address.errors.present?
  #       render 'bank_details'
  #   end 
  # end


  # private
  #   def bank_account_params
  #       params.require(:bank_account).permit(:bank_account_type,:title,:number,:number_confirmation,:routing_number,:bank_name,:id_number)
  #   end

  #   def address_params
  #       params.require(:address).permit(:street_address,:city,:state,:zip)
  #   end

end