class String
  def from_querystring_to_hash
    ActionController::AbstractRequest.send(:parse_query_parameters, self)
  end
end
