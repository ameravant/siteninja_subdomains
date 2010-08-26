module ActionController
  module Routing
    class RouteSet
      def extract_request_environment(request)
        { :method => request.method, :subdomain => request.subdomains.last }
      end
    end
    class Route
      alias_method :old_recognition_conditions, :recognition_conditions
      def recognition_conditions
        result = old_recognition_conditions
        result << "conditions[:subdomain]" if conditions[:subdomain] 
        result
      end
    end
  end
end
