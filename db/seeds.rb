# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#Admin create 
Admin.create(email: "admin@yavolo.com", password: "password") if Rails.env.development? && Admin.count == 0

Ship.find_or_create_by(name: 'UK Mainland')
Ship.find_or_create_by(name: 'Highlands')
Ship.find_or_create_by(name: 'Islands')
Ship.find_or_create_by(name: 'Ireland')
Ship.find_or_create_by(name: 'Northen Ireland')
