module Admin
  # Controller for dumping and loading singleton Config class
  class ConfigsController < ApplicationController
    before_action :set_config, only: %i[show edit update]
    authorize_resource

    # GET /configs or /configs.json
    def index
      # We're explicitly raising an error here to make it obvious that we don't want to
      # default to the default ActionController behavior.
      raise NoMethodError
      # @configs = Config.all
    end

    # GET /configs/1 or /configs/1.json
    def show; end

    # GET /configs/new
    def new
      # We're explicitly raising an error here to make it obvious that we don't want to
      # default to the default ActionController behavior.
      raise NoMethodError
      # @config = Config.new
    end

    # GET /configs/1/edit
    def edit; end

    # POST /configs or /configs.json
    def create
      # We're explicitly raising an error here to make it obvious that we don't want to
      # default to the default ActionController behavior.
      raise NoMethodError
      # @config = Config.new(config_params)
      #
      # respond_to do |format|
      #   if @config.save
      #     format.html { redirect_to config_url(@config), notice: 'Config was successfully created.' }
      #     format.json { render :show, status: :created, location: @config }
      #   else
      #     format.html { render :new, status: :unprocessable_entity }
      #     format.json { render json: @config.errors, status: :unprocessable_entity }
      #   end
      # end
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
      # We're explicitly raising an error here to make it obvious that we don't want to
      # default to the default ActionController behavior.
      raise NoMethodError
      # @config.destroy!
      #
      # respond_to do |format|
      #   format.html { redirect_to configs_url, notice: 'Config was successfully destroyed.' }
      #   format.json { head :no_content }
      # end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_config
      @config = Config.current
    end

    # Only allow a list of trusted parameters through.
    def config_params
      params.fetch(:config_file)
    end
  end
end