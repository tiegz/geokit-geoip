require File.dirname(__FILE__) + '/test_helper.rb'

class TestGeokitGeoip < MiniTest::Test

  context "GeoIpCityGeocoder" do
    setup do
      @geocoder = Geokit::Geocoders::GeoIpCityGeocoder
    end

    should "have a default geoip_data_path" do
      path = File.expand_path(File.join(File.dirname(__FILE__), "..", "data", "GeoLiteCity.dat"))
      assert_equal path, Geokit::Geocoders.geoip_data_path
    end

    should "be able to set geoip_data_path" do
      orig_path = Geokit::Geocoders.geoip_data_path
      Geokit::Geocoders.geoip_data_path = "foo"
      assert_equal "foo", Geokit::Geocoders.geoip_data_path
      # Reset
      Geokit::Geocoders.geoip_data_path = orig_path
    end


    bad_ips = ["nonesuch", "0.0.0.0", "127.0.0.1"]
    bad_ips.each do |bad_ip|
      should "return a blank GeoLoc for #{bad_ip}" do
        assert_equal Geokit::GeoLoc.new, @geocoder.geocode(bad_ip)
      end
    end

    context "with a good ip" do
      setup { @ip = '67.244.97.190' }
      should "be successful" do
        result = @geocoder.geocode(@ip)
        assert result.success?, result.city
      end
      should "set the right attributes" do
        loc = @geocoder.geocode(@ip)
        assert_equal "New York", loc.city
        assert_equal "NY", loc.state
        assert_equal "US", loc.country_code
        assert (40..41).include?(loc.lat)
        assert (-74..-73).include?(loc.lng)
        assert_equal 5, loc.zip.size
      end
    end

    context "with a good ip that returns ISO-8859-I" do
      setup { @ip = '66.203.219.253' }
      should "be successful" do
        result = @geocoder.geocode(@ip)
        assert result.success?, result.city
      end
      should "set the right attributes (as UTF8)" do
        loc = @geocoder.geocode(@ip)
        puts loc.city
        assert_equal "Linière", loc.city
        assert_equal "QC", loc.state
        assert_equal "CA", loc.country_code
        assert (46..47).include?(loc.lat)
        assert (-71..-70).include?(loc.lng)
        assert_equal 0, loc.zip.size
      end
    end
  end
end
