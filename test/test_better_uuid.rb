require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class TestBetterUUID < Test::Unit::TestCase
  def setup
    @uuid = UUIDTools::UUID.timestamp_create
  end

  def test_is_stored_in_its_raw_form
    model = UuidActiveRecordTest.new
    model.uuid = @uuid
    assert_equal(@uuid.raw, model.send(:read_attribute_before_type_cast, "uuid"))
    assert_equal(@uuid.hexdigest, model.uuid)
  end

  def test_can_write_string_styled_uuids
    model = UuidActiveRecordTest.new
    model.uuid = @uuid.to_s
    assert_equal(@uuid.raw, model.send(:read_attribute_before_type_cast, "uuid"))
    assert_equal(@uuid.hexdigest, model.uuid)
  end

  def test_can_write_hexdigest_uuids
    model = UuidActiveRecordTest.new
    model.uuid = @uuid.hexdigest
    assert_equal(@uuid.raw, model.send(:read_attribute_before_type_cast, "uuid"))
    assert_equal(@uuid.hexdigest, model.uuid)
  end

  def test_can_save_and_retrieve_UUIDs
    model = UuidActiveRecordTest.new
    model.uuid = @uuid
    model.save!
    model.reload
    assert_equal(@uuid.hexdigest, model.uuid)
    assert_equal(@uuid.raw, model.send(:read_attribute_before_type_cast, "uuid"))
  end

  def test_adds_a_UUID_on_save
    model = UuidActiveRecordTest.new
    assert(model.uuid.blank?)
    model.save!
    assert(!model.uuid.blank?)
    assert_equal(32, model.uuid.size)
  end

  def test_finds_a_model_by_UUID
    UuidActiveRecordTest.create!
    m = UuidActiveRecordTest.find(:first, :conditions => ["UUID is not null"])
    uuid = m.uuid
    assert(!uuid.blank?)
    found_m = UuidActiveRecordTest.find(:first, :conditions => {:uuid => uuid})
    assert_equal(m, found_m)
    found_m = UuidActiveRecordTest.find_by_uuid(uuid)
    assert_equal(m, found_m)
  end
end
