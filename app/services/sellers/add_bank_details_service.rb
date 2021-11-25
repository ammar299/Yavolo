module Sellers

  class AddBankDetailsService < ApplicationService
    MCC = 5045 
    PRODUCT_DESCRIPTION = "Yavolo Ltd."
    attr_reader :params, :errors, :status

    def initialize(params)
      @params = params
      @bank_detail = params[:bank_detail]
      @errors = []
    end

    def call(*args)
      begin
        create_custom_connect_account
      rescue => e
        @errors << e.message
        begin
          stripe_account = seller.get_seller_stripe_account
          if stripe_account.present?
            stripe_errors = set_stripe_errors_if_any(stripe_account) 
            stripe_errors << {stripe_error: e.message}
            external_detail = stripe_account["external_accounts"]["data"][0]
            seller.bank_detail.update(requirements: stripe_errors,
              account_verification_status: stripe_account[:payouts_enabled].to_s,
              bank_name: external_detail["bank_name"],
              last4: external_detail["last4"],
              stripe_account_type: stripe_account["type"]
            ) if seller.bank_detail.present?
          end
        rescue => e
          @errors << e.message
        end
      end
      self
    end
    
    private
    def create_custom_connect_account
      connect_account = Stripe::Account.create(connect_account_params)
      if connect_account.present?
        external_detail = connect_account["external_accounts"]["data"][0]
        requirements = set_stripe_errors_if_any(connect_account)
        connect_account_link = create_connect_account_link(connect_account)
        if seller.bank_detail.present?
          seller.bank_detail.update(bank_detail_update_params(connect_account,external_detail,requirements,connect_account_link))
        else
          seller.create_bank_detail(bank_detail_update_params(connect_account,external_detail,requirements,connect_account_link))
        end
      end
      @status = connect_account.id
      connect_account
    end

    def create_connect_account_link(connect_account)
      link = Stripe::AccountLink.create(
        account: connect_account.id,
        refresh_url: "#{ENV['HOST_DOMAIN']}/sellers/check_onboarding_status",
        return_url: "#{ENV['HOST_DOMAIN']}/sellers/check_onboarding_status",
        type: 'account_onboarding',
        collect: 'eventually_due',
      )
    end

    def bank_detail_update_params(connect_account,external_detail,requirements,connect_account_link)
      {
        customer_stripe_account_id: connect_account.id,
        requirements: requirements,
        account_verification_status: connect_account[:payouts_enabled].to_s,
        bank_name: external_detail["bank_name"],
        last4: external_detail["last4"],
        stripe_account_type: connect_account["type"],
        onboarding_link: connect_account_link.url,
        account_holder_name: external_detail["account_holder_name"],
        fingerprint: external_detail["fingerprint"],
        available_payout_methods: external_detail["available_payout_methods"][0],
        country: @bank_detail[:address][:country],
        currency: @bank_detail[:currency],
        account_number: account_number,
        sort_code: @bank_detail[:routing_number].to_i 
      }
    end

    def account_number
      @bank_detail[:account_number]
    end

    def connect_account_params
      {
        type:'custom',
        country: @bank_detail[:address][:country],
        email: seller.email,
        capabilities: { card_payments:{requested: true}, transfers:{requested: true} },
        external_account: bank_account_params,
        business_type: 'individual',
        tos_acceptance: {
          date: Time.now.in_time_zone('Eastern Time (US & Canada)').to_i,
          ip: remote_ip
        },
        business_profile: { mcc: MCC, product_description: PRODUCT_DESCRIPTION },
        individual: {
          address: address_params,
          dob: dob_params, 
          email: seller.email, 
          first_name: seller.first_name || "#{seller.email.split("@")[0] || "yavolo's seller"}", 
          id_number: account_number,
          last_name: seller.last_name || "#{seller.email.split("@")[0] || "yavolo's seller"}",
          phone: phone_number
        },
        
      }
    end

    def remote_ip
      remote_ip = "172.18.80.19"
    end

    def phone_number
      begin
        invoice = seller.addresses.where(address_type: "invoice_address").last.phone_number
      rescue
        @errors << "Please enter phone number for invoice address details."
      end
    end

    def bank_account_params
      { object: 'bank_account', country: @bank_detail[:address][:country], currency: @bank_detail[:currency], account_number: account_number, routing_number: @bank_detail[:routing_number].to_i }
    end
    
    def address_params
      begin
        address = seller.addresses.where(address_type: "invoice_address").last #provider.address
        {city: address.city, line1: address.address_line_1, postal_code: address.postal_code, state: address.state }
      rescue
        @errors << "Please fill invoice address details."
      end
    end
    
    def dob_params
      begin
        dob = seller.business_representative.date_of_birth
        { day: dob.day, month: dob.month, year: dob.year }
      rescue
        @errors << "Please provide date of birth of bussiness representative."
      end
    end

    def set_stripe_errors_if_any(stripe_account)
      key_mappings = {"line1"=>"street_address","postal_code"=>"zip_code"}
      stripe_errors = []
      if stripe_account.requirements.errors.present?
        stripe_account.requirements.errors.each do |e|
          key = e.requirement.split('.').last=="line1" || e.requirement.split('.').last=="postal_code" ? key_mappings[e.requirement.split('.').last] : e.requirement.split('.').last
          stripe_errors << {"#{key.to_sym}"=> "Error in #{key.titleize}: #{e.reason}" }
        end
      end
      stripe_errors
    end

    def seller
      @seller ||= params[:seller].reload
    end

  end

end