module Admin
  # Coordinate creation and management of controlled vocabularies
  class VocabulariesController < ApplicationController
    load_and_authorize_resource(find_by: :slug, id_param: :slug)

    # GET /admin/vocabularies or /admin/vocabularies.json
    def index
      @vocabularies = Vocabulary.all
    end

    # GET /admin/vocabularies/1 or /admin/vocabularies/1.json
    def show; end

    # GET /admin/vocabularies/new
    def new
      @vocabulary = Vocabulary.new
    end

    # GET /admin/vocabularies/1/edit
    def edit; end

    # POST /admin/vocabularies or /admin/vocabularies.json
    def create
      @vocabulary = Vocabulary.new(vocabulary_params)

      respond_to do |format|
        if @vocabulary.save
          format.html { redirect_to @vocabulary, notice: 'Vocabulary was successfully created.' }
          format.json { render :show, status: :created, location: @vocabulary }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @vocabulary.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/vocabularies/1 or /admin/vocabularies/1.json
    def update
      respond_to do |format|
        if @vocabulary.update(vocabulary_params)
          format.html { redirect_to @vocabulary, notice: 'Vocabulary was successfully updated.' }
          format.json { render :show, status: :ok, location: @vocabulary }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @vocabulary.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /admin/vocabularies/1 or /admin/vocabularies/1.json
    def destroy
      @vocabulary.destroy!

      respond_to do |format|
        format.html { redirect_to vocabularies_url, notice: 'Vocabulary was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    # Only allow a list of trusted parameters through.
    def vocabulary_params
      params.require(:vocabulary).permit(:name, :slug, :description)
    end
  end
end
