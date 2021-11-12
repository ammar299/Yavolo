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
        import_sellers_from_csv
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

      def import_sellers_from_csv
        file_path = "#{Rails.root}/public/#{csv_import.file.url}"
        csv_file_conent = File.read(file_path)
        csv = CSV.parse(csv_file_conent, :headers => true)
        csv_import.update({status: :importing})
        csv.each do |row|
          seller_found = Seller.where(email: row["email"])&.first
          if !seller_found.present?
            password = Random.rand(11111111...99999999)
            uid = Random.rand(00000000...99999999)
            seller = Seller.new(
              email: row["email"],
              password: "#{password}",
              first_name: row["first_name"],
              last_name: row["last_name"],
              surname: row["surname"],
              gender: row["gender"],
              date_of_birth: row["date_of_birth"],
              contact_number: row["contact_number"],
              provider: "admin",
              uid: uid,
              account_status: 0,
              listing_status: row["listing_status"],
              contact_email: row["contact_email"],
              contact_name: row["contact_name"],
              subscription_type: row["subscription_type"]
            )

            if seller.valid?
              seller.save
              create_associate_seller_data(seller,row)
              # AdminMailer.with(to: row["email"].to_s.downcase, password: password ).send_account_creation_email.deliver_now #send notification email to seller
            else
              @errors << "seller: #{row["email"]} "
              @errors << seller.errors.full_messages.join("<br>")
              @errors << "<hr>"
              puts "error occurred"
              next
            end
          else
            puts "seller already exists or error found"
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
        create_bussiness_representative(seller,row)
        create_company_detail(seller,row)
        create_business_representative_address(seller,row)
        create_business_address(seller,row)
        create_return_address(seller,row)
        create_invoice_address(seller,row)
        puts "*** Associated Entries completed ***"
      end

      def create_bussiness_representative(seller,row)
        seller.create_business_representative(
          email: row["business_representative_email"],
          job_title: row["business_representative_job_title"], 
          date_of_birth: row["business_representative_date_of_birth"],
          contact_number: row["business_representative_contact_number"],
          full_legal_name: row["business_representative_full_legal_name"]
        )
      end

      def create_company_detail(seller,row)
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
      end

      def create_business_representative_address(seller,row)
        seller.addresses.create(
          address_line_1: address_line_1("business_representative_address_line_1",row),
          address_line_2: address_line_2("business_representative_address_line_2",row),
          city: city("business_representative_address_city", row),
          county: county("business_representative_address_county", row),
          state: state("business_representative_address_state", row),
          country: country("business_representative_address_country", row),
          postal_code: postal_code("business_representative_address_postal_code", row),
          phone_number: phone_number("business_representative_address_phone_number", row),
          address_type: row["business_representative_address_type"]
        )
      end

      def create_business_address(seller,row)
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
      end

      def create_return_address(seller,row)
        seller.addresses.create(
          address_line_1: address_line_1("return_address_line_1",row),
          address_line_2: address_line_2("return_address_line_2",row),
          city: city("return_address_city", row),
          county: county("return_address_county", row),
          state: state("return_address_state", row),
          country: country("return_address_country", row),
          postal_code: postal_code("return_address_postal_code", row),
          phone_number: phone_number("return_address_phone_number", row),
          address_type: row["return_address_type"]
        )
      end

      def create_invoice_address(seller,row)
        seller.addresses.create(
          address_line_1: address_line_1("invoice_address_line_1",row),
          address_line_2: address_line_2("invoice_address_line_2",row),
          city: city("invoice_address_city", row),
          county: county("invoice_address_county", row),
          state: state("invoice_address_state", row),
          country: country("invoice_address_country", row),
          postal_code: postal_code("invoice_address_postal_code", row),
          phone_number: phone_number("invoice_address_phone_number", row),
          address_type: row["invoice_address_type"]
        )
      end

      def address_line_1(field, row)
        row["#{field}"] || row["business_address_line_1"]
        
      end

      def address_line_2(field, row)
        row["#{field}"] || row["business_address_line_2"]
      end

      def city(field, row)
        row["#{field}"] || row["business_address_city"]
      end

      def county(field, row)
        row["#{field}"] || row["business_address_county"]
      end

      def state(field, row)
        row["#{field}"] || row["business_address_state"]
      end

      def country(field, row)
        row["#{field}"] || row["business_address_country"]
      end

      def postal_code(field, row)
        row["#{field}"] || row["business_address_postal_code"]
      end

      def phone_number(field, row)
        row["#{field}"] || row["business_address_phone_number"]
      end
  end
end

