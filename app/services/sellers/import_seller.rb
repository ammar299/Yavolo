module Sellers
  class ImportSeller < ApplicationService
    require 'csv'
    attr_reader :status, :errors, :params

    def initialize(params)
        @params = params
        @status = true
        @errors = []
    end


    def call
      begin
        import_products_from_csv
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

      def import_products_from_csv
        file_path = "#{Rails.root}/public/#{csv_import.file.url}"
        csv_file_conent = File.read(file_path)
        csv = CSV.parse(csv_file_conent, :headers => true)
        csv_import.update({status: :importing})
        csv.each do |row|
          seller_found = Seller.where(email: row["email"])&.first
          if !seller_found.present?
            password = Random.rand(11111111...99999999)
            seller = Seller.new(
              email: row["email"],
              password: "#{password}",
              first_name: row["first_name"],
              last_name: row["last_name"],
              surname: row["surname"],
              gender: row["gender"],
              date_of_birth: row["date_of_birth"],
              contact_number: row["contact_number"],
              provider: row["provider"],
              uid: row["uid"],
              account_status: 0,
              listing_status: row["listing_status"],
              contact_email: row["contact_email"],
              contact_name: row["contact_name"],
              subscription_type: row["subscription_type"]
            )
            if seller.valid?
              seller.save
              create_associate_seller_data(seller,row)
              AdminMailer.with(to: row["email"].to_s.downcase, password: password ).send_account_creation_email.deliver_now #send notification email to seller
            else
              @errors << seller.errors.full_messages.join("<br>")
            end
          else
            puts "seller already exists"
          end

        end
        @errors.present? ? csv_import.update(status: :failed, import_errors: @errors.uniq.join(', ') ) : csv_import.update({status: :imported})
        @errors.present? ? @status = false : @status = true
        self
      end

      def csv_import
        @csv_import ||= params[:csv_import]
      end

      def create_associate_seller_data(seller,row)
        puts "*** Associated Entries started ***"
        seller.create_business_representative(
          email: row["business_representative_email"],
          job_title: row["business_representative_job_title"], 
          date_of_birth: row["business_representative_date_of_birth"],
          contact_number: row["business_representative_contact_number"],
          full_legal_name: row["business_representative_full_legal_name"]
        )
        seller.create_company_detail(
          name: row["company_detail_name"],
          vat_number: row["company_detail_vat_number"],
          country: row["company_detail_country"],
          legal_business_name: row["company_detail_legal_business_name"],
          companies_house_registration_number: row["company_detail_companies_house_registration_number"],
          business_industry: row["company_detail_business_industry"],
          business_phone: row["company_detail_business_phone"],
          website_url: row["company_detail_website_url"],
          amazon_url: row["company_detail_amazon_url"],
          ebay_url: row["company_detail_ebay_url"],
          doing_business_as: row["company_detail_doing_business_as"]
        )
        seller.create_picture(
          name: row["picture_name"],
          imageable_id: row["picture_imageable_id"],
          imageable_type: row["picture_imageable_type"]
        )
        # seller.create_seller_api(name: row["seller_api_name"],api_token: row["seller_api_token"],status: row["seller_api_status"])
        seller.addresses.create(
          address_line_1: row["business_representative_address_line_1"],
          address_line_2: row["business_representative_address_line_2"],
          city: row["business_representative_address_city"],
          county: row["business_representative_address_county"],
          state: row["business_representative_address_state"],
          country: row["business_representative_address_country"],
          postal_code: row["business_representative_address_postal_code"],
          phone_number: row["business_representative_address_phone_number"],
          address_type: row["business_representative_address_type"]
        )
        seller.addresses.create(
          address_line_1: row["business_address_line_1"],
          address_line_2: row["business_address_line_2"],
          city: row["business_address_city"],
          county: row["business_address_county"],
          state: row["business_address_state"],
          country: row["business_address_country"],
          postal_code: row["business_address_postal_code"],
          phone_number: row["business_address_phone_number"],
          address_type: row["business_address_type"]
        )
        seller.addresses.create(
          address_line_1: row["return_address_line_1"],
          address_line_2: row["return_address_line_2"],
          city: row["return_address_city"],
          county: row["return_address_county"],
          state: row["return_address_state"],
          country: row["return_address_country"],
          postal_code: row["return_address_postal_code"],
          phone_number: row["return_address_phone_number"],
          address_type: row["return_address_type"]
        )
        seller.addresses.create(
          address_line_1: row["invoice_address_line_1"],
          address_line_2: row["invoice_address_line_2"],
          city: row["invoice_address_city"],
          county: row["invoice_address_county"],
          state: row["invoice_address_state"],
          country: row["invoice_address_country"],
          postal_code: row["invoice_address_postal_code"],
          phone_number: row["invoice_address_phone_number"],
          address_type: row["invoice_address_type"]
        )
        puts "*** Associated Entries completed ***"
      end
  end
end

