class Sellers::BankAccountsController < Sellers::BaseController

  def add_bank_details
    @seller = current_seller
    bank_account = Sellers::AddBankDetailsService.call({seller: current_seller, bank_detail: params })
    if bank_account.status.present?
      render json: {result: true, link: current_seller.bank_detail.onboarding_link}, status: :ok
    else
      if bank_account.errors.any?
        render json: {errors: bank_account.errors.uniq}, status: :ok
      else
        render json: {result: "success"}, status: :bad_request
      end
    end
  end

  def refresh_onboarding_link
    begin
      link = current_seller.bank_detail.get_refresh_onboarding_link if current_seller.bank_detail.customer_stripe_account_id.present?
      render json: {link: link}, status: :ok
    rescue => e
      render json: {link: ""}, status: :bad_request
    end
  end

  def check_onboarding_status
    begin
      status = current_seller.bank_detail.check_account_status if current_seller.bank_detail.customer_stripe_account_id.present?
      if status[:payouts_enabled] == true
        detail = current_seller.bank_detail.update(account_verification_status: status[:payouts_enabled].to_s,requirements: nil)
        if detail == true
          redirect_to sellers_profile_path(current_seller), notice: "Account verified successfully."
        else
          redirect_to sellers_profile_path(current_seller), notice: "Account information not updated. Please try again."
        end
      else
        redirect_to sellers_profile_path(current_seller), notice: "Account verification not completed."
      end
    rescue => e
      redirect_to sellers_profile_path(current_seller), notice: "Account verification not failed."
    end
  end

  def remove_payout_bank_account
    @seller = current_seller
    begin
      bank_account = @seller&.bank_detail
      current_seller.bank_detail.remove_bank_account if bank_account.present?
      flash.now[:notice] = "Bank account for payouts removed"
    rescue => e
      flash.now[:notice] = "Error occured: #{e.message}"
    end
  end
  
end