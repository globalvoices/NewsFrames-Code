class ToolsController < ActionController::Base
  helper_method :bias_detector_presenter

  def detect_bias
    begin
      respond_to do |format|
        mode = params[:mode]
        if mode == 'data'
          data = BiasDetector::DetectBias.(data: params[:bias_detector_input], mode: mode)
          @bias_detector_presenter = BiasDetectorPresenter.new(data)
          format.js
        else
          csv = BiasDetector::DetectBias.(data: params[:bias_detector_input], mode: mode)
          format.html { send_data csv, filename: "prism-#{Date.today}-#{mode}.csv" }
        end
      end
    rescue ServiceError => e
      flash[:error] = e.message
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def bias_detector_presenter
    @bias_detector_presenter ||= BiasDetectorPresenter.new('')
  end
end