if Redmine::VERSION.to_s < '2.3'
  Dir[File.dirname(__FILE__) + '/compatibility/2.1/*.rb'].each { |f| require f }
end