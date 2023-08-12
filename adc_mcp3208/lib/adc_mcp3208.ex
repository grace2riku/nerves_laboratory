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
  def read_voltage() do
    # 0chの電圧値を取得
    {:ok, ref} = Circuits.SPI.open("spidev0.0")
    {:ok, <<_::size(12), adc_counts::size(12)>>} = Circuits.SPI.transfer(ref, <<0x06, 0x00, 0x00>>)

    voltage = adc_counts / 4095 * 3.3

    # 測定結果を表示
    Logger.info("ADC count: #{adc_counts}, Voltage: #{voltage}")

    Circuits.SPI.close(ref)

    # 結果を返す
    voltage
  end
end
