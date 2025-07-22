class AchFilesController < ApplicationController
  before_action :require_authentication

  def new
    @ach_file = AchFile.new
  end

  def create
    input_attributes = {}
    if ach_file_params[:file_data].present?
      input_attributes = {
        modality: :file_upload,
        file_data: ach_file_params[:file_data],
        source: ach_file_params[:file_data].original_filename,
        name: ach_file_params[:file_data].original_filename
      }
    elsif ach_file_params[:pasted_text].present?
      input_attributes = { modality: :pasted_text, source: ach_file_params[:pasted_text] }
    elsif ach_file_params[:url].present?
      input_attributes = { modality: :url, source: ach_file_params[:url] }
    end

    @ach_file = Current.user.ach_files.build(ach_input_files_attributes: [input_attributes])

    if @ach_file.save
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
    params.require(:ach_file).permit(:pasted_text, :url, :file_data, ach_input_files_attributes: [:modality, :source, :file_data])
  end
end
