namespace :products do
  desc "Update products category filter ids"
  task update_category_filter_ids: :environment do
    Product.all.each{|p| p.save(validate: false) }
    puts "Updated category filter ids"
  end
end
