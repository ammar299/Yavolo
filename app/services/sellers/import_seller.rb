module Sellers
  class ImportSeller < ApplicationService
    require 'csv'
    attr_reader :status, :errors, :params

    def initialize(params)
        @params = params
        @status = true
        @errors = []
        @dob_errors = []
    end


    def call
      import_sellers_from_csv
      self
    end

    private

      def import_sellers_from_csv
        file_path = "#{Rails.root}/public/#{csv_import.file.url}"
        csv_file_conent = File.read(file_path)
        csv =  CSV.parse(csv_file_conent, headers: true).delete_if { |row| row.to_hash.values.all?(&:blank?) }
        csv_import.update({status: :importing})
        csv.each do |row|
          seller_found = Seller.where(email: row["user_email"])&.first
          if !seller_found.present?
            begin
              password = Random.rand(11111111...99999999)
              uid = (('A'..'Z').to_a.sample(2) + (0..9).to_a.sample(6) ).join
              seller = create_seller_instance(row,password,uid)
              if seller.valid?
                create_associate_seller_data(seller,row)
                if @errors.blank? && @dob_errors.blank? && seller.save
                  seller.update_seller_products_listing
                  seller.skip_password_validation = true
                  raw, hashed = Devise.token_generator.generate(Seller, :reset_password_token)
                  seller.reset_password_token = hashed
                  seller.reset_password_sent_at = Time.now.utc
                  AdminMailer.with(to: row["user_email"].to_s.downcase, token: raw,seller: seller ).send_account_creation_email.deliver_now #send notification email to seller
                else
                  error_messages(row, seller)
                end
              else
                format_error_messages(row, "", seller)
                next
              end
            rescue  StandardError => e
              format_error_messages(row, e, seller)
            end
          else
            puts "seller already exists or error found"
            @errors << "Seller: #{row["user_email"]} already exists"
          end
        end
        @errors.present? ? csv_import.update(status: :failed, import_errors: @errors.uniq.join(', ') ) : csv_import.update({status: :imported})
        @errors.present? ? @status = false : @status = true
        self
      end

      def create_seller_instance(row,password,uid)
        Seller.new(
          email: row["user_email"],
          password: "#{password}",
          first_name: row["user_first_name"],
          last_name: row["user_surname"],
          surname: row["user_surname"],
          date_of_birth: date_of_birth_is_valid_datetime(row["business_representative_date_of_birth"]),
          contact_number: row["business_representative_address_phone_number"],
          provider: "admin",
          uid: uid,
          account_status: account_status_rephrase(row),
          listing_status: listing_status_rephrase(row),
          subscription_type: set_subscription_type(row),
        )
      end

      def date_of_birth_is_valid_datetime(row)
        if row.present?
          begin
            dob = Date.strptime(row, '%d/%m/%Y')
            diff = Time.now.year - dob.year
            if dob > Time.now
              row = nil
              @dob_errors << "Date of birth cannot be in the future"
            elsif diff < 18
              row = nil
              @dob_errors << "Date of birth cannot be less than 18 year"
            else
              return row
            end
          rescue
            @dob_errors << "#{row} must be a valid date. Valid format is dd/mm/yyyy"
          end
        else
          @dob_errors << " Date of birth cannot blank"
        end
        @dob_errors
      end

      def error_messages(row, seller)
        @errors << "seller: #{row["user_email"]} "
        if @dob_errors.present?
          @dob_errors.each do |err|
            @errors << "#{err}" 
          end
        end
      
        @errors << seller.errors.full_messages.join("<br>") if seller.present?
      end

      def format_error_messages(row, e, seller)
        @errors << "seller: #{row["user_email"]} "
        if @dob_errors.present?
          @dob_errors.each do |err|
            @errors << "#{err}" 
          end
        end
      
        @errors << seller.errors.full_messages.join("<br>") if seller.present?
        @errors << "<hr>" if seller.present?
        if e.present?
          @errors << e.message unless seller.present?
        end
      end

      def account_status_rephrase(row)
        status = row["account_status"]
        case status.downcase
        when 'suspended','suspend'
          status = 'suspend'
        when 'active','activate'
          status = 'activate'
        when 'approve','approved'
          status = 'approve'
        when 'reject','rejected'
          status = 'rejected'
        else
          status = 'pending'
        end
        return status
      end

      def listing_status_rephrase(row)
        status = row["listing_status"]
        case status.downcase
        when 'active'
          status = 'active'
        else
          status = 'in_active'
        end
        return status
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
        seller.build_business_representative(
          email: business_representative_email_valid(seller,row),
          job_title: row["business_representative_job_title"], 
          date_of_birth: date_of_birth_is_valid_datetime(row["business_representative_date_of_birth"]),
          full_legal_name: row["business_representative_full_legal_name"]
        )
      end

      def create_company_detail(seller,row)
        seller.build_company_detail(
          name: row["company_name"],
          vat_number: company_vat_number(row),
          country: row["company_country"],
          legal_business_name: row["company_legal_business_name"],
          companies_house_registration_number: validate_house_registration_number(row),
          business_industry: row["company_business_industry"],
          website_url: row["company_website_url"],
          amazon_url: row["company_amazon_url"],
          ebay_url: row["company_ebay_url"],
          doing_business_as: row["company_doing_business_as"]
        )
      end
      
      def create_business_representative_address(seller,row)

        data = seller.addresses.new(
          address_line_1: address_line_1("business_representative_address_line_1",row),
          address_line_2: address_line_2("business_representative_address_line_2",row),
          city: city("business_representative_address_city", row),
          county: county("business_representative_address_county", row),
          state: state("business_representative_address_state", row),
          country: country("business_representative_address_country", row),
          postal_code: postal_code("business_representative_address_postal_code", row),
          phone_number: phone_number_valid("business_representative_address_phone_number", row),
          address_type: "business_representative_address"
        )
        
      end

      def create_business_address(seller,row)
        data = seller.addresses.new(
          address_line_1: row["business_address_line_1"],
          address_line_2: row["business_address_line_2"],
          city: row["business_address_city"],
          county: row["business_address_county"],
          state: row["business_address_state"],
          country: row["business_address_country"],
          postal_code: row["business_address_postal_code"],
          phone_number: phone_number_valid("business_address_phone_number",row),
          address_type: "business_address"
        )
        
      end

      def create_return_address(seller,row)
        data = seller.addresses.new(
          address_line_1: address_line_1("return_address_line_1",row),
          address_line_2: address_line_2("return_address_line_2",row),
          city: city("return_address_city", row),
          county: county("return_address_county", row),
          state: state("return_address_state", row),
          country: country("return_address_country", row),
          postal_code: postal_code("return_address_postal_code", row),
          phone_number: phone_number_valid("return_address_phone_number", row),
          address_type: "return_address"
        )
        
      end

      def create_invoice_address(seller,row)
        data = seller.addresses.new(
          address_line_1: address_line_1("invoice_address_line_1",row),
          address_line_2: address_line_2("invoice_address_line_2",row),
          city: city("invoice_address_city", row),
          county: county("invoice_address_county", row),
          state: state("invoice_address_state", row),
          country: country("invoice_address_country", row),
          postal_code: postal_code("invoice_address_postal_code", row),
          phone_number: phone_number_valid("invoice_address_phone_number", row),
          address_type: "invoice_address"
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

      def phone_number_valid(field, row)
        pattern=/^(\(?(\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/
        phone = row["#{field}"] || row["business_address_phone_number"]
        if phone.start_with?("+")
          return phone
        else
          phone = ("+").concat(phone)
        end
        if phone.present?
          if phone.match?(pattern)
            return phone
          else
            @errors << "For seller: #{row["user_email"]} phone number #{phone} is invalid. Enter valid UK phone number(e.g +447911123456)"
          end
        else
          @errors << "For seller: #{row["user_email"]} phone number can not blank. Enter valid UK phone number(e.g +447911123456)"
        end
      end

      def validate_house_registration_number(row)
        #valid pattern are: AB123456, 11123456, A9123456  length must be 8
        pattern =/^(?:([A-Z]\w|[0-9]{2})[0-9]{6})$/
        if row["company_companies_house_registration_number"].present?
          if row["company_companies_house_registration_number"].match?(pattern)
            return row["company_companies_house_registration_number"]
          else
            @errors << "For seller: #{row["user_email"]} Company house registration number #{row["company_companies_house_registration_number"]} is invalid. Valid format is: A9123456, 12345678 or AB345678"
          end
        end
      end

      def company_vat_number(row)
        pattern=/^GB(?:\d{3} ?\d{4} ?\d{2}(?:\d{3})?|[A-Z]{2}\d{3})$/
        if row["company_vat_number"].present?
          if row["company_vat_number"].match?(pattern)
            return row["company_vat_number"]
          else
            @errors << "For seller: #{row["user_email"]} Company VAT number #{row["company_vat_number"]} is invalid. Please enter a valid VAT number"
          end
        end
      end

      def business_representative_email_valid(seller,row)
        pattern = /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
        if row["business_representative_email"].match?(pattern)
          row["business_representative_email"]
        else
          @errors << "For seller: #{row["user_email"]} Business repersentative email #{row["business_representative_email"]} is invalid. Please enter a valid Business repersentative Email"
        end
      end

      def set_subscription_type(row)
        @selected_plan = SubscriptionPlan.where('lower(subscription_name) = ?', row["subscription_type"].downcase).first
        if @selected_plan.present?
          return @selected_plan.subscription_name
        else
          @errors << "For seller: #{row["user_email"]} #{row["subscription_type"]} Subscription type is not correct."
        end
      end

  end
end

