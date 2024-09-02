# frozen_string_literal: true

require 'offline_geocoder/version'
require 'singleton'
require 'monitor'
require 'csv'
require 'geokdtree'

class OfflineGeocoder
  include Singleton

  CSV_PATH = File.expand_path('../og_cities1000.csv', __dir__)

  def initialize
    @monitor = Monitor.new
    @initialized = false
    @cities = []
    @tree = Geokdtree::Tree.new(2)
    @table = []
  end

  def search(query, lon = nil)
    ensure_initialized
    lat, lon = lon.nil? ? [query[:lat], query[:lon]] : [query, lon]

    if lat && lon
      search_by_latlon(lat.to_f, lon.to_f)
    else
      search_by_attr(query)
    end
  end

  private

  def ensure_initialized
    @monitor.synchronize do
      return if @initialized
      load_data
      @initialized = true
    end
  end

  def load_data
    index = 0
    CSV.foreach(CSV_PATH, headers: true, header_converters: :symbol) do |row|
      as_hash = row.to_h
      as_hash[:lat] = as_hash[:lat].to_f
      as_hash[:lon] = as_hash[:lon].to_f
      @tree.insert([row[:lat], row[:lon]], index)
      @table << as_hash
      index += 1
    end
  end

  def search_by_latlon(lat, lon)
    @table[@tree.nearest([lat, lon]).data.to_i].to_h
  end

  def search_by_attr(query = {})
    @table.select { |object| object >= query }.first
  end
end
