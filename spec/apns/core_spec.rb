require File.dirname(__FILE__) + '/../spec_helper'

describe APNS do
  let(:notification_1) { APNS::Notification.new('device_token_1', {:alert => 'Hello iPhone', :badge => 3}) }
  let(:notification_2) { APNS::Notification.new('device_token_2', {:alert => 'Hello iPhone', :badge => 3}) }
  let(:notifications) { [notification_1, notification_2] }

  describe '#send_notifications' do
    context 'when tokens are ok' do
      it 'sends notifications and does not retry connecting again' do
        APNS.should_receive(:check_errors).and_return(false)
        APNS.should_receive(:open_connection).once.and_return([mock(close: nil), mock(write: '', close: nil)])
        APNS.send_notifications(notifications)
      end
    end

    context 'when there is an invalid token in batch' do
      context 'when first one is broken' do
        let(:expected_errors) { [APNS::Error.new(APNS::Error::INVALID_TOKEN, notification_1.message_identifier.unpack("N")[0], notification_1.device_token)] }

        before do
          APNS.should_receive(:check_errors).once.and_return(APNS::Error.new(APNS::Error::INVALID_TOKEN, notification_1.message_identifier.unpack("N")[0]))
        end

        it 'sends notification once' do
          APNS.should_receive(:check_errors).once.and_return(false)
          APNS.should_receive(:open_connection).twice.and_return([mock(close: nil), mock(write: '', close: nil)])
          APNS.send_notifications(notifications)
        end

        it 'returns invalid tokens' do
          APNS.should_receive(:check_errors).once.and_return(false)
          APNS.should_receive(:open_connection).twice.and_return([mock(close: nil), mock(write: '', close: nil)])
          errors = APNS.send_notifications(notifications)
          errors.count.should eql(1)
          assert_equal_error(errors.first, expected_errors.first)
        end
      end

      context 'when second one is broken' do
        let(:expected_errors) { [APNS::Error.new(APNS::Error::INVALID_TOKEN, notification_2.message_identifier.unpack("N")[0], notification_2.device_token)] }

        before do
          APNS.should_receive(:check_errors).once.and_return(APNS::Error.new(APNS::Error::INVALID_TOKEN, notification_2.message_identifier.unpack("N")[0]))
        end

        it 'sends notification once' do
          APNS.should_receive(:open_connection).twice.and_return([mock(close: nil), mock(write: '', close: nil)])
          APNS.send_notifications(notifications)
        end

        it 'returns invalid tokens' do
          APNS.should_receive(:open_connection).twice.and_return([mock(close: nil), mock(write: '', close: nil)])
          errors = APNS.send_notifications(notifications)
          errors.count.should eql(1)
          assert_equal_error(errors.first, expected_errors.first)
        end
      end
    end
  end

  def assert_equal_error(actual, expected)
    actual.code.should eql(APNS::Error::INVALID_TOKEN)
    actual.notification_id.should eql(expected.notification_id)
    actual.device_token.should eql(expected.device_token)
  end
end
