require 'openid/association'

class Association < ActiveRecord::Base
  set_table_name 'openid_associations'
  def from_record
    OpenID::Association.new(handle, secret, issued, lifetime, assoc_type)
  end
end

