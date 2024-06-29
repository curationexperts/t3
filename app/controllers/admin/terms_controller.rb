module Admin
  # Manage terms within a vocabulary
  class TermsController < ApplicationController
    before_action :set_vocabulary
    before_action :set_term, only: %i[show edit update destroy]
    authorize_resource

    def self.menu_group
      Vocabulary
    end

    # GET /admin/terms or /admin/terms.json
    def index
      @terms = @vocabulary.terms.order(:slug)
    end

    # GET /admin/terms/1 or /admin/terms/1.json
    def show; end

    # GET /admin/terms/new
    def new
      @term = Term.new(vocabulary: @vocabulary)
    end

    # GET /admin/terms/1/edit
    def edit; end

    # POST /admin/terms or /admin/terms.json
    def create
      @term = Term.new(term_params)

      respond_to do |format|
        if @term.save
          format.html { redirect_to term_url(@term), notice: 'Term was successfully created.' }
          format.json { render :show, status: :created, location: @term }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @term.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/terms/1 or /admin/terms/1.json
    def update
      respond_to do |format|
        if @term.update(term_params)
          format.html { redirect_to term_url(@term), notice: 'Term was successfully updated.' }
          format.json { render :show, status: :ok, location: @term }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @term.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /admin/terms/1 or /admin/terms/1.json
    def destroy
      @term.destroy!

      respond_to do |format|
        format.html do
          redirect_to vocabulary_terms_url(@vocabulary),
                      notice: "Term '#{@term.label}' was successfully destroyed."
        end
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_vocabulary
      @vocabulary = Vocabulary.find_by(slug: params[:vocabulary_slug])
    end

    def set_term
      @term = @vocabulary.terms.find_by(slug: params[:slug])
    end

    # Only allow a list of trusted parameters through.
    def term_params
      params.require(:term).permit(:vocabulary_id, :label, :slug, :value, :note)
    end
  end
end
