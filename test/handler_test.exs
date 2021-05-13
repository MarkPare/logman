defmodule LogmanHandlerTest do
  use ExUnit.Case

  @test_logs_dir "logs/test"

  setup do
    File.rm_rf!(@test_logs_dir)
    on_exit(fn -> File.rm_rf!(@test_logs_dir) end)
    :ok
  end

  test "logs message to file" do
    message = "123 some message\n"  
    path = Logman.Handler.get_log_file_path()

    Logman.Handler.log(message)

    assert File.exists?(path)
    assert File.read!(path) == message

    # Test that appending to file works
    next_message = "456 next message\n"

    Logman.Handler.log(next_message)

    assert File.read!(path) == message <> next_message
  end

  # NOTE: could not get multiple nodes to run during tests
  # because of address in use error caused by each node trying
  # to run http server on same port.
  # test "calls log on local node and on other nodes" do
  #   _ = :os.cmd('epmd -daemon')
  #   :ok = LocalCluster.start()
  #   nodes = LocalCluster.start_nodes("my-cluster", 3)
  #   [node1, node2, node3] = nodes
  #   :ok = LocalCluster.stop()
  #   assert true
  # end
end
