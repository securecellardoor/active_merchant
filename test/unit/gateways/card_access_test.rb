require 'test_helper'

class CardAccessTest < Test::Unit::TestCase
  def setup
    @gateway = CardAccessGateway.new(:merchant_id => '4097', :password => 'password')
    
    @credit_card = credit_card
    @amount = 100
    @declined_amount = 200

    @options = {
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end

  def test_successful_audit
    @gateway.expects(:ssl_post).returns(successful_audit_response)
  
    assert response = @gateway.audit(@amount, @options)
    assert_instance_of CardAccessResponse, response
    assert_success response
  
    assert_equal '1320866', response.status['CAS.RESPONSE.AUDIT1']
    assert response.test?
  end
  
  def test_successful_authorize
    @gateway.expects(:ssl_post).returns(successful_authorize_response)
    @gateway.expects(:ssl_post).returns(successful_audit_response)
  
    assert response = @gateway.authorize(@amount, @credit_card, @options)
    assert_instance_of CardAccessResponse, response
    assert_success response
  
    assert_equal '0', response.status['CAS.RESPONSE.STATUSCODE']
    assert_equal ['Approved or completed successfully'], response.message
    assert response.test?
  end
  
  def test_successful_capture
    @gateway.expects(:ssl_post).returns(successful_capture_response)
    @gateway.expects(:ssl_post).returns(successful_audit_response)
  
    assert response = @gateway.capture(@amount, @credit_card, 'authorization', @options)
    assert_instance_of CardAccessResponse, response
    assert_success response
    
    assert_equal '0', response.status['CAS.RESPONSE.STATUSCODE']
    assert_equal ['Approved or completed successfully'], response.message
    assert response.test?
  end
  
  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    @gateway.expects(:ssl_post).returns(successful_audit_response)
  
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_instance_of CardAccessResponse, response
    assert_success response
  
    assert_equal '0', response.status['CAS.RESPONSE.STATUSCODE']
    assert_equal ['Approved or completed successfully'], response.message
    assert response.test?
  end
  
  def test_successful_refund
    @gateway.expects(:ssl_post).returns(successful_refund_response)
    @gateway.expects(:ssl_post).returns(successful_audit_response)
  
    assert response = @gateway.refund(@amount, @credit_card, 'audit', @options)
    assert_instance_of CardAccessResponse, response
    assert_success response
  
    assert_equal '0', response.status['CAS.RESPONSE.STATUSCODE']
    assert_equal ['Approved or completed successfully'], response.message
    assert response.test?
  end
  
  def test_unsuccessful_audit
    @gateway.expects(:ssl_post).returns(unsuccessful_audit_response)
  
    assert response = @gateway.audit(@amount, @options)
    assert_instance_of CardAccessResponse, response
    assert_failure response
    
    assert_equal '60', response.status['CAS.RESPONSE.STATUSCODE']
    assert_equal ['Reserved or private use', 'Internal error'], response.message
    assert response.test?
  end
  
  def test_unsuccessful_blank_response
    @gateway.expects(:ssl_post).returns('')
  
    assert_raise(ActiveMerchant::Billing::InvalidCardAccessResponseError) do
      @gateway.authorize(@amount, @credit_card, @options)
    end
  end
  
  def test_unsuccessful_invalid_response
    @gateway.expects(:ssl_post).returns(invalid_response)
  
    assert_raise(ActiveMerchant::Billing::InvalidCardAccessResponseError) do
      @gateway.authorize(@amount, @credit_card, @options)
    end
  end
  
  def test_unsuccessful_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)
    @gateway.expects(:ssl_post).returns(successful_audit_response)
  
    assert response = @gateway.purchase(@declined_amount, @credit_card, @options)
    assert_failure response
    assert_equal ['Do not honour'], response.message
    assert response.test?
  end
  
  def test_unsuccessful_purchase_with_invalid_audit
    @gateway.expects(:ssl_post).returns(unsuccessful_audit_response)
  
    assert response = @gateway.purchase(@declined_amount, @credit_card, @options)
    assert_failure response
    assert_equal '60', response.status['CAS.RESPONSE.STATUSCODE']
    assert_equal ['Reserved or private use', 'Internal error'], response.message
    assert response.test?
  end

private

  def invalid_response
    <<-RESPONSE
DESTART
DE001=0110
DE004=100
DE015=1006
DE038=555555
DE039=00
DE042=000000000004097
DE048=CAS.RESPONSE.MSG=&CAS.RESPONSE.STATUSCODE=MA==&CAS.AUDIT=MTMyMDg2Ng==
    RESPONSE
  end

  def failed_purchase_response
    <<-RESPONSE
DESTART
DE001=0210
DE003=003000
DE004=100
DE015=1006
DE038=
DE039=05
DE042=000000000004097
DE048=CAS.RESPONSE.MSG=&CAS.RESPONSE.STATUSCODE=MA==&CAS.AUDIT=MTMyMDg2Ng==
DESTOP
    RESPONSE
  end
  
  def successful_audit_response
    <<-RESPONSE
DESTART
DE001=0810
DE039=00
DE042=000000000004097
DE048=CAS.RESPONSE.AUDIT1=MTMyMDg2Ng==&CAS.RESPONSE.AUDIT=MQ==
DESTOP
    RESPONSE
  end

  def successful_authorize_response
    <<-RESPONSE
DESTART
DE001=0110
DE004=100
DE015=1006
DE038=555555
DE039=00
DE042=000000000004097
DE048=CAS.RESPONSE.MSG=&CAS.RESPONSE.STATUSCODE=MA==&CAS.AUDIT=MTMyMDg2Ng==
DESTOP
    RESPONSE
  end

  def successful_capture_response
    <<-RESPONSE
DESTART
DE001=0230
DE004=100
DE015=1006
DE038=555555
DE039=00
DE042=000000000004097
DE048=CAS.RESPONSE.MSG=&CAS.RESPONSE.STATUSCODE=MA==&CAS.AUDIT=MTMyMDg2Ng==
DESTOP
    RESPONSE
  end

  def successful_purchase_response
    <<-RESPONSE
DESTART
DE001=0210
DE003=003000
DE004=100
DE015=1006
DE038=555555
DE039=00
DE042=000000000004097
DE048=CAS.RESPONSE.MSG=&CAS.RESPONSE.STATUSCODE=MA==&CAS.AUDIT=MTMyMDg2Ng==
DESTOP
    RESPONSE
  end

  def successful_refund_response
    <<-RESPONSE
DESTART
DE001=0210
DE003=200030
DE004=100
DE039=00
DE042=000000000004097
DE048=CAS.RESPONSE.MSG=&CAS.RESPONSE.STATUSCODE=MA==&CAS.AUDIT=MTMyMDg2Ng==
DESTOP
    RESPONSE
  end

  def unsuccessful_audit_response
    <<-RESPONSE
DESTART
DE001=0810
DE039=85
DE042=000000000004097
DE048=CAS.RESPONSE.MSG=SW50ZXJuYWwgZXJyb3I=&CAS.RESPONSE.STATUSCODE=NjA=
DESTOP
    RESPONSE
  end

end
