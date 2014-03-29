defmodule Exzmq.ZMQ3Test do
  use ExUnit.Case, async: false

  if System.get_env("ZMQ_TEST_SUITE") == "true" do

  def basic_tests_erlzmq(fun, transport, ip, port, type1, type2, mode, size) do
    basic_tests_erlzmq(fun, transport, ip, port, type1, [], type2, [], mode, size)
  end

  def basic_tests_erlzmq(fun, transport, ip, port, type1, id1, type2, id2, mode, size) do
    {:ok, c} = :erlzmq.context(1)
    {s1, s2} = create_bound_pair_erlzmq(c, type1, id1, type2, id2, mode, transport, ip, port)
    msg = String.duplicate("X", size)
    fun.({s1, s2}, msg, mode)
    ok = :erlzmq.close(s1)
    ok = Exzmq.close(s2)
    ok = :erlzmq.term(c)
  end

  def basic_tests_ezmq(fun, transport, ip, port, type1, type2, mode, size) do
    basic_tests_ezmq(fun, transport, ip, Port, type1, [], type2, [], mode, size)
  end

  def basic_tests_ezmq(fun, transport, ip, port, type1, id1, type2, id2, mode, size) do
    {:ok, c} = :erlzmq.context(1)
    {s1, s2} = create_bound_pair_ezmq(c, type1, id1, type2, id2, mode, transport, ip, port)
    msg = String.duplicate("X", size)
    fun({s1, s2}, msg, mode)
    :ok = Exzmq.close(s1)
    :ok = :erlzmq.close(s2)
    :ok = :erlzmq.term(c)
  end
  
  def create_bound_pair_erlzmq(ctx, type1, id1, type2, id2, mode, transport, ip, port) do
    
  	active = true

    if mode == :passive do
      active = false
    end
    
    {:ok, s1} = :erlzmq.socket(ctx, [type1, {:active, active}])
    {:ok, s2} = Exzmq.socket([{:type, type2}, {:active, active}, {:identity,id2}])
    :ok = erlzmq_identity(s1, id1)
    :ok = :erlzmq.bind(s1, transport)
    :ok = Exzmq.connect(s2, :tcp, ip, port, [])
    {s1, s2}
  end
  
  def erlzmq_identity(socket, []) do
    :ok
  end

  def erlzmq_identity(socket, id) do
    :erlzmq.setsockopt(socket, :identity, id)
  end
 
  test "reqrep_tcp_test_active" do
    basic_tests_erlzmq(&ping_pong_erlzmq/3, 'tcp://127.0.0.1:5555', {127,0,0,1}, 5555, :req, :rep, :active, 3)
    basic_tests_ezmq(&ping_pong_ezmq/3, 'tcp://127.0.0.1:5555', {127,0,0,1}, 5555, :req, :rep, :active, 3)
  end

  test "reqrep_tcp_test_passive" do
    basic_tests_erlzmq(&ping_pong_erlzmq/3, 'tcp://127.0.0.1:5556', {127,0,0,1}, 5556, :req, :rep, :passive, 3)
    basic_tests_ezmq(&ping_pong_ezmq/3, 'tcp://127.0.0.1:5556', {127,0,0,1}, 5556, :req, :rep, :passive, 3)
  end

  test "reqrep_tcp_id_test_active" do
    basic_tests_erlzmq(&ping_pong_erlzmq/3, 'tcp://127.0.0.1:5555', {127,0,0,1}, 5555, :req, "reqrep_tcp_id_test_active_req", :rep, "reqrep_tcp_id_test_active_rep", :active, 3)
    basic_tests_ezmq(&ping_pong_ezmq/3, 'tcp://127.0.0.1:5555', {127,0,0,1}, 5555, :req, "reqrep_tcp_id_test_active_req", :rep, "reqrep_tcp_id_test_active_rep", :active, 3)
  end

  test "reqrep_tcp_id_test_passive" do
    basic_tests_erlzmq(&ping_pong_erlzmq/3, 'tcp://127.0.0.1:5556', {127,0,0,1}, 5556, :req, "reqrep_tcp_id_test_passive_req", :rep, "reqrep_tcp_id_test_passive_rep", :passive, 3)
    basic_tests_ezmq(&ping_pong_ezmq/3, 'tcp://127.0.0.1:5556', {127,0,0,1}, 5556, :req, "reqrep_tcp_id_test_passive_req", :rep, "reqrep_tcp_id_test_passive_rep", :passive, 3)
  end

  test "reqrep_tcp_large_active" do
    basic_tests_erlzmq(&ping_pong_erlzmq/3, 'tcp://127.0.0.1:5557', {127,0,0,1}, 5557, :req, :rep, :active, 256)
    basic_tests_ezmq(&ping_pong_ezmq/3, 'tcp://127.0.0.1:5557', {127,0,0,1}, 5557, :req, :rep, :active, 256)
  end

  test "reqrep_tcp_large_passive" do
    basic_tests_erlzmq(&ping_pong_erlzmq/3, 'tcp://127.0.0.1:5558', {127,0,0,1}, 5558, :req, :rep, :passive, 256)
    basic_tests_ezmq(&ping_pong_ezmq/3, 'tcp://127.0.0.1:5558', {127,0,0,1}, 5558, :req, :rep, :passive, 256)
  end
 
  test "dealerrep_tcp_test_active" do
    basic_tests_erlzmq(&ping_pong_erlzmq_dealer/3, 'tcp://127.0.0.1:5559', {127,0,0,1}, 5559, :dealer, :rep, :active, 4)
    basic_tests_ezmq(&ping_pong_ezmq_dealer/3, 'tcp://127.0.0.1:5559', {127,0,0,1}, 5559, :dealer, :rep, :active, 4)
  end

  test "dealerrep_tcp_test_passive" do
    basic_tests_erlzmq(&ping_pong_erlzmq_dealer/3, 'tcp://127.0.0.1:5560', {127,0,0,1}, 5560, :dealer, :rep, :passive, 3)
    basic_tests_ezmq(&ping_pong_ezmq_dealer/3, 'tcp://127.0.0.1:5560', {127,0,0,1}, 5560, :dealer, :rep, :passive, 3)
  end
  
  test "reqdealer_tcp_id_test_active" do
    basic_tests_erlzmq(&ping_pong_erlzmq_dealer/3, 'tcp://127.0.0.1:5561', {127,0,0,1}, 5561, :req, "reqdealer_tcp_id_test_active_req", :dealer, "reqdealer_tcp_test_active_dealer", :active, 3)
    basic_tests_ezmq(&ping_pong_ezmq_dealer/3, 'tcp://127.0.0.1:5561', {127,0,0,1}, 5561, :req, "reqdealer_tcp_id_test_active_req", :dealer, "reqdealer_tcp_test_active_dealer", :active, 3)
  end

  test "reqdealer_tcp_id_test_passive" do
    basic_tests_erlzmq(&ping_pong_erlzmq_dealer/3, 'tcp://127.0.0.1:5562', {127,0,0,1}, 5562, :req, "reqdealer_tcp_id_test_passive_req", :dealer, "reqdealer_tcp_test_passive_dealer", :active, 3)
    basic_tests_ezmq(&ping_pong_ezmq_dealer/3, 'tcp://127.0.0.1:5562', {127,0,0,1}, 5562, :req, "reqdealer_tcp_id_test_passive_req", :dealer, "reqdealer_tcp_test_passive_dealer", :active, 3)
  end

  test "reqrouter_tcp_test_active" do
    basic_tests_erlzmq(&ping_pong_erlzmq_router/3, 'tcp://127.0.0.1:5561', {127,0,0,1}, 5561, :req, :router, :active, 3)
    basic_tests_ezmq(&ping_pong_ezmq_router/3, 'tcp://127.0.0.1:5561', {127,0,0,1}, 5561, :req, :router, :active, 3)
  end

  test "reqrouter_tcp_test_passive" do
    basic_tests_erlzmq(&ping_pong_erlzmq_router/3, 'tcp://127.0.0.1:5562', {127,0,0,1}, 5562, :req, :router, :passive, 3)
    basic_tests_ezmq(&ping_pong_ezmq_router/3, 'tcp://127.0.0.1:5562', {127,0,0,1}, 5562, :req, :router, :passive, 3)
  end

  test "reqrouter_tcp_id_test_active" do
    basic_tests_erlzmq(&ping_pong_erlzmq_router/3, 'tcp://127.0.0.1:5561', {127,0,0,1}, 5561, :req, "reqrouter_tcp_test_active_req", :router, "reqrouter_tcp_test_active_router", :active, 3)
    basic_tests_ezmq(&ping_pong_ezmq_router/3, 'tcp://127.0.0.1:5561', {127,0,0,1}, 5561, :req, "reqrouter_tcp_test_active_req", :router, "reqrouter_tcp_test_active_router", :active, 3)
  end

  test "reqrouter_tcp_id_test_passive" do
    basic_tests_erlzmq(&ping_pong_erlzmq_router/3, 'tcp://127.0.0.1:5562', {127,0,0,1}, 5562, :req, "reqrouter_tcp_test_active_req", :router, "reqrouter_tcp_test_active_router", :passive, 3)
    basic_tests_ezmq(&ping_pong_ezmq_router/3, 'tcp://127.0.0.1:5562', {127,0,0,1}, 5562, :req, "reqrouter_tcp_test_active_req", :router, "reqrouter_tcp_test_active_router", :passive, 3)
  end
   
  def ping_pong_erlzmq({s1, s2}, msg, :active) do
    :ok = :erlzmq.send(s1, msg, [:sndmore])
    :ok = :erlzmq.send(s1, msg)
    assert_mbox({:zmq, s2, [msg,msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s2, [msg])
    assert_mbox({:zmq, s1, msg, []})

    :ok = :erlzmq.send(s1, msg)
    assert_mbox({:zmq, s2, [msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s2, [msg])
    assert_mbox({:zmq, s1, msg, []})
    assert_mbox_empty()

    :ok
  end

  def ping_pong_erlzmq({s1, s2}, msg, :active) do
    :ok = :erlzmq.send(s1, msg, [:sndmore])
    :ok = :erlzmq.send(s1, msg)
    assert_mbox({:zmq, s2, [msg,msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s2, [msg])
    assert_mbox({:zmq, s1, msg, []})

    :ok = :erlzmq.send(s1, msg)
    assert_mbox({:zmq, s2, [msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s2, [msg])
    assert_mbox({:zmq, s1, msg, []})
    assert_mbox_empty()

    :ok
  end

  def ping_pong_erlzmq({s1, s2}, msg, :passive) do
    :ok = :erlzmq.send(s1, msg)
    {:ok, [msg]} = Exzmq.recv(s2)
    :ok = Exzmq.send(s2, [msg])
    {:ok, msg} = :erlzmq.recv(s1)
    :ok = :erlzmq.send(s1, msg, [:sndmore])
    :ok = :erlzmq.send(s1, msg)
    {:ok, [msg,msg]} = Exzmq.recv(s2)
    :ok
  end

  def ping_pong_ezmq({s1, s2}, msg, :active) do
    :ok = Exzmq.send(s1, [msg,msg])
    assert_mbox({:zmq, s2, msg, [:rcvmore]})
    assert_mbox({:zmq, s2, msg, []})
    assert_mbox_empty()

    :ok = :erlzmq.send(s2, msg)
    assert_mbox({:zmq, s1, [msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s1, [msg])
    assert_mbox({:zmq, s2, msg, []})
    assert_mbox_empty()

    :ok = :erlzmq.send(s2, msg, [:sndmore])
    :ok = :erlzmq.send(s2, msg)
    assert_mbox({zmq, s1, [msg,msg]})
    assert_mbox_empty()

    :ok
  end
      
  def ping_pong_ezmq({s1, s2}, msg, passive) do
    :ok = Exzmq.send(s1, [msg])
    {:ok, msg} = :erlzmq.recv(s2)
    :ok = :erlzmq.send(s2, msg)
    {:ok, [msg]} = Exzmq.recv(s1)
    :ok = Exzmq.send(s1, [msg,msg])
    {:ok, msg} = :erlzmq.recv(s2)
    {:ok, msg} = :erlzmq.recv(s2)
    :ok
  end

  def ping_pong_erlzmq_dealer({s1, s2}, msg, active) do
    :ok = :erlzmq.send(s1, msg, [:sndmore])
    :ok = :erlzmq.send(s1, msg)
    assert_mbox({:zmq, s2, [msg,msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s2, [msg])
    assert_mbox({:zmq, s1, msg, []})

    :ok = :erlzmq.send(s1, msg)
    assert_mbox({:zmq, s2, [msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s2, [msg])
    assert_mbox({zmq, s1, msg, []})
    assert_mbox_empty()

    :ok
  end
      
  def ping_pong_erlzmq_dealer({s1, s2}, msg, :passive) do
    :ok = :erlzmq.send(s1, msg)
    {:ok, [msg]} = Exzmq.recv(s2)
    :ok = Exzmq.send(s2, [msg])
    {:ok, msg} = :erlzmq.recv(s1)
    :ok = :erlzmq.send(s1, msg, [:sndmore])
    :ok = :erlzmq.send(s1, msg)
    {:ok, [msg,msg]} = Exzmq.recv(s2)
    :ok
  end

  def ping_pong_ezmq_dealer({s1, s2}, msg, :active) do
    :ok = Exzmq.send(s1, [msg,msg])
    assert_mbox({:zmq, s2, <<>>, [:rcvmore]})
    assert_mbox({:zmq, s2, msg, [:rcvmore]})
    assert_mbox({:zmq, s2, msg, []})
    assert_mbox_empty()

    :ok = :erlzmq.send(s2, <<>>, [:sndmore])
    :ok = :erlzmq.send(s2, msg)
    assert_mbox({:zmq, s1, [msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s1, [msg])
    assert_mbox({:zmq, s2, <<>>, [:rcvmore]})
    assert_mbox({:zmq, s2, msg, []})
    assert_mbox_empty()

    :ok = :erlzmq.send(s2, <<>>, [:sndmore])
    :ok = :erlzmq.send(s2, msg, [:sndmore])
    :ok = :erlzmq.send(s2, msg)
    assert_mbox({:zmq, s1, [msg,msg]})
    assert_mbox_empty()

    :ok
  end
      
  def ping_pong_ezmq_dealer({s1, s2}, msg, :passive) do
    :ok = Exzmq.send(s1, [msg])
    {:ok, <<>>} = :erlzmq.recv(s2)
    {:ok, msg} = :erlzmq.recv(s2)
    :ok = :erlzmq.send(s2, <<>>, [sndmore])
    :ok = :erlzmq.send(s2, msg)
    {:ok, [msg]} = Exzmq.recv(s1)
    :ok = Exzmq.send(s1, [msg,msg])
    {:ok, <<>>} = :erlzmq.recv(s2)
    {:ok, msg} = :erlzmq.recv(s2)
    {:ok, msg} = :erlzmq.recv(s2)
    :ok
  end

  def dealer_ping_pong_erlzmq({s1, s2}, msg, active) do
    :ok = :erlzmq.send(s1, <<>>, [:sndmore])
    :ok = :erlzmq.send(s1, msg, [:sndmore])
    :ok = :erlzmq.send(s1, msg)

    assert_mbox({zmq, s2, [msg,msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s2, [msg])
    assert_mbox({zmq, s1, <<>>, [:rcvmore]})
    assert_mbox({zmq, s1, msg, []})
    assert_mbox_empty()

    :ok = :erlzmq.send(s1, <<>>, [:sndmore])
    :ok = :erlzmq.send(s1, msg)
    assert_mbox({zmq, s2, [msg]})
    assert_mbox_empty()

    :ok = Exzmq.send(s2, [msg])
    assert_mbox({zmq, s1, <<>>, [:rcvmore]})
    assert_mbox({zmq, s1, msg, []})
    assert_mbox_empty()

    :ok
  end
      
  def dealer_ping_pong_erlzmq({s1, s2}, msg, :passive) do
    :ok = :erlzmq.send(s1, <<>>, [:sndmore])
    :ok = :erlzmq.send(s1, msg)
    {:ok, [msg]} = Exzmq.recv(s2)
    :ok = Exzmq.send(s2, [msg])
    {:ok, <<>>} = :erlzmq.recv(s1)
    {:ok, msg} = :erlzmq.recv(s1)
    :ok = :erlzmq.send(s1, <<>>, [sndmore])
    :ok = :erlzmq.send(s1, msg, [sndmore])
    :ok = :erlzmq.send(s1, msg)
    {:ok, [msg,msg]} = Exzmq.recv(s2)
    :ok
  end

  ## assert that message queue is empty....
  def assert_mbox_empty() do
    receive do
      m -> assert false
	  after
	    0 -> :ok
  	end
  end

  ## assert that top message in the queue is what we think it should be
  def assert_mbox(msg) do
    assert_mbox_match({msg,[],[:ok]})
  end

  def assert_mbox_match(match_spec) do
    compiled_match_spec = :ets.match_spec_compile([match_spec])
    receive do
      m -> case :ets.match_spec_run([m], compiled_match_spec) do
                [] -> assert false
                [ret] -> ret
           end
      after
       1000 ->
           assert false
    end
  end

  end

end