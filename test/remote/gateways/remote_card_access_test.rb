require 'test_helper'

class RemoteCardAccessTest < Test::Unit::TestCase
  
  def setup
    @gateway = CardAccessGateway.new(:merchant_id => '4097', :password => 'password1234')
    
    @amount = 100
    @approved_card = credit_card('4000000000000002')
    @declined_card = credit_card('4005550000000001')
    @credit_card = credit_card('4111111111111111')
    
    @options = {}
  end
  
  def test_approved_card_audit
    assert response = @gateway.audit(@amount, @options)
    assert_success response
  end
  
  def test_approved_card_purchase
    assert response = @gateway.purchase(@amount, @approved_card, @options)
    assert_success response
    assert_equal ['Approved or completed successfully'], response.message
  end
  
  def test_declined_card_purchase
    assert response = @gateway.purchase(@amount, @declined_card, @options)
    assert_failure response
    assert_equal ['Do not honour'], response.message
  end
  
  APPROVED_TESTS = {
    100 => 'Approved or completed successfully',
    200 => 'Honour with identification',
    300 => 'Approved for partial amount',
    400 => 'Approved VIP'
  }
  
  APPROVED_TESTS.each do |amount, message|
    define_method :"test_#{message.downcase.gsub(' ', '_')}_purchase" do
      assert response = @gateway.purchase(amount, @credit_card, @options)
      assert_success response
      assert_equal [message], response.message
    end
  end
  
  DECLINED_TESTS = {
    5 => 'Refer to card issuer',
    10 => 'Suspected fraud',
    33 => 'Expired card',
    51 => 'Exceeds withdrawal amount limits',
    68 => 'Lost card',
    205 => 'Do not honour',
    251 => 'Exceeds withdrawal frequency limit',
    268 => 'Stolen card, pick up',
    310 => 'Hard capture (requires that card be picked up at ATM)'
  }
  
  DECLINED_TESTS.each do |amount, message|
    define_method :"test_#{message.downcase.gsub(' ', '_')}_purchase" do
      assert response = @gateway.purchase(amount, @credit_card, @options)
      assert_failure response
      assert_equal [message], response.message
    end
  end
  
  def test_approved_authorize_and_capture
    assert authorize = @gateway.authorize(@amount, @approved_card, @options)
    assert_success authorize
    assert_equal ['Approved or completed successfully'], authorize.message
    assert authorize.authorization
    assert capture = @gateway.capture(@amount, @approved_card, authorize.authorization)
    assert_success capture
    assert_equal ['Approved or completed successfully'], capture.message
  end
  
  def test_approved_refund
    response = @gateway.purchase(@amount, @approved_card, @options)
    assert_success response
    
    assert response = @gateway.refund(@amount, @approved_card, response.audit, @options)
    assert_success response
    assert_equal ['Approved or completed successfully'], response.message
  end
  
  def test_invalid_merchant_id
    gateway = CardAccessGateway.new(:merchant_id => '1', :password => 'not_my_pass')
    assert response = gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal ['Reserved or private use', 'Security type is different from what is configured in MMI'], response.message
  end
  
  def test_invalid_password
    gateway = CardAccessGateway.new(:merchant_id => '4097', :password => 'not_my_pass')
    assert response = gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal ['Reserved or private use', 'Wrong security hash'], response.message
  end
end
