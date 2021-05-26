class HomeController < ApplicationController
    
    def index; end

    def signup; end

    def signin
      @user = User.last
      # respond_to do |format|
      #  format.html
      #  format.pdf do
      #    render pdf: "@user.first_name",
      #    template: "home/signin.html.erb",
      #    layout: 'pdf.html'
      #  end
      # end
      respond_to do |format|
        format.html {}
        format.pdf do
          # html = render_to_string(template: 'home/signin.pdf.erb', layout: 'layouts/application.pdf.erb')
          # pdf = WickedPdf.new.pdf_from_string(html)
          # send_data(pdf, filename: 'signin.pdf.erb', type: 'application/pdf', disposition: :attachment)
          render pdf: "home/signin.html.erb"   
        end
      end
    end
end