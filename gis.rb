#!/usr/bin/env ruby

class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end
    # set segments to segment_objects
    @segments = segment_objects
  end

  def to_geojson()
    {
      type: 'Feature', 
      properties: { title: @name }, 
      geometry:{
        type: 'MiltiLineString', 
        coordinates: @segments.map { |segments| segment.to_geojson }

      }
    }
  end
end

class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint

attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def to_geojson(indent=0)
    {
      "type": "Feature",
        geometry:{
          type: 'Point',
          coordinates: "[#{@lon}, #{@lat}]"
        },
        properties: {
          title: @name, 
          icon: @type
        }
    }
  end
end 

class World
def initialize(name, features = [])
  @name = name
  @features = features
end
  def add_feature(feature)
    @features.append(feature)
  end

  def to_geojson(indent=0)
    # translates output to json 
    {
      type: 'FeatureCollection', 
      #applies to_geojson method to each element in features and then puts that in a new array
      features: @features.map { |feature| feature.to_geojson }

    }
  end
end

def main()
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

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

