class RegistrationsController < Devise::RegistrationsController
    before_action :authenticate_user!

    protected

        def after_sign_up_path_for(resource)
            if resource.is_a?(User)
                if resource.seller?
                    seller_dashboard_path
                else
                    buyer_dashboard_path
                end
            else
                super
            end
        end

        def update_resource(resource, params)
            resource.update_with_password(params)
        end

end