# frozen_string_literal: true

# Subdomain Helper Module
module SubdomainHelpers
  def subdomain(subdomain)
    host! "#{subdomain}.ecourt.gov.bt"
  end
end
