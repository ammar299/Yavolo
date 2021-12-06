module Admins
  module Sellers

    class DeleteSpecificWrokerService < ApplicationService
      require 'sidekiq/api'
      attr_reader :params, :errors
      def initialize(seller)
        @seller = seller
        @errors = []
      end

      def call(*args)
        begin
          cancel_previous_worker
        rescue => exception
          puts "cancel_previous_worker service  exception: #{exception}"
        end
      end

      private
      def cancel_previous_worker
        worker_id = @seller&.seller_stripe_subscription&.associated_worker
        job = Sidekiq::ScheduledSet.new.find_job(worker_id) if worker_id.present?
        job.delete if job.present?
      end

    end

  end
end