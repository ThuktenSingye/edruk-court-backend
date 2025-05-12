# frozen_string_literal: true

module Reports
  # Report Chart Generator
  class ReportChartGenerator
    def initialize(data:, year:)
      @data = data
      @year = year
    end

    def generate
      {
        pie_chart: generate_pie_chart(@data[:cases]),
        bar_chart: generate_bar_charts(@data[:cases_overview])
      }
    end

    private

    def generate_pie_chart(data)
      g = Gruff::Pie.new(400)
      g.title = 'Cases Distribution'

      g.theme = {
        colors: %w[#1f77b4 #ff7f0e #2ca02c #d62728 #9467bd],
        marker_color: '#cccccc',
        background_colors: %w[#ffffff #ffffff]
      }

      g.font_color = 'black'

      data.each do |label, value|
        g.data(label.capitalize, value)
      end
      save_chart(g, "cases_pie_chart_#{@year}")
    end

    def generate_bar_charts(data)
      if data.values.all?(Hash)
        generate_group_bar_chart(data)
      else
        generate_bar_chart(data)
      end
    end

    def generate_group_bar_chart(data)
      g = Gruff::StackedBar.new(800)
      g.title = 'Cases Overview'
      g.theme = {
        colors: %w[#1f77b4 #ff7f0e #2ca02c #d62728 #9467bd],
        marker_color: '#cccccc',
        background_colors: %w[#ffffff #ffffff]
      }

      g.font_color = 'black'

      metrics = %w[total_case decided_case pending_case appeal_case enforced_case]

      court_levels = data.keys
      labels = {}
      court_levels.each_with_index { |court, i| labels[i] = court.to_s.humanize }
      g.labels = labels

      metrics.each do |metric|
        values = court_levels.map do |court|
          data[court][metric] || 0
        end
        g.data(metric.humanize, values)
      end

      save_chart(g, "cases_overview_grouped_bar_#{@year}")
    end

    def generate_bar_chart(data)
      g = Gruff::Bar.new(600)
      g.title = 'Cases Overview'

      g.theme = {
        colors: %w[#1f77b4 #ff7f0e #2ca02c #d62728 #9467bd],
        marker_color: '#cccccc',
        background_colors: %w[#ffffff #ffffff]
      }

      g.font_color = 'black'

      labels = {}
      data.keys.each_with_index { |key, i| labels[i] = key.to_s.humanize }

      g.labels = labels
      g.data('Cases', data.values)

      save_chart(g, "cases_overview_bar_#{@year}")
    end

    def save_chart(chart, filename_prefix)
      filename = "#{filename_prefix}_#{Time.current.to_i}.png"
      charts_dir = Rails.root.join('public', 'charts')
      FileUtils.mkdir_p(charts_dir) unless File.directory?(charts_dir)
      path = File.join(charts_dir, filename)
      chart.write(path)
      path
    end
  end
end
