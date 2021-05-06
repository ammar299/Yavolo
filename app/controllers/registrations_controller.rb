class RegistrationsController < Devise::RegistrationsController
    before_action :authenticate_user!

    protected

        def update_resource(resource, params)
            resource.update_with_password(params)
        end

end