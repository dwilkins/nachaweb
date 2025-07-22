class AchFilesController < ApplicationController
  def new
    @ach_file = AchFile.new
  end

  def create
    @ach_file = current_user.ach_files.build

    if @ach_file.save
      if ach_file_params[:file].present?
        @ach_file.ach_input_files.create(
          modality: :file_upload,
          source: ach_file_params[:file].read
        )
      elsif ach_file_params[:pasted_text].present?
        @ach_file.ach_input_files.create(
          modality: :pasted_text,
          source: ach_file_params[:pasted_text]
        )
      elsif ach_file_params[:url].present?
        @ach_file.ach_input_files.create(
          modality: :url,
          source: ach_file_params[:url]
        )
      end

      redirect_to @ach_file, notice: "ACH file was successfully created."
    else
      render :new
    end
  end

  def show
    @ach_file = AchFile.find_by!(uuid: params[:id])
  end

  private

  def ach_file_params
    params.require(:ach_file).permit(:file, :pasted_text, :url)
  end
end
