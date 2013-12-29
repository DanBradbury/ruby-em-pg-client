$:.unshift "lib"
gem 'eventmachine', '~> 1.0.0'
gem 'pg', ENV['EM_PG_CLIENT_TEST_PG_VERSION']
require 'date'
require 'eventmachine'
require 'pg/em'

describe 'em-pg-client options' do
  subject                   { PG::EM::Client }

  let(:callback)            { proc {|c, e| false } }
  let(:args)                { [{async_autoreconnect: true, connect_timeout: 10, host: 'foo'}] }
  let(:str_key_args)        { [{'async_autoreconnect'=>true, 'connect_timeout'=>10, 'host'=>'foo'}] }
  let(:pgconn_args)         { [{connect_timeout: 10, host: 'foo'}] }
  let(:str_key_pgconn_args) { [{'connect_timeout'=>10, 'host'=>'foo'}] }
  let(:async_options)       { {
                                :@async_autoreconnect => true,
                                :@connect_timeout => 10,
                                :@query_timeout=>0,
                                :@on_autoreconnect=>nil,
                                :@async_command_aborted=>false} }

  it "should parse options and not modify original hash" do
    orig_args = args.dup
    orig_options = orig_args.first.dup
    options = subject.parse_async_options orig_args
    options.should eq async_options
    orig_args.should eq pgconn_args
    args.first.should eq orig_options
  end

  it "should parse options with keys as strings" do
    orig_args = str_key_args.dup
    orig_options = orig_args.first.dup
    options = subject.parse_async_options orig_args
    options.should eq async_options
    orig_args.should eq str_key_pgconn_args
    str_key_args.first.should eq orig_options
  end

  it "should set async_autoreconnect according to on_autoreconnect" do
    options = subject.parse_async_options []
    options.should be_an_instance_of Hash
    options[:@on_autoreconnect].should be_nil
    options[:@async_autoreconnect].should be_false

    args = [on_autoreconnect: callback]
    options = subject.parse_async_options args
    args.should eq [{}]
    options.should be_an_instance_of Hash
    options[:@on_autoreconnect].should be callback
    options[:@async_autoreconnect].should be_true

    args = [async_autoreconnect: false,
      on_autoreconnect: callback]
    options = subject.parse_async_options args
    args.should eq [{}]
    options.should be_an_instance_of Hash
    options[:@on_autoreconnect].should be callback
    options[:@async_autoreconnect].should be_false

    args = [on_autoreconnect: callback,
      async_autoreconnect: false]
    options = subject.parse_async_options args
    args.should eq [{}]
    options.should be_an_instance_of Hash
    options[:@on_autoreconnect].should be callback
    options[:@async_autoreconnect].should be_false
  end

  it "should set only callable on_autoreconnect" do
    expect do
      subject.parse_async_options [on_autoreconnect: true]
    end.to raise_error(ArgumentError, /must respond to/)

    expect do
      subject.parse_async_options [on_autoreconnect: Object.new]
    end.to raise_error(ArgumentError, /must respond to/)

    options = subject.parse_async_options [on_autoreconnect: callback]
    options.should be_an_instance_of Hash
    options[:@on_autoreconnect].should be callback
  end

end