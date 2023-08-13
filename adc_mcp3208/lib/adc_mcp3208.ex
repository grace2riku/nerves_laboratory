defmodule AdcMcp3208 do
  @moduledoc """
  Documentation for AdcMcp3208.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AdcMcp3208.hello
      :world

  """
  def hello do
    :world
  end

  require Logger
  @start_bit 1
  def read_voltage(channel) do
    # 1 = single_ended, 0 = differential
    single_ended = 1

    # 指定ch(0-7)の電圧値を取得
    {:ok, ref} = Circuits.SPI.open("spidev0.0")
    {:ok, <<_::12, adc_counts::12>>} = Circuits.SPI.transfer(ref, <<0::5, @start_bit::1, single_ended::1, channel::3, 0::6, 0x00>>)

    voltage = adc_counts / 4095 * 3.3

    # 測定結果を表示
    Logger.info("Channel = #{channel}, ADC count = #{adc_counts}, Voltage = #{voltage}")

    Circuits.SPI.close(ref)

    # 電圧値を返す
    voltage
  end
end
