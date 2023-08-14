defmodule SpresenseHostif do
  @moduledoc """
  Documentation for SpresenseHostif.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SpresenseHostif.hello
      :world

  """
  def hello do
    :world
  end

  require Logger
  alias Circuits.SPI
  @icmd_available_size_id 0x10

  def get_bufsize(buffer_id) do
    {:ok, ref} = SPI.open("spidev0.0", mode: 1, speed_hz: 800000)
    icmd_available_cmd = @icmd_available_size_id + buffer_id

    {:ok, <<_::16, cmd_result::8, bufsize::16-little>>} = SPI.transfer(ref, <<icmd_available_cmd, 0xff, 0xff, 0xff, 0xff>>)

    Circuits.SPI.close(ref)

    Logger.info("cmd_result = #{cmd_result}, Buffer id = #{buffer_id}, Buffer size = #{bufsize}")

    case cmd_result do
      0 -> {:ok, bufsize}
      _ -> {:error, 0}
    end
  end

end
