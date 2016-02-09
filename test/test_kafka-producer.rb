require 'test/unit'
require 'timeout'
require 'jruby-kafka'
require 'util'

class TestKafkaProducer < Test::Unit::TestCase
  def send_kafka_producer_msg(topic = 'test')
    producer = Kafka::KafkaProducer.new(KAFKA_PRODUCER_OPTIONS)
    producer.connect
    producer.send_msg(topic,nil, nil, 'test message')
  end

  def test_01_send_message
    topic = 'test_send'
    future = send_kafka_producer_msg topic
    assert_not_nil(future)
    begin
      timeout(30) do
        until future.isDone() do
          next
        end
      end
    end
    assert(future.isDone(), 'expected message to be done')
    assert(future.get().topic(), topic)
    assert_equal(future.get().partition(), 0)

  end

  def send_kafka_producer_msg_cb(&block)
    producer = Kafka::KafkaProducer.new(KAFKA_PRODUCER_OPTIONS)
    producer.connect
    producer.send_msg('test',nil, nil, 'test message', &block)
  end

  def test_02_send_msg_with_cb
    metadata = exception = nil
    future = send_kafka_producer_msg_cb { |md,e| metadata = md; exception = e }
    assert_not_nil(future)    
    begin
      timeout(30) do
        while metadata.nil? && exception.nil? do
          next
        end
      end
    end
    assert_not_nil(metadata)   
    assert_instance_of(Java::OrgApacheKafkaClientsProducer::RecordMetadata, metadata)
    assert_nil(exception)
    assert(future.isDone(), 'expected message to be done')
  end

  def test_03_get_sent_msg
    topic = 'get_sent_msg'
    send_kafka_producer_msg topic
    queue = SizedQueue.new(20)
    consumer = Kafka::Consumer.new(consumer_options({:topic => topic}))
    streams = consumer.message_streams
    streams.each_with_index do |stream|
      Thread.new { consumer_test stream, queue}
    end
    begin
      timeout(30) do
        until queue.length > 0 do
          sleep 1
          next
        end
      end
    end
    consumer.shutdown
    found = []
    until queue.empty?
      found << queue.pop
    end
    assert(found.include?('test message'), 'expected to find message: test message')
  end
end
