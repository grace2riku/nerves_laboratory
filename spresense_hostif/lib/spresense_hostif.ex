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
  @icmd_varlen_trans_id 0xa0

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

  def get_version do
    # バージョンが格納されているバッファのサイズを取得する。spresenseサンプルプログラムでは2
    {:ok, bufsize} = get_bufsize(2)

    # dummy data(2byte) + status(1byte)
    total_len = bufsize + 3
    {cmd_result, version_str} = host_receive(2, total_len, true)

    case cmd_result do
      :ok -> {Logger.info("cmd_result = #{cmd_result}, Version = #{version_str}")}
      _ -> {Logger.info("cmd_result = #{cmd_result}, #{version_str}")}
    end

    {cmd_result, version_str}
  end

  import Bitwise
  def host_receive(buffer_id, bufsize, lock) do
    data_len = bufsize - 3
    icmd_varlen_trans_cmd = @icmd_varlen_trans_id + buffer_id
    lock_bit =
      if lock do
        0x40
      else
        0x00
      end

    data_len_low_byte = data_len &&& 0xff
    data_len_high_byte = ((data_len >>> 8) &&& 0x3f) ||| lock_bit

    Logger.info("bufsize = #{bufsize}, data_len = #{data_len}, icmd_varlen_trans_cmd = #{icmd_varlen_trans_cmd}, data_len_low_byte = #{data_len_low_byte}, data_len_high_byte = #{data_len_high_byte}")

    {:ok, ref} = SPI.open("spidev0.0", mode: 1, speed_hz: 800000)

    {:ok, <<_::1-unit(16), cmd_result::1-unit(8), receive_binary_data::bytes>>}
      = SPI.transfer(ref, <<icmd_varlen_trans_cmd::1-unit(8), data_len_low_byte::1-unit(8), data_len_high_byte::1-unit(8), 0xff::size(data_len)-unit(8)>>)

    SPI.close(ref)

    case cmd_result do
      0 -> {:ok, receive_binary_data}
      _ -> {:error, "Error receive data."}
    end
  end


end
