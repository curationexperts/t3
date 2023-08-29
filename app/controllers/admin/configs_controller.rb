module Admin
  # Manage Solr configuration including fields
  class ConfigsController < ApplicationController
    before_action :set_config, only: %i[show edit update]
    load_and_authorize_resource

    # GET /admin/config or /admin/config.json
    def show; end

    # GET /admin/config/edit
    def edit; end

    # PATCH/PUT /admin/config or /admin/config.json
    def update
      respond_to do |format|
        if @config.update(config_params)
          format.html { redirect_to config_url, notice: 'Config was successfully updated.' }
          format.json { render :show, status: :ok, location: @config }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @config.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_config
      @config = Config.current
    end

    # Only allow a list of trusted parameters through.
    def config_params
      params.require(:config).permit(:setup_step, :solr_host, :solr_version, :solr_core,
                                     fields_attributes: %i[
                                       solr_field_name enabled display_label
                                       searchable facetable search_results item_view
                                     ])
    end
  end
end
