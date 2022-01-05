module Paypal
  class PaypalResponse < ApplicationService

    def self.parsed_response(response)
      JSON.parse(openstruct_to_hash(response).to_json)
    end

    def self.openstruct_to_hash(object, hash = {})
      object.each_pair do |key, value|
        hash[key] = value.is_a?(OpenStruct) ? openstruct_to_hash(value) : value.is_a?(Array) ? array_to_hash(value) : value
      end
      hash
    end

    # Utility to convert Array of OpenStruct into Hash.
    def self.array_to_hash(array, hash = [])
      array.each do |item|
        x = item.is_a?(OpenStruct) ? openstruct_to_hash(item) : item.is_a?(Array) ? array_to_hash(item) : item
        hash << x
      end
      hash
    end
  end
end