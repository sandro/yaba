#if config.respond_to?(:gems)
  #config.gem 'ruby-openid', :lib => 'openid', :version => '>=2.0.4'
#else
  #puts 'Please upgrade Rails to 2.1.0 or greater in order to use openid wrapper'
#end

#config.to_prepare do
  ActionController::Base.send :include, OpenidWrapper
#end

RAILS_DEFAULT_LOGGER.info "** openid_wrapper: initialized properly."
