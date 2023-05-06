# Manage Solr configuration including fields
class ConfigsController < ApplicationController
  before_action :set_config, only: %i[show edit update destroy]

  # GET /configs or /configs.json
  def index
    @configs = Config.all
    redirect_to action: 'new' if @configs.empty?
  end

  # GET /configs/1 or /configs/1.json
  def show; end

  # GET /configs/new
  def new
    @config = Config.new
  end

  # GET /configs/1/edit
  def edit; end

  # POST /configs or /configs.json
  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @config = Config.new(config_params)

    @config.verify_host unless @config.verified?

    preliminary_status = @config.verified? ? :accepted : :unprocessable_entity

    respond_to do |format|
      if @config.save
        format.html { redirect_to config_url(@config), notice: 'Config was successfully created.' }
        format.json { render :show, status: :created, location: @config }
      else
        format.html { render :new, status: preliminary_status }
        format.json { render json: @config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /configs/1 or /configs/1.json
  def update
    respond_to do |format|
      if @config.update(config_params)
        format.html { redirect_to config_url(@config), notice: 'Config was successfully updated.' }
        format.json { render :show, status: :ok, location: @config }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @config.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /configs/1 or /configs/1.json
  def destroy
    @config.destroy

    respond_to do |format|
      format.html { redirect_to configs_url, notice: 'Config was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_config
    @config = Config.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def config_params
    params.require(:config).permit(:solr_host, :solr_version, :solr_core, :fields)
  end
end
