require 'spec_helper'
require 'models/session_proxy'
require 'models/cookie_names'
require 'rails_helper'

describe SessionProxy do
  let(:api_client) { double(:api_client) }
  let(:path) { "/session" }

  it 'should return cookies when a session is created' do
    x_forwarded_for = double(:x_forwarded_for)
    authn_request_body = {
        SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
        SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
        SessionProxy::PARAM_ORIGINATING_IP => x_forwarded_for
    }
    cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time'
    }
    expect(api_client).to receive(:post).with(path, authn_request_body).and_return(cookie_hash)
    cookies = SessionProxy.new(api_client).create_session('my-saml-request', 'my-relay-state', x_forwarded_for)
    expect(cookies).to eq cookie_hash
  end

  it 'should return a list of IDP ids for the session' do
    cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
        'SOME_OTHER_COOKIE' => 'something else'
    }

    expected_cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
    }
    idp_list = double(:idp_list)

    expect(api_client).to receive(:get).with('/session/idps', {cookies: expected_cookie_hash}).and_return(idp_list)
    result = SessionProxy.new(api_client).idps_for_session(cookie_hash)
    expect(result).to eq idp_list
  end

  it 'should select an IDP for the session' do
    cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
        'SOME_OTHER_COOKIE' => 'something else'
    }

    expected_cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
    }

    ip_address = '1.1.1.1'
    body = {'entityId' => 'an-entity-id', 'originatingIp' => ip_address}
    expect(api_client).to receive(:put)
      .with(SessionProxy::SELECT_IDP_PATH, body, {cookies: expected_cookie_hash})
    SessionProxy.new(api_client).select_idp(cookie_hash, 'an-entity-id', ip_address)
  end

  it 'should get an IDP authn request' do
    cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
        'SOME_OTHER_COOKIE' => 'something else'
    }

    expected_cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
    }
    authn_request = {
        'location' => 'some-location',
        'samlRequest' => 'a-saml-request',
        'relayState' => 'relay-state',
        'registration' => false
    }
    ip_address = '1.1.1.1'
    params = {SessionProxy::PARAM_ORIGINATING_IP => ip_address}
    expect(api_client).to receive(:get)
      .with(SessionProxy::IDP_AUTHN_REQUEST_PATH, {cookies: expected_cookie_hash, params: params})
      .and_return(authn_request)
    result = SessionProxy.new(api_client).idp_authn_request(cookie_hash, ip_address)
    attributes = {
        'location' => 'some-location',
        'saml_request' => 'a-saml-request',
        'relay_state' => 'relay-state',
        'registration' => false
    }
    expect(result).to have_attributes(attributes)
  end

  it 'should fail to get an IDP authn request when fields are missing from response' do
    cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
        'SOME_OTHER_COOKIE' => 'something else'
    }

    expected_cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
    }
    authn_request = {
        'location' => 'some-location',
        'relayState' => 'relay-state',
        'registration' => false
    }
    ip_address = '1.1.1.1'
    params = {SessionProxy::PARAM_ORIGINATING_IP => ip_address}
    expect(api_client).to receive(:get)
      .with(SessionProxy::IDP_AUTHN_REQUEST_PATH, {cookies: expected_cookie_hash, params: params})
      .and_return(authn_request)
    expect {
      SessionProxy.new(api_client).idp_authn_request(cookie_hash, ip_address)
    }.to raise_error SessionProxy::ModelError, "Saml request can't be blank"
  end
end
