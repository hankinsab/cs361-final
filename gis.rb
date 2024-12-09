#!/usr/bin/env ruby
require 'json'

#track segments represents line segements with certain properties 

class Track
  def initialize(segments, name=nil)
    @name = name
    #converts an array of points into TrackSegment objects
    @segments = segments.map { |segment| TrackSegment.new(segment) }
  end

  #Returns a hash of geoson representation
  def to_geojson_hash
    {
      "type" => "Feature",
      "properties" => { "title" => @name },
      "geometry" => {
        "type" => "MultiLineString",
        # converts segment objects into array of coordinates 
        "coordinates" => @segments.map { |segment| segment.coordinates_array }
      }
    }
  end
  #converts the hash into json string formatting 
  def to_geojson
    to_geojson_hash.to_json
  end
end

#A series of points that format a line
class TrackSegment
  def initialize(coordinates)
    @coordinates = coordinates
  end

  #converts segment points into a array of coordinates 
  def coordinates_array
    @coordinates.map { |point| [point.lon, point.lat] }
  end
end

#Geographical point/ location 
class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end

  #Array of coodinates where elevatoin is optional 
  def point_coordinates
    coords = [@lon, @lat]
    coords << @ele if @ele
    coords
  end
end 

#Extends point to include more metadata (name and type)
class Waypoint < Point
  attr_reader :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    super(lon, lat, ele)
    @name = name
    @type = type
  end
#Returns hash of geojson 
  def to_geojson_hash
    feature = {
      "type" => "Feature",
      "properties" => {},
      "geometry" => {
        "type" => "Point",
        "coordinates" => point_coordinates
      }
    }
    
    #if name and type exist, add then. They are optional 
    feature["properties"]["title"] = @name if @name
    feature["properties"]["icon"] = @type if @type
    feature
  end
#converts hash into json string
  def to_geojson
    to_geojson_hash.to_json
  end
end 

#Contains all feautures, represents the enitre map 
class World
  def initialize(name, features = [])
    @name = name
    @features = features
  end
# Adds either track or Waypoint to the world 
  def add_feature(feature)
    @features << feature
  end
#converts to json string
  def to_geojson
    {
      "type" => "FeatureCollection",
      #convert each feature to it's hash representation 
      "features" => @features.map{ |feature| feature.to_geojson_hash }
    }.to_json
  end
end

def main
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  ts1 = [
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson
end

if File.identical?(__FILE__, $0)
  main()
end