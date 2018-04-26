require 'open3'

module BiasDetector
  class DetectBias
    def self.call(params)
      data = params[:data]
      raise ArgumentError, 'Missing data' unless data.present?

      mode = params[:mode]
      raise ArgumentError, 'Missing mode' unless mode.present?

      tool_directory = Rails.root.join('bias-detector', 'bsd', 'bsdetector')
      tool = Rails.root.join(tool_directory, 'newsframe.py')
      raise ServiceError, 'Missing tool' unless tool.exist?

      # escape data, handle both types of newlines
      data = ActiveSupport::JSON.encode(data)
      data.gsub! '\r\n', '\n'
      data = data.split('\n').select(&:present?).join('\n')      
      data.gsub! '\n', '\r\n'

      bias_mode = '-d'
      if mode == 'normalized'
        bias_mode = '-n'
      elsif mode == 'extended'
        bias_mode = '-e'
      else
        bias_mode = '-d'
      end

      stdout, stderr, status = Open3.capture3("python #{tool} #{bias_mode} #{data}", chdir: tool_directory)
      if stdout.present?
        stdout
      else
        Rollbar.error(stderr)
        raise ServiceError, "Error while running bias prism tool"
      end
    end
  end
end