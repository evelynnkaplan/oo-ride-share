require "csv"
require "time"

require_relative "passenger"
require_relative "trip"
require_relative "driver"

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(directory: "./support")
      @drivers = Driver.load_all(directory: directory)
      @passengers = Passenger.load_all(directory: directory)
      @trips = Trip.load_all(directory: directory)
      connect_trips
    end

    def find_passenger(id)
      Passenger.validate_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    def find_driver(id)
      Driver.validate_id(id)
      return @drivers.find { |driver| driver.id == id }
    end

    def inspect
      # Make puts output more useful
      return "#<#{self.class.name}:0x#{object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    def request_trip(passenger_id)
      i = 1
      @drivers.each do |driver|
        if driver.status == :AVAILABLE
          @driver = driver
          break
        end
        i += 1
        if @drivers.length == i
          raise NotImplementedError, "No available drivers."
          exit
        end
      end

      trip_id = @trips.length + 1
      passenger = find_passenger(passenger_id)

      trip = RideShare::Trip.new(id: trip_id, driver: @driver, driver_id: @driver.id, passenger: passenger, passenger_id: passenger_id, start_time: Time.now.to_s)

      @driver.add_requested_trip(trip)
      passenger.add_trip(trip)
      @trips << trip

      return trip
    end

    private

    def connect_trips
      @trips.each do |trip|
        passenger = find_passenger(trip.passenger_id)
        trip.connect_passenger(passenger)
        driver = find_driver(trip.driver_id)
        trip.connect_driver(driver)
      end

      return trips
    end
  end
end
