require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class GitHubOrganization < OmniAuth::Strategies::OAuth2
      option :name, 'github_organization'
      option :scope, 'user,read:org'
      option :organization, 'example'
      # rubocop:disable Style/BracesAroundHashParameters
      option :client_options, {
        site: 'https://api.github.com',
        authorize_url: 'https://github.com/login/oauth/authorize',
        token_url: 'https://github.com/login/oauth/access_token'
      }

      def request_phase
        super
      end

      def authorize_params
        super.tap do |params|
          %w[scope client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      def callback_phase
        error = request.params["error_reason"] || request.params["error"]
        if error
          fail!(error, CallbackError.new(request.params["error"], request.params["error_description"] || request.params["error_reason"], request.params["error_uri"]))
        elsif !options.provider_ignores_state && (request.params["state"].to_s.empty? || request.params["state"] != session.delete("omniauth.state"))
          fail!(:csrf_detected, CallbackError.new(:csrf_detected, "CSRF detected"))
        else
          self.access_token = build_access_token
          self.access_token = access_token.refresh! if access_token.expired?
          self.access_token.options[:mode] = :query
          organizations = self.access_token.get('user/orgs', headers: { 'Accept' => 'application/vnd.github.v3' }).parsed
          fail!(:user_denied, CallbackError.new(:user_denied, options['organization'])) unless  organizations.map { |x| x['login'] }.include? options['organization']
          super
        end
      rescue ::OAuth2::Error, CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end

      uid { raw_info['id'].to_s }

      info do
        {
          'nickname' => raw_info['login'],
          'email' => email,
          'name' => raw_info['name'],
          'image' => raw_info['avatar_url'],
          'urls' => {
            'GitHub' => raw_info['html_url'],
            'Blog' => raw_info['blog'],
          },
        }
      end

      extra do
        { raw_info: raw_info, all_emails: emails }
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('user').parsed
      end

      def email
        email_access_allowed? ? primary_email : raw_info['email']
      end

      def primary_email
        primary = emails.find { |i| i['primary'] && i['verified'] }
        primary && primary['email'] || nil
      end

      # The new /user/emails API - http://developer.github.com/v3/users/emails/#future-response
      def emails
        return [] unless email_access_allowed?
        access_token.options[:mode] = :query
        @emails ||= access_token.get('user/emails', headers: { 'Accept' => 'application/vnd.github.v3' }).parsed
      end

      def email_access_allowed?
        return false unless options['scope']
        email_scopes = %w[user user:email]
        scopes = options['scope'].split(',')
        (scopes & email_scopes).any?
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

OmniAuth.config.add_camelization 'github_organization', 'GitHubOrganization'
