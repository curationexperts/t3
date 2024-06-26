module Admin
  # Manage style and branding related settings
  class ThemesController < ApplicationController
    before_action :set_theme, only: %i[edit update activate destroy]
    before_action :set_theme_with_current, only: :show
    load_and_authorize_resource

    # GET /themes or /themes.json
    def index
      @themes = Theme.order(:label, :created_at).to_a << Theme.new(label: 'Add Theme')
    end

    # GET /themes/1 or /themes/1.json
    def show; end

    # GET /themes/new
    def new
      @theme = Theme.new
    end

    # GET /themes/1/edit
    def edit; end

    # POST /themes or /themes.json
    def create
      @theme = Theme.new(theme_params)

      respond_to do |format|
        if @theme.save
          format.html { redirect_to theme_url(@theme) }
          format.json { render :show, status: :created, location: @theme }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @theme.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /themes/1 or /themes/1.json
    def update
      respond_to do |format|
        if @theme.update(theme_params)
          format.html { redirect_to theme_url(@theme) }
          format.json { render :show, status: :ok, location: @theme }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @theme.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH /themes/1/activate or /themes/1/activate.json
    def activate
      @theme.activate! # always succeeds and returns itself
      respond_to do |format|
        format.html { redirect_to theme_url(@theme) }
        format.json { render :show, status: :ok, location: @theme }
      end
    end

    # DELETE /themes/1 or /themes/1.json
    def destroy
      @theme.destroy

      respond_to do |format|
        format.html { redirect_to themes_url }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_theme
      @theme = Theme.find(params[:id])
    end

    def set_theme_with_current
      if params[:id] == 'current'
        @theme = Theme.current
      else
        set_theme
      end
    end

    # Only allow a list of trusted parameters through.
    def theme_params
      params.require(:theme).permit(:label, :site_name, :main_logo, :favicon,
                                    :header_color, :header_text_color,
                                    :background_color, :background_accent_color)
    end
  end
end
