require 'csv'

class BiasDetectorPresenter

  def initialize(data)
    @bias_components = data.lines    
  end
  
  def table_keys
    @keys ||= ['bias_composite', 'norm_value_cnt', 'norm_self_refer_cnt', 'norm_presup_cnt', 'norm_attribution_cnt']
  end

  def table_values
    return [] if @bias_components.empty?

    all_keys = @bias_components.first.parse_csv.map(&:strip)
    indexes = []
    table_keys.each do |key|
      indexes << all_keys.index(key)
    end

    values = []
    @bias_components.drop(1).each do |list|
      list_arr = list.parse_csv
      entry = []
      indexes.each do |index|
        entry << list_arr[index].to_f.round(4)
      end
      values << entry
    end
    values
  end
end
