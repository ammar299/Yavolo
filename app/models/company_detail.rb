class CompanyDetail < ApplicationRecord
    belongs_to :seller
    # validates_format_of :website_url, :with => /(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/ix, :message => "URL is of type http/https//:www.google.com"
    # validates_format_of :ebay_url, :with => /(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/ix, :message => "URL is of type http/https//:www.google.com"
    # validates_format_of :amazon_url, :with => /(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/ix, :message => "URL is of type http/https//:www.google.com"
end
