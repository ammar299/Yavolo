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
            seller = Seller.new(email: row["email"],password: "password",first_name: row["first_name"],last_name: row["last_name"],surname: row["surname"],gender: row["gender"],date_of_birth: row["date_of_birth"],contact_number: row["contact_number"],provider: row["provider"],uid: row["uid"],account_status: row["account_status"],listing_status: row["listing_status"],contact_email: row["contact_email"],contact_name: row["contact_name"],subscription_type: row["subscription_type"])
            if seller.valid?
              seller.save
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

      # def required_csv_fields
      #   [
      #   "id","email", "first_name", "last_name", "surname", "gender", "date_of_birth", "contact_number", "provider", "uid", "account_status", "listing_status", "contact_email", "contact_name", "subscription_type"
      #   ]
      # end

      # def permitted_params(row)
      #   params.require(:seller).permit(:email,:first_name,:last_name,:surname,:gender,:date_of_birth,:contact_number,:provider,:uid,:account_status,:listing_status,:contact_email,:contact_name,:subscription_type)
      # end

      # def have_required_fields?(row)
      #   params_hash = row.to_hash
      #   (required_csv_fields-params_hash.keys).blank?
      # end

  end
end
