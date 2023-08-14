module Admin
  # Manage custom domain names for the application
  class CustomDomainsController < ApplicationController
    # before_action :set_custom_domain, only: %i[show edit update destroy]
    load_and_authorize_resource

    # GET /admin/custom_domains or /admin/custom_domains.json
    def index
      @custom_domains = CustomDomain.all
    end

    # GET /admin/custom_domains/1 or /admin/custom_domains/1.json
    def show; end

    # GET /admin/custom_domains/new
    def new
      @custom_domain = CustomDomain.new
    end

    # GET /admin/custom_domains/1/edit
    # Action Not Routable
    # def edit; end

    # POST /admin/custom_domains or /admin/custom_domains.json
    def create
      @custom_domain = CustomDomain.new(custom_domain_params)

      respond_to do |format|
        if @custom_domain.save
          format.html { redirect_to custom_domains_url }
          format.json { redirect_to custom_domains_url, format: :json }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @custom_domain.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/custom_domains/1 or /admin/custom_domains/1.json
    # Action Not Routable

    # DELETE /admin/custom_domains/1 or /admin/custom_domains/1.json
    def destroy
      @custom_domain.destroy

      respond_to do |format|
        format.html { redirect_to custom_domains_url }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_custom_domain
      @custom_domain = Admin::CustomDomain.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def custom_domain_params
      params.require(:custom_domain).permit(:host)
    end
  end
end
